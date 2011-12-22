module namespace main = 'http://www.socialito.org/main';

import module namespace http="http://www.28msec.com/modules/http";
import module namespace util="http://www.socialito.org/lib/util";

import module namespace control="http://www.socialito.org/lib/controllers/main";

declare sequential function main:init ()
{
    declare $err := util:get-request-param($control:ERR-PARAM);
    declare $msg := util:get-request-param($control:MSG-PARAM);
    
    control:do-init($err, $msg);
};

declare sequential function main:update ()
{
    control:do-refresh();
    control:do-update();
    
    control:next((), "Cache updated succesfully");
};

declare sequential function main:clear ()
{
    control:do-refresh();
    control:do-clear();
    
    control:next((), "Cache cleared succesfully");
};


declare sequential function main:dispose ()
{
    control:do-refresh();
    control:do-dispose();
    
    (::)
    control:next((), "Account disposed succesfully");
};
