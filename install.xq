import module namespace xqpm = 'http://xqpm' at 'https://raw.githubusercontent.com/james-jw/xqpm/master/src/xqpm.xqm';
declare variable $path as xs:string external;

let $config := doc('https://raw.githubusercontent.com/james-jw/xqpm/master/src/xqpm.xml')
return
  xqpm:init($config, $path)
