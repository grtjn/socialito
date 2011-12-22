module namespace acco = 'http://www.socialito.org/lib/models/account';

import module namespace rand="http://www.28msec.com/modules/random";
import module namespace secu="http://www.28msec.com/modules/security";
import module namespace xqddf = "http://www.zorba-xquery.com/modules/xqddf";  

declare collection acco:accounts-collection as element(account)*;
declare variable $acco:accounts-collection := xs:QName("acco:accounts-collection");  

declare function acco:account-exists (
    $user as xs:string
)
    as xs:boolean
{
    exists(acco:get-account-data($user))
};

declare sequential function acco:create-account (
    $user as xs:string?,
    $pass as xs:string?,
    $pass2 as xs:string?
)
    as empty-sequence()
{
    declare $id as xs:string :=
        rand:random-string(xs:unsignedInt(16));
    declare $signed-pass as xs:string :=
        secu:ssign(<pass>{$pass}</pass>);
    
    if (not(exists($user) and exists($pass) and exists($pass2))) then
        error(xs:QName("MISSING-DETAILS"), "Please enter missing details")
    else
        ();
    
    if (not($pass = $pass2)) then
        error(xs:QName("PASSWORD-MISMATCH"), concat("Password ", $pass, " doesn't match ", $pass2, ", please retry"))
    else
        ();
    
    if (acco:account-exists($user)) then
        error(xs:QName("ACCOUNT-EXISTS"), concat("Account ", $user, " already exists"))
    else
        ();

    xqddf:insert-nodes(
        $acco:accounts-collection,
        <account id="{$id}">
            <user>{$user}</user>
            <pass>{$signed-pass}</pass>
            <extra></extra>
        </account>
    );
};

declare sequential function acco:delete-account (
    $user as xs:string
)
    as empty-sequence()
{
    declare $account-data :=
        acco:get-account-data($user);
        
    xqddf:delete-nodes(
        $acco:accounts-collection,
        $account-data
    );
};

declare function acco:validate-credentials (
    $user as xs:string,
    $pass as xs:string
)
    as xs:boolean
{
    let $account-data :=
        acco:get-account-data($user)
    let $signed-pass :=
        secu:ssign(<pass>{$pass}</pass>)
    return
        string($account-data/pass) eq $signed-pass
};

declare function acco:get-account-data (
    $user as xs:string
)
    as element(account)?
{
    acco:get-all()[user eq $user]
};

declare sequential function acco:add-account-data (
    $user as xs:string,
    $key as xs:string,
    $value as item()*
)
{
    declare $account-data :=
        acco:get-account-data($user);
        
    if (not(exists($account-data))) then
        error(xs:QName("ACCOUNT-NOT-FOUND"), concat("Account ", $user, " doesn't exist"))
    else
        ();

    insert node
        element {$key} {$value}
    as last into
        $account-data/extra;
};

declare sequential function acco:update-account-data (
    $user as xs:string,
    $key as xs:string,
    $value as item()*
)
{
    declare $account :=
        acco:get-account-data($user);
    declare $account-data :=
        $account/extra/*[local-name() eq $key];
        
    if (not(exists($account))) then
        error(xs:QName("ACCOUNT-NOT-FOUND"), concat("Account ", $user, " doesn't exist"))
    else
        ();

    if (exists($account-data)) then
        replace node
            $account-data
        with
            element {$key} {$value}
    else
        insert node
            element {$key} {$value}
        as last into
            $account/extra;
};

declare sequential function acco:delete-account-data (
    $user as xs:string,
    $key as xs:string,
    $value as item()*
)
{
    declare $account-data :=
        acco:get-account-data($user);
        
    if (not(exists($account-data))) then
        error(xs:QName("ACCOUNT-NOT-FOUND"), concat("Account ", $user, " doesn't exist"))
    else
        ();

    delete node
        $account-data/extra/*[local-name() eq $key][empty($value) or ($value eq .)];
};

declare function acco:get-all (
)
    as element(account)*
{
    xqddf:collection($acco:accounts-collection)
};

declare sequential function acco:clear-all (
)
    as empty-sequence()
{
    xqddf:delete-nodes($acco:accounts-collection, xqddf:collection($acco:accounts-collection));
};
