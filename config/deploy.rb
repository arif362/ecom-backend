# config valid for current version and patch releases of Capistrano
lock '~> 3.14.1'

set :application, 'shopoth_backend'
set :deploy_user, 'deploy'
set :deploy_path, "/home/#{fetch(:deploy_user)}/apps"
set :repo_url, 'git@github.com:misfit-tech/shopoth-ecom-backend.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/home/#{deploy_user}/#{deploy_path}/#{app_name}_#{stage}/"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Set rbenv
# set :rbenv_type, :system
set :rbenv_ruby, '2.7.1'
set :rbenv_path, '/usr/local/rbenv/'

set :puma_threads,    [4, 16]
set :puma_workers,    0
set :pty,             true
# set :use_sudo,        false
# set :deploy_via,      :remote_cache
# set :deploy_to,       "/home/#{fetch(:deploy_user)}/apps/#{fetch(:application)}_#{fetch(:stage)}"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}_#{fetch(:stage)}_puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.access.log"
set :puma_error_log,  "#{release_path}/log/puma.error.log"
set :puma_preload_app, true
set :puma_init_active_record, false  # Change to true if using ActiveRecord

# Default value for :linked_files is []
append :linked_files, 'config/database.yml', '.rbenv-vars', 'puma.rb', 'pumactl.shopoth', "config/credentials/#{fetch(:stage)}.key"

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/sitemaps', 'public/system', 'public/uploads', 'public/exported_files', 'vendor/bundle', 'storage'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :security

# set :assets_roles, [:web, :app]

# Defaults to ["/path/to/release_path/public/#{fetch(:assets_prefix)}/.sprockets-manifest*", "/path/to/release_path/public/#{fetch(:assets_prefix)}/manifest*.*"]
# This should match config.assets.manifest in your rails config/application.rb
# set :assets_manifests, ['app/assets/config/manifest.js']

# If you need to touch public/images, public/javascripts, and public/stylesheets on each deploy
# set :normalize_asset_timestamps, %w{public/images public/javascripts public/stylesheets}


=begin

namespace :deploy do
  task :setup_config do
    on roles(:app) do
     app_path = "apps/#{fetch(:application)}_#{fetch(:stage)}"
     # sudo "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{fetch(:application)}_staging"
     execute "mkdir -p #{app_path}/shared/config"
     # execute "mkdir -p #{app_path}/shared/config"
     upload! 'config/database.example.yml', "#{shared_path}/config/database.yml"
     upload! '.env', "#{shared_path}/config/"
     puts "Now edit the config files in #{shared_path}."
    end
  end

=end

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "rm -rf #{shared_path}/tmp/sockets/#{fetch(:application)}_#{fetch(:stage)}_puma.sock"
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  desc 'Stop PUMA manually and then start'
  task :manual_start do
    on roles(:app) do
      # Make sure the bash script is executable
      # execute "cd #{current_path} && . #{shared_path}/pumactl.batb", pty: false
      execute ". #{current_path}/pumactl.shopoth", pty: false
    end
  end
end

namespace :deploy do
  desc 'Make sure local git is in sync with remote.'
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/development`
        puts 'WARNING: HEAD is not the same as origin/development'
        puts 'Run `git push` to sync changes.'
        exit
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  before :deploy,       'puma:make_dirs'
  # before :starting,     :check_revision
  # after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  after  :finishing,    'puma:manual_start'

end
