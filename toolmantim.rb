require 'rubygems'
require 'sinatra'

__DIR__ = File.dirname(__FILE__)

%w(article quip).each do |model|
  require "#{__DIR__}/lib/#{model}"
end

Article.path = "#{__DIR__}/articles"

helpers do
  def article_path(article)
    "/articles/#{article.slug}"
  end
  def partial(name)
    haml :"_#{name}", :layout => false
  end
  def next_article(article)
    next_index = @articles.index(article) - 1
    @articles[next_index] unless next_index < 0
  end
  def previous_article(article)
    prev_index = @articles.index(article) + 1
    @articles[prev_index] unless prev_index > @articles.length + 1
  end
end

before do
  @articles = Article.all.sort
end

get '/' do
  haml :home
end

get '/articles/:id' do
  @article = Article[params[:id]] # or 404
  @article_html = haml(@article.template, :layout => false)
  haml :article
end

# Legacy URLs for articles
get '/article/:year/:month/:day/:id' do
  redirect "/articles/#{params[:id]}", 301
end

get '/articles' do
  @articles_by_year_then_month = @articles.inject({}) do |acc, article|
    acc[article.published.year] ||= {}
    acc[article.published.year][article.published.month] ||= []
    acc[article.published.year][article.published.month] << article
    acc
  end
  haml :archive
end

get '/articles.atom' do
  content_type 'application/atom+xml'
  haml :feed
end

get '/projects' do
  haml :projects
end

not_found do
  haml :not_found
end