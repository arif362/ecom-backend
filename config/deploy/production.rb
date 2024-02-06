# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

# server "example.com", user: "deploy", roles: %w{app db web}, my_property: :my_value
# server "example.com", user: "deploy", roles: %w{app web}, other_property: :other_value
# server "db.example.com", user: "deploy", roles: %w{db}



# role-based syntax
# ==================

# Defines a role with one or multiple servers. The primary server in each
# group is considered to be the first unless any hosts have the primary
# property set. Specify the username and a domain or IP for the server.
# Don't use `:all`, it's a meta role.

# role :app, %w{deploy@example.com}, my_property: :my_value
# role :web, %w{user1@primary.com user2@additional.com}, other_property: :other_value
# role :db,  %w{deploy@example.com}



# Configuration
# =============
# You can set any configuration variable like in config/deploy.rb
# These variables are then only loaded and set in this stage.
# For available Capistrano configuration variables see the documentation page.
# http://capistranorb.com/documentation/getting-started/configuration/
# Feel free to add new variables to customise your setup.



# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult the Net::SSH documentation.
# http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start
#
# Global options
# --------------
 set :ssh_options, {
   forward_agent: true,
   user: fetch(:deploy_user),
   keys: %w(~/.ssh/id_rsa ~/.ssh/shopoth-live.pem),
 }
#
# The server-based syntax can be used to override options:
# ------------------------------------
# server "example.com",
#   user: "user_name",
#   roles: %w{web app},
#   ssh_options: {
#     user: "user_name", # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: "please use keys"
#   }
#

set :stage, :production
set :branch, :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

set :rails_env, :production
# set :server_port_ssl, 443

set :full_app_name, "#{fetch(:application)}_#{fetch(:stage)}"

# server '18.136.211.177', user: fetch(:deploy_user).to_s, roles: %w(app db), primary: true
server '3.1.82.51', user: fetch(:deploy_user).to_s, roles: %w(app db), primary: true
# server '54.179.189.120', user: fetch(:deploy_user).to_s, roles: %w(app), primary: true
# server '52.221.182.218', user: fetch(:deploy_user).to_s, roles: %w(app), primary: true
# server '52.221.220.140', user: fetch(:deploy_user).to_s, roles: %w(app), primary: true
server '54.179.233.148', user: fetch(:deploy_user).to_s, roles: %w(app), primary: true
# server '18.139.117.79', user: fetch(:deploy_user).to_s, roles: %w(app), primary: true
# server '13.213.44.131', user: fetch(:deploy_user).to_s, roles: %w(app), primary: true
# server '13.229.99.24', user: fetch(:deploy_user).to_s, roles: %w(app), primary: true

# set :server_names, {
#   '192.168.33.10': '192.168.33.10 node0.server',
#   '192.168.33.11': '192.168.33.11 node1.server',
#   '192.168.33.12': '192.168.33.12 node2.server',
# }

set :deploy_to, "#{fetch(:deploy_path)}/#{fetch(:full_app_name)}"
