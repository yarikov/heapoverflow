FROM ruby:3.1.2

ENV NODE_VERSION 4.1.2

RUN apt update && apt -y install libvips

RUN curl -SLO --progress-bar "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
  && rm -rf node-v$NODE_VERSION-linux-x64.tar.xz

COPY Gemfile* /usr/src/app/
WORKDIR /usr/src/app

RUN gem install bundler:2.3.26

COPY . /usr/src/app
