module namespace control = "http://www.socialito.org/lib/controllers/account";

(:
 : Session Handler proxying module
 :)

import module namespace http="http://www.28msec.com/modules/http";

import module namespace session="http://www.socialito.org/lib/models/session";
import module namespace model="http://www.socialito.org/lib/models/account";
import module namespace view="http://www.socialito.org/lib/views/account";

(: these should be imported by view, but that gives cyclic dependencies :)
declare variable $control:CREATE-URI as xs:string := $view:CREATE-URI;
declare variable $control:DISPOSE-URI as xs:string := $view:DISPOSE-URI;

declare variable $control:USER-PARAM as xs:string := $view:USER-PARAM;
declare variable $control:PASS-PARAM as xs:string := $view:PASS-PARAM;
declare variable $control:PASS2-PARAM as xs:string := $view:PASS2-PARAM;
declare variable $control:ERR-PARAM as xs:string := $view:ERR-PARAM;
declare variable $control:MSG-PARAM as xs:string := $view:MSG-PARAM;

declare function control:is-initialized (
)
    as xs:boolean
{
    let $user as xs:string? :=
        session:get-session-user()
    return
        exists($user) and model:account-exists($user)
};

declare sequential function control:do-init (
    $err as xs:string?,
    $msg as xs:string?
)
    as empty-sequence()
{
    declare $user as xs:string? :=
        session:get-session-user();
    declare $exists as xs:boolean :=
        exists($user) and model:account-exists($user);
    
    if (exists($msg) or exists($err)) then
        exit returning control:show-create($user, (), (), $err, $msg)
    else
        ();
        
    if (not($exists)) then
        exit returning control:show-create($user, (), (), (), "Account doesn't exist")
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

declare sequential function control:do-update (
)
    as empty-sequence()
{
    ()
};

declare sequential function control:do-create (
    $user as xs:string?,
    $pass as xs:string?,
    $pass2 as xs:string?
)
    as empty-sequence()
{
    model:create-account($user, $pass, $pass2);
    
    session:login($user, $pass);
};

declare function control:show-create (
    $user as xs:string?,
    $pass as xs:string?,
    $pass2 as xs:string?,
    $err as xs:string?,
    $msg as xs:string?
)
{
    view:show-new-account($user, $pass, $pass2, $err, $msg)
};

declare sequential function control:do-clear (
)
    as empty-sequence()
{
    declare $user as xs:string? :=
        session:get-session-user();

    model:delete-account-data($user, "page-layout", ());
};

declare sequential function control:do-dispose (
)
    as empty-sequence()
{
    declare $user as xs:string? :=
        session:get-session-user();

    model:delete-account($user);
};
