module namespace admin = 'http://www.socialito.org/admin';

declare ordering ordered;

import module namespace dctx="http://www.zorba-xquery.com/modules/introspection/dctx";
import module namespace http="http://www.28msec.com/modules/http";
import module namespace sctx="http://www.zorba-xquery.com/modules/introspection/sctx";
import module namespace ser="http://www.zorba-xquery.com/modules/serialize";
import module namespace xqddf="http://www.zorba-xquery.com/modules/xqddf";

import module namespace data="http://www.socialito.org/lib/data";
import module namespace util="http://www.socialito.org/lib/util";
import module namespace tapi="http://www.socialito.org/lib/twitter";

import module namespace acco="http://www.socialito.org/lib/models/account";
import module namespace sess="http://www.socialito.org/lib/models/session";
import module namespace twit="http://www.socialito.org/lib/models/twitter";
import module namespace tweet="http://www.socialito.org/lib/models/tweet";

import module namespace oauth="http://www.28msec.com/modules/oauth/client";

declare variable $admin:xml-output :=
    <output
        method="xml" 
        version="1.0"
        encoding="UTF-8" 
        omit-xml-declaration="yes"
        standalone="yes"
        cdata-section-elements=""
        indent="yes"
        media-type=""/>;

declare sequential function admin:test ()
{
    put(<html><body>Hello world!</body></html>, "http://www.socialito.org/test/test.xml");
    collection("http://www.socialito.org/test/test.xml");
};

declare sequential function admin:index ()
{
    let $context := util:get-request-context()
    return
    <html>
        <body>
            <h1>Accounts management</h1>
            <h3>Context</h3>
            <p>{ eval { "oauth:timestamp()" }, trace("test", "test") }</p>
            <pre>{ser:serialize($context, $admin:xml-output)}</pre>
            <h3>Actions</h3>
            <ul>
                <li><a href="/admin/list-accounts">List all accounts</a></li>
                <li><a href="/admin/clear-accounts">Clear all accounts</a></li>
                <li><a href="/admin/list-sessions">List all sessions</a></li>
                <li><a href="/admin/clear-sessions">Clear all sessions</a></li>
                <li><a href="/admin/explore-database">Explore database</a></li>
                <li><a href="/admin/clear-database" onclick="return confirm('Are you sure? This cannot be undone!!!');">Clear database</a></li>
                <li><a href="/admin/test-twitter">Test Twitter</a></li>
            </ul>
            <p>{ eval { "oauth:timestamp()" }, trace("test", "test") }</p>
        </body>
    </html>
};

declare sequential function admin:list-accounts ()
{
    <html>
        <body>
            <h1>Accounts</h1>
            <a href="/admin/index">Back to management</a>
            {
                let $accounts :=
                    acco:get-all()
                return
                    <ul>
                        <b>{count($accounts)} accounts</b>
                    {
                        for $account in $accounts
                        let $user as xs:string := string($account/user)
                        return
                            <li><pre>{ser:serialize($account, $admin:xml-output)}</pre></li>
                    }</ul>
            }
        </body>
    </html>
};

declare sequential function admin:clear-accounts ()
{
    acco:clear-all();
    
    <html>
        <body>
            <h1>Accounts cleared succesfully</h1>
            <a href="/admin/index">Back to management</a>
        </body>
    </html>;
};

declare sequential function admin:list-sessions ()
{
    <html>
        <body>
            <h1>Sessions</h1>
            <a href="/admin/index">Back to management</a>
            {
                let $sessions :=
                    sess:get-all()
                return
                    <ul>
                        <b>{count($sessions)} sessions</b>
                    {
                        for $session in $sessions
                        return
                            <li><pre>{ser:serialize($session, $admin:xml-output)}</pre></li>
                    }</ul>
            }
        </body>
    </html>
};

declare sequential function admin:clear-sessions ()
{
    sess:clear-all();
    
    <html>
        <body>
            <h1>Sessions cleared succesfully</h1>
            <a href="/admin/index">Back to management</a>
        </body>
    </html>;
};

declare sequential function admin:clear-database ()
{
    for $collection in sctx:declared-collections()
        return xqddf:delete-nodes($collection, xqddf:collection($collection));

    <html>
        <body>
            <h1>Database cleared succesfully</h1>
            <h2>(Op hoop van zegen)</h2>
            <a href="/admin/index">Back to management</a>
        </body>
    </html>;
};

declare function admin:explore-database ()
{
    <html>
        <head>
            <style>
                tr {{ text-align: left; }}
                td {{ vertical-align: top; }}
                td.nowrap {{ white-space: nowrap; }}
            </style>
        </head>
        <body>
            <h1>Explore database</h1>
            <a href="/admin/index">Back to management</a>
            <h3>Details</h3>
            <table>
                <tr><th>Property</th><th>Value</th></tr>
                <tr><td class="nowrap">base-uri</td><td>{sctx:base-uri()}</td></tr>
                <tr><td class="nowrap">boundary-space-policy</td><td>{sctx:boundary-space-policy()}</td></tr>
                <tr><td class="nowrap">construction-mode</td><td>{sctx:construction-mode()}</td></tr>
                <tr><td class="nowrap">copy-namespaces-mode</td><td>{string-join(sctx:copy-namespaces-mode(), ", ")}</td></tr>
                <tr><td class="nowrap">declared-collections</td><td>{string-join(for $i in sctx:declared-collections() return string($i), ", ")}</td></tr>
                <tr><td class="nowrap">declared-indexes</td><td>{string-join(for $i in sctx:declared-indexes() return string($i), ", ")}</td></tr>
                <tr><td class="nowrap">declared-integrity-constraints</td><td>{string-join(for $i in sctx:declared-integrity-constraints() return string($i), ", ")}</td></tr>
                <tr><td class="nowrap">default-collation</td><td>{sctx:default-collation()}</td></tr>
                <tr><td class="nowrap">default-collection-type</td><td>{sctx:default-collection-type()}</td></tr>
                <tr><td class="nowrap">default-function-namespace</td><td>{sctx:default-function-namespace()}</td></tr>
                <tr><td class="nowrap">default-order</td><td>{sctx:default-order()}</td></tr>
                <tr><td class="nowrap">function-names</td><td>{string-join(for $i in sctx:function-names() return string($i), ", ")}</td></tr>
                <tr><td class="nowrap">in-scope-attribute-declarations</td><td>{string-join(for $i in sctx:in-scope-attribute-declarations() return string($i), ", ")}</td></tr>
                <tr><td class="nowrap">in-scope-attribute-groups</td><td>{string-join(for $i in sctx:in-scope-attribute-groups() return string($i), ", ")}</td></tr>
                <tr><td class="nowrap">in-scope-element-declarations</td><td>{string-join(for $i in sctx:in-scope-element-declarations() return string($i), ", ")}</td></tr>
                <tr><td class="nowrap">in-scope-element-groups</td><td>{string-join(for $i in sctx:in-scope-element-groups() return string($i), ", ")}</td></tr>
                <tr><td class="nowrap">in-scope-schema-types</td><td>{string-join(for $i in sctx:in-scope-schema-types() return string($i), ", ")}</td></tr>
                <tr><td class="nowrap">in-scope-variables</td><td>{string-join(for $i in sctx:in-scope-variables() return string($i), ", ")}</td></tr>
                <tr><td class="nowrap">ordering-mode</td><td>{sctx:ordering-mode()}</td></tr>
                <tr><td class="nowrap">statically-known-collations</td><td>{string-join(for $i in sctx:statically-known-collations() return string($i), ", ")}</td></tr>
                <tr><td class="nowrap">statically-known-documents</td><td>{string-join(for $i in sctx:statically-known-documents() return string($i), ", ")}</td></tr>
                <tr><td class="nowrap">statically-known-namespaces</td><td>{string-join(sctx:statically-known-namespaces(), ", ")}</td></tr> 
                <tr><td class="nowrap">xpath10-compatibility-mode</td><td>{sctx:xpath10-compatibility-mode()}</td></tr>
            </table>
            <h3>Integrity contraints</h3>
            <ul>{
                let $items := sctx:declared-integrity-constraints()
                return
                    if (exists($items)) then
                        for $i in $items
                        return
                            <li>{$i}</li>
                    else
                        <li><i>(no integrity constraints)</i></li>
            }</ul>
            <h3>Collections</h3>
            <ul>{
                let $items := (sctx:declared-collections())
                return
                    if (exists($items)) then
                        for $i in $items
                        let $available := dctx:is-available-collection($i)
                        return
                            if ($available) then
                                <li><a href="/admin/explore-collection?name={$i}">{$i}</a></li>
                            else
                                <li>{$i}</li>
                    else
                        <li><i>(no collections)</i></li>
            }</ul>
            <h3>Indexes</h3>
            <ul>{
                let $items := sctx:declared-indexes()
                return
                    if (exists($items)) then
                        for $i in $items
                        let $available := dctx:is-available-index($i)
                        return
                            if ($available) then
                                <li><a href="/admin/explore-index?name={$i}">{$i}</a></li>
                            else
                                <li>{$i}</li>
                    else
                        <li><i>(no indexes)</i></li>
            }</ul>
        </body>
    </html>

(: TODO:

dctx:
 activated-integrity-constraints() as xs:QName* 
 available-collections() as xs:QName* 
 available-indexes() as xs:QName* 
 is-activated-integrity-constraint($name as xs:QName) as xs:boolean 
 is-available-collection($name as xs:QName) as xs:boolean 
 is-available-index($name as xs:QName) as xs:boolean 

sctx:
 function-arguments-count($function as xs:QName) as xs:int* 
 function-names() as xs:QName* 
 in-scope-attribute-declarations() as xs:QName* 
 in-scope-attribute-groups() as xs:QName* 
 in-scope-element-declarations() as xs:QName* 
 in-scope-element-groups() as xs:QName* 
 in-scope-schema-types() as xs:QName* 
 in-scope-variables() as xs:QName* 
 is-declared-collection($name as xs:QName) as xs:boolean 
 is-declared-index($name as xs:QName) as xs:boolean 
 is-declared-integrity-constraint($name as xs:QName) as xs:boolean 
 option($name as xs:QName) as xs:string? 
 ordering-mode() as xs:string 
 statically-known-collations() as xs:anyURI* 
 statically-known-document-type($document as xs:string) as xs:QName 
 statically-known-documents() as xs:anyURI* 
 statically-known-namespace-binding($prefix as xs:string) as xs:string? 
 statically-known-namespaces() as xs:string* 
 xpath10-compatibility-mode() as xs:boolean 


sctx:
 base-uri() as xs:string? 
 boundary-space-policy() as xs:string 
 construction-mode() as xs:string 
 copy-namespaces-mode() as xs:string+ 
 declared-collections() as xs:QName* 
 declared-indexes() as xs:QName* 
 declared-integrity-constraints() as xs:QName* 
 default-collation() as xs:string 
 default-collection-type() as xs:string 
 default-function-namespace() as xs:string 
 default-order() as xs:string 
 function-arguments-count($function as xs:QName) as xs:int* 
 function-names() as xs:QName* 
 in-scope-variables() as xs:QName* 
 is-declared-collection($name as xs:QName) as xs:boolean 
 is-declared-index($name as xs:QName) as xs:boolean 
 is-declared-integrity-constraint($name as xs:QName) as xs:boolean 
 ordering-mode() as xs:string 
 statically-known-collations() as xs:anyURI* 
 statically-known-documents($uri as xs:string) as xs:QName 
 statically-known-namespace-binding($prefix as xs:string) as xs:string? 
 statically-known-namespaces() as xs:string* 
 xpath10-compatibility-mode() as xs:boolean 

:)
};

declare function admin:explore-collection ()
{
    let $name := http:get-parameters("name")
    let $name := element { $name } {}
    let $name := node-name($name)
    return
    <html>
        <body>
            <h1>Explore collection</h1>
            <a href="/admin/explore-database">Back to database</a>
            <h3>Collection {$name}</h3>
            <ul>{
				if ($name eq xs:QName("data:messages-collection")) then
                    <li><i>(no nodes)</i></li>
				else
					let $items := xqddf:collection($name)
					return
						if (exists($items)) then
							for $i in $items
							return
								<li><pre>{ser:serialize($i, $admin:xml-output)}</pre></li>
						else
							<li><i>(no nodes)</i></li>
            }</ul>
        </body>
    </html>
};

declare sequential function admin:test-twitter ()
{
    declare $user := sess:get-session-user();
    declare $last-id as xs:string? := if (exists($user)) then (tweet:get-last($user)/*/id/string())[1] else ();
    declare $since as xs:string? :=
        if (exists($last-id)) then
            concat("since_id=", $last-id)
        else
            ();

    declare $items :=
            (:
            twit:get-paged-cached-tweets($user, 1, 10);
            :)
            tapi:get-resource ($tapi:STAT_USER_TL, 1, "user_id=187980079&amp;count=200&amp;include_rts=true&amp;include_entities=true&amp;contributor_details=true"); (:socialito_2011:)
    <html>
        <body>
            <h1>Test Twitter</h1>
            <a href="/admin/index">Back to management</a>
            <h3>Input</h3>
            <ul>
                <li><i>{$since}</i></li>
            </ul>
            <h3>Response</h3>
            <ul>{
                if (exists($items)) then
                    for $i in $items
                    return
                        <li><pre>{ser:serialize($i, $admin:xml-output)}</pre></li>
                else
                    <li><i>(no messages)</i></li>
            }</ul>
        </body>
    </html>
};

