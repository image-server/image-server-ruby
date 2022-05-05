FROM ruby:2.7.6

MAINTAINER Alberto Calderon (@bertocq)

RUN echo 'gem: --no-rdoc --no-ri' >> /.gemrc

WORKDIR /usr/src/app

RUN apt-get -q update && \
    apt-get install -yq cmake && \
    apt-get -q clean && \
    rm -rf /var/lib/apt/lists/*

COPY . .

ARG BUNDLE_GITHUB__COM
ENV BUNDLER_VERSION=2.1.4
RUN gem update --system \
    && gem install bundler -v $BUNDLER_VERSION \
    && bundle install -j 4

CMD ["bundle", "exec",  "rake"]
