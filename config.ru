ENV['TZ'] = 'Australia/Sydney'

require 'rubygems'
gem 'sinatra', '~> 0.3'
require 'sinatra'

gem 'teapot', '~> 1'
require 'teapot'

set :run      => false,
    :env      => :production,
    :root     => File.dirname(__FILE__),
    :views    => File.dirname(__FILE__) + "/views",
    :public   => File.dirname(__FILE__) + "/public",
    :app_file => "toolmantim.rb"

require File.join(File.dirname(__FILE__), "toolmantim.rb")

use Teapot, "English Breakfast"

run Sinatra.application
