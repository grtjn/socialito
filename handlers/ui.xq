module namespace ui = "http://www.socialito.org/ui";

(:
 : UI main module
 :
 : Main controller containing all application logic
 :)

import module namespace util="http://www.socialito.org/lib/util";

import module namespace main="http://www.socialito.org/lib/controllers/main";
import module namespace control="http://www.socialito.org/lib/controllers/ui";

declare sequential function ui:home()
{
    declare $is-init as xs:boolean :=
        main:is-initialized();

    if (not($is-init)) then (
        exit returning main:do-init((), "Session expired")
    ) else ();

    main:do-refresh();
    
    main:next((), ());
};

declare sequential function ui:show-user()
{
    declare $user-id := util:get-request-param($control:USER_ID-PARAM);
    declare $screen-name := util:get-request-param($control:SCREEN_NAME-PARAM);
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

        control:add-user-widget($user-id, $screen-name);

    } catch * ($code, $msg, $val) {
        let $err :=
            util:format-error($code, $msg, $val)
        return
            exit returning control:show-home($err, ()) 
    };
    
    if (not($is-ajax)) then
        main:next((), ())
    else
        control:get-ajax-response("show-user");
};

declare sequential function ui:show-friends()
{
    declare $user-id := util:get-request-param($control:USER_ID-PARAM);
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

        control:add-friends-widget($user-id);

    } catch * ($code, $msg, $val) {
        let $err :=
            util:format-error($code, $msg, $val)
        return
            exit returning control:show-home($err, ()) 
    };
    
    if (not($is-ajax)) then
        main:next((), ())
    else
        control:get-ajax-response("show-friends");
};

declare sequential function ui:show-followers()
{
    declare $user-id := util:get-request-param($control:USER_ID-PARAM);
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

        control:add-followers-widget($user-id);

    } catch * ($code, $msg, $val) {
        let $err :=
            util:format-error($code, $msg, $val)
        return
            exit returning control:show-home($err, ()) 
    };
    
    if (not($is-ajax)) then
        main:next((), ())
    else
        control:get-ajax-response("show-followers");
};

declare sequential function ui:show-hashtag()
{
    declare $hashtag := util:get-request-param($control:HASHTAG-PARAM);
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

        control:add-hashtag-widget($hashtag);

    } catch * ($code, $msg, $val) {
        let $err :=
            util:format-error($code, $msg, $val)
        return
            exit returning control:show-home($err, ()) 
    };
    
    if (not($is-ajax)) then
        main:next((), ())
    else
        control:get-ajax-response("show-hashtag");
};

declare sequential function ui:show-mentions()
{
    declare $user-id := util:get-request-param($control:USER_ID-PARAM);
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

        control:add-mentions-widget($user-id);

    } catch * ($code, $msg, $val) {
        let $err :=
            util:format-error($code, $msg, $val)
        return
            exit returning control:show-home($err, ()) 
    };
    
    if (not($is-ajax)) then
        main:next((), ())
    else
        control:get-ajax-response("show-mentions");
};

declare sequential function ui:show-tweets()
{
    declare $user-id := util:get-request-param($control:USER_ID-PARAM);
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

        control:add-tweets-widget($user-id);

    } catch * ($code, $msg, $val) {
        let $err :=
            util:format-error($code, $msg, $val)
        return
            exit returning control:show-home($err, ()) 
    };
    
    if (not($is-ajax)) then
        main:next((), ())
    else
        control:get-ajax-response("show-tweets");
};

declare sequential function ui:update-widget()
{
    declare $id := util:get-request-param($control:WIDGET-ID-PARAM);
    declare $status := util:get-request-param($control:WIDGET-STATUS-PARAM);
    declare $title := util:get-request-param($control:WIDGET-TITLE-PARAM);
    declare $color := util:get-request-param($control:WIDGET-COLOR-PARAM);
    declare $page := util:get-request-param-as-int($control:WIDGET-PAGE-PARAM);
    declare $count := util:get-request-param-as-int($control:WIDGET-COUNT-PARAM);

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

        control:update-widget($id, $status, $title, $color, $page, $count);

    } catch * ($code, $msg, $val) {
        let $err :=
            util:format-error($code, $msg, $val)
        return
            exit returning control:show-home($err, ()) 
    };
    
    if (not($is-ajax)) then
        main:next((), ())
    else
        control:get-ajax-response-by-id($id);
        (:(<b>UPDATE OK!</b>);:)
};

declare sequential function ui:move-widget()
{
    declare $id := util:get-request-param($control:WIDGET-ID-PARAM);
    declare $column as xs:integer := util:get-request-param-as-int($control:WIDGET-COLUMN-PARAM);
    declare $position as xs:integer := util:get-request-param-as-int($control:WIDGET-POSITION-PARAM);
    
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

        control:move-widget($id, $column, $position);

    } catch * ($code, $msg, $val) {
        let $err :=
            util:format-error($code, $msg, $val)
        return
            exit returning control:show-home($err, ())
    };
    
    if (not($is-ajax)) then
        main:next((), ())
    else
        ();
};

declare sequential function ui:delete-widget()
{
    declare $id := util:get-request-param($control:WIDGET-ID-PARAM);
   
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

        control:delete-widget($id);

    } catch * ($code, $msg, $val) {
        let $err :=
            util:format-error($code, $msg, $val)
        return
            exit returning control:show-home($err, ()) 
    };
    
    if (not($is-ajax)) then
        main:next((), ())
    else
        ();
};
