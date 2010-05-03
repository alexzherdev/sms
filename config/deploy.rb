set :application, "SMS"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/apps/sms"
set :deploy_via, :remote_cache

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :repository, "git@github.com:alexzherdev/sms.git"
set :scm, :git
set :scm_command, "/usr/local/git/bin/git"
set :local_scm_command, "/usr/local/git/bin/git"
set :user, "alex"
set :branch, "master"
set :runner, "alex"

set :rails_env, "production"

role :app, "localhost"
role :web, "localhost"
role :db,  "localhost", :primary => true

desc "Reconfigures and restarts Sphinx search daemon"
task :restart_sphinx do
  run "cd #{current_path}; rake ts:stop RAILS_ENV=production; true"
  run "cd #{current_path}; rake ts:index RAILS_ENV=production"
  run "cd #{current_path}; rake ts:start RAILS_ENV=production"
end

task :after_update_code, :roles => [:app] do
  run "ln -s /#{shared_path}/vendor/rails #{release_path}/vendor/rails"
end

namespace :deploy do
  task :migrate, :roles => :app do
    run "cd #{current_release}; rake db:migrate RAILS_ENV=production"
  end
  
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
  
end

after "deploy:restart", :restart_sphinx