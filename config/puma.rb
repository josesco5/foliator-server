environment "production"

bind  "unix:///home/ubuntu/deployment/shared/tmp/sockets/puma.sock"
pidfile "/home/ubuntu/deployment/shared/tmp/pids/puma.pid"
state_path "/home/ubuntu/deployment/shared/tmp/sockets/puma.state"
directory "/home/ubuntu/deployment/current"

workers 2
threads 1,2

daemonize true

activate_control_app 'unix:///home/ubuntu/deployment/shared/tmp/sockets/pumactl.sock'

prune_bundler
