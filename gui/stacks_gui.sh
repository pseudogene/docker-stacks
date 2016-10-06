#!/bin/bash
#
# Copyright 2015-2016, Micha‘l Bekaert <michael.bekaert@stir.ac.uk>
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
DEBIAN_FRONTEND=noninteractive apt-get install -y wget gcc g++ make --no-install-recommends
DEBIAN_FRONTEND=noninteractive apt-get install -y zlib1g-dev libdbd-mysql-perl samtools libbam-dev perl mysql-client --no-install-recommends

perl -MCPAN -e 'my $c = "CPAN::HandleConfig"; $c->load(doit => 1, autoconfig => 1); $c->edit(prerequisites_policy => "follow"); $c->edit(build_requires_install_policy => "yes"); $c->commit'
perl -MCPAN -e 'force install Spreadsheet::WriteExcel'


wget http://catchenlab.life.illinois.edu/stacks/source/stacks-${STACKVERSION}.tar.gz
tar xzf stacks-${STACKVERSION}.tar.gz
cd stacks-${STACKVERSION} || exit
./configure --enable-bam --with-bam-include-path=/usr/include/samtools --with-bam-lib-path=/usr/lib
make -j 8
make -j 8 -k install
make -j 8 -k install
sed -i -e 's,$mysql_config;,$mysql_config;\nmy $cnf_secure = $cnf . (exists $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} ? " --host=" . $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} : (exists $ENV{"MYSQL_HOST"} ? " --host=" . $ENV{"MYSQL_HOST"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} ? " --password=" . $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} : (exists $ENV{"MYSQL_PASS"} ? " --password=" . $ENV{"MYSQL_PASS"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_USER"} ? " --user=" . $ENV{"MYSQL_APP_ENV_MYSQL_USER"} : (exists $ENV{"MYSQL_USER"} ? " --user=" . $ENV{"MYSQL_USER"} : q{}));,' -i -e 's,mysql --defaults-file=$cnf,mysql --defaults-file=$cnf_secure,g' /usr/local/bin/denovo_map.pl
sed -i -e 's,$mysql_config;,$mysql_config;\nmy $cnf_secure = $cnf . (exists $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} ? " --host=" . $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} : (exists $ENV{"MYSQL_HOST"} ? " --host=" . $ENV{"MYSQL_HOST"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} ? " --password=" . $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} : (exists $ENV{"MYSQL_PASS"} ? " --password=" . $ENV{"MYSQL_PASS"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_USER"} ? " --user=" . $ENV{"MYSQL_APP_ENV_MYSQL_USER"} : (exists $ENV{"MYSQL_USER"} ? " --user=" . $ENV{"MYSQL_USER"} : q{}));,' -i -e 's,mysql --defaults-file=$cnf,mysql --defaults-file=$cnf_secure,g' /usr/local/bin/ref_map.pl
sed -i -e 's,DBI:mysql:$db:mysql,DBI:mysql:$db:" . (exists $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} ? ";host=" . $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} : (exists $ENV{"MYSQL_HOST"} ? ";host=" . $ENV{"MYSQL_HOST"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} ? ";password=" . $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} : (exists $ENV{"MYSQL_PASS"} ? ";password=" . $ENV{"MYSQL_PASS"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_USER"} ? ";user=" . $ENV{"MYSQL_APP_ENV_MYSQL_USER"} : (exists $ENV{"MYSQL_USER"} ? ";user=" . $ENV{"MYSQL_USER"} : q{})) . ";mysql,g' /usr/local/bin/export_sql.pl
sed -i -e 's,DBI:mysql:$db:mysql,DBI:mysql:$db:" . (exists $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} ? ";host=" . $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} : (exists $ENV{"MYSQL_HOST"} ? ";host=" . $ENV{"MYSQL_HOST"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} ? ";password=" . $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} : (exists $ENV{"MYSQL_PASS"} ? ";password=" . $ENV{"MYSQL_PASS"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_USER"} ? ";user=" . $ENV{"MYSQL_APP_ENV_MYSQL_USER"} : (exists $ENV{"MYSQL_USER"} ? ";user=" . $ENV{"MYSQL_USER"} : q{})) . ";mysql,g' -i -e 's,$mysql_config;,$mysql_config;\nmy $cnf_secure = $cnf . (exists $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} ? " --host=" . $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} : (exists $ENV{"MYSQL_HOST"} ? " --host=" . $ENV{"MYSQL_HOST"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} ? " --password=" . $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} : (exists $ENV{"MYSQL_PASS"} ? " --password=" . $ENV{"MYSQL_PASS"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_USER"} ? " --user=" . $ENV{"MYSQL_APP_ENV_MYSQL_USER"} : (exists $ENV{"MYSQL_USER"} ? " --user=" . $ENV{"MYSQL_USER"} : q{}));,' -i -e 's,mysql --defaults-file=$cnf,mysql --defaults-file=$cnf_secure,g' /usr/local/bin/index_radtags.pl
sed -i -e 's,$mysql_config;,$mysql_config;\nmy $cnf_secure = $cnf . (exists $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} ? " --host=" . $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} : (exists $ENV{"MYSQL_HOST"} ? " --host=" . $ENV{"MYSQL_HOST"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} ? " --password=" . $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} : (exists $ENV{"MYSQL_PASS"} ? " --password=" . $ENV{"MYSQL_PASS"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_USER"} ? " --user=" . $ENV{"MYSQL_APP_ENV_MYSQL_USER"} : (exists $ENV{"MYSQL_USER"} ? " --user=" . $ENV{"MYSQL_USER"} : q{}));,' -i -e 's,mysql --defaults-file=$cnf,mysql --defaults-file=$cnf_secure,g' /usr/local/bin/load_radtags.pl
sed -i -e 's,DBI:mysql:$db:mysql,DBI:mysql:$db:" . (exists $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} ? ";host=" . $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} : (exists $ENV{"MYSQL_HOST"} ? ";host=" . $ENV{"MYSQL_HOST"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} ? ";password=" . $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} : (exists $ENV{"MYSQL_PASS"} ? ";password=" . $ENV{"MYSQL_PASS"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_USER"} ? ";user=" . $ENV{"MYSQL_APP_ENV_MYSQL_USER"} : (exists $ENV{"MYSQL_USER"} ? ";user=" . $ENV{"MYSQL_USER"} : q{})) . ";mysql,g' /usr/local/bin/load_sequences.pl
chown www-data:www-data /usr/local/share/stacks/php/export
cd ..

DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-client php5-mysqlnd libspreadsheet-writeexcel-perl --no-install-recommends

echo -e "[client]\nport=3306\nlocal-infile=1\n" > /usr/local/share/stacks/sql/mysql.cnf
cp /usr/local/share/stacks/sql/mysql.cnf /root/.my.cnf


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
