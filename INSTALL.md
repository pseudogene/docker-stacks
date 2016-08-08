# Build manually

```
git clone https://github.com/pseudogene/docker-stacks.git
cd docker-stacks

docker build -t pseudogene/docker-stacks:cli .
docker tag -f pseudogene/docker-stacks:cli pseudogene/docker-stacks:1.42
docker tag -f pseudogene/docker-stacks:cli pseudogene/docker-stacks:1.42-cli
docker tag -f pseudogene/docker-stacks:cli pseudogene/docker-stacks:latest

cd gui
docker build -t pseudogene/docker-stacks:gui .
docker tag -f pseudogene/docker-stacks:gui pseudogene/docker-stacks:1.42-gui

cd ../..
```

# Start one-in-one
Start docker Daemons:

```
mkdir -p /var/lib/mysql
docker run -d --restart=always -v /var/lib/mysql:/var/lib/mysql -p 3306:3306 -e MYSQL_PASS="dbpass" -e MYSQL_USER="dbuser" --name MySQL-App tutum/mysql
docker run -d --restart=always -p 80:80 --link MySQL-App:MySQL-App --name stacks-gui pseudogene/docker-stacks:gui

docker run -it --rm -v /export:/mnt --link MySQL-App:MySQL-App docker-stacks:cli /bin/bash
```

And start the Stacks Tutorial:

```
wget http://catchenlab.life.illinois.edu/stacks/tutorial/stacks_samples.tar.gz
tar xfz stacks_samples.tar.gz
add_database.pl tut2_radtags
mkdir stacks
denovo_map.pl -m 3 -M 2 -n 3 -T 15 -B tut2_radtags -b 1 -t -a 2016-06-22  -D "Tutorial cross Genetic Map RAD-Tag Samples"  -o ./stacks  -p ./stacks_samples/male.fa  -p ./stacks_samples/female.fa -r ./stacks_samples/progeny_1.fa -r ./stacks_samples/progeny_2.fa  -r ./stacks_samples/progeny_3.fa
```

You can then access the interface via your web browser at

>    http://localhost/stacks/

# Start on remote servers

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
