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

perl -MCPAN -e 'my $c = "CPAN::HandleConfig"; $c->load(doit => 1, autoconfig => 1); $c->edit(prerequisites_policy => "follow"); $c->edit(build_requires_install_policy => "yes"); $c->commit'
perl -MCPAN -e 'force install Spreadsheet::WriteExcel'

wget http://catchenlab.life.illinois.edu/stacks/source/stacks-${STACKVERSION}.tar.gz
tar xzf stacks-${STACKVERSION}.tar.gz
cd stacks-${STACKVERSION} || exit
./configure --enable-sparsehash --enable-bam --with-bam-include-path=/usr/include/samtools --with-bam-lib-path=/usr/lib
make -j 8

/bin/mkdir -p '/usr/local/bin'
/usr/bin/install -c ustacks pstacks estacks cstacks sstacks rxstacks hstacks process_radtags process_shortreads kmer_filter clone_filter genotypes populations phasedstacks '/usr/local/bin'
/bin/mkdir -p '/usr/local/bin'
/usr/bin/install -c scripts/denovo_map.pl scripts/ref_map.pl scripts/export_sql.pl scripts/sort_read_pairs.pl scripts/exec_velvet.pl scripts/load_sequences.pl scripts/index_radtags.pl scripts/load_radtags.pl scripts/stacks_export_notify.pl '/usr/local/bin'
/bin/mkdir -p '/usr/local/share/stacks'
/bin/mkdir -p '/usr/local/share/stacks/sql'
/usr/bin/install -c -m 644  sql/mysql.cnf.dist sql/catalog_index.sql sql/stacks.sql sql/tag_index.sql sql/chr_index.sql '/usr/local/share/stacks/sql'

sed -e "s,_VERSION_,${STACKVERSION}," -e 's,_BINDIR_,/usr/local/bin/,g' -e 's,_PKGDATADIR_,/usr/local/share/stacks/,g' -e 's,$mysql_config;,$mysql_config;\nmy $cnf_secure = $cnf . (exists $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} ? " --host=" . $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} : (exists $ENV{"MYSQL_HOST"} ? " --host=" . $ENV{"MYSQL_HOST"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} ? " --password=" . $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} : (exists $ENV{"MYSQL_PASS"} ? " --password=" . $ENV{"MYSQL_PASS"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_USER"} ? " --user=" . $ENV{"MYSQL_APP_ENV_MYSQL_USER"} : (exists $ENV{"MYSQL_USER"} ? " --user=" . $ENV{"MYSQL_USER"} : q{}));,' -e 's,mysql --defaults-file=$cnf,mysql --defaults-file=$cnf_secure,g' /usr/local/bin/denovo_map.pl > /usr/local/bin/denovo_map.pl.subst
mv /usr/local/bin/denovo_map.pl.subst /usr/local/bin/denovo_map.pl
chmod +x /usr/local/bin/denovo_map.pl
sed -e "s,_VERSION_,${STACKVERSION}," -e 's,_BINDIR_,/usr/local/bin/,g' -e 's,_PKGDATADIR_,/usr/local/share/stacks/,g' -e 's,$mysql_config;,$mysql_config;\nmy $cnf_secure = $cnf . (exists $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} ? " --host=" . $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} : (exists $ENV{"MYSQL_HOST"} ? " --host=" . $ENV{"MYSQL_HOST"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} ? " --password=" . $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} : (exists $ENV{"MYSQL_PASS"} ? " --password=" . $ENV{"MYSQL_PASS"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_USER"} ? " --user=" . $ENV{"MYSQL_APP_ENV_MYSQL_USER"} : (exists $ENV{"MYSQL_USER"} ? " --user=" . $ENV{"MYSQL_USER"} : q{}));,' -e 's,mysql --defaults-file=$cnf,mysql --defaults-file=$cnf_secure,g' /usr/local/bin/ref_map.pl > /usr/local/bin/ref_map.pl.subst
mv /usr/local/bin/ref_map.pl.subst /usr/local/bin/ref_map.pl
chmod +x /usr/local/bin/ref_map.pl
sed -e "s,_VERSION_,${STACKVERSION}," -e 's,_PKGDATADIR_,/usr/local/share/stacks/,g' -e 's,DBI:mysql:$db:mysql,DBI:mysql:$db:" . (exists $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} ? ";host=" . $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} : (exists $ENV{"MYSQL_HOST"} ? ";host=" . $ENV{"MYSQL_HOST"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} ? ";password=" . $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} : (exists $ENV{"MYSQL_PASS"} ? ";password=" . $ENV{"MYSQL_PASS"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_USER"} ? ";user=" . $ENV{"MYSQL_APP_ENV_MYSQL_USER"} : (exists $ENV{"MYSQL_USER"} ? ";user=" . $ENV{"MYSQL_USER"} : q{})) . ";mysql,g' /usr/local/bin/export_sql.pl > /usr/local/bin/export_sql.pl.subst
mv /usr/local/bin/export_sql.pl.subst /usr/local/bin/export_sql.pl
chmod +x /usr/local/bin/export_sql.pl
#sed -e "s,_VERSION_,${STACKVERSION}," -e 's,_PKGDATADIR_,/usr/local/share/stacks/,g' -e 's,DBI:mysql:$db:mysql,DBI:mysql:$db:" . (exists $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} ? ";host=" . $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} : (exists $ENV{"MYSQL_HOST"} ? ";host=" . $ENV{"MYSQL_HOST"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} ? ";password=" . $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} : (exists $ENV{"MYSQL_PASS"} ? ";password=" . $ENV{"MYSQL_PASS"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_USER"} ? ";user=" . $ENV{"MYSQL_APP_ENV_MYSQL_USER"} : (exists $ENV{"MYSQL_USER"} ? ";user=" . $ENV{"MYSQL_USER"} : q{})) . ";mysql,g' -e 's,mysql --defaults-file=$cnf,mysql --defaults-file=$cnf" . (exists $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} ? " --host=" . $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} : (exists $ENV{"MYSQL_HOST"} ? " --host=" . $ENV{"MYSQL_HOST"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} ? " --password=" . $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} : (exists $ENV{"MYSQL_PASS"} ? " --password=" . $ENV{"MYSQL_PASS"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_USER"} ? " --user=" . $ENV{"MYSQL_APP_ENV_MYSQL_USER"} : (exists $ENV{"MYSQL_USER"} ? " --user=" . $ENV{"MYSQL_USER"} : q{})) . ",g' /usr/local/bin/index_radtags.pl > /usr/local/bin/index_radtags.pl.subst
sed -e "s,_VERSION_,${STACKVERSION}," -e 's,_PKGDATADIR_,/usr/local/share/stacks/,g' -e 's,DBI:mysql:$db:mysql,DBI:mysql:$db:" . (exists $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} ? ";host=" . $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} : (exists $ENV{"MYSQL_HOST"} ? ";host=" . $ENV{"MYSQL_HOST"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} ? ";password=" . $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} : (exists $ENV{"MYSQL_PASS"} ? ";password=" . $ENV{"MYSQL_PASS"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_USER"} ? ";user=" . $ENV{"MYSQL_APP_ENV_MYSQL_USER"} : (exists $ENV{"MYSQL_USER"} ? ";user=" . $ENV{"MYSQL_USER"} : q{})) . ";mysql,g' -e 's,$mysql_config;,$mysql_config;\nmy $cnf_secure = $cnf . (exists $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} ? " --host=" . $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} : (exists $ENV{"MYSQL_HOST"} ? " --host=" . $ENV{"MYSQL_HOST"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} ? " --password=" . $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} : (exists $ENV{"MYSQL_PASS"} ? " --password=" . $ENV{"MYSQL_PASS"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_USER"} ? " --user=" . $ENV{"MYSQL_APP_ENV_MYSQL_USER"} : (exists $ENV{"MYSQL_USER"} ? " --user=" . $ENV{"MYSQL_USER"} : q{}));,' -e 's,mysql --defaults-file=$cnf,mysql --defaults-file=$cnf_secure,g' /usr/local/bin/index_radtags.pl > /usr/local/bin/index_radtags.pl.subst
mv /usr/local/bin/index_radtags.pl.subst /usr/local/bin/index_radtags.pl
chmod +x /usr/local/bin/index_radtags.pl
sed -e "s,_VERSION_,${STACKVERSION}," -e 's,_PKGDATADIR_,/usr/local/share/stacks/,g' -e 's,$mysql_config;,$mysql_config;\nmy $cnf_secure = $cnf . (exists $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} ? " --host=" . $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} : (exists $ENV{"MYSQL_HOST"} ? " --host=" . $ENV{"MYSQL_HOST"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} ? " --password=" . $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} : (exists $ENV{"MYSQL_PASS"} ? " --password=" . $ENV{"MYSQL_PASS"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_USER"} ? " --user=" . $ENV{"MYSQL_APP_ENV_MYSQL_USER"} : (exists $ENV{"MYSQL_USER"} ? " --user=" . $ENV{"MYSQL_USER"} : q{}));,' -e 's,mysql --defaults-file=$cnf,mysql --defaults-file=$cnf_secure,g' /usr/local/bin/load_radtags.pl > /usr/local/bin/load_radtags.pl.subst
mv /usr/local/bin/load_radtags.pl.subst /usr/local/bin/load_radtags.pl
chmod +x /usr/local/bin/load_radtags.pl
sed -e "s,_VERSION_,${STACKVERSION}," /usr/local/bin/sort_read_pairs.pl > /usr/local/bin/sort_read_pairs.pl.subst
mv /usr/local/bin/sort_read_pairs.pl.subst /usr/local/bin/sort_read_pairs.pl
chmod +x /usr/local/bin/sort_read_pairs.pl
sed -e "s,_VERSION_,${STACKVERSION}," /usr/local/bin/exec_velvet.pl > /usr/local/bin/exec_velvet.pl.subst
mv /usr/local/bin/exec_velvet.pl.subst /usr/local/bin/exec_velvet.pl
chmod +x /usr/local/bin/exec_velvet.pl
sed -e "s,_VERSION_,${STACKVERSION}," -e 's,_PKGDATADIR_,/usr/local/share/stacks/,g' -e 's,DBI:mysql:$db:mysql,DBI:mysql:$db:" . (exists $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} ? ";host=" . $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} : (exists $ENV{"MYSQL_HOST"} ? ";host=" . $ENV{"MYSQL_HOST"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} ? ";password=" . $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} : (exists $ENV{"MYSQL_PASS"} ? ";password=" . $ENV{"MYSQL_PASS"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_USER"} ? ";user=" . $ENV{"MYSQL_APP_ENV_MYSQL_USER"} : (exists $ENV{"MYSQL_USER"} ? ";user=" . $ENV{"MYSQL_USER"} : q{})) . ";mysql,g' /usr/local/bin/load_sequences.pl > /usr/local/bin/load_sequences.pl.subst
mv /usr/local/bin/load_sequences.pl.subst /usr/local/bin/load_sequences.pl
chmod +x /usr/local/bin/load_sequences.pl

cd ..

echo -e "[client]\nport=3306\nlocal-infile=1\n" > /usr/local/share/stacks/sql/mysql.cnf
cp /usr/local/share/stacks/sql/mysql.cnf /root/.my.cnf

DEBIAN_FRONTEND=noninteractive apt-get remove -y gcc g++ make
DEBIAN_FRONTEND=noninteractive apt-get autoremove -y
DEBIAN_FRONTEND=noninteractive apt-get autoclean -y
DEBIAN_FRONTEND=noninteractive apt-get clean

rm -rf stacks-${STACKVERSION}.tar.gz stacks-${STACKVERSION}
