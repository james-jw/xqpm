module namespace test = 'http://basex.org/modules/xqunit-tests';
import module namespace xqpm = 'http://xqpm' at 'xqpm.xqm'; 

 declare %unit:test function test:expand-params() {
   let $hash := map {
      'base': '~/base',
      'repo': '{{base}}/repo',
      'webapp': '{{base}}/webapp',
      'static': '{{webapp}}/static',
      'js': '{{static}}/js'
   }
   let $out := xqpm:expand-params($hash)
   return (
     unit:assert-equals('~/base/repo', $out?repo),
     unit:assert-equals('~/base/webapp/static/js', $out?js)
   )
 };

 declare %unit:before('process-params') function test:before-params() {
   let $config := element config {
     <params>
       <param name="base">/rootWrong</param>
       <param name="lib">{{{{base}}}}/lib</param>
       <param name="repo">{{{{base}}}}/repo</param>
       <param name="webapp">{{{{base}}}}/webapp</param>
       <param name="static">{{{{webapp}}}}/static</param>
       <param name="js">{{{{static}}}}/js</param>
       <param name="css">{{{{static}}}}/css</param>
       <param name="fonts">{{{{static}}}}/fonts</param>
    </params>
   }
   let $user-config := element config {
    <params>
      <param name="base">/rootTest</param>
    </params>
   }
   return ( 
     file:write('test-params.xml', $config),
     file:write('test-user-params.xml', $user-config)
   ) 
 };

 declare %unit:test function test:process-params() {
   let $user-config := doc('test-user-params.xml') 
   let $out := xqpm:process-params(doc('test-params.xml'), $user-config)
   return (
    unit:assert-equals($out?repo, '/rootTest/repo')
   )
 };

 declare %unit:after('process-params') function test:after-params() {(
     file:delete('test-params.xml'),
     file:delete('test-user-params.xml')
 )};

