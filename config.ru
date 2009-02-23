ENV['TZ'] = 'Australia/Sydney'

require 'rubygems'

gem 'rack', '0.9.1'
require 'rack'

gem 'sinatra', '0.9.0.4'
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

run Sinatra::Application
