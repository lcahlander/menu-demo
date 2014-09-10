xquery version "3.0";

module namespace app="http://exist-db.org/apps/menu-demo/templates";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://exist-db.org/apps/menu-demo/config" at "config.xqm";

declare namespace expath="http://expath.org/ns/pkg";

(:~
 : This is a sample templating function. It will be called by the templating module if
 : it encounters an HTML element with an attribute: data-template="app:test" or class="app:test" (deprecated). 
 : The function has to take 2 default parameters. Additional parameters are automatically mapped to
 : any matching request or function parameter.
 : 
 : @param $node the HTML node with the attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function app:test($node as node(), $model as map(*)) {
    <p>Dummy template output generated by function app:test at {current-dateTime()}. The templating
        function was triggered by the class attribute <code>class="app:test"</code>.</p>
};

declare function app:page-setup($node as node(), $model as map(*)) as map(*) {
 map { 'page-title' := 'Foo',
(:        'meta' := (<meta http-equiv="refresh" content="30"/>),
:)        'page-menu' := (
                        <menu>
                            <name>Home</name>
                            <menu-item>
                                <name>Home</name>
                                <url>index.html</url>
                            </menu-item>
                            <menu-item>
                                <name>Two</name>
                                <url>two.html</url>
                            </menu-item>
                        </menu>,
                        <menu-item>
                            <name>Admin</name>
                            <url>index.html</url>
                        </menu-item>,
                        <menu>
                            <name>Tertiary</name>
                            <menu-item>
                                <name>Home</name>
                                <url>index.html</url>
                            </menu-item>
                            <menu-item>
                                <name>Two</name>
                                <url>two.html</url>
                            </menu-item>
                        </menu>
                        ) }
};

declare function app:page-meta($node as node(), $model as map(*)) {
    $model('meta')
};

declare function app:each($node as node(), $model as map(*), $from as xs:string, $to as xs:string, $nowrap as xs:string?) {
    for $item in $model($from)
    return if($nowrap = 'true')
        then
            templates:process($node/node(), map:new(($model, map:entry($to, $item))))
        else
        element { node-name($node) } {
            if ($model($templates:CONFIGURATION)($templates:CONFIG_DEBUG)) then
                    $node/@*
                else
                    $node/@*[not(starts-with(local-name(.), "data-template"))], 
            templates:process($node/node(), map:new(($model, map:entry($to, $item))))
        }
};


declare function app:model-name-switch($node as node(), $model as map(*), $key as xs:string?, $list as xs:string?) {
    let $value := $model($key)/name()
    let $seq := fn:tokenize($list, ',')
    let $pos := fn:index-of($seq, $value)
    return if (fn:empty($pos)) then $value else templates:process($node/node()[$pos], $model)
};


declare %templates:wrap function app:menu-name($node as node(), $model as map(*))  {
    $model('menu')/name/text()
};

declare %templates:wrap function app:menu-link($node as node(), $model as map(*))  {
    attribute { 'href' } { $model('menu')/url/text() } , $model('menu')/name/text()
};

declare function app:menu-setup($node as node(), $model as map(*)) as map(*) {
    map { 'menu-items' := $model('menu')/menu-item }
};

declare %templates:wrap function app:page-title($node as node(), $model as map(*))  {
    if ($model('page-title')) then $model('page-title') else $config:expath-descriptor/expath:title/text()
};
