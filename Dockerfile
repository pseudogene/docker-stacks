FROM ubuntu:16.04
MAINTAINER Michael Bekaert <michael.bekaert@stir.ac.uk>

LABEL description="Stacks (CLI) Docker" version="1.2" Vendor="Institute of Aquaculture, University of Stirling"
ENV STACKVERSION 1.43
ENV DOCKERVERSION 1.2

USER root

RUN apt-get update

WORKDIR /root
COPY stacks_cli.sh /stacks_cli.sh
RUN /bin/bash /stacks_cli.sh
COPY add_database.pl /usr/local/bin/add_database.pl
RUN chmod +x /usr/local/bin/add_database.pl
RUN rm -f /stacks_cli.sh

WORKDIR /mnt
