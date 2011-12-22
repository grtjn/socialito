module namespace data = 'http://www.socialito.org/lib/data';

import module namespace xqddf = "http://www.zorba-xquery.com/modules/xqddf";  

(: would rather define these externally, but that is not allowed if they
 : are not within import scope, and that would null the effect..
 :)
declare collection data:followers-collection as element()*;
declare collection data:friends-collection as element()*;
declare collection data:hashtags-collection as element()*;
declare collection data:mentions-collection as element()*;
declare collection data:messages-collection as element()*;
declare collection data:tweets-collection as element()*;
declare collection data:urls-collection as element()*;
declare collection data:users-collection as element()*;

(: indexes by user, to speed up paging :)
(:
declare automatically maintained value equality index data:followers
    on nodes xqddf:collection(xs:QName("data:followers-collection"))
    by string(@user) as xs:string;

declare automatically maintained value equality index data:friends
    on nodes xqddf:collection(xs:QName("data:friends-collection"))
    by string(@user) as xs:string;

declare automatically maintained value equality index data:hashtags
    on nodes xqddf:collection(xs:QName("data:hashtags-collection"))
    by string(@user) as xs:string;

declare automatically maintained value equality index data:mentions 
    on nodes xqddf:collection(xs:QName("data:mentions-collection"))
    by string(@user) as xs:string;

declare automatically maintained value equality index data:messages
    on nodes xqddf:collection(xs:QName("data:messages-collection"))
    by string(@user) as xs:string;

declare automatically maintained value equality index data:tweets 
    on nodes xqddf:collection(xs:QName("data:tweets-collection"))
    by string(@user) as xs:string;

declare automatically maintained value equality index data:urls
    on nodes xqddf:collection(xs:QName("data:urls-collection"))
    by string(@user) as xs:string;

declare automatically maintained value equality index data:users
    on nodes xqddf:collection(xs:QName("data:users-collection"))
    by string(@user) as xs:string;
:)

(: indexes by user-key, to speed up individual access :)
(:
declare automatically maintained value equality index data:followers-by-key 
    on nodes xqddf:collection(xs:QName("data:followers-collection"))
    by concat(@user, '-', @key) as xs:string;

declare automatically maintained value equality index data:friends-by-key 
    on nodes xqddf:collection(xs:QName("data:friends-collection"))
    by concat(@user, '-', @key) as xs:string;

declare automatically maintained value equality index data:hashtags-by-key 
    on nodes xqddf:collection(xs:QName("data:hashtags-collection"))
    by concat(@user, '-', @key) as xs:string;

declare automatically maintained value equality index data:mentions-by-key 
    on nodes xqddf:collection(xs:QName("data:mentions-collection"))
    by concat(@user, '-', @key) as xs:string;

declare automatically maintained value equality index data:messages-by-key 
    on nodes xqddf:collection(xs:QName("data:messages-collection"))
    by concat(@user, '-', @key) as xs:string;

declare automatically maintained value equality index data:tweets-by-key 
    on nodes xqddf:collection(xs:QName("data:tweets-collection"))
    by concat(@user, '-', @key) as xs:string;

declare automatically maintained value equality index data:urls-by-key 
    on nodes xqddf:collection(xs:QName("data:urls-collection"))
    by concat(@user, '-', @key) as xs:string;

declare automatically maintained value equality index data:users-by-key 
    on nodes xqddf:collection(xs:QName("data:users-collection"))
    by concat(@user, '-', @key) as xs:string;
:)

(: convenience variables :)
declare variable $data:followers-collection := xs:QName("data:followers-collection");
declare variable $data:friends-collection := xs:QName("data:friends-collection");
declare variable $data:hashtags-collection := xs:QName("data:hashtags-collection");
declare variable $data:mentions-collection := xs:QName("data:mentions-collection");
declare variable $data:messages-collection := xs:QName("data:messages-collection");
declare variable $data:tweets-collection := xs:QName("data:tweets-collection");
declare variable $data:urls-collection := xs:QName("data:urls-collection");
declare variable $data:users-collection := xs:QName("data:users-collection");

declare variable $data:followers := xs:QName("data:followers");
declare variable $data:friends := xs:QName("data:friends");
declare variable $data:hashtags := xs:QName("data:hashtags");
declare variable $data:mentions := xs:QName("data:mentions");
declare variable $data:messages := xs:QName("data:messages");
declare variable $data:tweets := xs:QName("data:tweets");
declare variable $data:urls := xs:QName("data:urls");
declare variable $data:users := xs:QName("data:users");

declare variable $data:followers-by-key := xs:QName("data:followers-by-key");
declare variable $data:friends-by-key := xs:QName("data:friends-by-key");
declare variable $data:hashtags-by-key := xs:QName("data:hashtags-by-key");
declare variable $data:mentions-by-key := xs:QName("data:mentions-by-key");
declare variable $data:messages-by-key := xs:QName("data:messages-by-key");
declare variable $data:tweets-by-key := xs:QName("data:tweets-by-key");
declare variable $data:urls-by-key := xs:QName("data:urls-by-key");
declare variable $data:users-by-key := xs:QName("data:users-by-key");

declare sequential function data:delete-all (
    $collection as xs:QName,
    $user as xs:string
)
    as empty-sequence()
{
    declare $nodes :=
        data:get-all($collection, $user);
    
    xqddf:delete-nodes($collection, $nodes);
};

declare sequential function data:add (
    $collection as xs:QName,
    $user as xs:string,
    $key as xs:string?,
    $sortkey as xs:string?,
    $sortdate as xs:dateTime?,
    $data as element()*
)
    as empty-sequence()
{
    declare $last-modified := current-dateTime();
    declare $data-xml :=
        <data user="{$user}" key="{$key}" last-modified="{string($last-modified)}" sortkey="{$sortkey}" sortdate="{string($sortdate)}">{$data}</data>;
    
    xqddf:insert-nodes($collection, $data-xml);
};

declare sequential function data:delete (
    $collection as xs:QName,
    $user as xs:string,
    $keys as xs:string*
)
    as empty-sequence()
{
    declare $data :=
        data:get($collection, $user, $keys);
    
    xqddf:delete-nodes($collection, $data);
};

declare function data:get-last-modified-item (
    $collection as xs:QName,
    $user as xs:string
)
    as element()*
{
    let $data :=
        data:get-all($collection, $user)
    return (
        for $i in $data
        order by $i/@last-modified descending
        return
            $i
    )[1]
};

declare function data:get-last-item (
    $collection as xs:QName,
    $user as xs:string
)
    as element()*
{
    let $data :=
        data:get-all($collection, $user)
    return (
        for $i in $data
        order by $i/@sortkey descending
        return
            $i
    )[1]
};

declare function data:get-latest-item (
    $collection as xs:QName,
    $user as xs:string
)
    as element()*
{
    let $data :=
        data:get-all($collection, $user)
    return (
        for $i in $data
        order by $i/@sortdate descending
        return
            $i
    )[1]
};

declare function data:get (
    $collection as xs:QName,
    $user as xs:string,
    $keys as xs:string*
)
    as element()*
{
    if (not($keys)) then
        data:get-all($collection, $user)
        
    else if ($collection eq $data:hashtags-collection) then
        xqddf:collection($data:hashtags-collection)[@user eq $user][@key = $keys]
        (:
        for $key in $keys
        return
            xqddf:probe-index-point($data:hashtags-by-key, concat($user, '-', $key))
        :)

    else if ($collection eq $data:mentions-collection) then
        xqddf:collection($data:mentions-collection)[@user eq $user][@key = $keys]
        (:
        for $key in $keys
        return
            xqddf:probe-index-point($data:mentions-by-key, concat($user, '-', $key))
        :)

    else if ($collection eq $data:urls-collection) then
        xqddf:collection($data:urls-collection)[@user eq $user][@key = $keys]
        (:
        for $key in $keys
        return
            xqddf:probe-index-point($data:urls-by-key, concat($user, '-', $key))
        :)

    else if ($collection eq $data:users-collection) then
        xqddf:collection($data:users-collection)[@user eq $user][@key = $keys]
        (:
        for $key in $keys
        return
            xqddf:probe-index-point($data:users-by-key, concat($user, '-', $key))
        :)

    else if ($collection eq $data:followers-collection) then
        xqddf:collection($data:followers-collection)[@user eq $user][@key = $keys]
        (:
        for $key in $keys
        return
            xqddf:probe-index-point($data:followers-by-key, concat($user, '-', $key))
        :)

    else if ($collection eq $data:friends-collection) then
        xqddf:collection($data:friends-collection)[@user eq $user][@key = $keys]
        (:
        for $key in $keys
        return
            xqddf:probe-index-point($data:friends-by-key, concat($user, '-', $key))
        :)

    else if ($collection eq $data:messages-collection) then
        xqddf:collection($data:messages-collection)[@user eq $user][@key = $keys]
        (:
        for $key in $keys
        return
            xqddf:probe-index-point($data:messages-by-key, concat($user, '-', $key))
        :)

    else if ($collection eq $data:tweets-collection) then
        xqddf:collection($data:tweets-collection)[@user eq $user][@key = $keys]
        (:
        for $key in $keys
        return
            xqddf:probe-index-point($data:tweets-by-key, concat($user, '-', $key))
        :)

    else
        error(xs:QName("NO-KEY-INDEX"), concat("No key index for collection ", $collection))
};

declare function data:get-all (
    $collection as xs:QName,
    $user as xs:string
)
    as element()*
{
    if ($collection eq $data:hashtags-collection) then
        xqddf:collection($data:hashtags-collection)[@user eq $user]
        (:
        xqddf:probe-index-point($data:hashtags, $user)
        :)

    else if ($collection eq $data:mentions-collection) then
        xqddf:collection($data:mentions-collection)[@user eq $user]
        (:
        xqddf:probe-index-point($data:mentions, $user)
        :)

    else if ($collection eq $data:urls-collection) then
        xqddf:collection($data:urls-collection)[@user eq $user]
        (:
        xqddf:probe-index-point($data:urls, $user)
        :)

    else if ($collection eq $data:tweets-collection) then
        xqddf:collection($data:tweets-collection)[@user eq $user]
        (:
        xqddf:probe-index-point($data:tweets, $user)
        :)

    else if ($collection eq $data:messages-collection) then
        xqddf:collection($data:messages-collection)[@user eq $user]
        (:
        xqddf:probe-index-point($data:messages, $user)
        :)

    else if ($collection eq $data:friends-collection) then
        xqddf:collection($data:friends-collection)[@user eq $user]
        (:
        xqddf:probe-index-point($data:friends, $user)
        :)

    else if ($collection eq $data:followers-collection) then
        xqddf:collection($data:followers-collection)[@user eq $user]
        (:
        xqddf:probe-index-point($data:followers, $user)
        :)

    else if ($collection eq $data:users-collection) then
        xqddf:collection($data:users-collection)[@user eq $user]
        (:
        xqddf:probe-index-point($data:users, $user)
        :)

    else
        error(xs:QName("NO-INDEX"), concat("No index for collection ", $collection))
};

declare function data:get-paged (
    $collection as xs:QName,
    $user as xs:string,
    $start as xs:integer,
    $end as xs:integer
)
    as element()*
{
    if ($collection eq $data:hashtags-collection) then
        xqddf:collection($data:hashtags-collection)[@user eq $user][position() = ($start to $end)]
        (:
        xqddf:probe-index-point($data:hashtags, $user)[position() = ($start to $end)]
        :)

    else if ($collection eq $data:mentions-collection) then
        xqddf:collection($data:mentions-collection)[@user eq $user][position() = ($start to $end)]
        (:
        xqddf:probe-index-point($data:mentions, $user)[position() = ($start to $end)]
        :)

    else if ($collection eq $data:urls-collection) then
        xqddf:collection($data:urls-collection)[@user eq $user][position() = ($start to $end)]
        (:
        xqddf:probe-index-point($data:urls, $user)[position() = ($start to $end)]
        :)

    else if ($collection eq $data:tweets-collection) then
        xqddf:collection($data:tweets-collection)[@user eq $user][position() = ($start to $end)]
        (:
        xqddf:probe-index-point($data:tweets, $user)[position() = ($start to $end)]
        :)

    else if ($collection eq $data:messages-collection) then
        xqddf:collection($data:messages-collection)[@user eq $user][position() = ($start to $end)]
        (:
        xqddf:probe-index-point($data:messages, $user)[position() = ($start to $end)]
        :)

    else if ($collection eq $data:friends-collection) then
        xqddf:collection($data:friends-collection)[@user eq $user][position() = ($start to $end)]
        (:
        xqddf:probe-index-point($data:friends, $user)[position() = ($start to $end)]
        :)

    else if ($collection eq $data:followers-collection) then
        xqddf:collection($data:followers-collection)[@user eq $user][position() = ($start to $end)]
        (:
        xqddf:probe-index-point($data:followers, $user)[position() = ($start to $end)]
        :)

    else
        error(xs:QName("NO-INDEX"), concat("No index for collection ", $collection))
};

declare function data:get-date-sorted (
    $collection as xs:QName,
    $user as xs:string,
    $keys as xs:string*
)
    as element()*
{
    for $i in
        data:get($collection, $user, $keys)
    order by $i/@sortdate descending
    return
        $i
};

declare function data:get-key-sorted (
    $collection as xs:QName,
    $user as xs:string,
    $keys as xs:string*
)
    as element()*
{
    for $i in
        data:get($collection, $user, $keys)
    order by $i/@sortkey ascending
    return
        $i
};

declare function data:get-all-date-sorted (
    $collection as xs:QName,
    $user as xs:string
)
    as element()*
{
    for $i in
        data:get-all($collection, $user)
    order by $i/@sortdate descending
    return
        $i
};

declare function data:get-all-key-sorted (
    $collection as xs:QName,
    $user as xs:string
)
    as element()*
{
    for $i in
        data:get-all($collection, $user)
    order by $i/@sortkey ascending
    return
        $i
};

declare function data:get-facets (
    $collection as xs:QName,
    $user as xs:string,
    $include-values as xs:boolean?
)
    as element()*
{
    let $all := data:get-all($collection, $user) 
    let $keys := distinct-values($all/@key)
    for $key in $keys
    let $values := data:get($collection, $user, $key)
    let $count := count($values)
    order by $count descending, $key ascending
    return
        <facet key="{$key}" sortkey="{$values[1]/@sortkey}" score="{$count}">{
            if (boolean($include-values)) then
                $values
            else ()
        }</facet>
};

declare function data:get-total (
    $collection as xs:QName,
    $user as xs:string
)
    as xs:integer
{
    count(data:get-all($collection, $user))
};

declare function data:get-total (
    $collection as xs:QName,
    $user as xs:string,
    $keys as xs:string*
)
    as xs:integer
{
    count(data:get($collection, $user, $keys))
};
