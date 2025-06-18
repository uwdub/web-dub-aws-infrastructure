#
# Stage source
#
# Obtain the source.
#
FROM alpine:3 as stage_source

COPY web_dub web_dub/

#
# Stage build_python
#
# Build the site.
#
FROM python:3.6 AS stage_build_python

WORKDIR /web_dub
COPY --from=stage_source /web_dub .

RUN  set -ex \
     && pip --disable-pip-version-check install -r requirements3.txt \
     && invoke compile_calendar

#
# Stage build_ruby
#
# Build the site. Requires Node for less.
#
FROM ruby:2.5.1 AS stage_build_ruby

WORKDIR /
RUN mkdir web_dub
WORKDIR /web_dub
COPY --from=stage_build_python /web_dub .

RUN set -ex \
    && echo 'deb http://archive.debian.org/debian stretch main' > /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --allow-unauthenticated \
       curl \
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
    && /bin/bash -l -c "nvm install 8.17.0" \
    && /bin/bash -l -c "nvm alias default 8.17.0" \
    && apt-get clean

RUN set -ex \
    && /bin/bash -l -c "npm install" \
    && gem install bundler -v 1.16.5 \
    && bundle install \
    && /bin/bash -l -c "bundle exec jekyll build -t --config _config.yml,_config-production.yml"

#
# Serve the site.
#
FROM nginx:alpine AS stage_serve

COPY --from=stage_build_ruby /web_dub/_site /usr/share/nginx/html
