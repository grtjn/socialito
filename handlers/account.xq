module namespace account = 'http://www.socialito.org/account';

(:
 : Account controller handler module
 :)

import module namespace util="http://www.socialito.org/lib/util";

import module namespace main="http://www.socialito.org/lib/controllers/main";
import module namespace control="http://www.socialito.org/lib/controllers/account";

declare sequential function account:create()
{
    (: fetch credentials entered by user (if any) :)
    declare $user := util:get-request-param($control:USER-PARAM);
    declare $pass := util:get-request-param($control:PASS-PARAM);
    declare $pass2 := util:get-request-param($control:PASS2-PARAM);
    
    (: Create attempt :)
    try {
    
        control:do-create($user, $pass, $pass2)
    
    } catch * ($code, $msg, $val) {
        (: attempt failed, let user retry :)
        let $err :=
            util:format-error($code, $msg, $val)
        return
            exit returning control:show-create($user, $pass, $pass2, $err, ())
    };
    
    (: create succesfull! :)
    main:next((), "Account created succesfully");
};

declare sequential function account:dispose()
{
    main:do-refresh();
    
    control:do-dispose();
    
    (: dispose succesfull! :)
    main:next((), "Account disposed succesfully");
};
