require 'logger'

$stdout.sync = true
Logger

require 'bundler/setup'
Bundler.require

require './app'
run Sinatra::Application