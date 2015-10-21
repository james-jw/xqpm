# xqpm
Simple Ant like dependency managament script for populating service directories from remote repositories using purely xquery.

###Dependencies
Currently, BaseX, git and unzip are the only required system dependencies.

###Installation
You can use xqpm to install itself!

Within a bash command prompt type the following, providing the path to the BaseX directory for bpath:
<pre>basex -bpath=/root/basex https://raw.githubusercontent.com/james-jw/xqpm/master/install.xq</pre>
In the above example, BaseX would be intalled in the <code>/root</code> folder. 

####Manual Install
* Clone this directory to your Basex/repo folder.
* Add the <code>xqpm/src</code> folder to your path

###Usage
1) Create a <code>collect.xml</code>file to define the xqpm collection process. <br />
2) In the same folder, execute: <code>basex ~/basex/repo/xqpm/src/xqpm.xq</code> to retreive the dependencies.

A collect.xml file defines where the source mapping files are located, as well as what dependencies are required and where to place them. See collect.xml for an example.

####Sources
The collect.xml file can reference multiple sources.xml files for aliasing package names. This is not required but simplifies the configuration by reducing the need for defining dependency paths. See the collect.xml and sources.xml file for an example.
