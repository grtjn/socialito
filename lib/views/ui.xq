module namespace view = 'http://www.socialito.org/lib/views/ui';

(:
 : VIEW library
 :
 : Module responsible for rendering all socialito HTML pages
 :)
import module namespace html="http://www.socialito.org/lib/html";
import module namespace util="http://www.socialito.org/lib/util";
import module namespace tapi="http://www.socialito.org/lib/twitter";

import module namespace sess="http://www.socialito.org/lib/models/session";
import module namespace twit="http://www.socialito.org/lib/models/twitter";
import module namespace ui="http://www.socialito.org/lib/models/ui";

declare variable $view:HOME-URI as xs:string := "/";
declare variable $view:UPDATE-URI as xs:string := "/twitter/update";
declare variable $view:LOGOUT-URI as xs:string := "/session/logout";
declare variable $view:SWITCH-URI as xs:string := "/twitter/invalidate";
declare variable $view:CLEAR-URI as xs:string := "/main/clear";
declare variable $view:DISPOSE-URI as xs:string := "/main/dispose";

declare variable $view:UPDATE-WIDGET-URI as xs:string := "/ui/update-widget";
declare variable $view:SHOW-USER-URI as xs:string := "/ui/show-user";
declare variable $view:SHOW-FRIENDS-URI as xs:string := "/ui/show-friends";
declare variable $view:SHOW-FOLLOWERS-URI as xs:string := "/ui/show-followers";
declare variable $view:SHOW-HASHTAG-URI as xs:string := "/ui/show-hashtag";
declare variable $view:SHOW-MENTIONS-URI as xs:string := "/ui/show-mentions";
declare variable $view:SHOW-TWEETS-URI as xs:string := "/ui/show-tweets";

declare variable $view:SEND-TWEET-URI as xs:string := "/twitter/tweet-new";
declare variable $view:FOLLOW-FRIEND-URI as xs:string := "/twitter/follow-friend";
declare variable $view:DROP-FRIEND-URI as xs:string := "/twitter/drop-friend";

declare variable $view:USER_ID-PARAM as xs:string := "user_id";
declare variable $view:SCREEN_NAME-PARAM as xs:string := "screen_name";
declare variable $view:STATUS-PARAM as xs:string := "status";
declare variable $view:ISAJAX-PARAM as xs:string := "isajax";
declare variable $view:SEARCH-PARAM as xs:string := "q";
declare variable $view:ACTION-PARAM as xs:string := "action";
declare variable $view:HASHTAG-PARAM as xs:string := "hashtag";

declare variable $view:WIDGET-ID-PARAM as xs:string := "id";
declare variable $view:WIDGET-STATUS-PARAM as xs:string := "status";
declare variable $view:WIDGET-TITLE-PARAM as xs:string := "title";
declare variable $view:WIDGET-COLOR-PARAM as xs:string := "color";
declare variable $view:WIDGET-PAGE-PARAM as xs:string := "page";
declare variable $view:WIDGET-COUNT-PARAM as xs:string := "count";
declare variable $view:WIDGET-COLUMN-PARAM as xs:string := "column";
declare variable $view:WIDGET-POSITION-PARAM as xs:string := "position";

declare sequential function view:show-home (
    $err as xs:string?,
    $msg as xs:string?
)
    as element(html)
{
    declare $user := sess:get-session-user();
    declare $layout := ui:get-page-layout($user);

    declare $column1 :=
        for $widget in $layout/column[1]/widget
        return
            view:create-widget($user, $widget, false());
    declare $column2 :=
        for $widget in $layout/column[2]/widget
        return
            view:create-widget($user, $widget, false());
    declare $column3 :=
        for $widget in $layout/column[3]/widget
        return
            view:create-widget($user, $widget, false());
    declare $column4 :=
        for $widget in $layout/column[4]/widget
        return
            view:create-widget($user, $widget, false());

    html:format-4-column-page(
        "Home",
        (
                if (exists($err)) then
                    <p class="error">{$err}</p>
                else (),
                if (exists($msg)) then
                    <p class="info">{$msg}</p>
                else ()
        ),
        $column1,
        $column2,
        $column3,
        $column4
    )
};

declare sequential function view:get-ajax-response-by-id (
    $id as xs:string
)
    as item()*
{
    declare $user := sess:get-session-user();
    declare $layout := ui:get-page-layout($user);

    declare $widget := $layout//widget[@id=$id];
    if (exists($widget)) then
         view:create-widget($user, $widget, true())
    else
        ()
};

declare sequential function view:get-ajax-response (
    $action as xs:string
)
    as item()*
{
    declare $user := sess:get-session-user();
    declare $layout := ui:get-page-layout($user);

    (: multiple widgets can be affected by a single action!! :)
    declare $touched-widgets :=
        for $widget in $layout/column/widget
        let $type := $widget/@type
        where (
            ($type eq $ui:TYPE-DIRECT-MESSAGES) and
            ($action = ("dm", "block", "unblock", "follow", "unfollow"))
        ) or (
            ($type eq $ui:TYPE-FIND-PEOPLE) and
            ($action = ())
        ) or (
            ($type eq $ui:TYPE-FOLLOWERS) and
            ($action = ("block", "unblock"))
        ) or (
            ($type eq $ui:TYPE-FRIENDS) and
            ($action = ("unfollow", "follow"))
        ) or (
            ($type eq $ui:TYPE-HASHTAG) and
            ($action = ("dm", "mention"(:, "tweet":)))
        ) or (
            ($type eq $ui:TYPE-MENTIONS) and
            ($action = ("mention", "block", "unblock", "follow", "unfollow"))
        ) or (
            ($type eq $ui:TYPE-RECENT-URLS) and
            ($action = ("dm", "mention"(:, "tweet":)))
        ) or (
            ($type eq $ui:TYPE-TIMELINE-PUBLIC) and
            ($action = ("tweet", "mention", "block", "follow"))
        ) or (
            ($type eq $ui:TYPE-TOP-HASHTAGS) and
            ($action = ("dm", "mention"(:, "tweet":)))
        ) or (
            ($type eq $ui:TYPE-TOP-MENTIONS) and
            ($action = ("dm", "mention"(:, "tweet":)))
        ) or (
            ($type eq $ui:TYPE-TWEET-NEW) and
            ($action = ())
        ) or (
            ($type eq $ui:TYPE-USER-DETAILS) and
            ($action = ("block", "unblock", "follow", "unfollow"))
        )
        return
            $widget;
    
    for $widget in $touched-widgets
    return
        view:create-widget($user, $widget, true())
};

declare sequential function view:create-widget(
    $user as xs:string,
    $config as element(widget),
    $is-ajax as xs:boolean
)
{
    declare $type := $config/@type;
    
    if ($type eq $ui:TYPE-DIRECT-MESSAGES) then
        view:widget-direct-messages($user, $config, $is-ajax)
    else if ($type eq $ui:TYPE-FIND-PEOPLE) then
        view:widget-find-people($user, $config, $is-ajax)
    else if ($type eq $ui:TYPE-FOLLOWERS) then
        view:widget-followers($user, $config, $is-ajax)
    else if ($type eq $ui:TYPE-FRIENDS) then
        view:widget-friends($user, $config, $is-ajax)
    else if ($type eq $ui:TYPE-HASHTAG) then
        view:widget-hashtag($user, $config, $is-ajax)
    else if ($type eq $ui:TYPE-MENTIONS) then
        view:widget-mentions($user, $config, $is-ajax)
    else if ($type eq $ui:TYPE-RECENT-URLS) then
        view:widget-recent-urls($user, $config, $is-ajax)
    else if ($type eq $ui:TYPE-TIMELINE-PUBLIC) then
        view:widget-timeline-public($user, $config, $is-ajax)
    else if ($type eq $ui:TYPE-TOP-HASHTAGS) then
        view:widget-top-hashtags($user, $config, $is-ajax)
    else if ($type eq $ui:TYPE-TOP-MENTIONS) then
        view:widget-top-mentions($user, $config, $is-ajax)
    else if ($type eq $ui:TYPE-TWEET-NEW) then
        view:widget-tweet-new($user, $config, $is-ajax)
    else if ($type eq $ui:TYPE-USER-DETAILS) then
        view:widget-user-details($user, $config, $is-ajax)
    else
        error(xs:QName("UNKNOWN-WIDGET"), concat("Cannot display widget of type ", $config/@type))
};

declare sequential function view:widget-user-details(
    $user as xs:string,
    $config as element(widget),
    $is-ajax as xs:boolean
)
    as item()*
{
    declare $id := ($config/@id, "widget_userdetails")[1];
    declare $title := ($config/@title, "User Details")[1];
    declare $status := ($config/@status, $ui:STATUS-NORMAL)[1];
    declare $color := ($config/@color, "white")[1];
    declare $class := string($config/@class);

    declare $user-details := util:get-request-context()//account;

    declare $user-id-param := ($config/user-id/string(.))[1];
    declare $screen-name-param := ($config/screen-name/string(.))[1];
    
    declare $is-current-user :=
        empty($user-id-param) and empty($screen-name-param);

    declare $has-tweets := twit:has-tweets();

    declare $twitter-user-info :=
        try {
            if (exists($screen-name-param)) then
                twit:get-cached-user-by-screen-name($user, $screen-name-param)
            else (
                twit:get-cached-user($user, $user-id-param)
            )
        } catch * ($code, $msg, $val) {
            ()
        };

    declare $user-id := $twitter-user-info/id/string();
    declare $screen-name := $twitter-user-info/screen_name/string();
    
    declare $following := $twitter-user-info/following/string();
    declare $url_follow_friend := concat($view:FOLLOW-FRIEND-URI, "?", $view:USER_ID-PARAM, "=", $user-id);
    declare $url_drop_friend := concat($view:DROP-FRIEND-URI, "?", $view:USER_ID-PARAM, "=", $user-id);

    declare $image-url :=
        if (exists($twitter-user-info/profile_image_url)) then
            $twitter-user-info/profile_image_url/string()
        else
            "/images/default_twitter.png";
    
    declare $ul-class :=
        if ($is-current-user) then " is-current" else "";
    
    declare $contents := (
        <ul class="tweets userdetails{$ul-class}">
            <li>
                <img class="avatar" alt="{$screen-name}" src="{$image-url}"/>
                { if (string-length($screen-name) > 0) then
                    <h4><a href="http://twitter.com/{$screen-name}" target="_blank">{$screen-name}</a></h4>
                  else ()
                }
                { if (string-length($twitter-user-info/statuses_count) > 0) then
                    <p><a href="{$view:SHOW-TWEETS-URI}?{$view:USER_ID-PARAM}={$user-id-param}">({$twitter-user-info/statuses_count/string()} tweets)</a></p>
                  else ()
                }
                <div class="icons">
                {
                    if ($is-current-user) then (
                        <span>That's me</span>
                    ) else if ($following = 'false') then (
                        <a class="icon follow" href="{$url_follow_friend}" title="Follow"><span>follow</span></a>,
                        <a class="icon unfollow dummy" href="#"><span>...</span></a>,
                        <a class="icon mention" href="#" title="Mention" rel="{$screen-name}"><span>mention</span></a>,
                        <a class="icon dm dummy" href="#"><span>...</span></a>,
                        <a class="icon block" href="#" title="Block"><span>...</span></a>,
                        <a class="icon retweet" href="#" title="Retweet"><span>...</span></a>
                    ) else (
                        <a class="icon follow dummy" href="#" title="Following"><span>following</span></a>,
                        <a class="icon unfollow" href="{$url_drop_friend}" title="Unfollow"><span>unfollow</span></a>,
                        <a class="icon mention" href="#" title="Mention" rel="{$screen-name}"><span>mention</span></a>,
                        <a class="icon dm" href="#" title="Send DM" rel="{$screen-name}"><span>DM</span></a>,
                        <a class="icon block" href="#" title="Block"><span>...</span></a>,
                        <a class="icon retweet" href="#" title="Retweet"><span>...</span></a>
                    )
                }
                </div>
            </li>
            { if (string-length($twitter-user-info/name) > 0) then
            <li>
                <label>Full name: </label>
                <span>{$twitter-user-info/name/string()}</span>
            </li>
                else ()
            }
            { if ($is-current-user) then
                <li>
                    <label>SOCIAL(ito) name: </label>
                    <span>{$user-details/user/string()}</span>
                </li>
              else ()
            }
            { if (string-length($twitter-user-info/location) > 0) then
            <li>
                <label>Location: </label>
                <span>{$twitter-user-info/location/string()}</span>
            </li>
                else ()
            }
            { if (string-length($twitter-user-info/followers_count) > 0) then
            <li>
                <label>Followers: </label>
                <span><a href="{$view:SHOW-FOLLOWERS-URI}?{$view:USER_ID-PARAM}={$user-id-param}">{$twitter-user-info/followers_count/string()}</a></span>
            </li>   
                else ()
            }
            { if (string-length($twitter-user-info/friends_count) > 0) then
            <li>
                <label>Following: </label>
                <span><a href="{$view:SHOW-FRIENDS-URI}?{$view:USER_ID-PARAM}={$user-id-param}">{$twitter-user-info/friends_count/string()}</a></span>
            </li>  
                else ()
            }
            { if (string-length($twitter-user-info/favourites_count) > 0) then
            <li>
                <label>Favourites: </label>
                <span>{$twitter-user-info/favourites_count/string()}</span>
            </li>    
                else ()
            }
            { if (string-length($twitter-user-info/listed_count) > 0) then
            <li>
                <label>Listed: </label>
                <span>{$twitter-user-info/listed_count/string()}</span>
            </li>    
                else ()
            }
        </ul>,
        if ($is-current-user) then
            let $logout-msg :=
                "Your tweets will be preserved for next time, unless you Clear before you logout. You can also Dispose your account once Cleared. Continue?"
            let $clear-msg :=
                "This will flush all tweets, messages and friend details, and also reset the page layout. Continue?"
            let $dispose-msg :=
                "This will delete your account permanently. You will have to recreate your account to continue using this application. OK?"
            return
            <div class="buttons">
                <form action="{$view:UPDATE-URI}" method="POST">
                    <button type="submit">Update</button>
                </form>
                <form action="{$view:LOGOUT-URI}" method="POST">
                    <button type="submit" onclick="return confirm('{$logout-msg}')">Log out</button>
                </form>
                { if ($has-tweets) then
                    <form action="{$view:CLEAR-URI}" onclick="return confirm('{$clear-msg}')" method="POST">
                        <button type="submit">Clear</button>
                    </form>
                  else
                    <form action="{$view:DISPOSE-URI}" onclick="return confirm('{$dispose-msg}')" method="POST">
                        <button type="submit">Dispose</button>
                    </form>
                }
            </div>
        else ()
    );

    if ($is-ajax) then
        $contents
    else
        html:widget($id, $title, $status, $class, $color, $contents);
};

declare sequential function view:widget-find-people (
    $user as xs:string,
    $config as element(widget),
    $is-ajax as xs:boolean
)
    as item()*
{
    declare $id := ($config/@id, "widget_findpeople")[1];
    declare $title := ($config/@title, "Find People")[1];
    declare $status := ($config/@status, $ui:STATUS-NORMAL)[1];
    declare $color := ($config/@color, "white")[1];
    declare $class := string($config/@class);
    
    declare $q := util:get-request-param($view:SEARCH-PARAM);

    declare $search-results := 
        if (exists($q)) then
            twit:get-info($tapi:USER_SEARCH, concat("per_page=5&amp;page=1&amp;q=", $q))
        else ();
    
    declare $contents :=
        <form id="form_findpeople" method="post">       
            <input id="search_text" name="q" value="{$q}"/>
            <div class="buttons">
                <button type="submit">Search</button>
            </div>      
            <ul class="tweets">{view:format-persons($search-results/*)}</ul>  
        </form>;
    
    if ($is-ajax) then
        $contents
    else
        html:widget($id, $title, $status, $class, $color, $contents);
};

declare sequential function view:widget-followers(
    $user as xs:string,
    $config as element(widget),
    $is-ajax as xs:boolean
)
    as item()*
{
    declare $id := ($config/@id, "widget_followers")[1];
    declare $title := ($config/@title, "Followers")[1];
    declare $status := ($config/@status, $ui:STATUS-NORMAL)[1];
    declare $color := ($config/@color, "white")[1];
    declare $class := string($config/@class);

    declare $page := ($config/page/xs:integer(.), 1)[1];
    declare $count := ($config/count/xs:integer(.), 5)[1];

    declare $user-id := ($config/user-id/string(.))[1];
    
    declare $items as element(user)* :=
        if (exists($user-id)) then
            twit:get-followers($user, $user-id, $page, $count)
        else
            twit:get-paged-cached-followers($user, $page, $count);
    declare $total as xs:integer :=
        if (exists($user-id)) then
            twit:get-followers-total($user, $user-id)
        else
            twit:get-cached-followers-total($user);
    
    declare $twitter-user-info :=
        try {
            twit:get-cached-user($user, $user-id)
        } catch * ($code, $msg, $val) {
            ()
        };

    declare $screen-name := $twitter-user-info/screen_name/string();

    declare $contents := (
        if (exists($user-id)) then
            <h3>{util:first-upper($screen-name)}'s {$total} followers</h3>
        else
            <h3>My {$total} followers</h3>,
        <ul class="tweets">{view:format-persons($items)}</ul>,
        view:add-items-nav($id, $page, $count, $total)
    );

    if ($is-ajax) then
        $contents
    else
        html:widget($id, $title, $status, $class, $color, $contents);
};

declare sequential function view:widget-friends(
    $user as xs:string,
    $config as element(widget),
    $is-ajax as xs:boolean
)
    as item()*
{
    declare $id := ($config/@id, "widget_friends")[1];
    declare $title := ($config/@title, "Friends")[1];
    declare $status := ($config/@status, $ui:STATUS-NORMAL)[1];
    declare $color := ($config/@color, "white")[1];
    declare $class := string($config/@class);

    declare $page := ($config/page/xs:integer(.), 1)[1];
    declare $count := ($config/count/xs:integer(.), 5)[1];

    declare $user-id := ($config/user-id/string(.))[1];
    
    declare $items as element(user)* :=
        if (exists($user-id)) then
            twit:get-friends($user, $user-id, $page, $count)
        else
            twit:get-paged-cached-friends($user, $page, $count);
    declare $total as xs:integer :=
        if (exists($user-id)) then
            twit:get-friends-total($user, $user-id)
        else
            twit:get-cached-friends-total($user);
    
    declare $twitter-user-info :=
        try {
            twit:get-cached-user($user, $user-id)
        } catch * ($code, $msg, $val) {
            ()
        };

    declare $screen-name := $twitter-user-info/screen_name/string();

    declare $contents := (
        if (exists($user-id)) then
            <h3>{util:first-upper($screen-name)} follows {$total} people</h3>
        else
            <h3>I follow {$total} people</h3>,
        <ul class="tweets">{view:format-persons($items)}</ul>,
        view:add-items-nav($id, $page, $count, $total)
    );
    
        
    if ($is-ajax) then
        $contents
    else
        html:widget($id, $title, $status, $class, $color, $contents);
};

declare sequential function view:widget-hashtag (
    $user as xs:string,
    $config as element(widget),
    $is-ajax as xs:boolean
)
    as item()*
{
    declare $id := ($config/@id, "widget_findpeople")[1];
    declare $title := ($config/@title, "Find People")[1];
    declare $status := ($config/@status, $ui:STATUS-NORMAL)[1];
    declare $color := ($config/@color, "white")[1];
    declare $class := string($config/@class);
    
    declare $hashtag := ($config/hashtag/xs:string(.), "#socialito_2010")[1];
    declare $page := ($config/page/xs:integer(.), 1)[1];
    declare $count := ($config/count/xs:integer(.), 5)[1];

    declare $items as element(status)* := twit:get-paged-cached-hashtag-tweets($user, $hashtag, $page, $count);
    declare $total as xs:integer := twit:get-cached-hashtag-tweets-total($user, $hashtag);
        
    declare $contents := (
        <h3>{$total} cached #{$hashtag} tweets</h3>,
        view:format-tweets($user, $items),
        view:add-items-nav($id, $page, $count, $total)
    );

    if ($is-ajax) then
        $contents
    else
        html:widget($id, $title, $status, $class, $color, $contents);
};

declare sequential function view:widget-mentions (
    $user as xs:string,
    $config as element(widget),
    $is-ajax as xs:boolean
)
    as item()*
{
    declare $id := ($config/@id, "widget_mentions")[1];
    declare $title := ($config/@title, "Mentions")[1];
    declare $status := ($config/@status, $ui:STATUS-NORMAL)[1];
    declare $color := ($config/@color, "white")[1];
    declare $class := string($config/@class);

    declare $page := ($config/page/xs:integer(.), 1)[1];
    declare $count := ($config/count/xs:integer(.), 5)[1];
    
    declare $user-id := 
        if (exists($config/user-id)) then
            ($config/user-id/string(.))[1]
        else
            twit:get-user-id();
    
    declare $items as element(status)* := twit:get-paged-cached-mention-tweets($user, $user-id, $page, $count);
    declare $total as xs:integer := twit:get-cached-mention-tweets-total($user, $user-id);

    declare $contents := (
        <h3>{$total} cached mentions</h3>,
        view:format-tweets($user, $items),
        view:add-items-nav($id, $page, $count, $total)
    );
    
    if ($is-ajax) then
        $contents
    else
        html:widget($id, $title, $status, $class, $color, $contents);
};

declare sequential function view:widget-direct-messages (
    $user as xs:string,
    $config as element(widget),
    $is-ajax as xs:boolean
)
    as item()*
{
    declare $id := ($config/@id, "widget_messages")[1];
    declare $title := ($config/@title, "Direct Messages")[1];
    declare $status := ($config/@status, $ui:STATUS-NORMAL)[1];
    declare $color := ($config/@color, "white")[1];
    declare $class := string($config/@class);

    declare $page := ($config/page/xs:integer(.), 1)[1];
    declare $count := ($config/count/xs:integer(.), 5)[1];

    declare $items as element(direct_message)* := twit:get-paged-cached-messages($user, $page, $count);
    declare $total as xs:integer := twit:get-cached-messages-total($user);
    
    declare $contents := (
        <h3>{$total} cached messages</h3>,
        view:format-tweets($user, $items),
        view:add-items-nav($id, $page, $count, $total)
    );
    
    if ($is-ajax) then
        $contents
    else
        html:widget($id, $title, $status, $class, $color, $contents);
};

declare sequential function view:widget-recent-urls (
    $user as xs:string,
    $config as element(widget),
    $is-ajax as xs:boolean
)
    as item()*
{
    declare $id := ($config/@id, "widget_recent_urls")[1];
    declare $title := ($config/@title, "Recent Urls")[1];
    declare $status := ($config/@status, $ui:STATUS-NORMAL)[1];
    declare $color := ($config/@color, "white")[1];
    declare $class := string($config/@class);

    declare $count := ($config/count/xs:integer(.), 5)[1];

    declare $items as element(data)* := twit:get-recent-urls($user, $count);
    declare $tweets :=
        for $i in $items
        return block {
            declare $url := $i/@key/string();
            declare $date := util:format-date($i/@sortdate/string());
            
            <li>
                <div>
                    <a class="url" href="{$url}" target="_blank">{$url}</a> ({$date})
                </div>
            </li>;
        };

    declare $contents := (
        <ol class="tweets">{
            $tweets
        }</ol>
    );
    
    if ($is-ajax) then
        $contents
    else
        html:widget($id, $title, $status, $class, $color, $contents);
};

declare sequential function view:widget-timeline-public (
    $user as xs:string,
    $config as element(widget),
    $is-ajax as xs:boolean
)
    as item()*
{
    declare $id := ($config/@id, "widget_timeline_public")[1];
    declare $title := ($config/@title, "Current Timeline")[1];
    declare $status := ($config/@status, $ui:STATUS-NORMAL)[1];
    declare $color := ($config/@color, "white")[1];
    declare $class := string($config/@class);

    declare $page := ($config/page/xs:integer(.), 1)[1];
    declare $count := ($config/count/xs:integer(.), 5)[1];
    declare $user-id-param := ($config/user-id/string(.))[1];

    declare $items as element(status)* := twit:get-paged-cached-tweets($user, $user-id-param, $page, $count);
    declare $total as xs:integer := twit:get-cached-tweets-total($user, $user-id-param);
    
    declare $contents := (
        <h3>{$total} cached tweets</h3>,
        view:format-tweets($user, $items),
        view:add-items-nav($id, $page, $count, $total)
    );
    
    if ($is-ajax) then
        $contents
    else
        html:widget($id, $title, $status, $class, $color, $contents);
};

declare sequential function view:widget-top-hashtags (
    $user as xs:string,
    $config as element(widget),
    $is-ajax as xs:boolean
)
    as item()*
{
    declare $id := ($config/@id, "widget_top_hashtags")[1];
    declare $title := ($config/@title, "Top Hashtags")[1];
    declare $status := ($config/@status, $ui:STATUS-NORMAL)[1];
    declare $color := ($config/@color, "white")[1];
    declare $class := string($config/@class);

    declare $count := ($config/count/xs:integer(.), 5)[1];

    declare $items as element(facet)* := twit:get-top-hashtags($user, $count);
    
    declare $contents := (
        view:format-hashtags($user, $items)
    );
    
    if ($is-ajax) then
        $contents
    else
        html:widget($id, $title, $status, $class, $color, $contents);
};

declare sequential function view:widget-top-mentions (
    $user as xs:string,
    $config as element(widget),
    $is-ajax as xs:boolean
)
    as item()*
{
    declare $id := ($config/@id, "widget_top_mentions")[1];
    declare $title := ($config/@title, "Top Mentions")[1];
    declare $status := ($config/@status, $ui:STATUS-NORMAL)[1];
    declare $color := ($config/@color, "white")[1];
    declare $class := string($config/@class);

    declare $count := ($config/count/xs:integer(.), 5)[1];

    declare $items as element(facet)* := twit:get-top-mentions($user, $count);
    
    declare $contents := (
        <ol class="tweets" id="top_mentions_tweets">{
            (: url_show_hashtag klopt nog niet!! :)
            let $url_show_mentions := concat($view:SHOW-MENTIONS-URI, "?", $view:USER_ID-PARAM, "=")
            
            for $i in $items
            let $id := $i/@key/string()
            let $name := $i/@sortkey/string()
            let $score := $i/@score/string()
            return
            <li>
                <div>
                    <a class="mention" href="{$url_show_mentions}{$id}" rel="{$score}">@{$name}</a> <span class="score">({$score})</span>
                </div>
            </li>
        }</ol>
    );
    
    if ($is-ajax) then
        $contents
    else
        html:widget($id, $title, $status, $class, $color, $contents);
};

declare sequential function view:widget-tweet-new (
    $user as xs:string,
    $config as element(widget),
    $is-ajax as xs:boolean
)
    as item()*
{
    declare $id := ($config/@id, "widget_tweet_new")[1];
    declare $title := ($config/@title, "Quick Tweet")[1];
    declare $status := ($config/@status, $ui:STATUS-NORMAL)[1];
    declare $color := ($config/@color, "white")[1];
    declare $class := string($config/@class);

    declare $contents :=
        <form id="form_tweet_new" method="post" action="{$view:SEND-TWEET-URI}">
            <input type="hidden" id="tweet_action" name="action" value="tweet" />
            <textarea cols="10" rows="5" id="tweet_text" name="status"></textarea>
            <div class="buttons">
                <button type="submit" id="submit_tweet_new">Send</button>
                <img src="/images/spinner.gif" id="tweet_spinner" alt="Working..." />
            </div>
        </form>;

    if ($is-ajax) then
        $contents
    else
        html:widget($id, $title, $status, $class, $color, $contents);
};

declare function view:add-items-nav (
    $id as xs:string,
    $page as xs:integer,
    $count as xs:integer,
    $total as xs:integer
)
    as item()*
{
    <ul class="tweets-nav">
        { if ($page gt 1) then
            <li class="prev"><a href="{$view:UPDATE-WIDGET-URI}?{$view:WIDGET-ID-PARAM}={$id}&amp;{$view:WIDGET-PAGE-PARAM}={$page - 1}&amp;{$view:WIDGET-COUNT-PARAM}={$count}" title="Previous page"><span>Prev</span></a></li>
          else ()
        }
        { if (($page * $count + 1) le $total) then
            <li class="next"><a href="{$view:UPDATE-WIDGET-URI}?{$view:WIDGET-ID-PARAM}={$id}&amp;{$view:WIDGET-PAGE-PARAM}={$page + 1}&amp;{$view:WIDGET-COUNT-PARAM}={$count}" title="Next page"><span>Next</span></a></li>
          else ()
        }
    </ul>
};

declare sequential function view:format-hashtags (
    $user as xs:string,
    $hashtags as element()*
)
    as item()*
{
        <ol class="tweets" id="top_mentions_hashtags">{
            (: url_show_hashtag klopt nog niet!! :)
            let $url_show_hashtag := concat($view:SHOW-HASHTAG-URI, "?", $view:HASHTAG-PARAM, "=")
            
            for $i in $hashtags
            let $name := $i/@key/string()
            let $score := $i/@score/string()
            return
            <li>
                <div>
                    <a class="hashtag" href="{$url_show_hashtag}{$name}" rel="{$score}">#{$name}</a> <span class="score">({$score})</span>
                </div>
            </li>
        }</ol>
};

declare sequential function view:format-tweets (
    $user as xs:string,
    $tweets as element()*
)
    as item()*
{
    declare $current-user-id := twit:get-user-id();
	
    declare $tweets :=
        for $tweet in $tweets
        return view:format-tweet($user, $current-user-id, $tweet);
    
    <ul class="tweets">
        {
            $tweets
        }
    </ul>;
};

declare sequential function view:format-tweet (
    $user as xs:string,
    $current-user-id as xs:string,
    $tweet as element()
)
{
    declare $tweet-sender-details := 
            ($tweet/(sender | user))[1];
    declare $user-id := $tweet-sender-details/id;
    declare $sender :=
        if (exists($tweet-sender-details/screen_name)) then
            $tweet-sender-details
        else
            twit:get-cached-user($user, $user-id);

    declare $tweet-id := $tweet/id;
    declare $screenname := string($sender/screen_name);
    declare $avatar := string($sender/profile_image_url);
    declare $timestamp := util:format-date($tweet/created_at);
    declare $msg := $tweet/text/node();
    declare $following := $sender/following;
    declare $friendcnt := $sender/friends_count;
    declare $followcnt := $sender/followers_count;
    declare $url_follow_friend := concat($view:FOLLOW-FRIEND-URI, "?", $view:USER_ID-PARAM, "=", $user-id);
    declare $url_drop_friend := concat($view:DROP-FRIEND-URI, "?", $view:USER_ID-PARAM, "=", $user-id);
    declare $url_show_user_by_screenname := concat($view:SHOW-USER-URI, "?", $view:SCREEN_NAME-PARAM, "=");
    declare $url_show_hashtag := concat($view:SHOW-HASHTAG-URI, "?", $view:HASHTAG-PARAM, "=");
	
	view:tweet($current-user-id, $user-id, $screenname, $avatar, $timestamp, $msg, $following, $friendcnt, $followcnt, $url_follow_friend, $url_drop_friend, $url_show_user_by_screenname, $url_show_hashtag);
};

declare function view:tweet (
    $current-user-id as xs:string,
    $sender-user-id as xs:integer,
    $screenname as xs:string,
    $avatar as xs:string,
    $timestamp as xs:string,
    $msg as item()*,
    $following as xs:string,
    $friendcnt as xs:integer,
    $followcnt as xs:integer,
    $url_follow_friend as xs:string,
    $url_drop_friend as xs:string,
    $url_show_user_by_screenname as xs:string,
    $url_show_hashtag as xs:string
)
    as element()
{
    let $is-current-user as xs:boolean := string($current-user-id) eq string($sender-user-id)
    let $class := if ($is-current-user) then "is-current" else ""
    return
        <li>
			<div class="{$class}">
                <img src="{$avatar}" alt="{$screenname}" class="avatar" />
                <a class="person" href="{$url_show_user_by_screenname}{$screenname}">{$screenname} ({string($friendcnt)}/{string($followcnt)})</a>
                <span class="timestamp">{$timestamp}</span>
                <p class="says">{view:process-text($msg, $url_show_user_by_screenname, $url_show_hashtag)}</p>
                <div class="icons">
                {
					if ($is-current-user) then (
						<span>That's me</span>
					) else if ($following = 'false') then (
						<a class="icon follow" href="{$url_follow_friend}" title="Follow"><span>follow</span></a>,
						<a class="icon unfollow dummy" href="#"><span>...</span></a>,
						<a class="icon mention" href="#" title="Mention" rel="{$screenname}"><span>mention</span></a>,
						<a class="icon dm dummy" href="#"><span>...</span></a>,
						<a class="icon block" href="#" title="Block"><span>...</span></a>,
						<a class="icon retweet" href="#" title="Retweet" rel="{$msg}"><span>...</span></a>
					) else (
						<a class="icon follow dummy" href="#" title="Following"><span>following</span></a>,
						<a class="icon unfollow" href="{$url_drop_friend}" title="Unfollow"><span>unfollow</span></a>,
						<a class="icon mention" href="#" title="Mention" rel="{$screenname}"><span>mention</span></a>,
						<a class="icon dm" href="#" title="Send DM" rel="{$screenname}"><span>DM</span></a>,
						<a class="icon block" href="#" title="Block"><span>...</span></a>,
						<a class="icon retweet" href="#" title="Retweet" rel="{$msg}"><span>...</span></a>
					)
                }
                </div>
            </div>
        </li>
};

declare function view:format-persons ( $persons as element(user)* )
{
    for $user in $persons
    let $id := $user/id
    let $screenname := string($user/screen_name)
    let $avatar := string($user/profile_image_url)
    let $following := ""
    let $friendcnt := $user/friends_count
    let $followcnt := $user/followers_count
    let $url_show_friend := concat($view:SHOW-USER-URI, "?", $view:USER_ID-PARAM, "=", $id)
    let $url_drop_friend := concat($view:DROP-FRIEND-URI, "?", $view:USER_ID-PARAM, "=", $id)
    return
        view:person($id, $screenname, $avatar, $following, $friendcnt, $followcnt, $url_show_friend, $url_drop_friend);
};

declare function view:person (
    $id as xs:integer,
    $screenname as xs:string,
    $avatar as xs:string,
    $following as xs:string,
    $friendcnt as xs:integer,
    $followcnt as xs:integer,
    $url_show_friend as xs:string,
    $url_drop_friend as xs:string
)
    as element()
{
    <li>
        <div>
            <img src="{$avatar}" alt="{$screenname}" class="avatar" />
            <a class="person" href="{$url_show_friend}">{$screenname} ({string($friendcnt)}/{string($followcnt)})</a>
            <a href="{$url_drop_friend}">drop</a>
        </div>
    </li>   
};

declare function view:process-text($msg as item()*, $url_show_user_by_screenname, $url_show_hashtag) {
    for $item in $msg
    let $text := string($item)
    return
        typeswitch ($item)
        case element(mention)
            return
                <a href="{concat($url_show_user_by_screenname,substring-after($text,'@'))}">{$text}</a>
        case element(url)
            return
                <a href="{$text}" target="_blank">{$text}</a>
        case element(hashtag)
            return
                <a href="{concat($url_show_hashtag,substring-after($text,'#'))}">{$text}</a>
        case element()
            return
                element {node-name($item)} {
                    $item/@*,
                    view:process-text($item/node(), $url_show_user_by_screenname, $url_show_hashtag)
                }
        default
            return
                $item
};
