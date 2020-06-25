## Build
FROM elixir:1.9-alpine

ARG APP_NAME=gpanel_one_page
ARG PHOENIX_SUBDIR=.
ARG mix_env=prod
ARG version=1.0.0
ENV MIX_ENV=${mix_env} VERSION=${version} REPLACE_OS_VARS=true TERM=xter
RUN echo $MIX_ENV

WORKDIR /opt/app

RUN apk update \
  && apk --no-cache --update add alpine-sdk tzdata openssl-dev python \
  && mix local.rebar --force \
  && mix local.hex --force

COPY mix.* ./

COPY ./config ./config

RUN mix do deps.get, deps.compile

COPY ./lib ./lib
COPY ./rel ./rel
COPY ./priv ./priv

RUN mix compile

RUN mix distillery.release --env=${mix_env} --verbose \
  && mv _build/${mix_env}/rel/${APP_NAME} /opt/release

## Production container
FROM alpine:3.10

ARG mix_env=prod

RUN apk update && apk --no-cache --update add bash openssl-dev tzdata python imagemagick pngcrush ca-certificates mysql-client curl vim patch

ENV PORT=80 MIX_ENV=${mix_env} REPLACE_OS_VARS=true

RUN echo $MIX_ENV

WORKDIR /opt/app

RUN mkdir tmp

EXPOSE ${PORT}

COPY --from=0 /opt/release .

CMD ["/opt/app/bin/gpanel_one_page", "foreground"]
