$(document).ready(function() {
    initForms();
    initIcons();
    initPaging();
    initPersons();
    initTagClouds();
    initTweetCharCount();
    initTweetNew();
    initWidgets();

    $("p.info").flash({ "colorFrom": "#000000", "colorTo": "#ffffff" }).delay(3000).fadeOut("slow");
    $("p.error").append("<a class='close' href='#'><span>close</span></a>");
    $("p.error").flash({ "colorFrom": "#000000", "colorTo": "#ffffff" });
    $("p.error .close").click(function() {
        $("p.error").fadeOut("slow");
    });

    $("#start-app a, .submit, button[type='submit']").click(function() { showProgress() });
});

var debug = 0;

function dbg(str) {
    if (debug != 1) return;
    alert(">>>>>" + str);
}

function initForms() {
    $("#twitter_continue").click(function() {
        /*$("#twitter_spinner").show();*/
        showProgress();
    });
}

function initTagClouds() {
    if($.browser.msie)
        return;

    var options = {"direction": "vertical", "easein": "easeOutBack", "speed": 4000};
    if ($("#top_mentions_hashtags li").length > 0) {
        $("#top_mentions_hashtags").addClass("tagcloud");
        $("#top_mentions_hashtags").tagCloud(options);
    }
}

function initTweetCharCount() {
    var optionsCharCount = {};
    $("#tweet_text").charCount(optionsCharCount);
}

function initTweetNew() {
    $("#submit_tweet_new").click(function() {
        $("#tweet_spinner").show();
        // Get contents of Tweet textarea
        var val = $("#tweet_text").val();
        // Get its length
        var length = val.length;
        var tweet_action = $("#tweet_action").val();
        // Make sure it's at least 1 and at most 140 characters
        if (length > 0 && length <= 140) {
            var url = $("#form_tweet_new").attr("action");
            $.post(url, { status: val, isajax: 1, action: tweet_action }, function(data) {
                doTweetSuccess(tweet_action, data);
                $("#tweet_spinner").hide();
            });
        } else {
            alert("You can only post a Tweet between 1 and 140 characters!");
        }
        // Return false to prevent form from being submitted
        return false;
    });
}

function initIcons() {
    $("a.dm").click(function () {
        var screenname = $(this).attr("rel");
        if (screenname.length > 0)
            setTweetText("DM " + screenname + " ", "dm");
    });

    $("a.mention").click(function () {
        var screenname = $(this).attr("rel");
        if (screenname.length > 0)
            setTweetText("@" + screenname + " ", "mention");
    });

    $("a.retweet").click(function () {
        var msg = $(this).attr("rel");
        if (msg.length > 0)
            setTweetText("RT " + msg + " ", "rt");
    });
}

function initPaging() {
    $(".tweets-nav li a").click(function() {
        var parent = $(this).parents(".widget");
        var widgetId = parent.attr("id");
        var url = $(this).attr("href");
        var content = $("#" + widgetId + " .widget-content");
        showSpinner(content);
        $.post(url, { isajax: 1 }, function(data) {
            content.html(data);
            content.flash();
            initIcons();
            initPaging();
        });
        return false;
    });
}

function initWidgets() {
    $(".widget-head a.remove").click(function() {
        var parent = $(this).parent().parent();
        var id = $(parent).attr("id");
        var url = "/ui/delete-widget?id=" + id;
        $.post(url, { isajax: 1 });
    });

    $(".widget-head a.collapse").click(function() {
        var widget = $(this).parent().parent();
        var status = getWidgetStatus(widget);
        if (status == "normal")
            status = "minimized";
        else
            status = "normal";
        setWidgetStatus(widget, status);
        updateWidget(widget, status, getWidgetColor(widget), getWidgetTitle(widget));
    });

    $("ul.colors>li").click(function() {
        var widget = $(this).parent().parent().parent().parent();
        var color = $(this).attr("class");
        updateWidget(widget, getWidgetStatus(widget), color, getWidgetTitle(widget));
    });

    $("button.set-title").click(function() {
        var widget = $(this).parent().parent().parent().parent();
        var textBox = $(this).prev(".text-title");
        var title = $(textBox).val();
        updateWidget(widget, getWidgetStatus(widget), getWidgetColor(widget), title);
    });

    $(".column").bind("sortstop", function(event, ui) {
        var id = ui.item.attr("id");
        var col = ui.item.parent("ul.column").index() + 1;
        var pos = ui.item.index() + 1;
        var url = "/ui/move-widget?id=" + id + "&column=" + col + "&position=" + pos;
        $.post(url, { isajax: 1 }, function(data) {

        });
    });
}

function doTweetSuccess(action, data) {
    switch (action) {
        case "dm":
            $("#widget_messages .widget-content").html(data);
            $("#widget_messages .widget-content").flash();
            break;
        /* "m" and "rt" can just fall back to default */ 
        case "m":
        case "rt":
        default:
            $("#widget_timeline_public .widget-content").html(data);
            $("#widget_timeline_public .widget-content").flash();
    }
    /* Reset Tweet text area and hidden action input */
    $("#tweet_text").val("");
    $("#tweet_action").val("tweet");
    /* Re-assign icon links! */
    initIcons();
}

function getWidgetColor(widget) {
    if (widget.hasClass("color-yellow")) return "color-yellow";
    if (widget.hasClass("color-red")) return "color-red";
    if (widget.hasClass("color-blue")) return "color-blue";
    if (widget.hasClass("color-white")) return "color-white";
    if (widget.hasClass("color-orange")) return "color-orange";
    if (widget.hasClass("color-green")) return "color-green";
    
    return "color-purple";
}

function getWidgetStatus(widget) {
    if (widget.hasClass("minimized"))
        return "minimized";
    else
        return "normal";
}

function setWidgetStatus(widget, status) {
    widget.removeClass("minimized");
    widget.removeClass("normal");
    widget.addClass(status);
    /*
    var sel = "#" + $(widget).attr("id") + " .widget-content";
    if (status == "minimized") {
        $(sel).hide();
    } else {
        $(sel).show();
    }
    */
}

function getWidgetTitle(widget) {
    var id = widget.attr("id");
    var title =  $("#" + id + " .text-title").val();
    return title;
}

function updateWidget(widget, widget_status, widget_color, widget_title) {
    widget_color = widget_color.replace("color-", "");
    dbg(widget_color + ", " + widget_status + ", " + widget_title);

    var url = "/ui/update-widget?id=" + widget.attr("id");
    url = url.concat("&isajax=", "1", "&status=", widget_status, "&color=", widget_color, "&title=", widget_title, "&page=", "1", "&count=", "5");
    var params = {};     //{ isajax: 1, status: widget_status, color: widget_color, title: widget_title, page: 1, count: 5 };
    $.post(url, params, function(data) {
        dbg("data: " + data);
    });
}

function setTweetText(text, action) {
    if (text.length < 1)
        return;
    $("#tweet_action").val(action);
    $("#tweet_text").val(text);
    $("#tweet_text").focus();
    $("#widget_tweet_new .widget-content").flash();
}

function initPersons() {
    $("a.person").click(function () {
        var screenname = $(this).attr("rel");
        if (screenname.length > 0) {
            
        }
        //return false;
    });
}

function OBSOLETE_flashElement(selector) {
    $(selector).stop().animate({ backgroundColor: "#4e9fcc" }, 500).animate({ backgroundColor: "#000000" }, 500);
}

function showProgress() {
    //add modal background
    $('<div><p>Hold your horses...</p></div>').addClass('progress_container').appendTo('body').show();
    //add spinner
}

function showSpinner(element) {
    //alert("class=" + element.attr("class"));
    $('<img src="/images/spinner.gif" class="spinner" alt="Working..." />').appendTo(element);
}

jQuery.fn.flash = function() {
    var el = $(this[0]);            // Your element
    try {
        var args = arguments[0] || {};  // Your object of arguments

        var colorFrom = args.colorFrom || "#4e9fcc";
        var colorTo = args.colorTo || "#333333";
        var timeout = args.timeOut || 500;
        return el.stop().animate({ backgroundColor: colorFrom }, 500).animate({ backgroundColor: colorTo }, timeout);
    } catch (e) { }
    return el;
    /*
    */
};