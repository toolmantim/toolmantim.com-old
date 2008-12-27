__DIR__ = File.dirname(__FILE__)

require 'rubygems'

gem 'sinatra'
gem 'third_base'

require 'sinatra'

require "#{__DIR__}/lib/article"
Article.path = "#{__DIR__}/articles"

get '/' do
  @articles = Article.all
  haml :home
end

get '/articles/:id' do
  @article = Article[params[:id]] # or 404
  @article_html = haml(@article.template, :layout => false)
  haml :article
end

get '/articles' do
  @articles = Article.all
  haml :archive
end
