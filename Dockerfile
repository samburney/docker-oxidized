ARG OXIDIZED_BUILD=latest

# Build latest msmtp from source
FROM ubuntu:jammy AS builder

RUN apt-get update && \
    apt-get install -y build-essential git autoconf automake libtool gettext texinfo libgnutls28-dev pkg-config && \
    apt-get clean

RUN mkdir /build && \
    cd /build && \
    git clone https://git.marlam.de/git/msmtp.git  && \
    cd msmtp && \
    autoreconf -i && \
    ./configure; make

# Add mailutils and newer msmtp to oxidized base image
FROM oxidized/oxidized:${OXIDIZED_BUILD}

LABEL maintainer Sam Burney <sburney@sifnt.net.au>

RUN apt-get update && \
    apt-get install -y --no-install-recommends mailutils && \
    apt-get clean

COPY --from=builder /build/msmtp/src/msmtp /usr/bin/msmtp

RUN ln -s /usr/bin/msmtp /usr/sbin/sendmail
