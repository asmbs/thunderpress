# -- Load extensions
require 'mina/git'
# require 'slack-notifier' # <-- Uncomment this to use Slack notifications

# -- Disable pretty-print to prevent known deploy issues
set :term_mode, :exec

# -- Repository settings
set :repo_name,  'asmbs/thunderpress' # <-- Replace this with your repo identifier
set :repo_url,   %[https://github.com/#{repo_name}.git]
set :ref_tag,    '' # For tag-based deploys
set :ref_commit, '' # For commit-based deploys
set :ref_branch, '' # For branch-based deploys

# -- Global SSH settings
set :forward_agent, true

# -- Shared paths and files
set :shared_paths, []


# ----------------------------------------------------------------------------------------------
# Environment setup
# ----------------------------------------------------------------------------------------------

task :environment do

  # -- Get server from command-line argument, or default to production
  server = ENV.has_key?('server') ? ENV['server'] : 'production'

  # -- Generate deploy settings for each server
  case server
  when 'production'

    # -- SSH settings
    set :domain, ''
    set :user,   ''
    set :port,   '22'
    # set :identity_file, '' # <-- If you're using a keypair, place the path to your private key here

    # -- Deploy path on server
    set :deploy_to, ''

    # -- Set repository reference for deployment
    set_ref('tag')

    # -- Set lists of commands to run on success or failure of deployment
    launch_commands = [
      %[composer install],
      %[sudo service httpd restart]
    ]
    clean_commands = []

  end
end


# ----------------------------------------------------------------------------------------------
# Task: `setup`
# ----------------------------------------------------------------------------------------------

task :setup => :environment do

  shared_path_dir = %[#{deploy_to}/shared]

  # -- List commands to create all shared files and folders here; they need to exist before
  #    `deploy:link_shared_paths` is run
  # Example:
  # queue! %[mkdir -p -m 777 "#{shared_path_dir}/uploads"]

end


# ----------------------------------------------------------------------------------------------
# Task: `deploy`
# ----------------------------------------------------------------------------------------------

task :deploy => :environment do
  deploy do

    # Deploy project
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'deploy:cleanup'

    # -- Run `launch` subtask on successful deployment
    to :launch do
      # Run any set launch commands
      if launch_commands.defined? && !launch_commands.empty?
        launch.commands.each { |cmd| queue! cmd }
      end

      # Post a Slack notification (maybe)
      if slack_enabled?
        # Do stuff
      end
    end

    # -- Run `clean` subtask on failed deployment
    to :clean do
      if clean_commands.defined? && !clean_commands.empty?
        clean_commands.each { |cmd| queue! cmd }
      end
    end
    
  end
end


# ----------------------------------------------------------------------------------------------
# Helper methods
# ----------------------------------------------------------------------------------------------

# -- Set repository reference (branch/commit/tag)
def set_ref (default_mode='branch')
  mode = ENV.has_key?('mode') ? ENV['mode'] : default_mode
  case mode
  when 'tag'
    set :commit, ref_tag
  when 'commit'
    set :commit, ref_commit
  when 'branch'
    set :branch, ref_branch
  end
end

# -- Check to see whether the slack-notifier gem is enabled
def slack_enabled?
  ref = Required::Module::const_get 'Slack'
  return true
rescue NameError
  return false
end
