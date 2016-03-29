# Load extensions
require 'mina/git'

# Disable pretty-print to prevent known deploy issues
set :term_mode, :exec

# Repository settings
#
# Settings:
#
# - repo_name     The canonical name of your repository. Used by :repository.
# - repository    The full URL to the repository.
# - default_mode  Specify the mode (commit | tag | branch) to use by default.
# - default_ref   Specify the reference (commit hash | tag name | branch name) to use
#                 by default.
#
set :repo_name,    'asmbs/thunderpress'
set :repository,   %[git@github.com:#{repo_name}.git]
set :default_mode, 'branch'
set :default_ref,  'master'


# Global SSH settings
#
set :forward_agent, true


# Shared paths and files
#
# Add shared paths and files (relative to the project root) here.
#
# NOTE: Make sure you queue the appropriate commands to create these items during the
#       :setup task!
#
set :shared_paths, [
  'web/app/uploads',  # WordPress uploads path -- do not remove
  '.env'              # Environment configuration -- do not remove
]


# Build script commands
#
# Add default build commands here. They will be run after the git repository has been
# cloned and the release directory has been populated.
#
# You can also add environment-specific build commands in your deploy/environment.rb file
# by adding commands to the `$env_build_commands` array.
#
$build_commands = [
    %[composer install]
]


# Launch commands
#
# Add default launch commands here. They will be run after a build has successfully
# completed and the release has been symlinked to `current`.
#
# You can also add environment-specific launch commands in your deploy/environment.rb file
# by adding commands to the `$env_launch_commands` array.
#
$launch_commands = []


# Clean commands
#
# Add default clean commands here. They will be run if a deploy or build step fails.
#
# You can also add environment-specific clean commands in your deploy/environment.rb file
# by adding commands to the `$env_clean_commands` array.
#
$clean_commands = []


# Slack settings
#
# The Thunderpress deploy automator can make use of a Slack webhook integration to post
# deploy notifications to a channel or DM.
#
# Settings:
#
# - slack_enabled   Whether to enable the Slack integration (false by default).
# - slack_url       Your service hook URL.
# - slack_username  Optional username override.
# - slack_channel   Optional channel override.
#
set :slack_enabled, false
set :slack_url,     %[https://hooks.slack.com/services/YOUR_INTEGRATION_KEY]
# set :slack_username, ''
# set :slack_channel,  ''


# ==============================================================================================


# Environment init -----------------------------------------------------------------------------

task :environment do

  # Get server from command-line argument, or default to production
  $server = ENV.has_key?('server') ? ENV['server'] : 'production'

  # Generate deploy settings for each server
  unless $server
    print_error %[A server must be specified.]
    exit
  end

  # Load environment configuration
  require_relative %[./deploy/#{$server}.rb]

  # Set up commit/tag/branch references for deploy
  set_deploy_ref settings.default_mode, settings.default_ref

end


# Task: `setup` --------------------------------------------------------------------------------

task :setup => :environment do

  shared_path_dir = %[#{deploy_to}/shared]

  # -- List commands to create all shared files and folders here; they need to exist before
  #    `deploy:link_shared_paths` is run
  # Example:
  # queue! %[mkdir -p -m 777 "#{shared_path_dir}/uploads"]
  queue! %[mkdir -p -m 777 "#{shared_path_dir}/web/app/uploads"]  # WordPress uploads path
  queue! %[touch "#{shared_path_dir}/.env"]                       # Environment configuration

end


# Task: `deploy` -------------------------------------------------------------------------------

task :deploy => :environment do
  deploy do

    # Deploy project
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'deploy:cleanup'

    ref = commit ? commit : branch

    # Configure :build subtask (after successful deploy)
    to :build do
        if defined? ($env_build_commands)
            $build_commands.unshift(*$env_build_commands)
            $build_commands.each { |cmd| queue! %[#{cmd}] }
        end
        slack_notify %[Build completed for _#{repo_name}_ (<#{repo_url}/tree/#{ref}|#{ref}>) on `#{$server}`]
    end

    # Configure :launch subtask (after successful build)
    to :launch do
        if defined? ($env_launch_commands)
            $launch_commands.unshift(*$env_launch_commands)
            $launch_commands.each { |cmd| queue! %[#{cmd}] }
        end
        slack_notify %[Successfully deployed _#{repo_name}_ (<#{repo_url}/tree/#{ref}|#{ref}>) on `#{$server}`]
    end

    # Configure :clean subtask (after failed deploy or build)
    to :clean do
        if defined? ($env_clean_commands)
            $clean_commands.unshift(*$env_clean_commands)
            $clean_commands.each { |cmd| queue! %[#{cmd}] }
        end
        slack_notify %[*DEPLOY FAILED:* _#{repo_name}_ (<#{repo_url}/tree/#{ref}|#{ref}>) on `#{$server}`]
    end

  end
end


# ==============================================================================================


# Helper methods -------------------------------------------------------------------------------

# Set repository reference (branch/commit/tag)
def set_deploy_ref(default_mode='branch', default_ref='master')
  # Load defaults first
  mode = default_mode
  ref = default_ref
  # Try loading from command line to override defaults
  if ENV['commit']
    mode = 'commit'
    ref = ENV['commit']
  elsif ENV['tag']
    mode = 'tag'
    ref = ENV['tag']
  elsif ENV['branch']
    mode = 'branch'
    ref = ENV['branch']
  end
  # Set Mina deploy parameters based on mode and ref
  case mode
  when 'tag'
    set :commit, ref
  when 'commit'
    set :commit, ref
  when 'branch'
    set :branch, ref
  end
end

# Check to see whether Slack can be used
def slack_enabled?
  return settings.slack_enabled && settings.slack_key
end

# Send Slack notification
def slack_notify (message)
  # Bail if no Slack post URL is defined
  if !slack_enabled?
    return
  end
  # Build payload
  payload = '{'
  payload << %["text":"#{message}"]
  if settings.slack_username
    payload << %[,"username":"#{settings.slack_username}"]
  end
  if settings.slack_channel
    payload << %[,"channel":"#{settings.slack_channel}"]
  end
  payload << '}'
  # Queue the POST command
  queue %[curl -X POST --data-urlencode 'payload=#{payload}' #{settings.slack_url}]
end
