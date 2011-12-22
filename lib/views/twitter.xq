module namespace view = 'http://www.socialito.org/lib/views/twitter';

(:
 : VIEW library
 :
 : Module responsible for rendering all socialito HTML pages
 :)
import module namespace html="http://www.socialito.org/lib/html";
import module namespace util="http://www.socialito.org/lib/util";

import module namespace model="http://www.socialito.org/lib/models/twitter";

declare variable $view:UPDATE-URI as xs:string := "/twitter/update";
declare variable $view:LOGOUT-URI as xs:string := "/session/logout";

declare variable $view:MSG-PARAM as xs:string := "msg";

declare function view:show-update (
    $err as xs:string?,
    $msg as xs:string?
)
    as element(html)
{
    html:format-page(
        "Twitter Cache",
        (),
        <div id="content" class="formview">
            <h1>Twitter</h1>
            {
                if (exists($err)) then
                    <p class="error">{$err}</p>
                else ()
            }
            {
                if (exists($msg)) then
                    <p class="info">{$msg}</p>
                else ()
            }
            <div class="importantnote">
                <h3>Note</h3>
                <p>
                    The application is about to retrieve {$model:cache-max} of your most recent tweets, {$model:cache-max} of your most recent messages and all of your friend details. This may take a few minutes.
                </p>
            </div>
            <form action="{$view:UPDATE-URI}" method="POST" name="login" id="login">
                <input type="hidden" name="skip" value="true" />
                <input type="submit" value="Update" id="twitter_continue" />{$html:nbsp}<a href="{$view:LOGOUT-URI}">Logout</a>
                <p id="twitter_spinner" style="display:none;"><img src="/images/spinner.gif" alt="Working..." />{$html:nbsp}Fetching your tweets...</p>
            </form>
        </div>
    )
};
