module namespace view = 'http://www.socialito.org/lib/views/account';

(:
 : VIEW library
 :
 : Module responsible for rendering all socialito HTML pages
 :)
import module namespace html="http://www.socialito.org/lib/html";
import module namespace util="http://www.socialito.org/lib/util";

import module namespace model="http://www.socialito.org/lib/models/account";

declare variable $view:LOGIN-URI as xs:string := "/session/login";
declare variable $view:CREATE-URI as xs:string := "/account/create";
declare variable $view:DISPOSE-URI as xs:string := "/account/dispose";

declare variable $view:USER-PARAM as xs:string := "user";
declare variable $view:PASS-PARAM as xs:string := "pass";
declare variable $view:PASS2-PARAM as xs:string := "pass2";
declare variable $view:ERR-PARAM as xs:string := "err";
declare variable $view:MSG-PARAM as xs:string := "msg";

declare function view:show-new-account (
    $user as xs:string?,
    $pass as xs:string?,
    $pass2 as xs:string?,
    $err as xs:string?,
    $msg as xs:string?
)
    as element(html)
{
    html:format-page(
        "Create new account",
        (),
        <div id="content" class="formview">
            <h1>Create new account</h1>
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
            <form action="{$view:CREATE-URI}" method="POST" name="login" id="login">
                <div>
                    <label for="{$view:USER-PARAM}">Username:</label>
                    <input type="text" name="{$view:USER-PARAM}" id="{$view:USER-PARAM}" value="{$user}"/>
                </div>
                <div>
                    <label for="{$view:PASS-PARAM}">Password:</label>
                    <input type="password" name="{$view:PASS-PARAM}" id="{$view:PASS-PARAM}" value=""/>
                </div>
                <div>
                    <label for="{$view:PASS2-PARAM}">Retype password:</label>
                    <input type="password" name="{$view:PASS2-PARAM}" id="{$view:PASS2-PARAM}" value=""/>
                </div>
                <input type="submit" value="Create" class="submit" />{$html:nbsp}<a href="{$view:LOGIN-URI}">Return to login</a>
            </form>

            <script>
                $(document).ready(function(){{
                    $("#{$view:USER-PARAM}").focus();
                }});
            </script>
        </div>
    )
};
