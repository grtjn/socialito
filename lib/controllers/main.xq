module namespace main = 'http://www.socialito.org/lib/controllers/main';

(:
 : Module with globally accessible app settings and intra handler redirects
 :)

import module namespace http="http://www.28msec.com/modules/http";
import module namespace util="http://www.socialito.org/lib/util";

import module namespace sess="http://www.socialito.org/lib/controllers/session";
import module namespace acco="http://www.socialito.org/lib/controllers/account";
import module namespace twit="http://www.socialito.org/lib/controllers/twitter";
import module namespace ui="http://www.socialito.org/lib/controllers/ui";

declare variable $main:ERR-PARAM := $sess:ERR-PARAM;
declare variable $main:MSG-PARAM := $sess:MSG-PARAM;

(: test purposes, when not connected to internet, skips Twitter Authorization :)
declare variable $main:OFF-LINE := false();

declare sequential function main:is-initialized (
)
    as xs:boolean
{
    declare $is-sess-init as xs:boolean :=
        sess:is-initialized();
    declare $is-acco-init as xs:boolean :=
        if ($is-sess-init) then
            acco:is-initialized()
        else false();
    declare $is-twit-init as xs:boolean :=
        if ($main:OFF-LINE) then
            true()
        else if ($is-acco-init) then
            twit:is-initialized()
        else false();
    declare $is-ui-init as xs:boolean :=
        if ($is-twit-init) then
            ui:is-initialized()
        else false();

    $is-sess-init and $is-acco-init and $is-twit-init and $is-ui-init
};

declare sequential function main:do-init (
    $err as xs:string?,
    $msg as xs:string?
)
{
    declare $is-sess-init as xs:boolean :=
        sess:is-initialized();
    declare $is-acco-init as xs:boolean :=
        if ($is-sess-init) then
            acco:is-initialized()
        else false();
    declare $is-twit-init as xs:boolean :=
        if ($main:OFF-LINE) then
            true()
        else if ($is-acco-init) then
            twit:is-initialized()
        else false();
    declare $is-ui-init as xs:boolean :=
        if ($is-twit-init) then
            ui:is-initialized()
        else false();
    
    if ($is-sess-init) then
        sess:do-refresh()
    else
        exit returning sess:do-init($err, $msg);
            
    if ($is-acco-init) then
        acco:do-refresh()
    else
        exit returning acco:do-init($err, $msg);
            
    if ($is-twit-init) then
        twit:do-refresh()
    else
        exit returning twit:do-init($err, $msg);

    if ($is-ui-init) then
        ui:do-refresh()
    else
        exit returning ui:do-init($err, $msg);

    (: init all done, show home! :)
    ui:show-home($err, $msg);
};

declare sequential function main:do-refresh (
)
    as empty-sequence()
{
    declare $is-sess-init as xs:boolean :=
        sess:is-initialized();
    declare $is-acco-init as xs:boolean :=
        acco:is-initialized();
    declare $is-twit-init as xs:boolean :=
        twit:is-initialized();
    declare $is-ui-init as xs:boolean :=
        ui:is-initialized();
    
    if ($is-sess-init) then
        sess:do-refresh()
    else
        ();
            
    if ($is-acco-init) then
        acco:do-refresh()
    else
        ();
            
    if ($is-twit-init) then
        twit:do-refresh()
    else
        ();

    if ($is-ui-init) then
        ui:do-refresh()
    else
        ();
};

declare sequential function main:do-update (
)
    as empty-sequence()
{
    declare $is-twit-init as xs:boolean :=
        twit:is-initialized();
    
    if ($is-twit-init) then
        twit:do-update()
    else
        ();
};

declare sequential function main:do-clear (
)
    as empty-sequence()
{
    acco:do-clear();
    twit:do-clear();
};

declare sequential function main:do-dispose (
)
    as empty-sequence()
{
    acco:do-clear();
    twit:do-clear();
    acco:do-dispose();
    sess:do-logout();
};

declare sequential function main:next(
    $err as xs:string?,
    $msg as xs:string?
) {
    declare $is-init as xs:boolean :=
        main:is-initialized();

    if ($is-init) then
        (:
        try {
        :)
            ui:show-home($err, $msg)
        (:
        } catch * ($code, $msg, $val) {
            let $err :=
                util:format-error($code, $msg, $val)
            return
                exit returning sess:show-login((), (), $err, ()) 
        }
        :)
    else
        http:set-redirect(concat("/main/init?err=", $err, "&amp;msg=", $msg));
};
