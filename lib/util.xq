module namespace util = 'http://www.socialito.org/lib/util';

import module namespace functx="http://www.functx.com";
import module namespace http="http://www.28msec.com/modules/http";
import module namespace ser="http://www.zorba-xquery.com/modules/serialize";

import module namespace acco="http://www.socialito.org/lib/models/account";
import module namespace sess="http://www.socialito.org/lib/models/session";

declare variable $util:digits := ('1', '2', '3', '4', '5', '6', '7', '8', '9', '0');
declare variable $util:months := ('jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec');

declare function util:format-error(
    $code,
    $msg,
    $val
)
    as xs:string
{
    concat($code, ": ", $msg)
};

declare function util:get-request-context (
)
    as element(context)
{
    let $user := sess:get-session-user()
    return
        <context>{
            if (exists($user)) then
                attribute session-user {$user}
            else (),
            
            util:get-request-details(),
            
            sess:get-session-data(),

            if (exists($user)) then
                acco:get-account-data($user)
            else ()
        }</context>;
};

declare function util:get-request-param (
    $name as xs:string
)
    as xs:string?
{
    util:get-request-param($name, ())
};

declare function util:get-request-param (
    $name as xs:string,
    $default as item()*
)
    as xs:string?
{
    let $values := http:get-parameters($name, $default)[string-length(string(.)) > 0]
    where exists($values)
    return
        string($values[1])
};

declare function util:get-request-param-as-int (
    $name as xs:string
)
    as xs:integer?
{
    util:get-request-param-as-int($name, ())
};

declare function util:get-request-param-as-int (
    $name as xs:string,
    $default as item()*
)
    as xs:integer
{
    let $value := util:get-request-param($name, $default)
    where exists($value)
    return
        xs:integer($value)
};

declare function util:get-request-param-as-bool (
    $name as xs:string
)
    as xs:boolean?
{
    util:get-request-param-as-bool($name, ())
};

declare function util:get-request-param-as-bool (
    $name as xs:string,
    $default as item()*
)
    as xs:boolean?
{
    let $value := util:get-request-param($name, $default)
    where exists($value)
    return
        boolean(normalize-space(lower-case($value)) = ('true', 'yes', 'ja', 't', 'y', 'j', '1'))
};

declare function util:get-request-details (
)
    as element(request)
{
    <request>
        <method>{http:get-method()}</method>
        <server-name>{http:get-server-name()}</server-name>
        <server-port>{http:get-server-port()}</server-port>
        <request-uri>{http:get-request-uri()}</request-uri>
        <query-string>{http:get-query-string()}</query-string>
        <user-agent>{http:get-user-agent()}</user-agent>
        <headers>{
            for $name in http:get-header-names()
            let $value := http:get-header($name)
            return
                <header name="{$name}">{
                    if ($value) then <value>{$value}</value> else ()
                }</header>
        }</headers>
        <params>{
            for $name in http:get-parameter-names()
            let $values := http:get-parameters($name)
            return
                <param name="{$name}">{
                    for $value in $values
                    return
                        <value>{$value}</value>
                }</param>
        }</params>
        <cookies>{
            http:get-cookies()
        }</cookies>
        <content length="{http:get-content-length()}" type="{http:get-content-type()}">{
            http:get-content()
        }</content>
        <files>{
            for $name in http:get-file-names()
            return
                <file name="{$name}">{ http:get-files($name)}</file>
        }</files>
    </request>
(: TODO:
 get-content-file-names($name as xs:string) as xs:string* 
 get-content-length-of-files($name as xs:string) as xs:long* 
 get-content-type-of-files($name as xs:string) as xs:string* 
:)
};

declare function util:serialize-xml(
    $xml as item()*
)
    as xs:string
{
    util:serialize-xml($xml, true())
};

declare function util:serialize-xml(
    $xml as item()*,
    $indent as xs:boolean
)
    as xs:string
{
    let $format :=
        <output
            method="xml" 
            version="1.0"
            encoding="UTF-8" 
            omit-xml-declaration="yes"
            standalone="yes"
            cdata-section-elements=""
            indent="{if ($indent) then 'yes' else 'no'}"
            media-type="application/xml"/>
    return
        ser:serialize($xml, $format)
};

declare sequential function util:parse-date(
    $date as xs:string
) as xs:dateTime
{
    (: Input:
     : Sat Jul 29 18:23:37 +0000 2006
     : 
     : Output:
     : 2006-07-29T18:23:37.00+00:00
     :)
    declare $date := lower-case(normalize-space($date));
    declare $tokens := tokenize($date, '\s+');

    declare $d_ := $tokens[3];
    declare $d :=
        if (string-length($d_) lt 2) then
            concat('0', $d_)
        else
            $d_;

    declare $m_ := $tokens[2];
    declare $m :=
        if ($m_ eq 'jan') then
            '01'
        else if ($m_ eq 'feb') then
            '02'
        else if ($m_ eq 'mar') then
            '03'
        else if ($m_ eq 'apr') then
            '04'
        else if ($m_ eq 'may') then
            '05'
        else if ($m_ eq 'jun') then
            '06'
        else if ($m_ eq 'jul') then
            '07'
        else if ($m_ eq 'aug') then
            '08'
        else if ($m_ eq 'sep') then
            '09'
        else if ($m_ eq 'oct') then
            '10'
        else if ($m_ eq 'nov') then
            '11'
        else if ($m_ eq 'dec') then
            '12'
        else
            '01';

    declare $y := $tokens[last()];

    declare $t := $tokens[4];

    declare $tz_ := $tokens[5];
    declare $tz := concat(substring($tz_, 1, 3), ':', substring($tz_, 4, 2));

    try {
        xs:dateTime(concat($y, '-', $m, '-', $d, 'T', $t, '.00', $tz));
    } catch * ($code, $msg, $val) {
        current-dateTime()
    };
};

declare sequential function util:format-date(
    $date as xs:string
) as xs:string
{
    declare $date_ := xs:dateTime($date);

    declare $day1 := day-from-dateTime($date_);
    declare $day := if ($day1 lt 10) then concat('0', $day1) else $day1;
    declare $month1 := month-from-dateTime($date_);
    declare $month := if ($month1 lt 10) then concat('0', $month1) else $month1;
    declare $year := year-from-dateTime($date_);
    
    declare $hour1 := hours-from-dateTime($date_);
    declare $hour := if ($hour1 lt 10) then concat('0', $hour1) else $hour1;
    declare $min1 := minutes-from-dateTime($date_);
    declare $min := if ($min1 lt 10) then concat('0', $min1) else $min1;

    try {
        concat($year, '-', $month, '-', $day, ' ', $hour, ':', $min);
    } catch * {
        $date
    };
};

declare function util:enrich-hashtags($msg as item()*) {
    for $item in $msg
    return
        typeswitch ($item)
        case text()
            return
                if ($item/parent::hashtag) then
                    $item
                else
                    for $m in functx:get-matches-and-non-matches($item, '#[^\s]+')
                    return
                        if (exists($m/self::match)) then
                            <hashtag>{$m/node()}</hashtag>
                        else
                            $m/node()                      
        case element()
            return
                element {node-name($item)} {
                    $item/@*,
                    util:enrich-hashtags($item/node())
                }
        default
            return
                $item
};

declare function util:enrich-mentions($msg as item()*) {
    for $item in $msg
    return
        typeswitch ($item)
        case text()
            return
                if ($item/parent::mention) then
                    $item
                else
                    for $m in functx:get-matches-and-non-matches($item, '@[^\s]+')
                    return
                        if (exists($m/self::match)) then
                            <mention>{$m/node()}</mention>
                        else
                            $m/node()                      
        case element()
            return
                element {node-name($item)} {
                    $item/@*,
                    util:enrich-mentions($item/node())
                }
        default
            return
                $item
};

declare function util:enrich-urls($msg as item()*) {
    for $item in $msg
    return
        typeswitch ($item)
        case text()
            return
                if ($item/parent::url) then
                    $item
                else
                    for $m in functx:get-matches-and-non-matches($item, 'http[s]?://[^\s]+')
                    return
                        if (exists($m/self::match)) then
                            <url>{$m/node()}</url>
                        else
                            $m/node()                      
        case element()
            return
                element {node-name($item)} {
                    $item/@*,
                    util:enrich-urls($item/node())
                }
        default
            return
                $item
};

declare function util:first-upper(
    $str as xs:string
)
    as xs:string
{
    concat(upper-case(substring($str, 1, 1)), substring($str, 2))
};
