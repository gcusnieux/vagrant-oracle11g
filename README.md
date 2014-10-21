vagrant-oracle11g
========================

Vagrant + Oralce Linux 6.5 + Oracle Database 11gR2 (Enteprise Edition) setup.
Does not include the DB11g binary.
You need to download that from the official site beforehand.


## Download

Download the database binary (11.2.0) from below.  Unzip to the subdirectory name "database".

http://www.oracle.com/technetwork/database/enterprise-edition/downloads/index.html

* linux.x64_11gR2_database_1of2.zip
* linux.x64_11gR2_database_2of2.zip

## Vagrant Setup

If you are behing a proxy, install vagrant-proxyconf.
```
(MacOSX)
$ export http_proxy=proxy:port
$ export https_proxy=proty:port

(Windows)
$ set http_proxy=proxy:port
$ set https_proxy=proxy:port

$ vagrant plugin install vagrant-proxyconf
```

Install VirtualBox plugin.
```
$ vagrant plugin install vagrant-vbguest
```

Clone this repository to the local directory.  Move the "database" directory to the same folder.
```
$ git clone https://github.com/gcusnieux/vagrant-oracle11g
$ cd vagrant-oracle11g
 ```

If you are behind a proxy, add follwing to Vagrantfile:
```
config.proxy.http     = "http://proxy:port"
config.proxy.https    = "http://proxy:port"
config.proxy.no_proxy = "localhost,127.0.0.1"
```

## Host OS Install (Vagrant)

vagrant up will do the following:
* download CentOS 6.5 and boot up
* convert into Oracle Linux 6.5 https://linux.oracle.com/switch/centos/
* fix locale warning
* install oracle-rdbms-server-11gR2-preinstall
* install UEKR3 and make it a default kernel

```
$ vagrant up
   :
==> default: Oracle Linux Server release 6.5
```

Reboot to switch the kernel to UEKR3.  Confirm that NUMA and Transparent Hugepage is turned "off".
```
$ vagrant reload

$ vagrant ssh

[vagrant@localhost ~]$ dmesg | more
Initializing cgroup subsys cpuset
Initializing cgroup subsys cpu
Linux version 3.8.13-35.3.2.el6uek.x86_64 (mockbuild@ca-build44.us.oracle.com) (gcc version 4.4.7 20120313 (Red Hat 4.4.7-3) (GCC) ) #2 SMP Tue Jul 22 13:17:34 PDT 2014
Command line: ro root=/dev/mapper/VolGroup-lv_root rd_NO_LUKS LANG=en_US.UTF-8 rd_NO_MD rd_LVM_LV=VolGroup/lv_swap SYSFONT=latarcyrheb-sun16 rd_LVM_LV=VolGroup/lv_root  KEYBOARDTYPE=pc KEYTABLE=us rd_NO_DM rhgb quiet numa=off transparent_hugepage=never
   :

[vagrant@localhost ~]$ exit

```

## DB Install

Install Database.
```
bash-4.1# su - oracle

[oracle@localhost ~]$ /vagrant/database/runInstaller -silent -ignorePrereq -responseFile /vagrant/db_install.rsp

Show the log file... 

[oracle@localhost ~]$ exit

bash-4.1# /opt/oraInventory/orainstRoot.sh
bash-4.1# /opt/oracle/product/11.2.0/dbhome_1/root.sh

```

Create listener using netca.
```
bash-4.1# su - oracle

[oracle@localhost ~]$ export DISPLAY=hostname:0.0
[oracle@localhost ~]$ netca -silent -responseFile /vagrant/database/response/netca.rsp

Parsing command line arguments:
    Parameter "silent" = true
    Parameter "responsefile" = /vagrant/database/response/netca.rsp
Done parsing command line arguments.
Oracle Net Services Configuration:
Profile configuration complete.
Oracle Net Listener Startup:
    Running Listener Control: 
      /opt/oracle/product/11.2.0/dbhome_1/bin/lsnrctl start LISTENER
    Listener Control complete.
    Listener started successfully.
Listener configuration complete.
Oracle Net Services configuration successful. The exit code is 0
```

Create Database.
```
[oracle@localhost ~]$ dbca -silent -createDatabase -responseFile /vagrant/dbca.rsp
Copying database files
1% complete
3% complete
11% complete
18% complete
37% complete
Creating and starting Oracle instance
40% complete
45% complete
50% complete
55% complete
56% complete
60% complete
62% complete
Completing Database Creation
66% complete
70% complete
73% complete
85% complete
96% complete
100% complete
Look at the log file "/opt/oracle/cfgtoollogs/dbca/orcl/orcl.log" for further details.
```

Test connection.
```
[oracle@localhost ~]$ sqlplus system/oracle@localhost:1521/orcl

```
