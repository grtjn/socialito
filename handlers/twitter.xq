module namespace twit = "http://www.socialito.org/twitter";

(:
 : AJAX main module
 :
 : Controller for handling AJAX calls
 :)

import module namespace http="http://www.28msec.com/modules/http";
import module namespace util="http://www.socialito.org/lib/util";

import module namespace main="http://www.socialito.org/lib/controllers/main";
import module namespace control="http://www.socialito.org/lib/controllers/twitter";

declare sequential function twit:authorize()
{
    (: performs a redirect! :)
    control:show-authorize();
};

declare sequential function twit:callback()
{
    (: authorize succesfull! :)
    control:do-callback();
        
    (: enforce a redirect to make sure a global twitter cookie is stored in browser first :)
    http:set-redirect("/twitter/prepare");
};

declare sequential function twit:prepare()
{
    control:do-prepare();
    
    main:next((), "Twitter authorized succesfully");
};

declare sequential function twit:update()
{
    declare $skip := util:get-request-param-as-bool("skip", false());
    declare $is-ajax := util:get-request-param-as-bool($control:ISAJAX-PARAM, false());

    declare $is-init as xs:boolean :=
        main:is-initialized();

    declare $twit-never-updated :=
        if ($is-init) then
            control:is-never-updated()
        else
            false();
        
    if (not($is-init)) then (
        if (not($is-ajax)) then
            exit returning main:do-init((), "Session expired")
        else ()
    ) else ();

    main:do-refresh();
    
    if (not($skip) and $twit-never-updated) then
        control:show-update((), ())
    else block {
        control:do-update();
    
        (: update can take quite a while! :)
        main:do-refresh();
        
        main:next((), "Twitter Cache updated succesfully");
    };
};

declare sequential function twit:invalidate()
{
    declare $is-ajax := util:get-request-param-as-bool($control:ISAJAX-PARAM, false());

    declare $is-init as xs:boolean :=
        main:is-initialized();

    if (not($is-init)) then (
        if (not($is-ajax)) then
            exit returning main:do-init((), "Session expired")
        else ()
    ) else ();

    main:do-refresh();
    
    control:do-invalidate();
        
    (: invalidate succesfull! :)
    main:next((), "Twitter invalidated succesfully");
};

declare sequential function twit:follow-friend()
{
    declare $user_id := util:get-request-param($control:USER_ID-PARAM);
    declare $is-ajax := util:get-request-param-as-bool($control:ISAJAX-PARAM, false());

    declare $is-init as xs:boolean :=
        main:is-initialized();

    if (not($is-init)) then (
        if (not($is-ajax)) then
            exit returning main:do-init((), "Session expired")
        else ()
    ) else ();

    main:do-refresh();
    
    try {

        control:do-follow-friend($user_id);

    } catch * ($code, $msg, $val) {
        let $err :=
            util:format-error($code, $msg, $val)
        return
            exit returning control:show-home($err, ()) 
    };
    

    if ($is-ajax) then
        control:get-ajax-response("follow")
    else
        main:next((), "Friend added succesfully");
};

declare sequential function twit:drop-friend()
{
    declare $user_id := util:get-request-param($control:USER_ID-PARAM);
    declare $is-ajax := util:get-request-param-as-bool($control:ISAJAX-PARAM, false());

    declare $is-init as xs:boolean :=
        main:is-initialized();

    if (not($is-init)) then (
        if (not($is-ajax)) then
            exit returning main:do-init((), "Session expired")
        else ()
    ) else ();

    main:do-refresh();
    
    try {

        control:do-drop-friend($user_id);

    } catch * ($code, $msg, $val) {
        let $err :=
            util:format-error($code, $msg, $val)
        return
            exit returning control:show-home($err, ())
    };
    

    if ($is-ajax) then
        control:get-ajax-response("unfollow")
    else
        main:next((), "Friend dropped succesfully");
};

declare sequential function twit:block-friend()
{
    declare $user_id := util:get-request-param($control:USER_ID-PARAM);
    declare $is-ajax := util:get-request-param-as-bool($control:ISAJAX-PARAM, false());

    declare $is-init as xs:boolean :=
        main:is-initialized();

    if (not($is-init)) then (
        if (not($is-ajax)) then
            exit returning main:do-init((), "Session expired")
        else ()
    ) else ();

    main:do-refresh();
    
    try {

        control:do-block-friend($user_id);

    } catch * ($code, $msg, $val) {
        let $err :=
            util:format-error($code, $msg, $val)
        return
            exit returning control:show-home($err, ())
    };
    

    if ($is-ajax) then
        control:get-ajax-response("block")
    else
        main:next((), "Blocked succesfully");
};

declare sequential function twit:unblock-friend()
{
    declare $user_id := util:get-request-param($control:USER_ID-PARAM);
    declare $is-ajax := util:get-request-param-as-bool($control:ISAJAX-PARAM, false());

    declare $is-init as xs:boolean :=
        main:is-initialized();

    if (not($is-init)) then (
        if (not($is-ajax)) then
            exit returning main:do-init((), "Session expired")
        else ()
    ) else ();

    main:do-refresh();
    
    try {
        control:do-unblock-friend($user_id);
    } catch * ($code, $msg, $val) {
        let $err :=
            util:format-error($code, $msg, $val)
        return
            exit returning control:show-home($err, ()) 
    };

    if ($is-ajax) then
        control:get-ajax-response("unblock")
    else
        main:next((), "Unblocked succesfully");
};

declare sequential function twit:tweet-new()
{
    declare $status := util:get-request-param($control:STATUS-PARAM);
    declare $action := util:get-request-param($control:ACTION-PARAM);
    declare $is-ajax := util:get-request-param-as-bool($control:ISAJAX-PARAM, false());

    declare $is-init as xs:boolean :=
        main:is-initialized();

    if (not($is-init)) then (
        if (not($is-ajax)) then
            exit returning main:do-init((), "Session expired")
        else ()
    ) else ();

    main:do-refresh();
    
    try {
        control:do-tweet-new(encode-for-uri($status));
    } catch * ($code, $msg, $val) {
        let $err :=
            util:format-error($code, $msg, $val)
        return
            exit returning control:show-home($err, ())
    };

    if ($is-ajax and exists($action)) then
        control:get-ajax-response($action)
    else
        main:next((), "Status updated succesfully");
};
