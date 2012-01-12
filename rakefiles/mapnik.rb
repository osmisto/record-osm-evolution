# -*- ruby -*-

require 'mathn'
require 'date'

MAPSHOTS_DIR = "#{CUR}/mapshots"
MAPSHOTS_TS = "#{MAPSHOTS_DIR}/.timestamp"

module Grabbers

  def Grabbers.lonlat2xy(zoom, lon, lat)
    lat_rad = lat / 180 * Math::PI
    n = 2.0 ** zoom
    x = ((lon + 180) / 360.0 * n).to_i
    y = ((1 - Math.log(Math.tan(lat_rad) + (1 / Math.cos(lat_rad))) / Math::PI) / 2.0 * n).to_i
    return x,y
  end


  class TileGrabber
    attr_accessor :zoom, :left, :right, :top, :bottom, :urls

    def initialize(params={})
      @urls = params[:urls] || []
      @zoom = params[:zoom]
      latlon_box(params[:bbox]) if params[:bbox]
    end

    def latlon_box(bbox)
      @left, @top = Grabbers.lonlat2xy(@zoom, bbox[0], bbox[1])
      @right, @bottom = Grabbers.lonlat2xy(@zoom, bbox[2], bbox[3])
    end

    def grab(file)
      url_args = @urls.map {|s| "-u #{s}"}.join(" ")
      # TODO: may be replace this with urby code
      sh "#{MAP_GRABBER} -z #{@zoom} -b #{@left},#{@top}-#{@right},#{@bottom} -f #{file} #{url_args}"
    end

  end
end

def get_last
  FileList.new("#{MAPSHOTS_DIR}/*.png").sort.last
end

namespace :mapnik do
  desc "Grab mapshots from mapnik layer"
  task :grab do
    last = get_last()
    last_size = last ? File.size(last) : 0

    time = DateTime.now.strftime("%F-%H-%M")
    file = "#{MAPSHOTS_DIR}/#{time}.png"

    g = Grabbers::TileGrabber.new :zoom => ZOOM, :bbox => BBOX
    g.grab(file)

    # Check if it has good difference
    diff = last_size - File.size(file)
    if (diff.abs < THRESHOLD and last != file)
      sh "rm #{file}"
    else
      sh "touch #{MAPSHOTS_TS}"
    end
  end
end
