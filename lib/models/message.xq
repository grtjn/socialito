module namespace msg = 'http://www.socialito.org/lib/models/message';

declare ordering ordered;

import module namespace data = "http://www.socialito.org/lib/data";  
import module namespace util = "http://www.socialito.org/lib/util";  

declare function msg:get-all (
    $user as xs:string
)
    as element()*
{
    data:get-all-date-sorted($data:messages-collection, $user);
};

declare function msg:get-total (
    $user as xs:string
)
    as xs:integer
{
    data:get-total($data:messages-collection, $user);
};

declare function msg:get-last (
    $user as xs:string
)
    as element()?
{
    data:get-latest-item($data:messages-collection, $user);
};

declare function msg:get-paged (
    $user as xs:string,
    $start as xs:integer,
    $end as xs:integer
)
    as element()*
{
    data:get-all-date-sorted($data:messages-collection, $user)[position() = ($start to $end)];
};

declare sequential function msg:delete-all (
    $user as xs:string
)
    as empty-sequence()
{
    data:delete-all($data:messages-collection, $user);
};

declare sequential function msg:add (
    $user as xs:string,
    $data as element()*
)
    as empty-sequence()
{
    for $t in $data
    return block {
        declare $key := $t/id;
        declare $sortkey := $t/id;
        declare $sortdate := util:parse-date(string($t/created_at));

        replace node
            $t/created_at
        with
            <created_at>{$sortdate}</created_at>;
            
        replace node
            $t/text
        with
            util:enrich-urls(util:enrich-mentions(util:enrich-hashtags($t/text)));
            
        data:add($data:messages-collection, $user, $key, $sortkey, $sortdate, $t);
    };
};

declare sequential function msg:delete (
    $user as xs:string,
    $data as element()*
)
    as empty-sequence()
{
    for $t in $data
    let $key := $t/id
    return
        data:delete($data:messages-collection, $user, $key);
};
