# Oracle XE 11g on Ubuntu 12.04 using Vagrant

This project enables you to install Oracle 11g XE in a virtual machine running
Ubuntu 12.04, using [Vagrant] and [Puppet].

## Acknowledgements

This project was created based on the information in
[Installing Oracle 11g R2 Express Edition on Ubuntu 64-bit] by Manish Raj, and
the GitHub repository [vagrant-oracle-xe] by Stefan Glase. The former explains
how to install Oracle XE 11g on Ubuntu 12.04, without explicitly providing a
Vagrant or provisioner configuration. The latter has the same purpose as this
project but uses Ubuntu 11.10.

Thanks to Brandon Gresham, Charles Walker, Chris Thompson, Jeff Caddel, Matthew
Buckett, Richard Kolb, and Steven Hsu for various contributions.

## Requirements

* You need to have [Vagrant] installed.
* The host machine probably needs at least 4 GB of RAM (I have only tested 8 GB
  of RAM).
* As Oracle 11g XE is only available for 64-bit machines at the moment, the host
  machine needs to have a 64-bit architecture.
* I have tested this project on a host machine running Ubuntu 12.04, but other
  operating systems should also work, as long as they can run Vagrant.

## Installation

* Check out this project:

        git clone https://github.com/hilverd/vagrant-ubuntu-oracle-xe.git

* Install [vbguest]:

        vagrant plugin install vagrant-vbguest

* Download [Oracle Database 11g Express Edition] for Linux x64. Place the file
  `oracle-xe-11.2.0-1.0.x86_64.rpm.zip` in the directory `modules/oracle/files`
  of this project. (Alternatively, you could keep the zip file in some other
  location and make a hard link to it from `modules/oracle/files`.)

* Run `vagrant up` from the base directory of this project. This should take a
  few minutes.

You should now be able to connect to the new database at `localhost:1521/XE`
as `system` with password `manager`. For example, if you have `sqlplus`
installed on the host machine you can do

    sqlplus system/manager@//localhost:1521/XE

You might need to add an entry to your `tnsnames.ora` file first:

    XE =
      (DESCRIPTION =
        (ADDRESS = (PROTOCOL = TCP)(HOST = 127.0.0.1)(PORT = 1521))
        (CONNECT_DATA =
          (SERVER = DEDICATED)
          (SERVICE_NAME = XE)
        )
      )

## Troubleshooting

It is important to assign enough memory to the virtual machine, otherwise you
will get an error

    ORA-00845: MEMORY_TARGET not supported on this system

during the configuration stage. In the `Vagrantfile` 512 MB is assigned. Lower
values may also work, as long as (I believe) 2 GB of virtual memory is available
for Oracle, swap is included in this calculation.

If you want to raise the limit of the number of concurrent connections, say to
200, then according to
[How many connections can Oracle Express Edition (XE) handle?] you should run

    ALTER SYSTEM SET processes=200 scope=spfile

and restart the database.

[Vagrant]: http://www.vagrantup.com/

[Puppet]: http://puppetlabs.com/

[Oracle Database 11g Express Edition]: http://www.oracle.com/technetwork/products/express-edition/overview/index.html

[Oracle Database 11g EE Documentation]: http://docs.oracle.com/cd/E17781_01/index.htm

[Installing Oracle 11g R2 Express Edition on Ubuntu 64-bit]: http://meandmyubuntulinux.blogspot.co.uk/2012/05/installing-oracle-11g-r2-express.html

[vagrant-oracle-xe]: https://github.com/codescape/vagrant-oracle-xe

[vbguest]: https://github.com/dotless-de/vagrant-vbguest

[How many connections can Oracle Express Edition (XE) handle?]: http://stackoverflow.com/questions/906541/how-many-connections-can-oracle-express-edition-xe-handle
