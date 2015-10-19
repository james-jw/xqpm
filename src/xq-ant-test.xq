module namespace test = 'http://basex.org/modules/xqunit-tests';
import module namespace xqpm = 'http://xq-ant'; 

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
