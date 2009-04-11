require 'rubygems'
gem 'sinatra', '0.9.0.4'
require 'sinatra'

gem 'haml', '~> 2.0.0'
require 'haml'

gem 'RedCloth', '~> 3.0'
gem 'rdiscount'

require 'net/http'
require 'uri'
require 'hpricot'

__DIR__ = File.dirname(__FILE__)

%w(article quip).each do |model|
  load "#{__DIR__}/lib/#{model}.rb"
end

Article.path = "#{__DIR__}/articles"

# Add Ruby 1.9's xmlschema method
class Date
  def xmlschema
    strftime("%Y-%m-%dT%H:%M:%S%Z")
  end unless defined?(xmlschema)
end

class Flickr
  def self.photos(method, params={})
    call(method, params)/:photo
  end
  def self.photo(*args)
    photos(*args).first
  end
  def self.sizes(photo)
    call("getSizes", "photo_id" => photo[:id])/:size
  end
  def self.call(method, params)
    res = Net::HTTP.get(URI.parse("http://api.flickr.com/services/rest/?method=flickr.photos.#{method}&api_key=0e5de53043827665f99e9508ce5c40cf&user_id=57794886@N00#{params.collect{|k,v|"&#{k}=#{v}"}}"))
    return Hpricot(res) if !res.include?('stat="fail"')
  end
end

helpers do
  def article_path(article)
    "/articles/#{article.slug}"
  end
  def next_article(article)
    next_index = @articles.index(article) - 1
    @articles[next_index] unless next_index < 0
  end
  def previous_article(article)
    prev_index = @articles.index(article) + 1
    @articles[prev_index] unless prev_index > @articles.length + 1
  end
  def versioned_stylesheet(stylesheet)
    "/stylesheets/#{stylesheet}.css?" + File.mtime(File.join(Sinatra::Application.views, "stylesheets", "#{stylesheet}.sass")).to_i.to_s
  end
  def versioned_js(js)
    "/javascripts/#{js}.js?" + File.mtime(File.join(Sinatra::Application.public, "javascripts", "#{js}.js")).to_i.to_s
  end
  def versioned_favicon
    "/favicon.ico?" + File.mtime(File.join(Sinatra::Application.public, "favicon.ico")).to_i.to_s
  end
  def partial(name)
    haml(:"_#{name}", :layout => false)
  end
  def article_html(article)
    haml(article.template, :layout => false)
  end
  def article_image_path(article, image)
    "/images/articles/#{article.slug}/#{image}"
  end
  def absoluteify_links(html)
    html.
      gsub(/href=(["'])(\/.*?)(["'])/, 'href=\1http://toolmantim.com\2\3').
      gsub(/src=(["'])(\/.*?)(["'])/, 'src=\1http://toolmantim.com\2\3')
  end
  def strip_tags(html)
    html.gsub(/<\/?[^>]*>/, "")
  end
  def flickr_src(photo, size=nil)
    "http://farm#{photo[:farm]}.static.flickr.com/#{photo[:server]}/#{photo[:id]}_#{photo[:secret]}#{size && "_#{size}"}.jpg"
  end
  def flickr_url(photo)
    "http://www.flickr.com/photos/toolmantim/#{photo[:id]}"
  end
end

before do
  @articles = Article.all.sort
end

get '/' do
  haml :home
end

%w( screen ie7 ie6 tumble ).each do |stylesheet|
  get "/stylesheets/#{stylesheet}.css" do
    content_type 'text/css'
    response["Expires"] = (Time.now + 60*60*24*356*3).httpdate # Cache for 3 years
    sass :"stylesheets/#{stylesheet}"
  end
end

get '/articles/:id' do
  @article = Article[params[:id]] || raise(Sinatra::NotFound)
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
  haml :feed, :layout => false
end

get '/tech/atom.xml' do
  redirect 'http://feeds.feedburner.com/toolmantim', 301
end

get '/projects' do
  haml :projects
end

get '/photos' do
  @recent_photos = Flickr.photos("search", "per_page" => 9)
  @feature_photos = Flickr.photos("search", "tags" => "feature", "per_page" => 500)
  haml :photos
end

get '/photos/:id' do
  @photo = Flickr.photo("getInfo", "photo_id" => params[:id]) || raise(Sinatra::NotFound)
  @sizes = Flickr.sizes(@photo)
  haml :photo
end

get '/sitemap.xml' do
  content_type 'application/xml'
  haml :sitemap, :layout => false
end

get '/sample-tumble' do
  haml :sample_tumble
end if Sinatra::Application.environment == :development

not_found do
  content_type 'text/html'
  haml :not_found
end

error do
  @error = request.env['sinatra.error'].to_s
  content_type 'text/html'
  haml :error
end unless Sinatra::Application.environment == :development