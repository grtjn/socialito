module namespace control = "http://www.socialito.org/lib/controllers/session";

(:
 : Session Handler proxying module
 :)

import module namespace http="http://www.28msec.com/modules/http";

import module namespace model="http://www.socialito.org/lib/models/session";
import module namespace view="http://www.socialito.org/lib/views/session";

(: these should be imported by view, but that gives cyclic dependencies :)
declare variable $control:LOGIN-URI as xs:string := $view:LOGIN-URI;
declare variable $control:LOGOUT-URI as xs:string := $view:LOGOUT-URI;

declare variable $control:USER-PARAM as xs:string := $view:USER-PARAM;
declare variable $control:PASS-PARAM as xs:string := $view:PASS-PARAM;
declare variable $control:ERR-PARAM as xs:string := $view:ERR-PARAM;
declare variable $control:MSG-PARAM as xs:string := $view:MSG-PARAM;

declare function control:is-initialized (
)
    as xs:boolean
{
    model:is-logged-in() and not(model:is-expired())
};

declare sequential function control:do-init (
    $err as xs:string?,
    $msg as xs:string?
)
    as empty-sequence()
{
    declare $is-logged-in as xs:boolean :=
        model:is-logged-in();
    declare $is-expired as xs:boolean :=
        model:is-expired();
    
    if (exists($msg) or exists($err)) then
        exit returning view:show-login((), (), $err, $msg)
    else
        ();
            
    if (not($is-logged-in)) then
        exit returning view:show-login("", (), (), "Please login first")
    else
        ();
            
    if ($is-expired) then
        exit returning view:show-login((), (), (), "Session expired")
    else
        ();
    
    control:do-refresh();
};

declare sequential function control:do-refresh (
)
    as empty-sequence()
{
    model:refresh();
};

declare sequential function control:do-login(
    $user as xs:string?,
    $pass as xs:string?
)
{
    model:login($user, $pass);
};

declare function control:show-login(
    $user as xs:string?,
    $pass as xs:string?,
    $err as xs:string?,
    $msg as xs:string?
)
{
    view:show-login($user, $pass, $err, $msg)
};

declare sequential function control:do-logout(
)
{
    model:logout();
};
