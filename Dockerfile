FROM debian:7-slim
MAINTAINER Ryos Suzuki<ryos@sinby.com>

# Install dependencies from Debian repositories
RUN apt-get update && apt-get install -y make wget bzip2 libfcgi-dev locales locales-all && apt-get clean

ENV DEBIAN_FRONTEND=noninteractive
RUN sed -e "s/^#.*\(ja_JP.UTF-8.*\)/\1/"  /etc/locale.gen > /etc/locale.gen && \
    /usr/sbin/locale-gen ja_JP.UTF-8 && \
    /usr/sbin/update-locale LANG=ja_JP.UTF-8

# Note: 1.4.11-1.4.16, 1.5.0 doesn't work for ironclad!! since compile error.

ARG SBCL_VERSION=1.4.10
ARG SBCL_BZIP=sbcl-$SBCL_VERSION-x86-64-linux-binary.tar.bz2
ARG SBCL_URL=http://prdownloads.sourceforge.net/sbcl/$SBCL_BZIP
ARG SBCL_SHA256_SUM=b773c40a1fa49d3c31fb9b520112674733409871422ec1d694bc37797b6dddb2

RUN wget --no-check-certificate --quiet $SBCL_URL -O /tmp/$SBCL_BZIP && \
    mkdir /tmp/sbcl && \
    tar jxvf /tmp/$SBCL_BZIP --strip-components=1 -C /tmp/sbcl/ && \
    cd /tmp/sbcl && \
    sh ./install.sh && \
    cd /tmp && \
    rm -rf /tmp/sbcl/ && \
    rm /tmp/$SBCL_BZIP

ENV LANG ja_JP.UTF-8

WORKDIR /tmp

RUN wget --no-check-certificate --quiet https://beta.quicklisp.org/quicklisp.lisp
RUN /usr/local/bin/sbcl --non-interactive --eval "(load \"/tmp/quicklisp.lisp\")" --eval "(quicklisp-quickstart:install :path \"/root/quicklisp/\")"

WORKDIR /root
RUN echo "(load \"/root/quicklisp/setup.lisp\")" > .sbclrc

#RUN sbcl --non-interactive --eval "(ql:quickload :clack)" --eval "(ql:quickload :cl-fastcgi)"
