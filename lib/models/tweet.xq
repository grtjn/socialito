module namespace tweet = 'http://www.socialito.org/lib/models/tweet';

import module namespace data = "http://www.socialito.org/lib/data";  
import module namespace util = "http://www.socialito.org/lib/util";  

declare function tweet:get-total (
    $user as xs:string,
    $user-id as xs:string?
)
    as xs:integer
{
    data:get-total($data:tweets-collection, $user, $user-id);
};

declare function tweet:get-paged (
    $user as xs:string,
    $user-id as xs:string?,
    $start as xs:integer,
    $end as xs:integer
)
    as element()*
{
    data:get-date-sorted($data:tweets-collection, $user, $user-id)[position() = ($start to $end)];
};

declare function tweet:get-total-mention-tweets (
    $user as xs:string,
    $user-id as xs:string
)
    as xs:integer
{
    data:get-total($data:mentions-collection, $user, $user-id);
};

declare function tweet:get-paged-mention-tweets (
    $user as xs:string,
    $user-id as xs:string,
    $start as xs:integer,
    $end as xs:integer
)
    as element()*
{
    data:get-date-sorted($data:mentions-collection, $user, $user-id)[position() = ($start to $end)];
};

declare function tweet:get-total-hashtag-tweets (
    $user as xs:string,
    $hashtag as xs:string
)
    as xs:integer
{
    data:get-total($data:hashtags-collection, $user, $hashtag);
};

declare function tweet:get-paged-hashtag-tweets (
    $user as xs:string,
    $hashtag as xs:string,
    $start as xs:integer,
    $end as xs:integer
)
    as element()*
{
    data:get-date-sorted($data:hashtags-collection, $user, $hashtag)[position() = ($start to $end)];
};

declare function tweet:get-recent-urls (
    $user as xs:string,
    $count as xs:integer
)
    as element(data)*
{
    data:get-all-date-sorted($data:urls-collection, $user)[position() = (1 to $count)];
};

declare function tweet:get-top-hashtags (
    $user as xs:string,
    $count as xs:integer
)
    as element(facet)*
{
    data:get-facets($data:hashtags-collection, $user, ())[position() = (1 to $count)];
};

declare function tweet:get-top-mentions (
    $user as xs:string,
    $count as xs:integer
)
    as element(facet)*
{
    data:get-facets($data:mentions-collection, $user, ())[position() = (1 to $count)];
};

declare function tweet:get-last (
    $user as xs:string
)
    as element()?
{
    data:get-latest-item($data:tweets-collection, $user);
};

declare sequential function tweet:delete-all (
    $user as xs:string
)
    as empty-sequence()
{
    data:delete-all($data:tweets-collection, $user);
    data:delete-all($data:hashtags-collection, $user);
    data:delete-all($data:mentions-collection, $user);
    data:delete-all($data:urls-collection, $user);
};

declare sequential function tweet:add (
    $user as xs:string,
    $user-id as xs:string,
    $data as element()*
)
    as empty-sequence()
{
    for $t in $data
    return block {
        declare $key := $t/user/id;
        declare $sortkey := $t/id;
        declare $sortdate := util:parse-date(string($t/created_at));
        declare $hashtags := $t/entities/hashtags/hashtag;
        declare $mentions := $t/entities/user_mentions/user_mention;
        declare $urls := $t/entities/urls/url;

        replace node
            $t/created_at
        with
            <created_at>{$sortdate}</created_at>;

        replace node
            $t/text
        with
            util:enrich-urls(util:enrich-mentions(util:enrich-hashtags($t/text)));
            
        for $h in ($hashtags)
        let $hashtag-key := $h/text
        let $hashtag-sortkey := $hashtag-key
        let $hashtag-sortdate := $sortdate
        return
            data:add($data:hashtags-collection, $user, $hashtag-key, $hashtag-sortkey, $hashtag-sortdate, $t);
            
        for $m in ($mentions)
        let $mention-key := $m/id
        let $mention-sortkey := $m/screen_name
        let $mention-sortdate := $sortdate
        return
            data:add($data:mentions-collection, $user, $mention-key, $mention-sortkey, $mention-sortdate, $t);
            
        for $u in ($urls)
        let $url-key := if (string-length($u/expanded_url) > 0) then $u/expanded_url else $u/url
        let $url-sortkey := $url-key
        let $url-sortdate := $sortdate
        return
            data:add($data:urls-collection, $user, $url-key, $url-sortkey, $url-sortdate, $t);
            
        data:add($data:tweets-collection, $user, $key, $sortkey, $sortdate, $t);
    };
};

declare sequential function tweet:delete (
    $user as xs:string,
    $data as element()*
)
    as empty-sequence()
{
    for $t in $data
    let $key := $t/id
    return
        data:delete($data:tweets-collection, $user, $key);
};
