environment 'production'

root = "#{Dir.getwd}"
puts "Root: #{root}"

bind 'tcp://0.0.0.0:3000'
pidfile "#{root}/tmp/puma/pid"
state_path "#{root}/tmp/puma/state"
stdout_redirect "#{root}/tmp/puma/log/stdout", "#{root}/tmp/puma/log/stderr", true
rackup "#{root}/config.ru"

threads 4, 8

activate_control_app

daemonize
