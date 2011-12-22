module namespace control = "http://www.socialito.org/lib/controllers/twitter";

(:
 : Twitter Handler proxying module
 :)

import module namespace http="http://www.28msec.com/modules/http";
import module namespace scs="http://www.28msec.com/modules/scs";

import module namespace view="http://www.socialito.org/lib/views/twitter";
import module namespace ui="http://www.socialito.org/lib/views/ui";
import module namespace model="http://www.socialito.org/lib/models/twitter";
import module namespace sess="http://www.socialito.org/lib/models/session";

declare variable $control:AUTHORIZE-URI as xs:string := "/twitter/authorize";
declare variable $control:CALLBACK-URI as xs:string := "/twitter/callback";
declare variable $control:INVALIDATE-URI as xs:string := "/twitter/invalidate";

declare variable $control:USER_ID-PARAM as xs:string := $ui:USER_ID-PARAM;
declare variable $control:STATUS-PARAM as xs:string := $ui:STATUS-PARAM;
declare variable $control:ISAJAX-PARAM as xs:string := $ui:ISAJAX-PARAM;
declare variable $control:ACTION-PARAM as xs:string := $ui:ACTION-PARAM;

declare sequential function control:is-initialized (
)
    as xs:boolean
{
    declare $is-authorized as xs:boolean :=
        model:is-authorized();
    declare $is-updated as xs:boolean :=
        (: model:is-updated() :)
        true();
    
    if (not($is-authorized)) then block {
        (: flush global cookie :)
        declare $flush :=
            http:set-cookie(
                <cookie
                    name="_scs"
                    path="/">
                </cookie>
            );
            
        false();
    } else
        $is-updated;
};

declare sequential function control:do-init (
    $err as xs:string?,
    $msg as xs:string?
)
    as empty-sequence()
{
    declare $is-authorized as xs:boolean :=
        model:is-authorized();
    declare $is-updated as xs:boolean :=
        model:is-updated();
    
    if (not($is-authorized)) then
        exit returning control:go-authorize()
    else
        ();
    
    if (not($is-updated)) then
        exit returning view:show-update((), "Twitter Cache needs to be initialized first")
    else
        ();
};

declare sequential function control:do-refresh (
)
    as empty-sequence()
{
    ();
};

declare sequential function control:is-never-updated (
)
    as xs:boolean
{
    model:is-never-updated()
};

declare sequential function control:show-update (
    $err as xs:string?,
    $msg as xs:string?
)
    as item()*
{
    view:show-update($err, $msg);
};

declare sequential function control:do-update (
)
    as empty-sequence()
{
    model:update();
};

declare sequential function control:do-clear (
)
    as empty-sequence()
{
    model:clear();
};

declare sequential function control:go-authorize (
)
    as empty-sequence()
{
    declare $flush_global_scc :=
        http:set-cookie(
            <cookie
                name="_scs"
                path="/">
            </cookie>
        );

    (: enforce a redirect to make sure the context is the twitter handler :)
    http:set-redirect("/twitter/authorize");
};

declare sequential function control:show-authorize (
)
    as empty-sequence()
{
    (: performs a redirect, showing an authorize screen from Twitter :)
    model:authorize()
};

declare sequential function control:do-callback (
)
    as empty-sequence()
{
    model:callback()
};

declare sequential function control:do-prepare (
)
    as empty-sequence()
{
    declare $scs :=
        scs:get();

    declare $scs_clear :=
        scs:clear();

    declare $make_scs_global :=
        http:set-cookie(
            <cookie
                name="_scs"
                path="/">
                {$scs}
            </cookie>
        );

    model:prepare();
};

declare sequential function control:do-invalidate (
)
    as empty-sequence()
{
    model:invalidate()
};

declare sequential function control:show-home (
    $err as xs:string?,
    $msg as xs:string?
)
{
    ui:show-home($err, $msg)
};

declare sequential function control:do-follow-friend (
    $user_id as xs:string?
)
    as empty-sequence()
{
    declare $user := sess:get-session-user();
    declare $friend := model:follow-friend($user, $user_id);
    
    ();
};

declare sequential function control:do-drop-friend (
    $user_id as xs:string?
)
    as empty-sequence()
{
    declare $user := sess:get-session-user();
    declare $friend := model:drop-friend($user, $user_id);

    ();
};

declare sequential function control:do-block-friend (
    $user_id as xs:string?
)
    as empty-sequence()
{
    declare $user := sess:get-session-user();
    declare $block := model:block-person($user, $user_id);

    ();
};

declare sequential function control:do-unblock-friend (
    $user_id as xs:string?
)
    as empty-sequence()
{
    declare $user := sess:get-session-user();
    declare $unblock := model:unblock-person($user, $user_id);

    ();
};

declare sequential function control:do-tweet-new (
    $status as xs:string?
)
    as empty-sequence()
{
    declare $user := sess:get-session-user();
    declare $tweet := model:tweet-new($user, $status);

    ();
};

declare sequential function control:get-ajax-response (
    $action as xs:string
)
    as item()*
{
    ui:get-ajax-response($action)
};
