FROM ruby:2.7.2

RUN apt-get update -qq && \
	apt-get install -y netcat && \
	rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY Gemfile* ./
RUN bundle config set deployment 'false' && \
	bundle config set without 'development test' && \
	bundle install
COPY . ./

EXPOSE 8080
CMD ["bin/puma", "-b", "tcp://0.0.0.0:9292"]
