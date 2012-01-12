#!/usr/bin/env ruby

require 'rexml/document'

lats = []
lons = []

file = ARGV[0]
xml = File.read(file)
doc = REXML::Document.new(xml)
doc.elements.each('//coordinates') do |e|
  e.text.split(' ').each do |pair|
    lon, lat = pair.split(',')
    lats.push(lat.to_f)
    lons.push(lon.to_f)
  end
end

puts "BBOX: #{lons.min} #{lats.max} #{lons.max} #{lats.min}"
