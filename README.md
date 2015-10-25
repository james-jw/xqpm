# xqpm
Simple Ant like dependency managament script for populating service directories from remote repositories using purely xquery.

## How it works
A local sources file generally found `~/.xqpm.xml`, which is created during the install outlines the directory structure for future installs. Take a look to see how it works.

Custom paths can be defined as necessary. The default 7 or so paths provided should remain, although can be altered to match your system, for use with generic xqpm usage.

If a package uses a path not defined, it can define the path in its own xqpm parameters. See the xqpm.xml files for example.

### Dependencies
Currently, BaseX, git and unzip are the only required system dependencies.

### Installation
You can use xqpm to install itself!

Within a bash command prompt type the following, providing the path to the BaseX directory for bpath:
<pre>basex -bpath=/root/basex https://raw.githubusercontent.com/james-jw/xqpm/master/install.xq</pre>
In the above example, BaseX would be intalled in the <code>/root</code> folder. 

##### Manual Install
* Clone this directory to your Basex/repo folder.
* Add the <code>xqpm/src</code> folder to your path

### Usage
1) Create a <code>xqpm.xml</code>file to define the xqpm collection process. <br />
2) In the same folder, execute: <code>xqpm</code> to retreive the dependencies.

A xqpm.xml file defines where the source mapping files are located, as well as what dependencies are required and where to place them. See xqpm.xml for an example.

The use cases for this module is not just XQuery module installation like the [expath package][0] spec, but is intended for configuring arbitrary directory structures and system variables.

##### Sources
The collect.xml file can reference multiple sources.xml files for aliasing package names. This is not required but simplifies the configuration by reducing the need for defining dependency paths. See the collect.xml and sources.xml file for an example.

#### Shout Out!
If you like what you see here please star the repo and follow me on github or linkedIn

Happy forking!!
