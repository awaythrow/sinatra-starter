ENV['APP_ENV'] ||= "development"

require 'dotenv/load'
require 'sinatra'
require 'sinatra/json'
require 'sinatra/activerecord'

require './app'
require 'require_all'
require_all 'models'
