ARG PG_VERSION=15
FROM postgres:${PG_VERSION}

RUN apt update \
 && apt install -y \
      curl \
      gcc \
      libcurl4-openssl-dev \
      make \
      postgresql-server-dev-${PG_MAJOR} \
      --

ARG PG_HTTP_VERSION=1.5.0
ARG PG_HTTP_URL=https://github.com/pramsey/pgsql-http/archive/refs/tags/v${PG_HTTP_VERSION}.tar.gz 
ARG PG_HTTP_CHECKSUM=43efc9e82afcd110f205b86b8d28d1355d39b6b134161e9661a33a1346818f5d

RUN cd /root \
 && curl -Lo pgsql-http.tar.gz ${PG_HTTP_URL} \
 && echo "${PG_HTTP_CHECKSUM} pgsql-http.tar.gz" | sha256sum --check \
 && tar -xvzf pgsql-http.tar.gz \
 && cd pgsql-http-${PG_HTTP_VERSION} \
 && make \
 && make install \
 && echo "create extension http;" > /docker-entrypoint-initdb.d/pgsql-http-init.sql
