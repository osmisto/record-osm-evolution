
SSH_TARGET ||= "?"

namespace :ssh do
  desc "Upload final gif using SSH"
  task :publicate => [GIF] do
    sh "scp #{GIF} #{SSH_TARGET}"
  end
end
