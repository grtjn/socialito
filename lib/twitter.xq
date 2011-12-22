module namespace tapi = 'http://www.socialito.org/lib/twitter';

import module namespace http="http://www.28msec.com/modules/http";
import module namespace oac="http://www.28msec.com/modules/oauth/commons";
import module namespace scs="http://www.28msec.com/modules/scs";

import schema namespace oa="http://www.28msec.com/modules/oauth/client";

declare variable $tapi:xml-output :=
    <output
        method="xml" 
        version="1.0"
        encoding="UTF-8" 
        omit-xml-declaration="yes"
        standalone="yes"
        cdata-section-elements=""
        indent="yes"
        media-type=""/>;

declare variable $tapi:config := 
    oac:config-twitter("HfmyHdHdDplcLRqAoE3cQg",
                       "FbstNoVMc201Aoiv4i3wWVMVxEZgX9OWwzFF3FQhbU",
                       concat("http://", http:get-server-name(), ":", http:get-server-port(), "/twitter/callback"));

(:
declare variable $tapi:config :=
    oac:config-twitter("pyfYN93gmoSRox8SDgOE6Q",
                       "EI93wx6gLlNsBjoZLgRJwpy4PNCPriWDYkZiU0yM",
                       concat("http://", http:get-server-name(), ":", http:get-server-port(), "/twitter/callback"));
:)

(:
 : http://apiwiki.twitter.com/Twitter-API-Documentation
 :
 : Search API Methods 
 :)

declare variable $tapi:SEARCH as xs:string := "search";
(:
GET -> atom
- max_id: Optional. Returns tweets with status ids less than the given id. 
- q: Optional.  The text to search for.  See the example queries section for examples of the syntax supported in this parameter 
- rpp: Optional. The number of tweets to return per page, up to a max of 100. 
- page: Optional. The page number (starting at 1) to return, up to a max of roughly 1500 results (based on rpp * page. Note: there are pagination limits. 
- since: Optional. Returns tweets with since the given date.  Date should be formatted as YYYY-MM-DD 
- since_id: Optional. Returns tweets with status ids greater than the given id. 
- geocode: Optional. Returns tweets by users located within a given radius of the given latitude/longitude.  The location is preferentially taking from the Geotagging API, but will fall back to their Twitter profile. The parameter value is specified by "latitide,longitude,radius", where radius units must be specified as either "mi" (miles) or "km" (kilometers). Note that you cannot use the near operator via the API to geocode arbitrary locations; however you can use this geocode parameter to search near geocodes directly. 
- show_user: Optional. When true, prepends "<user>:" to the beginning of the tweet. This is useful for readers that do not display Atom's author field. The default is false. 
- until: Optional. Returns tweets with generated before the given date.  Date should be formatted as YYYY-MM-DD 
- result_type: Optional. Specifies what type of search results you would prefer to receive. 
  . mixed: In a future release this will become the default value. Include both popular and real time results in the response.
  . recent: The current default value. Return only the most recent results in the response.
  . popular: Return only the most popular results in the response.
:)

(:
 : REST API Methods 
 :
 : Timeline Methods
 :)
declare variable $tapi:STAT_PUBLIC_TL as xs:string := "statuses/public_timeline";
declare variable $tapi:STAT_HOME_TL as xs:string := "statuses/home_timeline";
declare variable $tapi:STAT_FRIENDS_TL as xs:string := "statuses/friends_timeline";
declare variable $tapi:STAT_USER_TL as xs:string := "statuses/user_timeline";
declare variable $tapi:STAT_MENTIONS as xs:string := "statuses/mentions";
declare variable $tapi:STAT_RETWEETED_BY_ME as xs:string := "statuses/retweeted_by_me";
declare variable $tapi:STAT_RETWEETED_TO_ME as xs:string := "statuses/retweeted_to_me";
declare variable $tapi:STAT_RETWEETS_OF_ME as xs:string := "statuses/retweets_of_me";

(:
 : Status Methods
 :)
declare variable $tapi:STAT_SHOW as xs:string := "statuses/show";
declare variable $tapi:STAT_UPDATE as xs:string := "statuses/update";
declare variable $tapi:STAT_DESTROY as xs:string := "statuses/destroy";
declare variable $tapi:STAT_RETWEET as xs:string := "statuses/retweet";
declare variable $tapi:STAT_RETWEETS as xs:string := "statuses/retweets";
declare variable $tapi:STAT_RETWEETED_BY as xs:string := "statuses/id/retweeted_by";
declare variable $tapi:STAT_RETWEETED_BY_IDS as xs:string := "statuses/id/retweeted_by/ids";

(:
 : User Methods
 :)
declare variable $tapi:USER_SHOW as xs:string := "users/show";
declare variable $tapi:USER_LOOKUP as xs:string := "users/lookup";
declare variable $tapi:USER_SEARCH as xs:string := "users/search";
declare variable $tapi:USER_SUGGEST as xs:string := "users/suggestions";
declare variable $tapi:USER_SUGGEST_CAT as xs:string := "users/suggestions/category";
declare variable $tapi:STAT_FRIENDS as xs:string := "statuses/friends";
declare variable $tapi:STAT_FOLLOWERS as xs:string := "statuses/followers";

(:
 : List Methods
         POST lists      (create)
         POST lists id  (update)
         GET lists        (index)
         GET list id      (show)
         DELETE list id (destroy)

         GET list statuses
         GET list memberships
         GET list subscriptions
 :)
 
(:
 : List Members Methods
         GET list members
         POST list members
         DELETE list members
         GET list members id
 :)
 
(:
 : List Subscribers Methods
         GET list subscribers
         POST list subscribers
         DELETE list subscribers
         GET list subscribers id
 :)
 
(:
 : Direct Message Methods 
 :)
declare variable $tapi:DM_RECV as xs:string := "direct_messages";
declare variable $tapi:DM_SENT as xs:string := "direct_messages/sent";
declare variable $tapi:DM_NEW as xs:string := "direct_messages/new";
declare variable $tapi:DM_DESTROY as xs:string := "direct_messages/destroy";

(:
 : Friendship Methods
 :)
declare variable $tapi:FRIEND_CREATE as xs:string := "friendships/create";
declare variable $tapi:FRIEND_DESTROY as xs:string := "friendships/destroy";
declare variable $tapi:FRIEND_EXISTS as xs:string := "friendships/exists";
declare variable $tapi:FRIEND_SHOW as xs:string := "friendships/show";
declare variable $tapi:FRIEND_IN as xs:string := "friendships/incoming";
declare variable $tapi:FRIEND_OUT as xs:string := "friendships/outgoing";

(:
 : Social Graph Methods
 :)
declare variable $tapi:FRIEND_IDS as xs:string := "friends/ids";
declare variable $tapi:FOLLOW_IDS as xs:string := "followers/ids";

(:
 : Account Methods
 :)
declare variable $tapi:ACC_VERIFY as xs:string := "account/verify_credentials";
declare variable $tapi:ACC_LIMIT as xs:string := "account/rate_limit_status";
declare variable $tapi:ACC_END as xs:string := "account/end_session";
declare variable $tapi:ACC_UPDATE_DEVICE as xs:string := "account/update_delivery_device";
declare variable $tapi:ACC_UPDATE_COLORS as xs:string := "account/update_profile_colors";
declare variable $tapi:ACC_UPDATE_IMAGE as xs:string := "account/update_profile_image";
declare variable $tapi:ACC_UPDATE_BG_IMAGE as xs:string := "account/update_profile_background_image";
declare variable $tapi:ACC_UPDATE_PROFILE as xs:string := "account/update_profile";

(:
 : Favorite Methods
 :)
declare variable $tapi:FAV_ALL as xs:string := "favorites";
declare variable $tapi:FAV_CREATE as xs:string := "favorites/create";
declare variable $tapi:FAV_DESTROY as xs:string := "favorites/destroy";

(:
 : Notification Methods
 :)
declare variable $tapi:NOTIF_FOLLOW as xs:string := "notifications/follow";
declare variable $tapi:NOTIF_LEAVE as xs:string := "notifications/leave";

(:
 : Block Methods
 :)
declare variable $tapi:BLOCK_CREATE as xs:string := "blocks/create";
declare variable $tapi:BLOCK_DESTROY as xs:string := "blocks/destroy";
declare variable $tapi:BLOCK_EXISTS as xs:string := "blocks/exists";
declare variable $tapi:BLOCK_ALL as xs:string := "blocks/blocking";
declare variable $tapi:BLOCK_IDS as xs:string := "blocks/blocking/ids";

(:
 : Spam Reporting Methods
 :)
declare variable $tapi:SPAM_REPORT as xs:string := "report_spam";

(:
 : Saved Searches Methods
 :)
declare variable $tapi:SAVED_ALL as xs:string := "saved_searches";
declare variable $tapi:SAVED_SHOW as xs:string := "saved_searches/show";
declare variable $tapi:SAVED_CREATE as xs:string := "saved_searches/create";
declare variable $tapi:SAVED_DESTROY as xs:string := "saved_searches/destroy";

(:
 : OAuth Methods
 :)
declare variable $tapi:OA_REQ_TOKEN as xs:string := "oauth/request_token";
declare variable $tapi:OA_AUTHORIZE as xs:string := "oauth/authorize";
declare variable $tapi:OA_AUTHENTICATE as xs:string := "oauth/authenticate";
declare variable $tapi:OA_ACC_TOKEN as xs:string := "oauth/access_token";

(:
 : Trends Methods
 :)
declare variable $tapi:TREND_AVAIL as xs:string := "trends/available";
declare variable $tapi:TREND_LOC as xs:string := "trends/location";
declare variable $tapi:TREND as xs:string := "trends";
declare variable $tapi:TREND_CURR as xs:string := "trends/current";
declare variable $tapi:TREND_DAY as xs:string := "trends/daily";
declare variable $tapi:TREND_WEEK as xs:string := "trends/weekly";

(:
 : Geo methods
 :)
declare variable $tapi:GEO_NEARBY as xs:string := "geo/nearby_places";
declare variable $tapi:GEO_REVERSE as xs:string := "geo/reverse_geocode";
declare variable $tapi:GEO_ID as xs:string := "geo/id";

(:
 : Help Methods
 :)
declare variable $tapi:HELP as xs:string := "help/test";

declare sequential function tapi:is-authorized (
)
    as xs:boolean
{
    declare $has-cookie :=
        tapi:has-access-cookie();
    declare $session-expired :=
        if ($has-cookie) then
            (:
            tapi:session-expired()
            :)
            false()
        else true();
    
    not($session-expired)
};

declare function tapi:has-access-cookie (
)
    as xs:boolean
{
    exists(scs:get()/@type[. eq 'access'])
};

declare sequential function tapi:session-expired (
)
    as xs:boolean
{
    declare $is-verified :=
        try {
            tapi:get-current-user ()
        } catch * ($code, $msg, $val) {
            ()
        };
    
    empty($is-verified);
};

(:
  OAuth procedure starts here
:)
declare sequential function tapi:init (
)
{
    (: performs a redirect to twitter!! :)
    oac:init($tapi:config);
};

(:
  After a successful authentication, the service provider redirects back to this url
:)
declare sequential function tapi:callback (
)
    as empty-sequence()
{
    oac:callback($tapi:config);
};

declare sequential function tapi:get-current-user (
)
    as element(user)
{
    tapi:get-resource ($tapi:ACC_VERIFY);
};

declare sequential function tapi:invalidate (
)
    as empty-sequence()
{
    declare $end :=
        try {
            tapi:get-resource ($tapi:ACC_END)
        } catch * ($code, $msg, $val) {
            ()
        };

    declare $clear :=
        scs:clear();

    (: just to be sure :)
    http:set-cookie(
        <cookie
            name="_scs"
            path="/">
        </cookie>
    );

    ();
};

(: 
  Access the protected resource
:)
declare sequential function tapi:get-resource (
    $resource as xs:string
)
    as element()
{
    tapi:get-resource($resource, 1, ())
};

declare sequential function tapi:get-resource (
    $resource as xs:string,
    $version as xs:integer,
    $params as xs:string*
)
    as element()*
{
    (: Build url :)
    let $version := concat($version, "/")
    let $params :=
        if (exists($params)) then
            concat("?", string-join($params, "&amp;"))
        else ()
    let $url := fn:concat("http://api.twitter.com/", $version, $resource, ".xml", $params)

    (: Define HTTP request :)
    let $http-request :=
        validate {
            <oa:http-request>
                <oa:target-url>{$url}</oa:target-url>
            </oa:http-request> }
  
    (: send signed request for ressource :)
    let $response :=
        oac:resource($tapi:config, $http-request)

    (: return data from response :)
    return
        (: debug:
        <url>{$url}</url>
        :)
        if (not($response//oa:status-code = (200 to 210))) then
            error(xs:QName("tapi:BAD-RESPONSE"), string($response//error))
        else
            $response//oa:payload/*
};

declare sequential function tapi:post-update (
    $resource as xs:string,
    $version as xs:integer,
    $params as xs:string*
)
    as element()*
{
    (: Build url :)
    let $version := concat($version, "/")
    let $params :=
        if (exists($params)) then
            concat("?", string-join($params, "&amp;"))
        else ()
    let $url := fn:concat("http://api.twitter.com/", $version, $resource, ".xml", $params)

    (: Define HTTP request :)
    let $http-request :=
        validate {
            <oa:http-request>
                <oa:http-method>POST</oa:http-method>
                <oa:target-url>{$url}</oa:target-url>
            </oa:http-request> }
  
    (: send signed request for ressource :)
    let $response :=
        oac:resource($tapi:config, $http-request)

    (: return data from response :)
    return
        if (not($response//oa:status-code = (200 to 210))) then
            error(xs:QName("tapi:BAD-RESPONSE"), string($response//error))
        else
            $response//oa:payload/*
};
