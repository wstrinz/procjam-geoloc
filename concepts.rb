require 'open-uri'
require 'json'

data = open('http://conceptnet5.media.mit.edu/data/5.4/search?rel=/r/IsA&end=/c/en/soldier&limit=100')
puts JSON.parse(data.read)['edges'].map{|e| e['surfaceStart']}.compact
