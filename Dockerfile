# STAGE dev: Development environment
FROM node:10-alpine@sha256:fcd9b3cb2fb21157899bbdb35d1cdf3d6acffcd91ad48c1af5cb62c22d2d05b1 \
    AS dev

WORKDIR /src-d/blog

RUN apk add --no-cache make bash ca-certificates

COPY Makefile webpack.config.js ./
COPY package.json yarn.lock ./
COPY ./src ./src

RUN set -x \
    && apk add --no-cache --virtual .deps curl \
    && make project-dependencies \
    && yarn cache clean \
    && apk del .deps

COPY config.yaml .terminusMaximus ./

CMD ["make", "serve"]

################################
# Developement image stops here
# use '--target dev' on build to break here

# STAGE build: Build environment
FROM dev AS build

COPY ./content ./content
COPY ./data ./data
COPY ./static ./static
COPY ./themes ./themes

RUN make build

CMD ["make", "hugo-server"]

# STAGE runtime: Production environment

FROM alpine:3.8@sha256:621c2f39f8133acb8e64023a94dbdf0d5ca81896102b9e57c0dc184cadaf5528 \
    AS runtime

ARG CADDY_PLUGINS="http.cors"

RUN set -x \
    && apk add --no-cache --virtual .caddydeps tar curl \
    && curl -sL "https://caddyserver.com/download/linux/amd64?plugins=${CADDY_PLUGINS}&license=personal&telemetry=off" \
    | tar --no-same-owner -C /usr/bin/ -xz caddy \
    && chmod +x /usr/bin/caddy \
    && apk del .caddydeps

COPY Caddyfile /etc/Caddyfile
COPY --from=build /src-d/blog/public /var/www/public

CMD ["caddy", "--conf", "/etc/Caddyfile"]
