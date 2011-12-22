module namespace control = "http://www.socialito.org/lib/controllers/ui";

(:
 : Twitter Handler proxying module
 :)

import module namespace http="http://www.28msec.com/modules/http";
import module namespace util="http://www.socialito.org/lib/util";

import module namespace view="http://www.socialito.org/lib/views/ui";
import module namespace model="http://www.socialito.org/lib/models/ui";
import module namespace sess="http://www.socialito.org/lib/models/session";
import module namespace twit="http://www.socialito.org/lib/models/twitter";

declare variable $control:WIDGET-ID-PARAM := $view:WIDGET-ID-PARAM;
declare variable $control:WIDGET-STATUS-PARAM := $view:WIDGET-STATUS-PARAM;
declare variable $control:WIDGET-TITLE-PARAM := $view:WIDGET-TITLE-PARAM;
declare variable $control:WIDGET-COLOR-PARAM := $view:WIDGET-COLOR-PARAM;
declare variable $control:WIDGET-PAGE-PARAM := $view:WIDGET-PAGE-PARAM;
declare variable $control:WIDGET-COUNT-PARAM := $view:WIDGET-COUNT-PARAM;
declare variable $control:WIDGET-COLUMN-PARAM := $view:WIDGET-COLUMN-PARAM;
declare variable $control:WIDGET-POSITION-PARAM := $view:WIDGET-POSITION-PARAM;

declare variable $control:HASHTAG-PARAM := $view:HASHTAG-PARAM;
declare variable $control:USER_ID-PARAM := $view:USER_ID-PARAM;
declare variable $control:SCREEN_NAME-PARAM := $view:SCREEN_NAME-PARAM;
declare variable $control:ISAJAX-PARAM := $view:ISAJAX-PARAM;

declare function control:is-initialized (
)
    as xs:boolean
{
    true()
};

declare sequential function control:do-init (
    $err as xs:string?,
    $msg as xs:string?
)
    as empty-sequence()
{
    declare $is-init as xs:boolean :=
        control:is-initialized();
    
    if (exists($msg) or exists($err)) then
        exit returning view:show-home($err, $msg)
    else
        ();
            
    if (not($is-init)) then
        exit returning control:show-home((), ())
    else
        ();
            
    control:do-refresh();
};

declare sequential function control:do-refresh (
)
    as empty-sequence()
{
    ()
};

declare sequential function control:show-home (
    $err as xs:string?,
    $msg as xs:string?
)
{
    declare $twit-is-updated :=
        twit:is-updated();
    declare $twit-has-tweets :=
        twit:has-tweets();
        
    if (not(exists($err)) and not($twit-has-tweets)) then
        view:show-home("Twitter Cache has not yet been initialized. Use Update to retrieve your tweets and friend details from Twitter.", $msg)
    else if (not(exists($err)) and not($twit-is-updated)) then
        view:show-home("Use Update to update your tweets and friend details from Twitter.", $msg)
    else
        view:show-home($err, $msg)
};

declare sequential function control:get-ajax-response (
    $action as xs:string
)
    as item()*
{
    view:get-ajax-response($action)
};

declare sequential function control:get-ajax-response-by-id (
    $id as xs:string
)
    as item()*
{
    view:get-ajax-response-by-id($id)
};

declare sequential function control:update-widget (
    $id as xs:string,
    $status as xs:string?,
    $title as xs:string?,
    $color as xs:string?,
    $page as xs:integer?,
    $count as xs:integer?
)
{
    declare $user := sess:get-session-user();
    
    declare $params := (
        if (exists($page)) then
            <page>{$page}</page>
        else (),
        if (exists($count)) then
            <count>{$count}</count>
        else ()
    );
    
    model:update-widget($user, $id, $status, $title, $color, (), $params);
};

declare sequential function control:move-widget (
    $id as xs:string,
    $column as xs:integer?,
    $position as xs:integer?
)
{
    declare $user := sess:get-session-user();
    
    model:move-widget($user, $id, $column, $position);
};

declare sequential function control:delete-widget (
    $id as xs:string
)
{
    declare $user := sess:get-session-user();
    
    model:delete-widget($user, $id);
};

declare sequential function control:add-user-widget (
    $user-id as xs:string?,
    $screen-name as xs:string?
)
{
    declare $user := sess:get-session-user();
    declare $current-user-id := twit:get-user-id();
    
    declare $friend := 
        if (exists($user-id)) then
            twit:get-cached-user($user, $user-id)
        else
            twit:get-cached-user-by-screen-name($user, $screen-name);
    
    declare $friend-id :=
        $friend/id/string();
        
    declare $widget-id :=
        if (empty($friend-id) or ($friend-id = $current-user-id)) then
            'widget_user'
        else
            concat('widget_user_', $friend-id);
        
    declare $widget-exists := 
        model:widget-exists($user, $widget-id);
        
    declare $title :=
        if ($friend-id = $current-user-id) then
            "My Details"
        else
            concat(util:first-upper($friend/screen_name/string()), "'s Details");

    declare $params :=
        if ($friend-id = $current-user-id) then
            ()
        else if (exists($user-id)) then
            <user-id>{$user-id}</user-id>
        else if (exists($screen-name)) then
            <screen-name>{$screen-name}</screen-name>
        else ();
        
    if (not($widget-exists)) then
        model:add-widget($user, 3, $widget-id, $model:TYPE-USER-DETAILS, $model:STATUS-NORMAL, $title, "", "white", $params)
    else ();
};

declare sequential function control:add-friends-widget (
    $user-id as xs:string?
)
{
    declare $user := sess:get-session-user();
    declare $current-user-id := twit:get-user-id();
    
    declare $user-info := 
        twit:get-cached-user($user, $user-id);
    
    declare $widget-id :=
        if (empty($user-id) or ($user-id = $current-user-id)) then
            'widget_friends'
        else
            concat('widget_friends_', $user-id);
        
    declare $widget-exists := 
        model:widget-exists($user, $widget-id);
        
    declare $title :=
        if (empty($user-id) or ($user-id = $current-user-id)) then
            "My Friends"
        else
            concat(util:first-upper($user-info/screen_name), "'s Friends");

    declare $params := (
        if (empty($user-id) or ($user-id = $current-user-id)) then
            ()
        else
            <user-id>{$user-id}</user-id>,
        <page>1</page>,
        <count>5</count>
    );
    
    if (not($widget-exists)) then
        model:add-widget($user, 2, $widget-id, $model:TYPE-FRIENDS, $model:STATUS-NORMAL, $title, "people", "white", $params)
    else ();
};

declare sequential function control:add-followers-widget (
    $user-id as xs:string?
)
{
    declare $user := sess:get-session-user();
    declare $current-user-id := twit:get-user-id();
    
    declare $user-info := 
        twit:get-cached-user($user, $user-id);
    
    declare $widget-id :=
        if (empty($user-id) or ($user-id = $current-user-id)) then
            'widget_followers'
        else
            concat('widget_followers_', $user-id);
        
    declare $widget-exists := 
        model:widget-exists($user, $widget-id);
        
    declare $title :=
        if (empty($user-id) or ($user-id = $current-user-id)) then
            "My Followers"
        else
            concat(util:first-upper($user-info/screen_name), "'s Followers");

    declare $params := (
        if (empty($user-id) or ($user-id = $current-user-id)) then
            ()
        else
            <user-id>{$user-id}</user-id>,
        <page>1</page>,
        <count>5</count>
    );
    
    if (not($widget-exists)) then
        model:add-widget($user, 2, $widget-id, $model:TYPE-FOLLOWERS, $model:STATUS-NORMAL, $title, "people", "white", $params)
    else ();
};

declare sequential function control:add-hashtag-widget (
    $hashtag as xs:string
)
{
    declare $user := sess:get-session-user();
    
    declare $widget-id :=
        concat('widget_hashtag_', $hashtag);
        
    declare $widget-exists := 
        model:widget-exists($user, $widget-id);
        
    if (not($widget-exists)) then
        model:add-widget($user, 3, $widget-id, $model:TYPE-HASHTAG, $model:STATUS-NORMAL, concat("#", $hashtag, " Tweets"), "", "white", (<hashtag>{$hashtag}</hashtag>,<page>1</page>,<count>5</count>))
    else ();
};

declare sequential function control:add-mentions-widget (
    $user-id as xs:string?
)
{
    declare $user := sess:get-session-user();
    declare $current-user-id := twit:get-user-id();
    
    declare $user-info := 
        twit:get-cached-user($user, $user-id);
    
    declare $widget-id :=
        if (empty($user-id) or ($user-id = $current-user-id)) then
            'widget_mentions'
        else
            concat('widget_mentions_', $user-id);
        
    declare $widget-exists := 
        model:widget-exists($user, $widget-id);
        
    declare $title :=
        if (empty($user-id) or ($user-id = $current-user-id)) then
            "Mentioning Me"
        else
            concat("Mentioning ", util:first-upper($user-info/screen_name));

    declare $params := (
        if (empty($user-id) or ($user-id = $current-user-id)) then
            ()
        else
            <user-id>{$user-id}</user-id>,
        <page>1</page>,
        <count>5</count>
    );
    
    if (not($widget-exists)) then
        model:add-widget($user, 2, $widget-id, $model:TYPE-MENTIONS, $model:STATUS-NORMAL, $title, "", "white", $params)
    else ();
};

declare sequential function control:add-tweets-widget (
    $user-id as xs:string?
)
{
    declare $user := sess:get-session-user();
    declare $current-user-id := twit:get-user-id();
    
    declare $user-info := 
        twit:get-cached-user($user, $user-id);
    
    declare $widget-id :=
        if (empty($user-id) or ($user-id = $current-user-id)) then
            'widget_tweets'
        else
            concat('widget_tweets_', $user-id);
        
    declare $widget-exists := 
        model:widget-exists($user, $widget-id);
        
    declare $title :=
        if (empty($user-id) or ($user-id = $current-user-id)) then
            "My Tweets"
        else
            concat(util:first-upper($user-info/screen_name), "'s Tweets");

    declare $params := (
        if (empty($user-id) or ($user-id = $current-user-id)) then
            <user-id>{$current-user-id}</user-id>
        else
            <user-id>{$user-id}</user-id>,
        <page>1</page>,
        <count>5</count>
    );
    
    if (not($widget-exists)) then
        model:add-widget($user, 2, $widget-id, $model:TYPE-TIMELINE-PUBLIC, $model:STATUS-NORMAL, $title, "", "white", $params)
    else ();
};
