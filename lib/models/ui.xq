module namespace ui = 'http://www.socialito.org/lib/models/ui';

import module namespace data="http://www.socialito.org/lib/data";

import module namespace acco="http://www.socialito.org/lib/models/account";
import module namespace sess="http://www.socialito.org/lib/models/session";

declare variable $ui:TYPE-DIRECT-MESSAGES := "widget_messages";
declare variable $ui:TYPE-FIND-PEOPLE := "widget_findpeople";
declare variable $ui:TYPE-FOLLOWERS := "widget_followers";
declare variable $ui:TYPE-FRIENDS := "widget_friends";
declare variable $ui:TYPE-HASHTAG := "widget_hashtag";
declare variable $ui:TYPE-MENTIONS := "widget_mentions";
declare variable $ui:TYPE-RECENT-URLS := "widget_recent_urls";
declare variable $ui:TYPE-TIMELINE-PUBLIC := "widget_timeline_public";
declare variable $ui:TYPE-TOP-HASHTAGS := "widget_top_hashtags";
declare variable $ui:TYPE-TOP-MENTIONS:= "widget_top_mentions";
declare variable $ui:TYPE-TWEET-NEW := "widget_tweet_new";
declare variable $ui:TYPE-USER-DETAILS := "widget_user";

declare variable $ui:STATUS-MAXIMIZED := "maximized";
declare variable $ui:STATUS-NORMAL := "normal";
declare variable $ui:STATUS-MINIMIZED := "minimized";
declare variable $ui:STATUS-HIDDEN := "hidden";

declare variable $ui:default-page-layout :=
    <page-layout>
        <column>
            <widget id="{$ui:TYPE-USER-DETAILS}" type="{$ui:TYPE-USER-DETAILS}"
                status="{$ui:STATUS-NORMAL}" title="My Details" color="white" class="">
            </widget>
            <widget id="{$ui:TYPE-TWEET-NEW}" type="{$ui:TYPE-TWEET-NEW}"
                status="{$ui:STATUS-NORMAL}" title="Send Tweet" color="white" class="">
            </widget>
            <widget id="{$ui:TYPE-FRIENDS}" type="{$ui:TYPE-FRIENDS}"
                status="{$ui:STATUS-NORMAL}" title="My Friends" color="white" class="people">
                <page>1</page>
                <count>3</count>
            </widget>
            <widget id="{$ui:TYPE-FOLLOWERS}" type="{$ui:TYPE-FOLLOWERS}"
                status="{$ui:STATUS-NORMAL}" title="My Followers" color="white" class="people">
                <page>1</page>
                <count>3</count>
            </widget>
        </column>
        <column>
            <widget id="{$ui:TYPE-TIMELINE-PUBLIC}" type="{$ui:TYPE-TIMELINE-PUBLIC}"
                status="{$ui:STATUS-NORMAL}" title="Tweets" color="white" class="">
                <page>1</page>
                <count>5</count>
            </widget>
            <!--<widget id="{$ui:TYPE-MENTIONS}" type="{$ui:TYPE-MENTIONS}"
                status="{$ui:STATUS-NORMAL}" title="Mentioning Me" color="white" class="">
                <page>1</page>
                <count>5</count>
            </widget>-->            
        </column>
        <column>
            <widget id="{$ui:TYPE-DIRECT-MESSAGES}" type="{$ui:TYPE-DIRECT-MESSAGES}"
                status="{$ui:STATUS-NORMAL}" title="Messages" color="white" class="">
                <page>1</page>
                <count>5</count>
            </widget>
        </column>
        <column>
            <widget id="{$ui:TYPE-FIND-PEOPLE}" type="{$ui:TYPE-FIND-PEOPLE}"
                status="{$ui:STATUS-NORMAL}" title="Find People" color="white" class="people">
                <page>1</page>
                <count>5</count>
            </widget>
            <widget id="{$ui:TYPE-TOP-HASHTAGS}" type="{$ui:TYPE-TOP-HASHTAGS}"
                status="{$ui:STATUS-NORMAL}" title="Top Hashtags" color="white" class="">
                <count>5</count>
            </widget>
            <widget id="{$ui:TYPE-TOP-MENTIONS}" type="{$ui:TYPE-TOP-MENTIONS}"
                status="{$ui:STATUS-NORMAL}" title="Top Mentions" color="white" class="">
                <count>3</count>
            </widget>
            <widget id="{$ui:TYPE-RECENT-URLS}" type="{$ui:TYPE-RECENT-URLS}"
                status="{$ui:STATUS-NORMAL}" title="Most Recent URLs" color="white" class="">
                <count>3</count>
            </widget>
        </column>
    </page-layout>
;

declare function ui:get-page-layout(
    $user as xs:string
)
    as element(page-layout)
{
    let $acco := acco:get-account-data($user)
    let $layout := $acco//page-layout[not(page-layout)]
    return
        if (exists($layout)) then
            $layout
        else
            $ui:default-page-layout
};

declare sequential function ui:update-page-layout(
    $user as xs:string,
    $layout as element(page-layout)
)
{
    acco:update-account-data($user, "page-layout", $layout)
};

declare function ui:widget-exists(
    $user as xs:string,
    $id as xs:string
)
    as xs:boolean
{
    exists(ui:get-page-layout($user)/column/widget[@id = $id])
};

declare sequential function ui:add-widget(
    $user as xs:string,
    $column as xs:integer,
    $id as xs:string,
    $type as xs:string,
    $status as xs:string,
    $title as xs:string,
    $class as xs:string,
    $color as xs:string,
    $params as element()*
)
{
    declare $layout :=
        ui:get-page-layout($user);
        
    insert nodes
        <widget id="{$id}" type="{$type}" title="{$title}" status="{$status}" color="{$color}" class="{$class}">{$params}</widget>
    as last into
        $layout/column[$column];

    ui:update-page-layout($user, $layout);
};

declare sequential function ui:update-widget(
    $user as xs:string,
    $id as xs:string,
    $status as xs:string?,
    $title as xs:string?,
    $color as xs:string?,
    $class as xs:string?,
    $params as element()*
)
{
    declare $layout :=
        ui:get-page-layout($user);
    declare $widget :=
        $layout/column/widget[@id = $id];
    declare $type := $widget/@type;
    
    declare $status_ := if (exists($status)) then $status else $widget/@status;
    declare $title_ := if (exists($title)) then $title else $widget/@title;
    declare $class_ := if (exists($class)) then $class else $widget/@class;
    declare $color_ := if (exists($color)) then $color else $widget/@color;

    declare $params_ :=
        for $p in $widget/*
        let $replacement := $params/self::*[local-name() eq local-name($p)]
        return
            if (exists($replacement)) then
                $replacement
            else
                $p;

    replace node
        $widget
    with
        <widget id="{$id}" type="{$type}" title="{$title_}" status="{$status_}" color="{$color_}" class="{$class_}">{$params_}</widget>
    ;

    ui:update-page-layout($user, $layout);
};

(: [MSc] 2010-09-29 Changed pos from string to in :)
declare sequential function ui:move-widget(
    $user as xs:string,
    $id as xs:string,
    $column as xs:integer?,
    $position as xs:integer?
)
{
    declare $layout := ui:get-page-layout($user);
    declare $widget := $layout/column/widget[@id = $id];
    
    declare $column_ :=
        if (exists($column)) then
            $column
        else
            count($widget/parent::column/preceding-sibling::column) + 1;
    declare $position_ :=
        if (exists($position)) then
            $position
        else
            count($widget/preceding-sibling::widget) + 1;

    declare $new-widget :=
        element {node-name($widget)} {
            $widget/@*,
            $widget/*
        };
        
    declare $column-node :=
        $layout/column[position() eq $column_];
    declare $position-node :=
        $column-node/widget[position() eq $position_];
    
    if (exists($position-node)) then
        insert node
            $new-widget
        before
            $position-node
    else
        insert node
            $new-widget
        as last into
            $column-node
    ;
    
    delete node $widget;

    ui:update-page-layout($user, $layout);
};

declare sequential function ui:delete-widget(
    $user as xs:string,
    $id as xs:string
)
{
    declare $layout :=
        ui:get-page-layout($user);
        
    delete nodes
        $layout/column/widget[@id = $id];

    ui:update-page-layout($user, $layout);
};
