__DIR__ = File.dirname(__FILE__)

ENV['TZ'] = 'Australia/Sydney'

File.file?(gems_file = "#{__DIR__}/.gems") && File.read(gems_file).each do |gem_decl|
  gem_name, version = gem_decl[/^([^\s]+)/,1], gem_decl[/--version '?([^\s]+)'?/,1]
  version ? gem(gem_name, version) : gem(gem_name)
end
require 'sinatra'
require 'haml'
require 'sass'

$:.unshift "#{__DIR__}/lib"
require "flickr"
require "article"
require "quip"

Article.path = "#{__DIR__}/articles"

# Add Ruby 1.9's xmlschema method
class Date
  def xmlschema
    strftime("%Y-%m-%dT%H:%M:%S%Z")
  end unless defined?(xmlschema)
end

helpers do
  def article_path(article)
    "/thoughts/#{article.slug}"
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
    @article = article
    haml(article.template, :layout => false)
  end
  def article_image_path(article, image)
    "/images/thoughts/#{article.slug}/#{image}"
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
    "http://www.flickr.com/photos/toolmantim/#{photo[:id]}/"
  end
  def flickr_square(photo)
    %(<img src="#{flickr_src(photo, "s")}" width="75" height="75" />)
  end
  def photo_path(photo)
    "/photos/#{photo[:id]}"
  end
  def pluralize(number, singular)
    case number.to_i
    when 0
      "No #{singular}s"
    when 1
      "1 #{singular}"
    else
      "#{number} #{singular}s"
    end
  end
end

# De-slashify
before do
  if request.path != "/" && request.path[-1..-1] == "/"
    redirect request.path[0..-2], 301
    halt
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

get('/articles')      { redirect "/thoughts", 301 }
get('/articles.atom') { redirect "/thoughts", 301 }
get('/articles/:id')  { redirect "/thoughts/#{params[:id]}", 301 }
get('/article/:year/:month/:day/:id') { redirect "/thoughts/#{params[:id]}", 301 }
get('/images/articles/:slug/:image') { redirect "/images/thoughts/#{params[:slug]}/#{params[:image]}", 301 }

get '/thoughts' do
  @articles_by_year_then_month = @articles.inject({}) do |acc, article|
    acc[article.published.year] ||= {}
    acc[article.published.year][article.published.month] ||= []
    acc[article.published.year][article.published.month] << article
    acc
  end
  haml :archive
end

get '/thoughts.atom' do
  content_type 'application/atom+xml'
  haml :feed, :layout => false
end

get '/thoughts/:id' do
  @article = Article[params[:id]] || raise(Sinatra::NotFound)
  haml :article
end

get '/tech/atom.xml' do
  redirect 'http://feeds.feedburner.com/toolmantim', 301
end

get '/photos' do
  @recent_photos = $flickr.recent
  @feature_photos = $flickr.featured
  haml :photos
end

get '/photos/:id' do
  @photo = $flickr.photo(params[:id]) || raise(Sinatra::NotFound)
  @sizes = $flickr.sizes(@photo)
  @prev_photo, @next_photo = $flickr.next_previous(@photo)
  haml :photo
end

get '/sitemap.xml' do
  content_type 'application/xml'
  haml :sitemap, :layout => false
end

not_found do
  content_type 'text/html'
  haml :not_found
end

get '/sample-tumble' do
  haml :sample_tumble
end if Sinatra::Application.environment == :development

error do
  @error = request.env['sinatra.error'].to_s
  content_type 'text/html'
  haml :error
end unless Sinatra::Application.environment == :development