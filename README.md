# xqpm
Simple Ant like dependency managament script for populating service directories from remote repositories using purely xquery.


* [How it works](#how-it-works)
* [Dependencies](#dependencies)
* [Version 1 Beta](#version-v01-beta)
* [Installation](#installation)
 + [Maunal Install](#manual-install)
* [Usage](#usage)
 + [Use Case](#use-case)
 + [Sources](#sources)
* [Shout Out](#shout-out)

## How it works
A local ``configuration`` file located at `~/.xqpm.xml` will be created during the install. It outlines the directory structure for future installs. Take a look to see how it works!

Custom paths can be defined as necessary; however, the default paths provided should remain. Although they can be altered to match your system, their name should remain defined for use with generic xqpm packages published on github.

If a package uses a path not defined, it can define the path in its own xqpm parameters. Here is an example of what the default ``.xqpm.xml`` configuration file will contain:

```xml
<config>
    <sources url="https://raw.githubusercontent.com/james-jw/xqpm/master/sources.xml" />
    <params>
      <param name="home">~/root</param>
      <param name="base">~/root/basex</param>
      <param name="repo">{{base}}/repo</param>
      <param name="lib">{{base}}/lib</param>
      <param name="webapp">{{base}}/webapp</param>
      <param name="static">{{webapp}}/static</param>
      <param name="js">{{static}}/js</param>
      <param name="css">{{static}}/css</param>
      <param name="fonts">{{static}}/fonts</param>
    </params>
  </config>
  ```

Notice how the paths are dependent on eachother. The key paths are ``home`` and ``base``. Unless your structure changes, nothing else should need to be modified.

### Dependencies
Currently, BaseX, git and unzip are the only required system dependencies.

### Version v0.1 Beta
This is the initial release and likley has many quirks to work out. Please report any issues you run into so I can harden the release.

### Installation
You can use xqpm to install itself!

Within a bash command prompt type the following, providing the path to the BaseX directory for ``bpath``:
```bash
basex -bpath=/root/basex https://raw.githubusercontent.com/james-jw/xqpm/master/install.xq
```

In the above example, BaseX would be intalled in the <code>/root</code> folder. 

##### Manual Install
* Clone this directory to your Basex/repo folder.
* Add the <code>xqpm/src</code> folder to your path

### Usage
1) Create a <code>xqpm.xml</code>file to define the xqpm collection process. <br />
2) In the same folder, execute: <code>xqpm</code> to retreive the dependencies.

A xqpm.xml file defines where the source mapping files are located, as well as what dependencies are required and where to place them. Here is an example, and in fact, the dependency file for this module:

```xml
<config>
  <sources url="https://raw.githubusercontent.com/james-jw/xqpm/master/sources.xml" />
  <dependencies>
    <directory path="{{repo}}">
      <dependency name="xqpm" />
      <dependency name="xqpm-install" type="command" path="{{base}}/bin/basex">
        <argument>-c"repo install '{{repo}}/xqpm/src/xqpm.xqm'"</argument>
      </dependency>
      <dependency name="xq-mustache" />
    </directory>
    <directory path="{{base}}/bin">
      <dependency name="xqpm" path="https://raw.githubusercontent.com/james-jw/xqpm/master/src/xqpm" />
    </directory>
  </dependencies>
</config>
```

Notice how directory paths and other variables use ``{{mustache}}`` syntax to resolve values. The values come from the user ``.xqpm.xml`` configuration file, as well as the dependency file being installed. 

##### Use Case
The use cases for this module is not just XQuery module installation like the [expath package][0] spec, but is intended for configuring arbitrary directory structures and system variables.

##### Sources
An ``xqpm.xml`` file can reference multiple ``sources.xml`` files for aliasing package names. Although this is not required. It simplifies the configuration by reducing the need for defining dependency paths. See the xqpm.xml and sources.xml file for an example.

#### Shout Out!
If you like what you see here please star the repo and follow me on github or linkedIn

Happy forking!!

[0]: http://expath.org/modules/pkg/
