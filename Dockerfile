# The version of Alpine to use for the final image
# This should match the version of Alpine that the `elixir:1.9-alpine` image uses
ARG ALPINE_VERSION=3.10


### Prebuilding dependencies
FROM elixir:1.9-alpine AS deps_builder

ARG APP_NAME=gpanel_one_page
ARG MIX_ENV=prod
ARG PORT=4004

RUN echo $MIX_ENV

ENV SKIP_PHOENIX=${SKIP_PHOENIX} \
    APP_NAME=${APP_NAME} \
    MIX_ENV=${MIX_ENV}

WORKDIR /opt/app

RUN apk update && \
  apk upgrade --no-cache && \
  mix local.rebar --force && \
  mix local.hex --force

COPY mix.* ./
COPY ./assets ./assets
COPY ./config ./config
COPY ./priv ./priv
COPY ./lib ./lib
COPY ./rel ./rel

RUN \
  mkdir -p /opt/release && \
  mix deps.get && \
  mix deps.compile && \
  cp -r _build/${MIX_ENV}/lib /opt/release && \
  cp -r deps /opt/release && \
  cp mix.lock /opt/release

### Builing release step
FROM elixir:1.9-alpine AS builder

# The following are build arguments used to change variable parts of the image.
# The name of your application/release (required)
ARG APP_NAME=gpanel_one_page

# The version of the application we are building (required)
#ARG APP_VSN=0.1.0

# The environment to build with
ARG MIX_ENV=prod

# Set this to true if this release is not a Phoenix app
ARG SKIP_PHOENIX=false

# If you are using an umbrella project, you can change this
# argument to the directory the Phoenix app is in so that the assets
# can be built
ARG PHOENIX_SUBDIR=.

ARG GPANEL_HOST
ARG GPANEL_INTERNAL_PORT
ARG GPANEL_EXTERNAL_PORT
ARG GPANEL_SSL_CERT_PATH
ARG GPANEL_SSL_KEY_PATH
ARG GPANEL_SECRET_KEY_BASE

RUN echo $MIX_ENV

ENV SKIP_PHOENIX=${SKIP_PHOENIX} \
    APP_NAME=${APP_NAME} \
    MIX_ENV=${MIX_ENV} \
    GPANEL_HOST=${GPANEL_HOST} \
    GPANEL_INTERNAL_PORT=${GPANEL_INTERNAL_PORT} \
    GPANEL_EXTERNAL_PORT=${GPANEL_EXTERNAL_PORT} \
    GPANEL_SSL_CERT_PATH=${GPANEL_SSL_CERT_PATH} \
    GPANEL_SSL_KEY_PATH=${GPANEL_SSL_KEY_PATH} \
    GPANEL_SECRET_KEY_BASE=${GPANEL_SECRET_KEY_BASE}

WORKDIR /opt/app

#RUN apk update \
#  && apk --no-cache --update add alpine-sdk tzdata openssl-dev python \
#  && mix local.rebar --force \
#  && mix local.hex --force

# This step installs all the build tools we'll need
RUN apk update && \
  apk upgrade --no-cache && \
  apk add --no-cache \
    nodejs \
    yarn \
    git \
    build-base && \
  mix local.rebar --force && \
  mix local.hex --force

COPY mix.* ./
COPY ./assets ./assets
COPY ./config ./config
COPY ./priv ./priv
COPY ./lib ./lib
COPY ./rel ./rel

RUN mkdir -p _build/${MIX_ENV}
COPY --from=deps_builder /opt/release/lib _build/${MIX_ENV}/lib
COPY --from=deps_builder /opt/release/mix.lock .
COPY --from=deps_builder /opt/release/deps ./deps

RUN ls _build/${MIX_ENV}/
RUN ls .


# This step builds assets for the Phoenix app (if there is one)
# If you aren't building a Phoenix app, pass `--build-arg SKIP_PHOENIX=true`
# This is mostly here for demonstration purposes
RUN if [ ! "$SKIP_PHOENIX" = "true" ]; then \
  cd ${PHOENIX_SUBDIR}/assets && \
  yarn install && \
  yarn deploy && \
  cd ..; \
fi

RUN mix do compile, phx.digest

RUN \
  mkdir -p /opt/release && \
  MIX_ENV=${MIX_ENV} mix distillery.release --verbose && \
  cp -r _build/${MIX_ENV}/rel/${APP_NAME}/* /opt/release

### Production container
FROM alpine:${ALPINE_VERSION}

ARG APP_NAME=gpanel_one_page
ARG MIX_ENV=prod
ARG PORT=4004

RUN echo $MIX_ENV

RUN apk update && apk --no-cache --update add bash openssl-dev tzdata python imagemagick pngcrush ca-certificates curl vim patch

ENV MIX_ENV=${MIX_ENV} \
    REPLACE_OS_VARS=true \
    PORT=${PORT}

WORKDIR /opt/app

EXPOSE ${PORT}

COPY --from=builder /opt/release .

#CMD ["bash", "-c", "sleep 99999999"]
CMD ["/opt/app/bin/gpanel_one_page", "foreground"]