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

FROM abiosoft/caddy@sha256:918431577452be0f3117fa056b1280f0ef0cd2f002473f405f375495eed168f4 \
    AS runtime

COPY Caddyfile /etc/Caddyfile
COPY --from=build /src-d/blog/public /var/www/public
