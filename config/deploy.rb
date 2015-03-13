# -- Load extensions
require 'mina/git'

# -- Disable pretty-print to prevent known deploy issues
set :term_mode, :exec

# -- Repository settings
set :repo_name,  'asmbs/thunderpress' # <-- Replace this with your repo identifier
set :repo_url, %[https://github.com/#{repo_name}]
set :repository, %[#{repo_url}.git]
set :default_mode, 'branch' # Default mode for deploys that don't specify a commit, tag or branch
set :default_ref, 'master'  # Default ref for deploys that don't specify a commit, tag or branch

# -- Global SSH settings
set :forward_agent, true

# -- Shared paths and files
set :shared_paths, []

# -- Slack settings
set :slack_enabled, false
set :slack_key, 'YOUR_SLACK_KEY_HERE'
set :slack_url, lambda { %[https://hooks.slack.com/services/#{slack_key}] }
# set :slack_username, '' # Optional bot-name override
# set :slack_channel, '' # Optional channel override


# ----------------------------------------------------------------------------------------------
# Environment setup
# ----------------------------------------------------------------------------------------------

task :environment do

  # -- Get server from command-line argument, or default to production
  $server = ENV.has_key?('server') ? ENV['server'] : 'production'

  # -- Generate deploy settings for each server
  unless $server
    print_error %[A server must be specified.]
    exit
  end

  # -- Load settings for environment
  require_relative %[./deploy/#{$server}.rb]

  # -- Set up commit/tag/branch references for deploy
  set_deploy_ref settings.default_mode, settings.default_ref

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
      if defined?($launch_commands) && !$launch_commands.empty?
        $launch_commands.each { |cmd| queue! %[#{cmd}] }
      end
      ref = commit ? commit : branch
      slack_notify %[Deploy successful!\\n*Project:* #{repo_name} @ <#{repo_url}/tree/#{ref}|#{ref}>\\n*Server:* #{$server}]
    end

    # -- Run `clean` subtask on failed deployment
    to :clean do
      if defined?($clean_commands) && !$clean_commands.empty?
        $clean_commands.each { |cmd| queue! cmd }
      end
      slack_notify %[Deploy FAILED\\n*Project:* #{repo_name}\\n*Server:* #{$server}]
    end

  end
end


# ----------------------------------------------------------------------------------------------
# Helper methods
# ----------------------------------------------------------------------------------------------

# -- Set repository reference (branch/commit/tag)
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

# -- Check to see whether Slack can be used
def slack_enabled?
  return settings.slack_enabled && settings.slack_key
end

# -- Send Slack notification
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


