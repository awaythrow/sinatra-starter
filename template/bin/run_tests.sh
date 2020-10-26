#!/bin/bash
bundle config set deployment 'false'
bundle config set without 'development'
bundle config set with 'test'
bundle install

# Wait for db
while ! nc -z "$DATABASE_HOST" "$DATABASE_PORT"; do sleep 1; done
bin/rake db:drop db:create db:migrate
bin/rspec
