FROM ruby:2.6.10

ENV NODE_VERSION 4.1.2
ENV SPHINX_VERSION 2.2.11

RUN wget http://sphinxsearch.com/files/sphinx-$SPHINX_VERSION-release.tar.gz \
  && tar -zxvf sphinx-$SPHINX_VERSION-release.tar.gz \
  && cd sphinx-$SPHINX_VERSION-release \
  && ./configure --with-pgsql --with-mysql \
  && make \
  && make install \
  && rm -rf sphinx-$SPHINX_VERSION-release \
            sphinx-$SPHINX_VERSION-release.tar.gz

RUN curl -SLO --progress-bar "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
  && rm -rf node-v$NODE_VERSION-linux-x64.tar.xz

COPY Gemfile* /usr/src/app/
WORKDIR /usr/src/app

RUN gem install bundler:1.17.3

COPY . /usr/src/app
