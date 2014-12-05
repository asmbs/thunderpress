# -- Load extensions
require 'mina/git'

# -- Disable pretty-print to prevent known deploy issues
set :term_mode, :exec

# -- Repository settings
set :repo_name,  'asmbs/thunderpress' # <-- Replace this with your repo identifier
set :repo_url, %[https://github.com/#{repo_name}]
set :repository, %[#{repo_url}.git]

# -- Checkout references
set :ref_tag,    ''       # For tag-based deploys
set :ref_commit, ''       # For commit-based deploys
set :ref_branch, 'master' # For branch-based deploys

# -- Global SSH settings
set :forward_agent, true

# -- Shared paths and files
set :shared_paths, []

# -- Slack settings
set :slack_enabled, false
# set :slack_url, ''
# set :slack_username, ''
# set :slack_channel, ''


# ----------------------------------------------------------------------------------------------
# Environment setup
# ----------------------------------------------------------------------------------------------

task :environment do

  # -- Get server from command-line argument, or default to production
  $server = ENV.has_key?('server') ? ENV['server'] : 'production'

  # -- Generate deploy settings for each server
  case $server
  when 'production'

    # -- SSH settings
    set :domain, ''
    set :user,   ''
    set :port,   '22'
    # set :identity_file, '~/.ssh/path/to/key' # <-- If you're using a keypair, place the path to your private key here

    # -- Deploy path on server
    set :deploy_to, ''

    # -- Set repository reference for deployment
    set_ref('tag')

    # -- Set lists of commands to run on success or failure of deployment
    $launch_commands = [
      %[composer install],
      %[sudo service httpd restart]
    ]
    $clean_commands = []

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

# -- Check to see whether Slack can be used
def slack_enabled?
  return settings.slack_enabled && settings.slack_url
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


