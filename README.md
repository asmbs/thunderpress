# [Thunderpress](https://github.com/asmbs/thunderpress)

A slim WordPress stack inspired heavily by [Bedrock](https://github.com/roots/bedrock).

## Features

- Uses [Mina](http://nadarei.co/mina) for deploy management.
- Includes the [wp-parswdown](https://github.com/friartuck6000/wp-parsedown) plugin to convert WordPress to a Markdown-only CMS.
- Adds several other common and useful plugins out of the box.
- Uses [PHP dotenv](https://github.com/vlucals/phpdotenv) for more secure site config
- Uses environment-specific config files

## Requirements

- PHP 5.5 or later
- [Composer](https://getcomposer.org/doc/00-intro.md#installation-linux-unix-osx)

## Installation

1. Clone this repo, or [download a release](https://github.com/asmbs/thunderpress/releases).
2. Run `composer install`.
3. Copy `.env.example` to `.env` and modify your config parameters (see below).
4. Add any bespoke plugins/themes (be sure to update your `.gitignore` so they'll be tracked).
5. Set your host's document root to `/path/to/vhost/web` (or `/path/to/vhost/current/web` if you're using Mina for deploys).
6. Go!

Your site's WP Admin will be available at `http://example.com/wp/wp-admin`.

### Environment Variables

**Note:** Never track your `.env` file in git!

**Site Environment**

```ini
; Default values shown
WP_ENV     = 'development'
WP_HOME    = 'http://example.com'
WP_SITEURL = 'http://example.com/wp'
```

**Database**

```ini
; Default values shown
DB_NAME     = 'database_name'
DB_USER     = 'database_user
DB_PASSWORD = 'database_password'
DB_HOST     = 'localhost'
DB_PREFIX   = 'wp_'
```

**Keys/Salts**  
_You can generate these automatically with `composer run-script salts`_.

```ini
AUTH_KEY         = ''
SECURE_AUTH_KEY  = ''
LOGGED_IN_KEY    = ''
NONCE_KEY        = ''
AUTH_SALT        = ''
SECURE_AUTH_SALT = ''
LOGGED_IN_SALT   = ''
NONCE_SALT       = ''
```

**Optional Settings**

```ini
; Use another WordPress site in your data to manage users
WP_USER_TABLE      = ''
WP_USER_META_TABLE = ''

; Adjust PHP settings
WP_MEMORY_LIMIT = '128M'

; Analytics tracking (see below)
GA_PROPERTY_ID = 'your_property_id'
```

## Deploying

Make sure [mina is installed](http://nadarei.co/mina) before continuing:

```bash
gem install mina
```

1. Edit `config/deploy.rb` to set up global parameters.

2. To configure a target, copy the example `environment.rb.example` file to `<target>.rb`, where `<target>` is the name of the environment you want to deploy to. You can have as many target environments as you want.

3. Set up the deploy directory on the server:

    ```bash
    mina setup server=<target>
    ```

4. You can deploy to an environment using any branch, commit or tag:

    ```bash
    # Uses master branch by default
    mina deploy server=<target>
    
    # Specify a branch
    mina deploy server=<target> branch=<branch-name>
    
    # Specify a commit
    mina deploy server=<target> commit=<commit-sha>
    
    # Specify a tag
    mina deploy server=<target> tag=<tag-name>
    ```

## Other Stuff

### Google Analytics

Thunderpress includes a built-in plugin (not must-use, you have to activate it) that will automatically add your Google Analytics tracking script. To use it:

1. Activate the plugin
2. Set the `GA_PROPERTY_ID` environment variable in `.env`
3. That's it—the script will be added to your pages automatically.

**Note:** The tracking script _will not_ be added if you're logged in with admin/editing capabilities.