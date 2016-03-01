#!/bin/bash
#
# Copyright 2015-2016, Michaël Bekaert <michael.bekaert@stir.ac.uk>
#
# This file is part of docker-stacks.
#
# Docker-Stacks is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Docker-Stacks is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Docker-Stacks.If not, see <http://www.gnu.org/licenses/>.
#

STACKVERSION=1.37
DOCKERVERSION=1.0

DEBIAN_FRONTEND=noninteractive apt-get install -y wget gcc g++ make --no-install-recommends
DEBIAN_FRONTEND=noninteractive apt-get install -y zlib1g-dev libdbd-mysql-perl libsparsehash-dev samtools libbam-dev perl mysql-client --no-install-recommends
ln -s /usr/include/google /usr/include/sparsehash

wget http://catchenlab.life.illinois.edu/stacks/source/stacks-${STACKVERSION}.tar.gz
tar xzf stacks-${STACKVERSION}.tar.gz
cd stacks-${STACKVERSION} || exit
./configure --enable-sparsehash --enable-bam --with-bam-include-path=/usr/include/samtools --with-bam-lib-path=/usr/lib
make -j 8

/bin/mkdir -p '/usr/local/share/stacks/php'
/usr/bin/install -c -m 644  php/CatalogClass.php php/annotate_marker.php php/constants.php.dist php/index.php php/tags.php php/Locus.php php/catalog.php php/correct_genotypes.php php/correct_genotype.php php/export_batch.php php/last_modified.php php/version.php php/catalog_genotypes.php php/db_functions.php php/header.php php/samples.php php/stacks_functions.php php/view_sequence.php php/sequence_blast.php php/pop_view.php php/sumstat_view.php php/hapstat_view.php php/fst_view.php php/phist_view.php php/stack_view.php php/population_view.js php/ajax.js php/annotate.js php/stacks.js php/export.js php/stacks.css '/usr/local/share/stacks/php'
/bin/mkdir -p '/usr/local/share/stacks/php/images'
/usr/bin/install -c -m 644  php/images/caret-d.png php/images/caret-u.png php/images/excel_icon.png php/images/l-arrow-disabled.png php/images/l-arrow.png php/images/r-arrow-disabled.png php/images/r-arrow.png php/images/stacks_bg.png php/images/stacks_logo_rev_small.png '/usr/local/share/stacks/php/images'

sed -e 's,_PKGDATADIR_,/usr/local/share/stacks/,g' -e 's,_BINDIR_,/usr/local/bin/,g' \
		/usr/local/share/stacks/php/constants.php.dist > /usr/local/share/stacks/php/constants.php.dist.subst
mv /usr/local/share/stacks/php/constants.php.dist.subst /usr/local/share/stacks/php/constants.php.dist

/bin/mkdir -p '/usr/local/share/stacks/php/export'
/bin/chmod 755 /usr/local/share/stacks/php/export
chown www-data:www-data /usr/local/share/stacks/php/export

cd ..

DEBIAN_FRONTEND=noninteractive apt-get install -y php-mdb2-driver-mysql php-pear php-mdb2 --no-install-recommends
docker-php-ext-install mysql
pear install pear/MDB2#mysql
pear install MDB2_Driver_mysql

echo -e "[client]\nport=3306\nlocal-infile=1\n" > /root/.my.cnf

touch "/etc/apache2/conf-available/stacks.conf"
cat > "/etc/apache2/conf-available/stacks.conf" <<EOM
Alias /stacks "/usr/local/share/stacks/php"
<Directory "/usr/local/share/stacks/php">
    Order deny,allow
    Deny from all
    Allow from all
    Require all granted
</Directory>
<IfModule mod_php5.c>
    php_value include_path ".:/usr/share/php:/usr/local/lib/php"
    php_admin_flag engine on
</IfModule>
EOM
ln -s /etc/apache2/conf-available/stacks.conf /etc/apache2/conf-enabled/stacks.conf

echo "${STACKVERSION}</a><br><a href=\"https://github.com/mbekaert/docker-stacks/\">docker ${DOCKERVERSION}</a>" > /usr/local/share/stacks/php/version.php

echo -e "<!DOCTYPE HTML>\n<meta charset=\"UTF-8\"><meta http-equiv=\"refresh\" content=\"1; url=/stacks\"><script> window.location.href = \"/stacks\" </script><title>Page Redirection</title>If you are not redirected automatically, follow the <a href=\"/stacks\">link to Stacks</a>\n" > /var/www/html/index.php
chown www-data:www-data /var/www/html/index.php

sed -e 's,"dbuser",(!empty($_ENV["MYSQL_APP_ENV_MYSQL_USER"]) ? $_ENV["MYSQL_APP_ENV_MYSQL_USER"] : (!empty($_ENV["MYSQL_USER"]) ? $_ENV["MYSQL_USER"] : "dbuser")),g' -e 's,"dbpass",(!empty($_ENV["MYSQL_APP_ENV_MYSQL_PASS"]) ? $_ENV["MYSQL_APP_ENV_MYSQL_PASS"] : (!empty($_ENV["MYSQL_PASS"]) ? $_ENV["MYSQL_PASS"] : "dbpass")),g' -e 's,"localhost",(!empty($_ENV["MYSQL_APP_PORT_3306_TCP_ADDR"]) ? $_ENV["MYSQL_APP_PORT_3306_TCP_ADDR"] : (!empty($_ENV["MYSQL_HOST"]) ? $_ENV["MYSQL_HOST"] : "localhost")),g' /usr/local/share/stacks/php/constants.php.dist > /usr/local/share/stacks/php/constants.php

DEBIAN_FRONTEND=noninteractive apt-get remove -y gcc g++ make
DEBIAN_FRONTEND=noninteractive apt-get autoremove -y
DEBIAN_FRONTEND=noninteractive apt-get autoclean -y
DEBIAN_FRONTEND=noninteractive apt-get clean

rm -rf stacks-${STACKVERSION}.tar.gz stacks-${STACKVERSION}
