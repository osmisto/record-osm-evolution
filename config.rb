# -*- ruby -*-

# DIRS
HOME = File.dirname(__FILE__)
CUR = Dir.pwd
VAR = "#{CUR}/var"

# TOOLS
MAP_GRABBER = "#{HOME}/tools/mkmap.pl"


def rakefile(name)
  require "#{HOME}/rakefiles/#{name}"
end
