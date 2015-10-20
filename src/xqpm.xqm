(: Simple ant like collection module for gathering dependencies and placing them
 : in appropriate relative locations.
 : 
 : Execute the script in any directory with a collect.xml file:
 :
 : <config>
 :  <!-- Path to source map xml file -->
 :  <sources path="{path to collection source file}" />
 :  ...
 :  <dependencies>
 :    <directory path="{relative path}">
 :      <dependency name="{dependency name" path="{path? optional}" />
 :      ...
 :    </directory>
 :    ...
 :  </dependencies>
 : </config>
 :
 :)
module namespace local = 'http://xqpm';
import module namespace mustache = 'http://xq-mustache' at 'https://raw.githubusercontent.com/james-jw/xq-mustache/master/src/xq-mustache.xqm';

declare variable $local:config-name := 'xqpm.xml';
declare variable $local:user-config := fn:environment-variable('HOME') || '/.' || $local:config-name;
declare variable $local:user-config-template := function ($base-dir) {
  <config>
    <params>
      <param name="home">{fn:environment-variable('HOME')}</param>
      <param name="base">{$base-dir}</param>
      <param name="repo">{{{{base}}}}/repo</param>
      <param name="lib">{{{{base}}}}/lib</param>
      <param name="webapp">{{{{base}}}}/webapp</param>
      <param name="static">{{{{webapp}}}}/static</param>
      <param name="js">{{{{static}}}}/js</param>
      <param name="css">{{{{static}}}}/css</param>
      <param name="fonts">{{{{static}}}}/fonts</param>
    </params>
  </config>
};

declare %private function local:retrieve-git-sources($git as element(git-source)) {
  for $repo in json-doc($git/@path)?*  
  where $repo?name and $repo?clone_url
  return
    <source name="{$repo?name}" type="git" path="{$repo?clone_url}" />
};

(: Provided a map with values containing self referencing mustache expressions
 : returns a map with all expressions expanded.
 :)
declare function local:expand-params($params as map(*)) as map(*) {
  let $out := map:merge( 
    for $param in map:keys($params) 
    return map { $param: mustache:render($params($param), $params) }
  )
  return 
    if(($out?* ! mustache:is-mustache(.)) = true())
    then local:expand-params($out)
    else $out
};

declare function local:process-params($config as document-node()?, $user-config as document-node()?) {
  let $map := map:merge( (
    for $param in ($config, $user-config)/config/params/param
      return map { data($param/@name): data($param) },
      map { 'current-dir': file:current-dir() }
  ))
  return
    local:expand-params($map)
 };

declare function local:retrieve-sources($config as document-node()?, $user-config as document-node()?) {
  let $config := ($config, $user-config) return
  for $source in $config/config/sources
  let $out := doc($source/@url)   
  return
    ( $out//source,
      $config/sources/source,
      for $git in ($out, $config)//git-source return 
        local:retrieve-git-sources($git)
    )
};

declare function local:retrieve-user-config($base-dir as xs:string?) {
  if(file:exists($local:user-config)) 
  then file:read-text($local:user-config) => parse-xml() 
  else if(boolean($base-dir)) then 
    let $template := $local:user-config-template($base-dir)
    return        
      file:write($local:user-config, $template) 
  else 
    trace((), 'Either no user config found at ' || $local:user-config || ' or base param not defined.')
};

(: Allows for the installation of a single package.  : Requires that a .xqpm with appropriate sources and
 : parameters is defined
 :)
declare function local:install($package-name as xs:string) {
  let $user-config := local:retrieve-user-config(())
  let $sources := local:retrieve-sources((), $user-config) 
  let $params := local:process-params((), $user-config) 
  let $package := trace($sources[@name = $package-name]/@path)
  return
    try { local:init($package, $params, $sources) } catch * {()}
};

declare function local:init($config as document-node()) {
  local:init($config, ())
};

declare function local:init($config as document-node(), $base-dir as xs:string?) {
  let $user-config := local:retrieve-user-config($base-dir)
  let $sources := local:retrieve-sources($config, $user-config) 
  let $params := local:process-params($config, $user-config) 
  return
    if($user-config) then 
      local:init($config, $params, $sources)
    else 
      local:init($config, ())
};

declare %private function local:init($config as document-node(), $params as map(*), $sources as item()*) {
  let $sources := ($sources, $config/source)
  for $directory in $config//dependencies/directory
  let $dir-path := trace(mustache:render($directory/@path, $params), 'Processing directory: ')
  return
    (local:create-directories($dir-path),
     for $dep in $directory/dependency 
     let $name := trace($dep/@name, 'Processing: ')
     let $path := (($dep/@path, $sources[@name = $name]/@path)[1]) ! mustache:render(., $params)
     let $type := (($sources[@name = $name],$dep)/@type)[1]
     return try {
        if($type = 'command') then (
          local:execute-command($dep, $params)
        ) else if($type = 'git') then
          let $dest := $dir-path || '/' || $name || '/' return
          (
            proc:system("git", ("clone", $path, $dest )),
            if(file:exists($dest || $local:config-name)) then ( 
              trace("Processing dependencies for " || $name),
              local:init(doc($dest || $local:config-name), $params, $sources))
            else ()
          )
        else ( 
          if(fetch:content-type($path) = 'application/zip') then (
            let $file := file:temp-dir() || $name
            return (file:write-binary($file, fetch:binary($path)),
                    proc:system("unzip", ('-o', $file, '-d', $dir-path))))
          else if($type = 'binary') then
            let $file-name := tokenize($path, '/')[last()]
            return
              file:write-binary(trace($dir-path || '/' ||  $file-name, 'Writing binary: '), fetch:binary($path))
          else if($path) then
            file:write(trace($dir-path || '/' || $name, 'Writing: '), fetch:text($path)) 
          else trace("Failed to find dependency: " || $name)
        )
      } catch * {
        trace($dep, 'Processing failed: ' || $err:description || ' line: ' || $err:line-number)
      }
    )
};
declare %private function local:execute-command($dep as element(dependency), $params as map(*)) {
  let $arguments := $dep/argument ! mustache:render(., $params)
  return
    (
      trace('', 'Executing: ' || ($dep/@path, $arguments) => string-join(' ')),
      trace(proc:system($dep/@path, $arguments))
    )
};

declare %private function local:create-directories($directories) {
  for $dir in $directories return
  try { file:create-dir(string-join($directories, '\')) } 
  catch * { trace($err:description) }
};
