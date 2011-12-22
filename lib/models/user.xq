module namespace user = 'http://www.socialito.org/lib/models/user';

import module namespace data = "http://www.socialito.org/lib/data";  
import module namespace util = "http://www.socialito.org/lib/util";  

declare function user:get-paged-friends (
    $user as xs:string,
    $start as xs:integer,
    $end as xs:integer
)
    as element()*
{
    data:get-all-key-sorted($data:friends-collection, $user)[position() = ($start to $end)];
};

declare function user:get-paged-followers (
    $user as xs:string,
    $start as xs:integer,
    $end as xs:integer
)
    as element()*
{
    data:get-all-key-sorted($data:followers-collection, $user)[position() = ($start to $end)];
};

declare function user:get-total-friends (
    $user as xs:string
)
    as xs:integer
{
    data:get-total($data:friends-collection, $user);
};

declare function user:get-total-followers (
    $user as xs:string
)
    as xs:integer
{
    data:get-total($data:followers-collection, $user);
};

declare sequential function user:delete-all (
    $user as xs:string
)
    as empty-sequence()
{
    data:delete-all($data:users-collection, $user);
    data:delete-all($data:friends-collection, $user);
    data:delete-all($data:followers-collection, $user);
};

declare sequential function user:add (
    $user as xs:string,
    $data as element(user)*
)
    as empty-sequence()
{
    user:add($user, $data, false());
};

declare sequential function user:add-followers (
    $user as xs:string,
    $data as element(user)*
)
    as empty-sequence()
{
    user:add($user, $data, true());
};

declare sequential function user:add (
    $user as xs:string,
    $users as element(user)*,
    $is-follower as xs:boolean
)
    as empty-sequence()
{
    for $i in $users
    return block {
        declare $key := $i/id;
        declare $sortkey := $i/name;
        declare $sortdate := util:parse-date(string($i/created_at));
        declare $is-friend := exists($i/following[. eq 'true']);
    
        user:add-user($user, $key, $sortkey, $sortdate, $is-friend, $i, $is-follower);
    };
};

declare sequential function user:add-user (
    $user as xs:string,
    $key as xs:string?,
    $sortkey as xs:string?,
    $sortdate as xs:dateTime?,
    $is-friend as xs:boolean,
    $user-xml as element(user),
    $is-follower as xs:boolean
)
    as empty-sequence()
{
    declare $user-exists :=
        exists(data:get($data:users-collection, $user, $key));

    declare $friend-exists :=
        $is-friend and exists(data:get($data:friends-collection, $user, $key));

    declare $follower-exists :=
        $is-follower and exists(data:get($data:followers-collection, $user, $key));

    if (not($user-exists)) then
        data:add($data:users-collection, $user, $key, $sortkey, $sortdate, $user-xml)
    else
        ();

    if ($is-friend and not($friend-exists)) then
        data:add($data:friends-collection, $user, $key, $sortkey, $sortdate, $user-xml)
    else
        ();

    if ($is-follower and not($follower-exists)) then
        data:add($data:followers-collection, $user, $key, $sortkey, $sortdate, $user-xml)
    else
        ();
};


declare function user:get (
    $user as xs:string,
    $key as xs:string
)
    as element()?
{
    data:get($data:users-collection, $user, $key)[1];
};

declare function user:get-all (
    $user as xs:string
)
    as element()*
{
    data:get-all($data:users-collection, $user);
};

declare sequential function user:delete (
    $collection as xs:QName,
    $user as xs:string,
    $data as element(user)*
)
    as empty-sequence()
{
    declare $keys :=
        for $f in $data
        return
            $f/id;
    
    data:delete($collection, $user, $keys);
};

declare sequential function user:delete-user (
    $user as xs:string,
    $data as element(user)*
)
    as empty-sequence()
{
    user:delete($data:users-collection, $user, $data);
};

declare sequential function user:delete-friends (
    $user as xs:string,
    $data as element(user)*
)
    as empty-sequence()
{
    user:delete($data:friends-collection, $user, $data);
};

declare sequential function user:delete-followers (
    $user as xs:string,
    $data as element(user)*
)
    as empty-sequence()
{
    user:delete($data:followers-collection, $user, $data);
};
