require 'rubygems'
gem 'sequel'
require 'sequel'

DB = Sequel.connect('mysql://root:@localhost/toolmantim_production')

class Article < Sequel::Model
  one_to_many :comments, :order => :created_at
end
class Comment < Sequel::Model
end

Article.eager(:comments).filter(:category_id => 1).all.each do |article|
  f = File.open("articles/#{article[:permalink]}.haml", "w")
  f.puts "-# title: #{article[:title_html].gsub("'",'\\\'')}"
  f.puts "-# published: #{article[:published_at].strftime("%Y-%m-%d")}"
  f.puts "-# updated: #{article[:modified_at].strftime("%Y-%m-%d")}" if article[:modified_at]
  f.puts 
  f.puts ":textile"
  f.puts article[:body].gsub(/^/,"  ").gsub('#{','\#{')
  
  unless article.comments.empty?
    f.puts
    f.puts "#comments.comments"
    f.puts "  %h3 Comments"
    f.puts "  <p class='old-comments'>New comments are no longer being accepted.</p>"
    f.puts "  %ol"
    article.comments.each do |comment|
      f.puts "    %li#comment_#{comment[:id]}"
      f.puts "      %p.author"
      if comment[:url] && !comment[:url].empty?
        f.puts "        %a{:href => '#{comment[:url]}'} #{comment[:author]}"
      else
        f.puts "        #{comment[:author]}"
      end
      f.puts "      .body"
      f.puts "        :textile"
      f.puts comment[:body].gsub(/^/,"          ").gsub('#{','\#{')
    end
  end
end
