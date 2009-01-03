load 'deploy'

default_run_options[:pty] = true

set :application, 'toolmantim'

set :repository,  "git://github.com/toolmantim/toolmantim.git" 
set :deploy_to, "/var/www/toolmantim.com/app" 
set :deploy_via, :remote_cache
set :scm, 'git'
set :branch, 'master'
set :git_shallow_clone, 1
set :scm_verbose, true
set :use_sudo, false

server 'spiderpig.toolmantim.com', :app, :web

namespace :deploy do
  task :restart do
    run "touch #{current_path}/tmp/restart.txt" 
  end
end

after "deploy:restart", "deploy:cleanup"
