FROM alpine:3.12
RUN apk add --no-cache gpg brotli

ENV LANG C.UTF-8

# install ca-certificates so that HTTPS works consistently
# other runtime dependencies for Python are installed later
RUN apk add --no-cache ca-certificates

#ENV GPG_KEY %%PLACEHOLDER%%
ENV GPG_KEY 123D62DD87E7A81CA090CD65D18FC49C6F3A8EC0
ENV P_VERSION 11.3

RUN set -ex \
	&& apk add --no-cache --virtual .fetch-deps \
		gnupg \
		tar \
		xz \
	\
	&& wget -O archwrap.tar.gz "https://github.com/vaeth/archwrap/releases/download/v$P_VERSION/archwrap-$P_VERSION.tar.gz" \
	&& wget -O archwrap.tar.gz.asc "https://github.com/vaeth/archwrap/releases/download/v$P_VERSION/archwrap-$P_VERSION.tar.gz.asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" \
	&& gpg --batch --verify archwrap.tar.gz.asc archwrap.tar.gz \
	&& { command -v gpgconf > /dev/null && gpgconf --kill all || :; } \
	&& rm -rf "$GNUPGHOME" archwrap.tar.gz.asc \
	&& mkdir -p /usr/share/archwrap \
	&& tar -xJC /usr/local/bin --strip-components=1 -f archwrap.tar.gz \
  && tar -xvzC /tmp/foo --strip-components=2 -f archwrap.tar.gz archwrap-$P_VERSION/bin/ \
	&& rm archwrap.tar.gz
  
ENV GPG_KEY 123D62DD87E7A81CA090CD65D18FC49C6F3A8EC0
ENV P_VERSION 3.1

RUN set -ex \
	&& apk add --no-cache --virtual .fetch-deps \
		gnupg \
		tar \
		xz \
	\
	&& wget -O push.tar.gz "https://github.com/vaeth/push/releases/download/v$P_VERSION/push-$P_VERSION.tar.gz" \
	&& wget -O push.tar.gz.asc "https://github.com/vaeth/push/releases/download/v$P_VERSION/push-$P_VERSION.tar.gz.asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" \
	&& gpg --batch --verify push.tar.gz.asc push.tar.gz \
	&& { command -v gpgconf > /dev/null && gpgconf --kill all || :; } \
	&& rm -rf "$GNUPGHOME" push.tar.gz.asc \
	&& mkdir -p /usr/local/bin \
  && tar -xvzC /tmp/foo --strip-components=2 -f push.tar.gz push-$P_VERSION/bin/push.sh \
	&& rm push.tar.gz
  
  RUN set -ex \
	&& apk add --no-cache --virtual \
        libarchive-tools tar xz unarj unrar gzip brotli p7zip bzip2 unzip lz4 lrzip lzip lzop zip zstd
  RUN set -ex \
	&& apk add --no-cache --virtual -X http://dl-cdn.alpinelinux.org/alpine/edge/testing lzop

