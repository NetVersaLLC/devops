# http://michaelvanrooijen.com/articles/2011/06/01-more-concurrency-on-a-single-heroku-dyno-with-the-new-celadon-cedar-stack/

app_base = "/home/ubuntu/contact"

worker_processes 3
working_directory "#{app_base}/current"

# This loads the application in the master process before forking
# worker processes
# Read more about it here:
# http://unicorn.bogomips.org/Unicorn/Configurator.html
preload_app true

timeout 30

# This is where we specify the socket.
# We will point the upstream Nginx module to this socket later on
listen "#{app_base}/shared/unicorn.sock", :backlog => 64

pid "#{app_base}/shared/pids/unicorn.pid"

# Set the path of the log files inside the log folder of the testapp
stderr_path "#{app_base}/shared/log/err.log"
stdout_path "#{app_base}/shared/log/out.log"

before_fork do |server, worker|
# This option works in together with preload_app true setting
# What is does is prevent the master process from holding
# the database connection
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
# Here we are establishing the connection after forking worker
# processes
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end

