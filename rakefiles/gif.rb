
GIF = "#{NAME}-mapnik-zoom#{ZOOM}.gif"

file "./var/full.gif" => [MAPSHOTS_TS] do
  sh "convert -delay #{DELAY} ./mapshots/*.png -loop 0 ./var/full.gif"
end

file GIF => ["./var/full.gif"] do
  sh "gifsicle <./var/full.gif >#{GIF} -O2 #{COLORS ? '--colors ' + COLORS.to_s : ''}"
  sh "gifsicle -b #{GIF} -d #{LAST_DELAY} \"#-1\""
  sh "gifsicle -b #{GIF} -d #{FIRST_DELAY} \"#0\""
end

namespace :gif do
  desc "Create gif from mapshots"
  task :mapshots => GIF
end
