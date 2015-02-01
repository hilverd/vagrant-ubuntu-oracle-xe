## Oracle JDBC Driver

This folder is here to provide people that use this project a way to install Oracle JDBC driver in their
local Maven repository on the host.

### Installation (Manual)

You don't need to do this by hand; Puppet has instructions to run these steps automatically on the guest. These steps
are provided here for reference.

1. Go to [http://www.oracle.com/technetwork/database/enterprise-edition/jdbc-112010-090769.html](http://www.oracle.com/technetwork/database/enterprise-edition/jdbc-112010-090769.html)
2. Accept the license and download the `ojdbc6.jar` file under the *Oracle Database 11g Release 2 (11.2.0.4) JDBC
   Drivers* heading ("Classes for use with JDK 1.6. It contains the JDBC driver classes except classes for NLS support
   in Oracle Object and Collection types.").
3. Execute the following maven command to place the jar in your local Maven repository (`~/.m2/repository`):

        mvn install:install-file -Dfile=ojdbc6.jar -DpomFile=pom.xml

If you are running this command on Windows, since Windows' shell is terrible, you need to quote each argument
individually, like so:

    mvn install:install-file '-Dfile=ojdbc6.jar' '-DpomFile=pom.xml'
