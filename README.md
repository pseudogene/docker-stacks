# pseudogene / docker-stacks

[![](https://images.microbadger.com/badges/image/pseudogene/docker-stacks.svg)](https://microbadger.com/images/pseudogene/docker-stacks)

## Short Description
Stacks is a software pipeline for building loci from short-read sequences - Now in a Docker


## Full Description
Supported tags and respective Dockerfile links

 * `1.42`, `cli`, `latest` ([`Dockerfile`](https://github.com/pseudogene/docker-stacks/blob/master/Dockerfile))
 * `gui` ([`gui/Dockerfile`](https://github.com/pseudogene/docker-stacks/blob/master/gui/Dockerfile))

For more information about this image and its history, please see the relevant manifest file. This image is updated via pull requests to the `docker-stacks` [GitHub repo](https://github.com/pseudogene/docker-stacks/).

### What is STACKS?

[Stacks](http://catchenlab.life.illinois.edu/stacks/) is a software pipeline for building loci from short-read sequences, such as those generated on the Illumina platform. Stacks was developed to work with restriction enzyme-based data, such as RAD-seq, for the purpose of building genetic maps and conducting population genomics and phylogeography. Stacks is developed by Julian Catchen <jcatchen@illinois.edu> with contributions from Angel Amores <amores@uoregon.edu >, Paul Hohenlohe <hohenlohe@uidaho.edu>, and Bill Cresko <wcresko@uoregon.edu>.

>    http://catchenlab.life.illinois.edu/stacks/

### How to use this image.

For Stacks run through the command line interface (CLI). Stacks programs output simple, tab-separated values files, however, if one doesn’t have access to MySQL. To use the web-based graphic user interface (GUI), Stacks relies on the MySQL database. For more flexibility Stacks has been split into two docker, CLI and GUI allowing the deployment on Cloud, Cluster and docker Swamp.

### How to run this image with Command Line

For Stacks run through the command line interface (CLI) Docker image, you can do the following.

By default the path is `/mnt`, the import and export the result of your analyse you need to link the folder we your data are to the docker `/mnt` folder by user `-v <USERFOLDER>:/mnt`.

```
$ docker run -it --rm -v /export:/mnt pseudogene/docker-stacks:cli \
   ustacks -t fastq -f /mnt/f0_male.fq -o /mnt/stacks -i 1 -d -r -m 3 -M
```

Similarly, if you want to the CLI to access MySQL database you need to provide the server address, username and password via the environment variable: `-e MYSQL_HOST="<HOSTIP>" -e MYSQL_PASS="<MYSQLPASS>" -e MYSQL_USER="<MYSQLUSER>"`:

```
$ docker run -it --rm -v /export:/mnt -e MYSQL_HOST="127.0.0.1" \
   -e MYSQL_PASS="dbpass" -e MYSQL_USER="dbuser" pseudogene/docker-stacks:cli \
   denovo_map.pl -m 3 -M 3 -n 2 -T 15 -B tut_radtags -b 1 -A CP -t \
                                  -D "Genetic Map RAD-Tag Samples" \
                                  -o /mnt/stacks \
                                  -p /mnt/samples/f0_male.fq \
                                  -p /mnt/samples/f0_female.fq \
                                  -r /mnt/samples/progeny_01.fq \
                                  -r /mnt/samples/progeny_02.fq \
                                  -r /mnt/samples/progeny_03.fq
```

#### Add a _Stacks_ MySQL database

If you plan to use a MySQL database, Stacks requires you to manually create it. To simplify the process and allows more flexibility (specially regarding the location of the database and credentials) a small script has been add `add_database.pl`. Remember Stacks always use a constant suffix on our Stacks databases ('_radtags') to make it easy to set up blanket database permissions.

Here we will name the database after the tutorial.

```
docker run -it --rm -v /export:/mnt -e MYSQL_HOST="127.0.0.1" \
   -e MYSQL_PASS="dbpass" -e MYSQL_USER="dbuser" pseudogene/docker-stacks:cli \
   add_database.pl tut_radtags
```


### How to run this image with web-based graphic user interface

You will probably want to explore your analysis using the web-based graphic user interface. the web interface is highly recommended to help visualise your data, and if building a genetic map, to enable easy manual corrections to the data. PHP in conjunction with Apache httpd. Conveniently, we packaged the GUI docker with Stack web-interface with the Apache web server and PHP.
Modern versions of PHP (release 7) don't implement the old mysql driver, so currently the PHP release 5 is implemented.

To access MySQL database you need to provide the server address, username and password via the environment variable: `-e MYSQL_HOST="<HOSTIP>" -e MYSQL_PASS="<MYSQLPASS>" -e MYSQL_USER="<MYSQLUSER>"`. Run the commands to run the Docker image:

```
$ docker run -it --rm -p 80:80 -e MYSQL_HOST="127.0.0.1" \
   -e MYSQL_PASS="dbpass" -e MYSQL_USER="dbuser" pseudogene/docker-stacks:gui
```

We recommend that you run it as a background daemon:

```
$ docker run -d --restart=always -p 80:80 -e MYSQL_HOST="127.0.0.1" \
   -e MYSQL_PASS="dbpass" -e MYSQL_USER="dbuser" --name stacks-web pseudogene/docker-stacks:gui
```

You can then access the interface via your web browser at

>    http://localhost/stacks/


### All-in-one server

You will need a MySQL service, the Stacks GUI and Stacks CLI. If this example we will user the [`tutum/mysql`](https://hub.docker.com/r/tutum/mysql/) docker image for MySQL.

Start MySQL docker Daemon:

```
$ mkdir -p /var/lib/mysql
$ docker run -d --restart=always -v /var/lib/mysql:/var/lib/mysql -p 3306:3306 \
  -e MYSQL_PASS="dbpass" -e MYSQL_USER="dbuser" --name MySQL-App tutum/mysql
```

Start Stacks GUI docker Daemon:

```
$ docker run -d --restart=always -p 80:80 --link MySQL-App:MySQL-App \
  --name stacks-gui pseudogene/docker-stacks:gui
```

Stacks Tutorial run:

```
$ docker run -it --rm -v /export:/mnt --link MySQL-App:MySQL-App \
   pseudogene/docker-stacks:cli \
   denovo_map.pl -m 3 -M 3 -n 2 -T 15 -B tut_radtags -b 1 -A CP -t \
                                  -D "Genetic Map RAD-Tag Samples" \
                                  -o /mnt/stacks \
                                  -p /mnt/samples/f0_male.fq \
                                  -p /mnt/samples/f0_female.fq \
                                  -r /mnt/samples/progeny_01.fq \
                                  -r /mnt/samples/progeny_02.fq \
                                  -r /mnt/samples/progeny_03.fq
```

You can then access the interface via your web browser at

>    http://localhost/stacks/

Stop/remove everything

```
$ docker stop stacks-gui
$ docker rm stacks-gui
$ docker stop MySQL-App
$ docker rm MySQL-App
$ rm -rf /var/lib/mysql/*
```

### Remote servers access

Start MySQL docker Daemon on **Server #1** (IP 10.0.0.10):

```
$ mkdir -p /var/lib/mysql
$ docker run -d --restart=always -v /var/lib/mysql:/var/lib/mysql -p 3306:3306 \
  -e MYSQL_PASS="dbpass" -e MYSQL_USER="dbuser" --name MySQL-App tutum/mysql
```

Start Stacks GUI docker Daemon on **Server #2** (IP 10.0.0.20):

```
$ docker run -d --restart=always -p 80:80 -e MYSQL_HOST="10.0.0.10" \
   -e MYSQL_PASS="dbpass" -e MYSQL_USER="dbuser" \
   --name stacks-gui pseudogene/docker-stacks:gui
```

Stacks Tutorial run on **Server #3** (IP 10.0.0.30):

```
$ docker run -it --rm -v /export:/mnt -e MYSQL_HOST="10.0.0.10" \
   -e MYSQL_PASS="dbpass" -e MYSQL_USER="dbuser" pseudogene/docker-stacks:cli \
   denovo_map.pl -m 3 -M 3 -n 2 -T 15 -B tut_radtags -b 1 -A CP -t \
                                  -D "Genetic Map RAD-Tag Samples" \
                                  -o /mnt/stacks \
                                  -p /mnt/samples/f0_male.fq \
                                  -p /mnt/samples/f0_female.fq \
                                  -r /mnt/samples/progeny_01.fq \
                                  -r /mnt/samples/progeny_02.fq \
                                  -r /mnt/samples/progeny_03.fq
```

You can then access the interface via your web browser at

>    http://10.0.0.20/stacks/


### Colophon

Please see the Docker installation documentation for details on how to upgrade your Docker daemon.

#### User Feedback Documentation

Be sure to familiarise yourself with the repository's [README.md](https://github.com/pseudogene/docker-stacks/blob/master/README.md) file before attempting a pull request.

#### Issues

If you have any problems with or questions about this docker image, please contact us through a [GitHub issue](https://github.com/pseudogene/docker-stacks/issues).
Any issue related to Stacks itself must be done directly with [Stacks developers](http://catchenlab.life.illinois.edu/stacks/) or via the [stacks-user mailing list](http://groups.google.com/group/stacks-users).


#### Contributing

You are invited to contribute new features, fixes, or updates, large or small; we are always thrilled to receive pull requests, and do our best to process them as fast as we can.

Before you start to code, we recommend discussing your plans through a [GitHub issue](https://github.com/pseudogene/docker-stacks/issues), especially for more ambitious contributions. This gives other contributors a chance to point you in the right direction, give you feedback on your design, and help you find out if someone else is working on the same thing.
