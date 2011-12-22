module namespace twit = 'http://www.socialito.org/lib/models/twitter';

declare ordering ordered;

import module namespace data="http://www.socialito.org/lib/data";
import module namespace tapi="http://www.socialito.org/lib/twitter";
import module namespace mesg="http://www.socialito.org/lib/messages";

import module namespace msg="http://www.socialito.org/lib/models/message";
import module namespace sess="http://www.socialito.org/lib/models/session";
import module namespace tweet="http://www.socialito.org/lib/models/tweet";
import module namespace user="http://www.socialito.org/lib/models/user";

declare variable $twit:cache-max := 200;

declare sequential function twit:get-user-id (
)
    as xs:string?
{
    (sess:get-session-data()//twitter-user-id/string(.)[string-length(.) > 0])[1]
};

declare sequential function twit:is-authorized (
)
    as xs:boolean
{
    declare $user-id :=
        twit:get-user-id();
    declare $is-authorized :=
        tapi:is-authorized();
    
    exists($user-id) and $is-authorized;
};

declare sequential function twit:is-updated (
)
    as xs:boolean
{
    exists((sess:get-session-data()//twitter-is-updated[. eq 'true'])[1])
};

declare sequential function twit:has-tweets (
)
    as xs:boolean
{
    declare $user :=
        sess:get-session-user();
        
    twit:get-cached-tweets-total($user, ()) > 0
};

declare sequential function twit:is-never-updated (
)
    as xs:boolean
{
    declare $is-updated :=
        twit:is-updated();
    declare $has-tweets :=
        twit:has-tweets();

    not($has-tweets or $is-updated);
};

(:
  OAuth procedure starts here
:)
declare sequential function twit:authorize (
)
{
    (: performs a redirect to twitter!! :)
    tapi:init()
};

(:
  After a successful authentication, the service provider redirects back to this url
:)
declare sequential function twit:callback (
)
    as empty-sequence()
{
    tapi:callback();
};

declare sequential function twit:prepare (
)
    as empty-sequence()
{
    declare $user :=
        tapi:get-current-user();

    sess:add-session-data("twitter-user-id", string($user/id));
};

declare sequential function twit:invalidate (
)
    as empty-sequence()
{
    tapi:invalidate();

    sess:delete-session-data("twitter-user-id", ());
};

declare sequential function twit:update (
)
    as empty-sequence()
{
    declare $user :=
        sess:get-session-user();
    declare $user-id :=
        twit:get-user-id();
    
    sess:delete-session-data("twitter-is-updated", ());

    twit:update-user-cache($user, $user-id);
    twit:update-tweet-cache($user, $user-id);
    twit:update-message-cache($user, $user-id);
    
    sess:add-session-data("twitter-is-updated", "true");
};

declare sequential function twit:clear (
)
    as empty-sequence()
{
    declare $user :=
        sess:get-session-user();
    
    msg:delete-all($user);
    tweet:delete-all($user);
    user:delete-all($user);
    
    sess:delete-session-data("twitter-is-updated", ());
};

declare sequential function twit:update-user-cache (
    $user as xs:string,
    $user-id as xs:string
)
{
    declare $current-user :=
        try {
            (: Get current user :)
            tapi:get-resource($tapi:ACC_VERIFY, 1, ("include_entities=true"))
        } catch tapi:UNAUTHORIZED {
            error(xs:QName("user:TWITTER-UNAUTHORIZED"), "AUTH_TWITTER")
        };

    declare $friends :=
        try {
            (: Get all friends :)
            tapi:get-resource($tapi:STAT_FRIENDS, 1, (concat("user_id=", $user-id), "include_entities=true"))/*
        } catch tapi:UNAUTHORIZED {
            error(xs:QName("user:TWITTER-UNAUTHORIZED"), "AUTH_TWITTER")
        };
 
    declare $followers :=
        try {
            (: Get all followers :)
            tapi:get-resource($tapi:STAT_FOLLOWERS, 1, (concat("user_id=", $user-id), "include_entities=true"))/*
        } catch tapi:UNAUTHORIZED {
            error(xs:QName("user:TWITTER-UNAUTHORIZED"), "AUTH_TWITTER")
        };
        
    user:delete-all($user);

    user:add($user, $current-user);
    user:add($user, $friends);
    user:add-followers($user, $followers);
};

declare sequential function twit:update-tweet-cache (
    $user as xs:string,
    $user-id as xs:string
)
{
    declare $last-id as xs:string? := (tweet:get-last($user)/*/id/string())[1];
    declare $since as xs:string? :=
        if (exists($last-id)) then
            concat("since_id=", $last-id)
        else
            ();

    declare $tweets :=
        try {
            (: Get all tweets :)
            tapi:get-resource($tapi:STAT_FRIENDS_TL, 1, ($since, "page=1", concat("count=", $twit:cache-max), "trim_user=true", "include_rts=true", "include_entities=true"))
        } catch tapi:UNAUTHORIZED {
            error(xs:QName("tweet:TWITTER-UNAUTHORIZED"), "AUTH_TWITTER")
        };
 
    tweet:add($user, $user-id, $tweets/*);
};

declare sequential function twit:update-message-cache (
    $user as xs:string,
    $user-id as xs:string
)
{
    declare $last-id as xs:string? := (msg:get-last($user)/*/id/string())[1];
    declare $since as xs:string? :=
        if (exists($last-id)) then
            concat("since_id=", $last-id)
        else
            ();

    declare $params :=
        ($since, "page=1", concat("count=", $twit:cache-max div 2), "trim_user=true", "include_rts=true", "include_entities=true");
        
    declare $items :=
        try {
            (: Get all tweets :)
            tapi:get-resource($tapi:DM_RECV, 1, $params)/*,
            tapi:get-resource($tapi:DM_SENT, 1, $params)/*
        } catch tapi:UNAUTHORIZED {
            error(xs:QName("msg:TWITTER-UNAUTHORIZED"), "AUTH_TWITTER")
        };
 
    msg:add($user, $items);
};

declare sequential function twit:get-paged-cached-tweets (
    $user as xs:string,
    $user-id as xs:string?,
    $page as xs:integer,
    $count as xs:integer
)
    as element(status)*
{
    declare $start :=
        ($page - 1) * $count + 1;
    declare $end :=
        $page * $count;
    declare $tweets :=
        tweet:get-paged($user, $user-id, $start, $end);
    
    for $t in $tweets
    return
        $t/*;
};

declare function twit:get-cached-tweets-total (
    $user as xs:string,
    $user-id as xs:string?
)
    as xs:integer
{
    tweet:get-total($user, $user-id)
};

declare sequential function twit:get-paged-cached-messages (
    $user as xs:string,
    $page as xs:integer,
    $count as xs:integer
)
    as element(direct_message)*
{
    declare $start :=
        ($page - 1) * $count + 1;
    declare $end :=
        $page * $count;
    declare $items :=
        msg:get-paged($user, $start, $end);
    
    for $i in $items
    return
        $i/*;
};

declare function twit:get-cached-messages-total (
    $user as xs:string
)
    as xs:integer
{
    msg:get-total($user)
};

declare sequential function twit:get-paged-cached-mention-tweets (
    $user as xs:string,
    $user-id as xs:string?,
    $page as xs:integer,
    $count as xs:integer
)
    as element(status)*
{
    declare $user-id_ :=
        if (empty($user-id)) then
            twit:get-user-id()
        else $user-id;
 
    declare $start :=
        ($page - 1) * $count + 1;
    declare $end :=
        $page * $count;
    declare $tweets :=
        tweet:get-paged-mention-tweets($user, $user-id_, $start, $end);
    
    for $t in $tweets
    return
        $t/*;
};

declare sequential function twit:get-cached-mention-tweets-total (
    $user as xs:string,
    $user-id as xs:string?
)
    as xs:integer
{
    declare $user-id_ :=
        if (empty($user-id)) then
            twit:get-user-id()
        else $user-id;
 
    tweet:get-total-mention-tweets($user, $user-id_)
};

declare sequential function twit:get-paged-cached-hashtag-tweets (
    $user as xs:string,
    $hashtag as xs:string,
    $page as xs:integer,
    $count as xs:integer
)
    as element(status)*
{
    declare $user-id :=
        twit:get-user-id();
 
    declare $start :=
        ($page - 1) * $count + 1;
    declare $end :=
        $page * $count;
    declare $tweets :=
        tweet:get-paged-hashtag-tweets($user, $hashtag, $start, $end);
    
    for $t in $tweets
    return
        $t/*;
};

declare function twit:get-cached-hashtag-tweets-total (
    $user as xs:string,
    $hashtag as xs:string
)
    as xs:integer
{
    tweet:get-total-hashtag-tweets($user, $hashtag)
};

declare sequential function twit:get-cached-user (
    $user as xs:string,
    $user-id as xs:string?
)
    as element(user)?
{
    declare $user-id_ :=
        if (exists($user-id)) then
            $user-id
        else
            twit:get-user-id();
    declare $user-info :=
        user:get($user, $user-id_)/*;

    if (exists($user-info)) then
        $user-info
    else
        (:
        error(xs:QName("twit:UNKNOWN-USER"), concat("User ", $user-id_, " not in cache"))
        :)
        block {
            declare $user-info := twit:get-info($tapi:USER_SHOW, concat("user_id=", $user-id));
            
            user:add($user, $user-info);
            
            $user-info;
        };
};

declare sequential function twit:get-cached-user-by-screen-name (
    $user as xs:string,
    $screen-name as xs:string
)
    as element(user)?
{
    declare $user-info :=
        if (exists($screen-name)) then
            user:get-all($user)/*[screen_name eq $screen-name]
        else
            ();
        
    if (exists($user-info)) then
        $user-info[1]
    else
        (:
        error(xs:QName("twit:UNKNOWN-USER"), concat("User ", $screen-name, " not in cache"))
        :)
        block {
            declare $twit-user-info := twit:get-info($tapi:USER_SHOW, concat("screen_name=", $screen-name));
            
            user:add($user, $twit-user-info);
            
            $twit-user-info;
        };
};

declare sequential function twit:get-paged-cached-friends (
    $user as xs:string,
    $page as xs:integer,
    $count as xs:integer
)
    as element(user)*
{
    declare $user-id :=
        twit:get-user-id();
 
    declare $start :=
        ($page - 1) * $count + 1;
    declare $end :=
        $page * $count;
    declare $friends :=
        user:get-paged-friends($user, $start, $end);
    
    for $i in $friends
    return
        $i/*;
};

declare function twit:get-cached-friends-total (
    $user as xs:string
)
    as xs:integer
{
    user:get-total-friends($user)
};

declare sequential function twit:get-paged-cached-followers (
    $user as xs:string,
    $page as xs:integer,
    $count as xs:integer
)
    as element(user)*
{
    declare $user-id :=
        twit:get-user-id();
 
    declare $start :=
        ($page - 1) * $count + 1;
    declare $end :=
        $page * $count;
    declare $friends :=
        user:get-paged-followers($user, $start, $end);
    
    for $i in $friends
    return
        $i/*;
};

declare function twit:get-cached-followers-total (
    $user as xs:string
)
    as xs:integer
{
    user:get-total-followers($user)
};

declare sequential function twit:get-friends(
    $user as xs:string,
    $user-id as xs:string,
    $page as xs:integer,
    $count as xs:integer
)
{
    declare $start :=
        ($page - 1) * $count + 1;
    declare $end :=
        $page * $count;

    twit:get-info($tapi:STAT_FRIENDS, (concat("user_id=", $user-id), "include_entities=true"))
        /*[position() = ($start to $end)]
};

declare sequential function twit:get-friends-total(
    $user as xs:string,
    $user-id as xs:string
)
{
    count(
        twit:get-info($tapi:STAT_FRIENDS, (concat("user_id=", $user-id), "include_entities=true"))
            /*
    )
};

declare sequential function twit:get-followers(
    $user as xs:string,
    $user-id as xs:string,
    $page as xs:integer,
    $count as xs:integer
)
{
    declare $start :=
        ($page - 1) * $count + 1;
    declare $end :=
        $page * $count;

    twit:get-info($tapi:STAT_FOLLOWERS, (concat("user_id=", $user-id), "include_entities=true"))
        /*[position() = ($start to $end)]
};

declare sequential function twit:get-followers-total(
    $user as xs:string,
    $user-id as xs:string
)
{
    count(
        twit:get-info($tapi:STAT_FOLLOWERS, (concat("user_id=", $user-id), "include_entities=true"))
            /*
    )
};

declare function twit:get-recent-urls (
    $user as xs:string,
    $count as xs:integer
)
    as element(data)*
{
    tweet:get-recent-urls($user, $count)
};

declare function twit:get-top-hashtags (
    $user as xs:string,
    $count as xs:integer
)
    as element(facet)*
{
    tweet:get-top-hashtags($user, $count)
};

declare function twit:get-top-mentions (
    $user as xs:string,
    $count as xs:integer
)
    as element(facet)*
{
    tweet:get-top-mentions($user, $count)
};

declare sequential function twit:get-info (
    $resource as xs:string,
    $params as xs:string*
)
    as element()*
{
    declare $info :=
        try {
            (: Get twitter info :)
            tapi:get-resource($resource, 1, $params)
        } catch tapi:UNAUTHORIZED {
            error(xs:QName("twit:TWITTER-UNAUTHORIZED"), $mesg:AUTH_TWITTER)
        };
 
    $info;
};

declare sequential function twit:get-info (
    $resource as xs:string
)
    as element()*
{
    twit:get-info($resource, ())
};

declare sequential function twit:follow-friend (
    $user as xs:string?,
    $user_id as xs:string?
)
    as element()*
{
    if (not(exists($user) and exists($user_id))) then

        error(xs:QName("MISSING-PARAMS"), $mesg:MISS_PARAMS)

    else block {
    
        declare $params :=
            concat("user_id=", $user_id);
        declare $friend :=
            try {
                (: Get all public timeline tweets :)
                tapi:post-update($tapi:FRIEND_CREATE, 1, $params)
            } catch tapi:UNAUTHORIZED ($code, $msg, $val) {
                error(xs:QName("TWITTER-UNAUTHORIZED"), $mesg:AUTH_TWITTER)
            } catch * ($code, $msg, $val) {
                error(xs:QName("UPDATE-FAILED"), concat("Update failed: ", $msg))
            };
     
        user:add($user, $friend);
        
        $friend;
    }
};

declare sequential function twit:drop-friend (
    $user as xs:string?,
    $user_id as xs:string?
)
    as element()*
{
    if (not(exists($user) and exists($user_id))) then

        error(xs:QName("MISSING-PARAMS"), $mesg:MISS_PARAMS)

    else block {
    
        declare $params :=
            concat("user_id=", $user_id);
        declare $friend :=
            try {
                tapi:post-update($tapi:FRIEND_DESTROY, 1, $params)
            } catch tapi:UNAUTHORIZED ($code, $msg, $val) {
                error(xs:QName("TWITTER-UNAUTHORIZED"), $mesg:AUTH_TWITTER)
            } catch * ($code, $msg, $val) {
                error(xs:QName("UPDATE-FAILED"), concat("Update failed: ", $msg))
            };
     
        user:delete-friends($user, $friend);
    
        $friend;
    }
};

declare sequential function twit:block-person (
    $user as xs:string?,
    $user_id as xs:string?
)
    as element()*
{
    if (not(exists($user) and exists($user_id))) then

        error(xs:QName("MISSING-PARAMS"), $mesg:MISS_PARAMS)

    else block {
    
        declare $params := concat("user_id=", $user_id);
        declare $block :=
            try {
                tapi:post-update($tapi:BLOCK_CREATE, 1, $params)
            } catch tapi:UNAUTHORIZED ($code, $msg, $val) {
                error(xs:QName("TWITTER-UNAUTHORIZED"), $mesg:AUTH_TWITTER)
            } catch * ($code, $msg, $val) {
                error(xs:QName("UPDATE-FAILED"), concat("Update failed: ", $msg))
            };
     
        user:delete-followers($user, $block);
    
        $block;
    }
};

declare sequential function twit:unblock-person (
    $user as xs:string?,
    $user_id as xs:string?
)
    as element()*
{
    if (not(exists($user) and exists($user_id))) then

        error(xs:QName("MISSING-PARAMS"), $mesg:MISS_PARAMS)

    else block {
    
        declare $params := concat("user_id=", $user_id);
        declare $unblock :=
            try {
                tapi:post-update($tapi:BLOCK_DESTROY, 1, $params)
            } catch tapi:UNAUTHORIZED ($code, $msg, $val) {
                error(xs:QName("TWITTER-UNAUTHORIZED"), $mesg:AUTH_TWITTER)
            } catch * ($code, $msg, $val) {
                error(xs:QName("UPDATE-FAILED"), concat("Update failed: ", $msg))
            };

        (: ?
        user:add-followers($user, $unblock);
        :)
    
        $unblock;
    }
};

declare sequential function twit:tweet-new (
    $user as xs:string?,
    $status as xs:string?
)
    as element()*
{
    if (not(exists($user) and exists($status))) then

        error(xs:QName("MISSING-PARAMS"), $mesg:MISS_PARAMS)

    else block {
    
        declare $user-id := twit:get-user-id();
        declare $params := concat("status=", $status);
        
        try {
            tapi:post-update($tapi:STAT_UPDATE, 1, $params)
        } catch tapi:UNAUTHORIZED ($code, $msg, $val) {
            error(xs:QName("TWITTER-UNAUTHORIZED"), $mesg:AUTH_TWITTER)
        } catch * ($code, $msg, $val) {
            error(xs:QName("UPDATE-FAILED"), concat("Update failed: ", $msg))
        };
        
        twit:update-tweet-cache($user, $user-id);
        twit:update-message-cache($user, $user-id);
    }
};
