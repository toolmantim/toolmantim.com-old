require 'rubygems'
require 'sinatra'

set :run      => false,
    :env      => :production,
    :root     => File.dirname(__FILE__),
    :app_file => "toolmantim.rb"

require File.join(File.dirname(__FILE__), "toolmantim.rb")

run Sinatra.application
