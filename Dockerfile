FROM alpine:3.12

ENV LANG C.UTF-8

RUN (echo "@edge http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories ; \
echo "@edgecommunity http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories ; \
echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories ; \
echo "############" ; \
cat /etc/apk/repositories ; \
echo "############" ; )


# install ca-certificates so that HTTPS works consistently
# other runtime dependencies for Python are installed later
RUN apk --no-cache upgrade && apk add --no-cache ca-certificates

#ENV GPG_KEY %%PLACEHOLDER%%
ENV GPG_KEY 123D62DD87E7A81CA090CD65D18FC49C6F3A8EC0
ENV P_VERSION 11.3

RUN set -ex \
	&& apk add --no-cache \
		gnupg \
		tar \
		xz \
	\
	&& wget -O archwrap.tar.gz "https://github.com/vaeth/archwrap/archive/v$P_VERSION.tar.gz" \
	&& wget -O archwrap.tar.gz.asc "https://github.com/vaeth/archwrap/releases/download/v$P_VERSION/archwrap-$P_VERSION.tar.gz.asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --batch --fingerprint --fingerprint --verbose --verbose --keyserver keyserver.ubuntu.com --keyserver hkp://keyserver.ubuntu.com:80  --recv-keys "$GPG_KEY" \
	&& echo "$GPG_KEY:6:" | gpg --batch --import-ownertrust - \
	&& gpg --batch --verbose --verify archwrap.tar.gz.asc archwrap.tar.gz \
	&& { command -v gpgconf > /dev/null && gpgconf --kill all || :; } \
	&& rm -rf "$GNUPGHOME" archwrap.tar.gz.asc \
	&& mkdir -p /usr/share/archwrap \
        && tar -xvzC /usr/local/bin --strip-components=2 -f archwrap.tar.gz archwrap-$P_VERSION/bin/ \
	&& rm archwrap.tar.gz
  
ENV GPG_KEY 123D62DD87E7A81CA090CD65D18FC49C6F3A8EC0
ENV P_VERSION 3.1

RUN set -ex \
	&& apk add --no-cache \
		gnupg \
		tar \
		xz \
	\
	&& wget -O push.tar.gz "https://github.com/vaeth/push/archive/v$P_VERSION.tar.gz" \
	&& wget -O push.tar.gz.asc "https://github.com/vaeth/push/releases/download/v$P_VERSION/push-$P_VERSION.tar.gz.asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --batch --fingerprint --fingerprint --verbose --verbose --keyserver keyserver.ubuntu.com --keyserver hkp://keyserver.ubuntu.com:80  --recv-keys "$GPG_KEY" \
	&& echo "$GPG_KEY:6:" | gpg --batch --import-ownertrust - \
	&& gpg --batch --verbose --verify push.tar.gz.asc push.tar.gz \
	&& { command -v gpgconf > /dev/null && gpgconf --kill all || :; } \
	&& rm -rf "$GNUPGHOME" push.tar.gz.asc \
	&& mkdir -p /usr/local/bin \
        && tar -xvzC /usr/local/bin --strip-components=2 -f push.tar.gz push-$P_VERSION/bin/push.sh \
	&& rm push.tar.gz
  
  RUN set -ex \
	&& apk add --no-cache \
        libarchive-tools tar xz unarj unrar gzip brotli p7zip bzip2 unzip lz4 lrzip lzip zip zstd 
  RUN set -ex apk add --no-cache lzop@testing
  #RUN set -ex \
  #	&& apk add --no-cache --virtual -X http://dl-cdn.alpinelinux.org/alpine/edge/testing lzop

