require "rubygems"
require "spec" # Satisfies Autotest and anyone else not using the Rake tasks
require 'fileutils'
require 'fancypath'
require 'time'

$:.unshift File.dirname(__FILE__) + "/../lib"

require 'article'

module Article::FixtureMethods
  def article
    Article.new("some-template.haml", "some contents")
  end
  def article_with_path(path)
    Article.new(path, "template contents")
  end
  def article_with_contents(contents)
    Article.new("some-template.haml", contents)
  end
  def article_with_published(date)
    Article.new("some-template.haml", "-# published: #{date}")
  end
  def article_with_updated(date)
    Article.new("some-template.haml", "-# updated: #{date}")
  end
  def tmp_articles_path
    File.join(File.dirname(__FILE__), "tmp", "articles")
  end
  def remove_tmp_articles
    FileUtils.rm_rf(tmp_articles_path) if File.directory?(tmp_articles_path)
  end
  def init_tmp_articles_path
    # Create the tmp article path once per description
    unless @inited_tmp_articles_path
      remove_tmp_articles
      FileUtils.mkdir_p(tmp_articles_path)
      Article.path = tmp_articles_path
      @inited_tmp_articles_path = true
    end
  end
  def remove_tmp_articles
    FileUtils.rm_rf(tmp_articles_path) if File.directory?(tmp_articles_path)
  end
  def create_article_file(filename, published=nil, title=nil, content=nil)
    init_tmp_articles_path
    File.open(File.join(tmp_articles_path, "#{filename}.haml"), "w") do |f|
      f.puts "-# published: #{published}" if published
      f.puts "-# title: #{published}" if title
      f.puts content if content
      f.flush
    end
  end
end

Spec::Runner.configure do |config|
  config.include(Article::FixtureMethods)
  config.after(:each) do
    remove_tmp_articles
  end
end