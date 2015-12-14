#!/usr/bin/env perl
#
# Copyright 2015, Michaël Bekaert <michael.bekaert@stir.ac.uk>
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
use strict;

if (scalar @ARGV > 0 ) {
    my $mysql_config  = "/usr/local/share/stacks/" . "sql/mysql.cnf";
    my $sql_path      = "/usr/local/share/stacks/" . "sql/";
    my $db            = $ARGV[0];
    my $cnf = (-e $ENV{"HOME"} . "/.my.cnf") ? $ENV{"HOME"} . "/.my.cnf" : $mysql_config;
    system("mysql --defaults-file=$cnf" . (exists $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} ? " --host=" . $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} : (exists $ENV{"MYSQL_HOST"} ? " --host=" . $ENV{"MYSQL_HOST"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} ? " --password=" . $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} : (exists $ENV{"MYSQL_PASS"} ? " --password=" . $ENV{"MYSQL_PASS"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_USER"} ? " --user=" . $ENV{"MYSQL_APP_ENV_MYSQL_USER"} : (exists $ENV{"MYSQL_USER"} ? " --user=" . $ENV{"MYSQL_USER"} : q{})) . " -e \"CREATE DATABASE $db\"");
    system("mysql --defaults-file=$cnf" . (exists $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} ? " --host=" . $ENV{"MYSQL_APP_PORT_3306_TCP_ADDR"} : (exists $ENV{"MYSQL_HOST"} ? " --host=" . $ENV{"MYSQL_HOST"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} ? " --password=" . $ENV{"MYSQL_APP_ENV_MYSQL_PASS"} : (exists $ENV{"MYSQL_PASS"} ? " --password=" . $ENV{"MYSQL_PASS"} : q{})) . (exists $ENV{"MYSQL_APP_ENV_MYSQL_USER"} ? " --user=" . $ENV{"MYSQL_APP_ENV_MYSQL_USER"} : (exists $ENV{"MYSQL_USER"} ? " --user=" . $ENV{"MYSQL_USER"} : q{})) . " $db < /usr/local/share/stacks/sql/stacks.sql");
    print {*STDOUT} "Created '$db' database\n";
}