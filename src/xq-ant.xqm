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
declare function local:retrieve-git-sources($git as element(git-source)) {
  let $req := <http:request method="GET" override-media-type="text/plain" />
  for $repo in  parse-json(http:send-request($req, $git/@path)[2])?*  
  where $repo?name and $repo?clone_url
  return
    <source name="{$repo?name}" type="git" path="{$repo?clone_url}" />
};

declare function local:retrieve-sources($config as document-node()) {
  for $source in $config//sources
  let $out := doc(trace($source/@url))   
  return
    ( $out//source,
      for $git in $out//git-source return 
        local:retrieve-git-sources($git)
    )
};

declare function local:create-directories($directories) {
  for $dir in $directories return
  try { file:create-dir(string-join($directories, '\\')) } 
  catch * { trace($err:description) }
};

(:'Applies dependencies to folder structure :)
declare function local:process-dependencies($config as document-node()) {
  let $sources := local:retrieve-sources($config) return
  for $directory in $config//dependencies/directory
  let $dir-path := file:current-dir() || '/' || $directory/@path || '/' return
    (local:create-directories(file:current-dir() || '/' || $directory/@path),
     for $dep in $directory/dependency 
     let $path := data(($dep/@path, $sources[@name = $dep/@name]/@path)[1]) 
     let $type := $sources[@name = $dep/@name]/@type
     let $result := try {
        if($type = 'git') then
          prof:void(proc:system("git", ("clone", $path, $dir-path || trace($dep/@name))))
        else ( 
              if(fetch:content-type(trace($path)) = 'application/zip') then (
                let $file := file:temp-dir() || $dep/@name
                return (file:write-binary($file, fetch:binary($path)),
                        prof:void(proc:system("unzip", ($file, '-d', $dir-path)))))
              else if($path) then fetch:text($path) 
              else trace("Failed to find dependency: " || $dep/@name)
        )
      } catch * {
        prof:void(trace($dep, $err:description))
      }
     return
       if($result) then 
         try { file:write($dir-path || '/' || $dep/@name, $result) }
         catch * { trace('Failed to writing dependency: ' || $dep/@name, $result) }
       else ()
    )
};

let $config := doc(file:current-dir() || '/collect.xml')
return 
  local:process-dependencies($config) 

