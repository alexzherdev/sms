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
set :user, "alex"
set :branch, "master"

set :rails_env, "production"

role :app, "sms.kicks-ass.org"
role :web, "sms.kicks-ass.org"
role :db,  "sms.kicks-ass.org", :primary => true