
DROPBOX_PUBLIC ||= File.expand_path("~/Dropbox/Public")

namespace :dropbox do
  desc "Publicate final files using Dropbox"
  task :publicate => [GIF] do
    sh "cp #{GIF} #{DROPBOX_PUBLIC}"
  end
end
