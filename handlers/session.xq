module namespace session = "http://www.socialito.org/session";

(:
 : Session controller handler module
 :)

import module namespace util="http://www.socialito.org/lib/util";

import module namespace main="http://www.socialito.org/lib/controllers/main";
import module namespace account="http://www.socialito.org/lib/controllers/account";
import module namespace control="http://www.socialito.org/lib/controllers/session";

declare sequential function session:login ()
{
    (: fetch request params :)
    declare $user := util:get-request-param($control:USER-PARAM);
    declare $pass := util:get-request-param($control:PASS-PARAM);
    
    (: Login attempt :)
    try {
    
        control:do-login($user, $pass);
    
    } catch UNKNOWN-ACCOUNT ($code, $msg, $val) {
        (: unknown account, redirect to account creation! :)
        let $err :=
            util:format-error($code, $msg, $val)
        return
            exit returning account:show-create($user, $pass, $pass, $err, ())
        
    } catch * ($code, $msg, $val) {
        (: attempt failed, let user retry :)
        let $err :=
            util:format-error($code, $msg, $val)
        return
            exit returning control:show-login($user, $pass, $err, ())
    };
    
    (: let main controller decide what's next.. :)
    main:next((), "Login succesful");
};

declare sequential function session:logout()
{
    control:do-logout();
    
    (: let main controller decide what's next.. :)
    main:next((), "Logout succesful");
};
