require 'rubygems'
require 'sinatra'

disable :run

set :env, :production
set :raise_errors, true
set :views, File.dirname(__FILE__) + '/views'
set :public, File.dirname(__FILE__) + '/public'
set :app_file, "toolmantim.rb"

require File.dirname(__FILE__) + "/toolmantim.rb"

run Sinatra.application
