module namespace sess = 'http://www.socialito.org/lib/models/session';

import module namespace acco="http://www.socialito.org/lib/models/account";
import module namespace http="http://www.28msec.com/modules/http";
import module namespace rand="http://www.28msec.com/modules/random";
import module namespace secu="http://www.28msec.com/modules/security";
import module namespace xqddf="http://www.zorba-xquery.com/modules/xqddf";

declare collection sess:sessions-collection as element(session)*;

declare variable $sess:sessions-collection as xs:QName :=
    xs:QName("sess:sessions-collection");

declare variable $sess:session-duration as xs:duration :=
    xs:duration("PT10M");

declare function sess:is-logged-in (
)
    as xs:boolean
{
    let $session-user as xs:string? :=
        sess:get-session-user()
    let $session-data as element(account)? :=
        if ($session-user) then
            acco:get-account-data($session-user)
        else ()
    return
        exists($session-data)
};

declare function sess:is-expired (
)
    as xs:boolean
{
    let $session-timeout as xs:dateTime? :=
        sess:get-session-timeout()
    return
        not(exists($session-timeout[. ge fn:current-dateTime()]))
};

declare sequential function sess:login (
    $user as xs:string?,
    $pass as xs:string?
)
    as empty-sequence()
{
    if (not(exists($user) and exists($pass))) then
        error(xs:QName("MISSING-CREDENTIALS"), "Please enter credentials")
    else
        ();
    
    if (not(acco:account-exists($user))) then
        error(xs:QName("UNKNOWN-ACCOUNT"), concat("Account ", $user, " doesn't exist"))
    else
        ();
    
    if (not(acco:validate-credentials($user, $pass))) then
        error(xs:QName("INVALID-CREDENTIALS"), "Invalid credentials")
    else
        ();
    
    sess:logout();
    
    sess:create-session-data($user);
};

declare sequential function sess:refresh (
)
    as empty-sequence()
{
    declare $new-session-timeout as xs:dateTime :=
        fn:current-dateTime() + $sess:session-duration;
    declare $session-data as element(session)? :=
        sess:get-session-data();

    if ($session-data) then
        replace value of node
            $session-data/timeout
        with
            $new-session-timeout
    else
        error(xs:QName("NO-SESSION"), "Should not be reached!")
};

declare sequential function sess:logout (
)
{
    sess:delete-session()
};  

(:
 : Handling session data
 :)

declare sequential function sess:create-session-data (
    $user as xs:string
)
    as empty-sequence()
{
    declare $session-timeout as xs:dateTime :=
        fn:current-dateTime() + $sess:session-duration;
    declare $id :=
        rand:random-string(xs:unsignedInt(16));
    
    sess:create-session-cookie($id);

    xqddf:insert-nodes(
        $sess:sessions-collection,
        <session id="{$id}">
            <user>{$user}</user>
            <timeout>{$session-timeout}</timeout>
            <extra></extra>
        </session>
    );
};

declare function sess:get-session-user (
)
    as xs:string?
{
    (: fails if session cookie doesn't validate :)
    let $session-data :=
        sess:get-session-data()
    return
        $session-data/user
};

declare function sess:get-session-timeout (
)
    as xs:dateTime?
{
    (: fails if session cookie doesn't validate :)
    let $session-data :=
        sess:get-session-data()
    return
        $session-data//timeout
};

declare function sess:get-session-data (
)
    as element(session)?
{
    (: fails if session cookie doesn't validate :)
    let $session-id as xs:string? :=
        sess:get-session-id()
    return
        sess:get-all()[@id eq $session-id]
};

declare sequential function sess:add-session-data (
    $key as xs:string,
    $value as item()*
)
{
    declare $session-data :=
        sess:get-session-data();

    if ($session-data) then
        insert node
            element {$key} {$value}
        as last into
            $session-data/extra
    else
        error(xs:QName("NO-SESSION"), "Should not be reached!")
};

declare sequential function sess:delete-session-data (
    $key as xs:string,
    $value as item()*
)
{
    declare $session-data :=
        sess:get-session-data();
        
    if (not(exists($session-data))) then
        (: ignore silently?
        error(xs:QName("SESSION-NOT-FOUND"), "Session doesn't exist")
        :)
        exit returning ()
    else
        ();

    delete node
        $session-data/extra/*[local-name() eq $key][empty($value) or ($value eq .)];
};

declare sequential function sess:delete-session (
)
    as empty-sequence()
{
    declare $session-data :=
        sess:get-session-data();
        
    sess:delete-session-cookie();

    xqddf:delete-nodes(
        $sess:sessions-collection,
        $session-data
    );
};

(:
 : Handling session cookie
 :)

declare sequential function sess:create-session-cookie (
    $id as xs:string
)
    as empty-sequence()
{
    declare $session :=
        <session id="{$id}"/>;
    declare $sign :=
        secu:ssign($session);

    (:
    http:create-session(
        $session
    );
    :)
    http:set-cookie(
        <cookie
            name="_session"
            path="/">
            <session signature="{$sign}" path="/">{
                $session
            }</session>
        </cookie>
    )
};

declare function sess:get-session-id (
)
    as xs:string?
{
    if (http:validate-session()) then
        (http:get-cookie("_session")//session[not(session)])[1]/@id
    else
        ()
};

declare sequential function sess:delete-session-cookie (
)
    as empty-sequence()
{
    (:
    http:delete-session();
    :)
    http:set-cookie(
        <cookie
            name="_session"
            path="/">
        </cookie>
    );
};

declare function sess:get-all (
)
    as element(session)*
{
    xqddf:collection($sess:sessions-collection)
};

declare sequential function sess:clear-all (
)
    as empty-sequence()
{
    xqddf:delete-nodes($sess:sessions-collection, xqddf:collection($sess:sessions-collection));
};
