FROM php:apache
MAINTAINER Michael Bekaert <michael.bekaert@stir.ac.uk>

LABEL description="Stacks (GUI) Docker" version="1.4" Vendor="Institute of Aquaculture, University of Stirling"
ENV STACKVERSION 1.48
ENV DOCKERVERSION 1.4

USER root

RUN apt-get update

WORKDIR /root
COPY stacks_gui.sh /stacks_gui.sh
RUN /bin/bash /stacks_gui.sh
RUN rm -f /stacks_gui.sh

WORKDIR /mnt
EXPOSE 80
