# xq-ant
Simple Ant like dependency managament script for populating service directories from remote repositories using purely xquery.

<h3>Dependencies</h3>
Currently, baseX, git and unzip are the only required system dependencies.

<h3>Installation</h3>
Clone this directory to your Basex/repo folder.
Add the basex/bin folder to your path

<h3>Usage</h3>
1) Create a <code>collect.xml</code>file to define the xq-ant collection process. <br />
2) In the same folder, execute: <code>basex ~/basex/repo/xq-ant/src/xq-ant.xq</code> to retreive the dependencies.

A collect.xml file defines where the source mapping files are located, as well as what dependencies are required and where to place them. See collect.xml for an example.

<h5>Sources</h5>
The collect.xml file can reference multiple sources.xml files for aliasing package names. This is not required but simplifies the configuration by reducing the need for defining dependency paths. See the collect.xml and sources.xml file for an example.
