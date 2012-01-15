
SSH_TARGET ||= File.expand_path("~/Dropbox/Public")

namespace :ssh
  desc "Upliad final gif using SSH"
  task :upload => [GIF] do
    sh "scp #{GIF} #{SSH_TARGET}"
  end
end
