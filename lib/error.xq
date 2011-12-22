module namespace err = "http://www.socialito.org/lib/error";

import module namespace http="http://www.28msec.com/modules/http";
import module namespace util="http://www.socialito.org/lib/util";
import module namespace html="http://www.socialito.org/lib/html";

declare function err:show($status, $msg)
{
    err:show($status, $msg, ())
};

declare function err:show($status, $msg, $stack)
{
    let $e :=
        <div class="error">
            <h4>Error: { $status }</h4>
            <p>{ $msg }</p>
        </div>
    let $e := html:widget("widget_error", "Whoopsie!", "normal", "widget-error", "red", $e)
    let $t :=  
        <div class="error">
            <h4>Trace</h4>
            <ul class="trace">
              {
                for $trace in $stack
                return
                  <li>{ util:serialize-xml($trace) }</li>
              }
            </ul>
            <div style="display: none">{$stack}</div>
        </div>
    let $t := html:widget("widget_trace", "Stack trace", "normal", "widget-error", "white", $t)
    let $r :=
        <div class="error">
            <pre>{ util:serialize-xml(util:get-request-context()) }</pre>
        </div>
    let $r := html:widget("widget_request", "Request information", "minimized", "widget-error", "white", $r)
    return
    
    html:format-2-column-page(concat("ERROR", $status), (), $e, $t, $r)
(:
  <html>
      <head>
          <title> ERROR { $status } </title>
      </head>
    <body>
      <center>
        <h1 style="color: #FF0000"> WHOOPSIE!! </h1>
        <h2>Error { $status }</h2>
        <p>{ $msg }</p>
        <h2>Trace</h2>
        <ul>
          {
            for $trace in $stack
            return
              <li>{ util:serialize-xml($trace) }</li>
          }
        </ul>
      </center>
      <p>
        <hr/>
        <h1> Request Information: </h1>
        <pre>{ util:serialize-xml(util:get-request-context()) }</pre>
        <hr/>
      </p>
    </body>
  </html>
:)
};
