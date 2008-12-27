__DIR__ = File.dirname(__FILE__)

require 'rubygems'

gem 'sinatra'
gem 'third_base'

require 'sinatra'

require "#{__DIR__}/lib/article"
Article.path = "#{__DIR__}/articles"

helpers do
  def article_url(article)
    # TODO:
  end
  def article_path(article)
    "/articles/#{article.slug}"
  end
end

get '/' do
  @articles = Article.all.sort
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

get '/articles.atom' do
  @articles = Article.all
  content_type 'application/atom+xml'
  haml :feed
end

not_found do
  haml :not_found
end