# ps-dpk-tarball

> Create DPK tarballs from patched Java and WebLogic

This repository contains sample scripts to create custom DPK tarballs to be used by the DPK to deploy patched versions of WebLogic and Java. There are three scripts: 

* `createCPUTarballs.ps1`: Create `.tgz` files from a `JAVA_HOME` and WebLogic `ORACLE_HOME` directories. 
* `cpu.ps1`: Sample script showing how to apply CPU patches using the custom `.tgz` files.
* `middleware.pp`: Puppet manifest to deploy only middleware changes with the DPK

To learn more about these scripts, [read this blog post]().