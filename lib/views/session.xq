module namespace view = 'http://www.socialito.org/lib/views/session';

(:
 : VIEW library
 :
 : Module responsible for rendering all socialito HTML pages
 :)
import module namespace html="http://www.socialito.org/lib/html";
import module namespace util="http://www.socialito.org/lib/util";

import module namespace model="http://www.socialito.org/lib/models/session";

declare variable $view:LOGIN-URI as xs:string := "/session/login";
declare variable $view:LOGOUT-URI as xs:string := "/session/logout";
declare variable $view:NEW-ACCOUNT-URI as xs:string := "/account/create";

declare variable $view:USER-PARAM as xs:string := "user";
declare variable $view:PASS-PARAM as xs:string := "pass";
declare variable $view:ERR-PARAM as xs:string := "err";
declare variable $view:MSG-PARAM as xs:string := "msg";

declare function view:show-login (
    $user as xs:string?,
    $pass as xs:string?,
    $err as xs:string?,
    $msg as xs:string?
)
    as element(html)
{
    html:format-page(
        "Login",
        (),
        <div id="content" class="formview">
            <h1>Login</h1>
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
            <form action="{$view:LOGIN-URI}" method="POST" name="login" id="login">
                <div>
                    <label for="{$view:USER-PARAM}">Username:</label>
                    <input type="text" name="{$view:USER-PARAM}" id="{$view:USER-PARAM}" value="{$user}"/>
                </div>
                <div>
                    <label for="{$view:PASS-PARAM}">Password:</label>
                    <input type="password" name="{$view:PASS-PARAM}" id="{$view:PASS-PARAM}" value=""/>
                </div>
                <input type="submit" value="Log In" class="submit" />{$html:nbsp}<a href="{$view:NEW-ACCOUNT-URI}">Create new account</a>
            </form>
            <div class="importantnote">
                <h3>Welcome to SOCIAL(ito)</h3>
                <p>
                    Socialito is a social media dashboard that helps you manage your <a href="http://twitter.com/" target="_blank">Twitter</a>
                    account. You will see all the information
                    you need on one page. It will help you navigate and search through your data. It also
                    helps you focus on people and topics that are important (to you). More background can
                    be found on the <a href="/about.html">About</a> page.
                </p>
                <p>&#160;</p>
                <h3>Important</h3>
                <p>
                    The following screen will open a page from Twitter to Authorise this
                    application access to your personal Twitter account. Your account
                    information will <b>not</b> be stored within this application. Please verify
                    that the Twitter Authorisation page mentions the correct
                    application name ('Socialito') and your <b>own</b> Twitter account.
                </p>
            </div>
            <script>
                $(document).ready(function(){{
                    $("#{$view:USER-PARAM}").focus();
                }});
            </script>
        </div>
    )
};
