import module namespace xqpm = 'http://xq-ant' at 'https://raw.githubusercontent.com/james-jw/xq-ant/master/src/xq-ant.xqm';
declare variable $base as xs:string external;

let $config := doc('https://raw.githubusercontent.com/james-jw/xq-ant/master/src/xqpm.xml')
return
  xqpm:process-dependencies($config, $base)
