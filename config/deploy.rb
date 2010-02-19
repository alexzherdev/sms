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

task :after_update_code, :roles => [:app] do
  run "ln -s /#{shared_path}/vendor #{release_path}/vendor"
end

namespace :deploy do
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