## Data With Flyway

This sub-project contains a means for creating tables and inserting data into the Oracle Express database.

Given you have followed all of the instructions on the parent project's README, this project is executed automatically
by Puppet during (re)provisioning.

If you want to add more tables and/or data to the Oracle Express instance, create files in

    src/main/resources/database/migrations
 
following the examples provided. The included examples are originally from the
[Flyway Getting Started documentation](http://flywaydb.org/getstarted/firststeps/maven.html), with some Oracle-specific
changes.

To learn more about adding migrations, read [Migrations & Versions](http://flywaydb.org/documentation/migration/) and
[Sql-based migrations](http://flywaydb.org/documentation/migration/sql.html).

After adding files in `src/main/resources/database/migrations`, a quick way to run the Flyway migrations is

    vagrant ssh -c 'bash ~/vagrant-ubuntu-oracle-xe/flyway.sh'

### Running Flyway Manually on the Host

You could also run Flyway manually on the host, assuming Oracle XE is up and running in the VM. You will need to perform
the steps documented in the [README for oracle-jdbc](../oracle-jdbc/README.md) to install the Oracle JDBC driver in your
Maven repository on the host OS.

Once done, running additional migrations is as simple as:

    mvn install flyway:migrate

If you want to drop the schema and start over from scratch:

    mvn flyway:clean

More commands are documented at [http://flywaydb.org/documentation/maven/](http://flywaydb.org/documentation/maven/).
