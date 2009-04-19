require 'net/http'
require 'hpricot'
require 'uri'
require 'delegate'

class Flickr
  def recent
    call("search", "per_page" => 9)/:photo
  end
  def featured
    call("search", "tags" => "feature", "per_page" => 500)/:photo
  end
  def photo(id)
    call("getInfo", "photo_id" => id).search(:photo).first
  end
  def sizes(photo)
    call("getSizes", "photo_id" => photo[:id])/:size
  end
  def next_previous(photo)
    featured = featured()
    [photo, featured].flatten.each {|p| def p.==(other); self[:id] == other[:id]; end }
    index = featured.index(photo)
    index && [index != 0 && featured[index-1], featured[index+1]]
  end
  def call(method, params)
    res = Net::HTTP.get(URI.parse("http://api.flickr.com/services/rest/?method=flickr.photos.#{method}&api_key=0e5de53043827665f99e9508ce5c40cf&user_id=57794886@N00#{params.collect{|k,v|"&#{k}=#{v}"}}"))
    return Hpricot(res) if !res.include?('stat="fail"')
  end
end

class PrefetchedFlickr < Flickr
  def initialize
    @featured_thread = create_featured_fetcher_thread
  end
  def featured_with_prefetch # override
    STDERR.puts "Returning cached flickr photos"
    @featured_thread["photos"]
  end
  alias :featured_without_prefetch :featured
  alias :featured :featured_with_prefetch

  private
    def create_featured_fetcher_thread
      Thread.new do
        Thread.current["photos"] = []
        while true do
          Thread.current["photos"] = featured_without_prefetch
          STDERR.puts "Fetched #{Thread.current["photos"].length} photos"
          sleep(30)
        end
      end
    end
end

$flickr = PrefetchedFlickr.new