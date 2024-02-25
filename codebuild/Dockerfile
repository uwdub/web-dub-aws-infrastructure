#
# Expected arguments
#

# GIT_REPOSITORY: GitHub repository URL (e.g., https://github.com/fogies/aws-infrastructure.git)
ARG GIT_REPOSITORY=https://github.com/uwdub/web-dub.git
# GIT_REPOSITORY_BRANCH: Branch to use from GIT_REPOSITORY
ARG GIT_REPOSITORY_BRANCH=master

#
# Stage arguments
#
# Confirm required arguments.
#
FROM alpine:3 as stage_required

ARG GIT_REPOSITORY
ARG GIT_REPOSITORY_BRANCH

RUN test -n "$GIT_REPOSITORY" || (echo "Argument GIT_REPOSITORY required" && false)
RUN test -n "$GIT_REPOSITORY_BRANCH" || (echo "Argument GIT_REPOSITORY_BRANCH required" && false)

#
# Stage git
#
# Obtain the web source from GitHub.
#
FROM alpine:3 AS stage_git

ARG GIT_REPOSITORY
ARG GIT_REPOSITORY_BRANCH

# Install git. Modeled on alpine/git:
# https://github.com/alpine-docker/git
RUN set -ex \
    && apk --update add git less openssh \
    && rm -rf /var/lib/apt/lists/* \
    && rm /var/cache/apk/*

# Clone web repository
RUN git clone -b $GIT_REPOSITORY_BRANCH $GIT_REPOSITORY web_dub

#
# Stage build_python
#
# Build the site.
#
FROM python:3.6 AS stage_build_python

WORKDIR /web_dub
COPY --from=stage_git /web_dub .

RUN  set -ex \
     && pip --disable-pip-version-check install -r requirements3.txt \
     && invoke compile_calendar

#
# Stage build_ruby
#
# Build the site. Requires Node for less.
#
FROM ruby:2.5.1 AS stage_build_ruby

WORKDIR /web_dub
COPY --from=stage_git /web_dub .

RUN set -ex \
    && echo 'deb http://archive.debian.org/debian stretch main' > /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y \
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
