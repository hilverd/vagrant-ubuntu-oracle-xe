## data-with-flyway

This sub-project for https://github.com/hilverd/vagrant-ubuntu-oracle-xe that contains a means for creating tables and 
inserting data into the Oracle Express instance the parent project provides.

Given you've followed all of the instructions on the parent project's README, this project is executed automatically
by Puppet during provisioning. 

If you want to add more tables and/or data to the Oracle Express instance, create files in src/main/resources/database/migrations
following the examples provided. The included examples are originally from the [Flyway Getting Started documentation](http://flywaydb.org/getstarted/firststeps/maven.html), with
some Oracle specific changes.

Learn more about adding migrations [here](http://flywaydb.org/documentation/migration/) and [here](http://flywaydb.org/documentation/migration/sql.html).

### Running Flyway manually

While the guest provided by the parent project is running, you can run Flyway commands manually.
You will need to perform the steps documented in [the README for oracle-jdbc](../oracle-jdbc/README.md) to install the Oracle JDBC
driver in your Maven repository on the host OS.

Once done, running additional migrations is as simple as:

> mvn install flyway:migrate

If you want to drop the schema and start over from scratch:

> mvn flyway:clean

More commands are documented at [http://flywaydb.org/documentation/maven/](http://flywaydb.org/documentation/maven/).

