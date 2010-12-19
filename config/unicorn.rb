# unicorn -c config/unicorn.rb -E production -D

# Environment variables
rails_env = ENV['RAILS_ENV'] || 'production'
cap_root = "#{ENV['HOME']}/#{rails_env}"
shared = "#{cap_root}/shared"

# 8 workers in production
worker_processes (rails_env == 'production' ? 8 : 4)

# Load rails+LinuxFr.org into the master before forking workers for super-fast worker spawn times
preload_app true

# Restart any workers that haven't responded in 30 seconds
timeout 30

# Set the root directory of our Rails app
working_directory "#{cap_root}/current"

# Logs & pid
stdout_path "#{shared}/log/unicorn.log"
stderr_path "#{shared}/log/unicorn.log"
pid "#{shared}/pids/unicorn.pid"

# Listen on a Unix data socket
listen "#{shared}/tmp/sockets/#{rails_env}.sock"


before_fork do |server, worker|
  # There's no need for the master process to hold a connection
  ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection

  # Don't share the redis connections
  $redis = Redis.connect
  Rails.cache.instance_variable_get(:@data).client.reconnect
end
