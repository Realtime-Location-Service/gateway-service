FROM alpine:3.6

ENV KONG_VERSION 1.2.0
ENV KONG_SHA256 049c63c930b14d8049ebd028794b690b52600c580be8fe129dac11062b8e2568

RUN adduser -Su 1337 kong \
	&& mkdir -p "/usr/local/kong" \
	&& apk add --no-cache --virtual .build-deps wget tar ca-certificates \
	&& apk add --no-cache libgcc openssl pcre perl tzdata curl git libcap su-exec \
	&& wget -O kong.tar.gz "https://bintray.com/kong/kong-alpine-tar/download_file?file_path=kong-$KONG_VERSION.apk.tar.gz" \
	&& echo "$KONG_SHA256 *kong.tar.gz" | sha256sum -c - \
	&& tar -xzf kong.tar.gz -C /tmp \
	&& rm -f kong.tar.gz \
	&& cp -R /tmp/usr / \
	&& rm -rf /tmp/usr \
	&& cp -R /tmp/etc / \
	&& rm -rf /tmp/etc \
	&& apk del .build-deps \
	&& chown -R kong:0 /usr/local/kong \
	&& chmod -R g=u /usr/local/kong

RUN luarocks install lua-resty-template
RUN luarocks install http

COPY plugins /usr/local/share/lua/5.1/kong/plugins
COPY kong-template.yml /usr/local/share/kong-template.yml
COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

STOPSIGNAL SIGQUIT

CMD ["kong", "start"]
