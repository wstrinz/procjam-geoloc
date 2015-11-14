require 'open-uri'
require 'json'

class Geo
  MAPZEN_BASE_V1 = "http://search.mapzen.com/v1"
  STRING_FNS = {
    make_cgi: ->(opts) { opts.map{|k,v| "#{k}=#{v}"}.join("&") }
  }

  #FNS = {
    #mapzen_call: ->(key, endpoint, opts) {
      #opts_fn = STRING_FNS[:make_cgi]
      #reverse_search = "api_key=#{key}"
      #path = "#{MAPZEN_BASE_V1}/#{endpoint}?#{auth_str}&#{opts_fn[opts]}"
      #puts path
      #JSON.parse open(path).read
    #},
    #search: ->(inst_fns, key, text) {
      #data = inst_fns[:mapzen_call]["search", {text: text}]
      #data['features']
    #},
    #reverse_search: ->(inst_fns, key, lat, lng) {
      #data = inst_fns[:mapzen_call]["reverse", {"point.lat": lat, "point.lon": lng}]
    #}
  #}

  def initialize(api_key)
    @api_key = api_key
    @path_fn = ->(endpoint, opts_text) {"http://search.mapzen.com/v1/#{endpoint}?api_key=#{@api_key}&#{opts_text}" }
    @make_call = ->(endpoint, opts) {
      path = @path_fn.call endpoint, STRING_FNS[:make_cgi].call(opts)
      JSON.parse open(path.to_s).read
    }
  end

  def search(text)
    data = @make_call['search', {text: text}]
    data['features']
  end

  def reverse_search(lat, lng, filters = {})
    @make_call['reverse', {'point.lat': lat, 'point.lon': lng}.merge(filters)]
  end

  def local_features(lat, lng, filters = {})
    rev = reverse_search(lat, lng, filters)
    rev.fetch("features",{}).map{|f| f.fetch('properties', {})}.compact
  end

  def place(id)
    @make_call['place', {ids: id}]
  end
end

geo = Geo.new(ENV['MAPZEN_KEY'])#.search["YMCA"]

resp = geo.local_features(43.064152199999995, -89.414197, layers: "venue,neighbourhood", size: 150)
ids = resp.map{|r| r['gid']}
# ids.map(&pl)
puts geo.place ids.join(',')

# puts JSON.pretty_unparse resp
