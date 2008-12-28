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
  f.puts "-# title: #{article[:title_html]}"
  f.puts "-# published: #{article[:published_at].strftime("%Y-%m-%d")}"
  f.puts "-# updated: #{article[:modified_at].strftime("%Y-%m-%d")}" if article[:modified_at]
  f.puts 
  f.puts ":textile"
  body = article[:body]
  body.gsub!(/^/,"  ")
  body.gsub!('#{','\#{')
  body.gsub!("h3. ", "h2. ")
  body.gsub!("h4. ", "h3. ")
  # Fix up headings
  body.gsub!("h3. ", "h2. ") if body.include?("h3. ") && !body.include?("h2. ") 
  body.gsub!("\t", "  ")
  f.puts body
  # unless article.comments.empty?
  #   f.puts
  #   f.puts "#archived-comments"
  #   f.puts "  %h1 Archived Comments"
  #   f.puts "  %p Previously comments were allowed on articles. Though no new comments are being accepted you can see the old comments below."
  #   f.puts "  %ol"
  #   article.comments.each do |comment|
  #     f.puts "    %li#comment_#{comment[:id]}"
  #     f.puts "      %p.author"
  #     if comment[:url] && !comment[:url].empty?
  #       f.puts "        %a{:href => '#{comment[:url]}'} #{comment[:author]}"
  #     else
  #       f.puts "        #{comment[:author]}"
  #     end
  #     f.puts "      .body"
  #     f.puts "        :textile"
  #     f.puts comment[:body].gsub(/^/,"          ").gsub('#{','\#{')
  #   end
  # end
end
