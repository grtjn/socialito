module namespace html = 'http://www.socialito.org/lib/html';

(:
 : HTML utility library
 :
 : Module with helper functions for quickly generating general HTML patterns
 :)

import module namespace functx="http://www.functx.com";
import module namespace ser="http://www.28msec.com/modules/serialize";

(: only used for debug info! :)
import module namespace util="http://www.socialito.org/lib/util";

declare variable $html:APP-NAME as xs:string := "Socialito";
declare variable $html:APP-VERSION as xs:string := "2010";

declare variable $html:nbsp as xs:string := codepoints-to-string(160);

declare function html:footer()
    as element(footer)
{
    <footer>
        <p>
            (c) 2010 SOCIAL(ito) - <a href="/about.html">About SOCIAL(ito)</a> - Built with: 
            <a href="http://www.28msec.com" target="_blank"><img src="http://download.28msec.com/images/button_28_sausalito.png" alt="Built with Sausalito" /></a>
            <a href="http://www.28msec.com" target="_blank"><img src="http://download.28msec.com/images/button_w3c_xquery.png" alt="100% XQuery" /></a>
        </p>
        <div style="display:none">{
            (: debug info! :)
            (: util:get-request-context() :)
            ()
        }</div>
    </footer>
};

declare function html:format-2-column-page (
    $title as xs:string,
    $error as item()*,
    $column1-contents as item()*,
    $column2-contents as item()*,
    $below-contents as item()*
)
    as element(html)
{
    let $dummy-contents := <li>{$html:nbsp}</li>
    return 
    html:format-page(
        $title,
        $error,
        <div id="columns" class="two-columns">
            <ul id="column1-2" class="column">
                { 
                if (exists($column1-contents)) then
                    $column1-contents
                else
                    $dummy-contents
                }
            </ul>
            <ul id="column2-2" class="column">
                { 
                if (exists($column2-contents)) then
                    $column2-contents
                else
                    $dummy-contents
                }
            </ul>
            {
            if (exists($below-contents)) then
                <ul id="column-below" class="column">
                    { $below-contents }
                </ul>
            else ()
            }
        </div>
    )
};



declare function html:format-4-column-page (
    $title as xs:string,
    $error as item()*,
    $column1-contents as item()*,
    $column2-contents as item()*,
    $column3-contents as item()*,
    $column4-contents as item()*
)
    as element(html)
{
    let $dummy-contents := <li>{$html:nbsp}</li>
    return 
    html:format-page(
        $title,
        $error,
        <div id="columns">
            <ul id="column1" class="column">
                { 
                if (exists($column1-contents)) then
                    $column1-contents
                else
                    $dummy-contents
                }
            </ul>
            <ul id="column2" class="column">
                { 
                if (exists($column2-contents)) then
                    $column2-contents
                else
                    $dummy-contents
                }
            </ul>
            <ul id="column3" class="column">
                { 
                if (exists($column3-contents)) then
                    $column3-contents
                else
                    $dummy-contents
                }
            </ul>
            <ul id="column4" class="column">
                { 
                if (exists($column4-contents)) then
                    $column4-contents
                else
                    $dummy-contents
                }
            </ul>            
        </div>
    )
};

declare function html:format-page (
    $title as xs:string,
    $error as item()*,
    $contents as item()*
)
    as element(html)
{
    (: Set (alternative) HTML5 DOCTYPE! :)
    ser:set-doctype-system("about:legacy-compat"),

    <html>
        { html:head($title) }
        <body>
            <div id="container">
                {
                    html:header(),
                    $error,
                    $contents,
                    html:footer()
                }
            </div>
            <!-- Initialize widgets! -->            
            <script src="/scripts/inettuts.js"></script>
        </body>
    </html>
};

declare function html:head (
    $title as xs:string
)
    as element(head)
{
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/> 
        <title>{$title} - {$html:APP-NAME} - {$html:APP-VERSION}</title>
        <meta name="keywords" content="" /> 
        <meta name="description" content="" /> 
        <link rel="stylesheet" type="text/css" href="/styles/reset.css" /> 
        <link rel="stylesheet" type="text/css" href="/styles/main.css" /> 
        <link rel="stylesheet" type="text/css" href="/styles/jquery.calendarPicker.css" />
        <link rel="stylesheet" type="text/css" href="/styles/inettuts.js.css" /> 
        <!--[if lt IE 7]>
        <link rel="stylesheet" type="text/css" media="all" href="/styles/ie6.css"/>
        <![endif]-->
        <script src="/scripts/jquery-1.4.2.min.js"></script>
        <script src="/scripts/jquery-ui-1.8.5.custom.min.js"></script>
        <script src="/scripts/jquery.charcount.js"></script>
        <script src="/scripts/jquery.color.js"></script>
        <script src="/scripts/jquery.tagcloud.min.js"></script>
        <script src="/scripts/jquery.easing.1.3.js"></script>
        <!--[if IE]>
        <script src="/scripts/html5.js"></script>
        <![endif]--> 
        <!--[if lte IE 7]>
        <script src="/scripts/ie.js"></script>
        <![endif]--> 
        <!-- scripts --> 
        <script src="/scripts/init.js"></script> 
    </head>
};

declare function html:header ()
    as element(header)
{
    <header id="page-header">
        <h1 id="logo"><a href="/"><span>SOCIAL(ito)</span></a></h1>
    </header>
};

declare function html:widget(
    $id as xs:string,
    $title as xs:string,
    $status as xs:string,
    $class as xs:string,    
    $color as xs:string,
    $contents as item()*
)
    as element(li)
{
    <li class="widget {$class} color-{$color} {$status}" id="{$id}">
        <div class="widget-head"><h3>{$title}</h3></div>
        <div class="widget-content">
            {
                $contents
            }
        </div>
    </li>
};
