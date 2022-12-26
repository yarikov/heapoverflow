ARG RUBY_VERSION

FROM ruby:$RUBY_VERSION

RUN apt update && apt install -y --no-install-recommends libvips42

ARG NODE_VERSION

RUN curl -SLO --progress-bar "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
  && rm -rf node-v$NODE_VERSION-linux-x64.tar.xz \
  && npm install -g yarn

COPY Gemfile* /usr/src/app/
WORKDIR /usr/src/app

ARG BUNDLER_VERSION
RUN gem install bundler:$BUNDLER_VERSION

COPY . /usr/src/app
