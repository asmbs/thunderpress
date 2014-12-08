# [ThunderPress](https://github.com/asmbs/thunderpress)

ThunderPress is a WordPress stack, based on [Bedrock][bedrock]; it includes a few nice plugins and replaces the Capistrano deploy automator with [Mina][mina]. In addition, it allows you to control the source of specified plugins and themes as part of your core package — for those projects where purpose-built plugins and themes are used, but you don't want to manage separate repositories for each.

[bedrock]:    https://github.com/roots/bedrock
[mina]:       http://nadarei.co/mina
[changelog]:  changelog.md

## Contents

1.  [Getting started (on development)](#getting-started-on-development)
2.  [Deploying to another server with Mina](#deploying-to-another-server-with-mina)
    -   [Setting up and deploying](#setting-up-and-deploying)
3.  [Environment variables](#environment-variables)

## Getting started (on development)

1.  Fork this repository or download a copy (preferably a stable release)
2.  Copy `.env.example` to `.env` and tailor your settings (see [Environment Variables](#environment-variables) below)
3.  Add or adjust any dependencies in `composer.json` and `package.json`
3.  Run `composer install` — Composer will automatically run `npm install` for you
4.  Point your virtual host's directory to `{PACKAGE_ROOT}/web`
5.  Access the WordPress dashboard at `http://yourdomain.com/wp/wp-admin`

## Deploying to another server with [Mina][mina]

Mina is a deployment and automation tool similar to Capistrano (which Bedrock supports), except it's _intensely faster_ — take a look at Mina's documentation to learn more about why.

Thunderpress uses a modified Mina deploy script that supports multiple environments and command-line commit targeting. Check out `config/deploy.rb` and the sample environment config, `config/deploy/environment.rb.example`, to learn how the two interact.

Thunderpress's deploy configuration also supports [Slack][slack] webhook notifications. If you or your team uses Slack and you have an _Incoming Webhook_ integration set up, Mina can automatically post messages to Slack for successful and failed deployments.

### Setting up and deploying

1.  Edit `config/deploy.rb` to set global project parameters and defaults, and to set up Slack notifications.

2.  Edit `config/deploy/<server-name>.rb` to configure the `<server-name>` environment (you can create as many environments as you'd like).

2.  Set up the deploy directory on the `<server-name>` environment:

    ```sh
    -$ mina setup server=<server-name>
    ```

3.  Deploy to the `<server-name>` environment using the branch, tag or commit specified by `<ref>`:
    
    ```sh
       # Deploy using a branch
    -$ mina deploy server=<server-name> [branch=<ref>]
       # OR, Deploy using a tag
    -$ mina deploy server=<server-name> [tag=<ref>]
       # OR, Deploy using a specific commit
    -$ mina deploy server=<server-name> [commit=<ref>]
    ```

[slack]: https://slack.com

## Environment variables

WordPress settings are defined as environment variables in the `.env` file, using this simple format:

```sh
VAR_NAME='value'
```

_**Note:** Never allow your `.env` file to be tracked by git, unless you want to publish your WordPress database credentials and auth keys on GitHub for the world to see._

#### Supported parameters:

**Environment:**

-   `WP_ENV`
-   `WP_HOME`
-   `WP_SITEURL`

**Database:**

-   `DB_NAME`
-   `DB_USER`
-   `DB_PASSWORD`
-   `DB_HOST`
-   `DB_PREFIX`

**Keys and salts:**

-   `AUTH_KEY`
-   `SECURE_AUTH_KEY`
-   `LOGGED_IN_KEY`
-   `NONCE_KEY`
-   `AUTH_SALT`
-   `SECURE_AUTH_SALT`
-   `LOGGED_IN_SALT`
-   `NONCE_SALT`

_**Note:** You can generate these automatically by running `composer run-script salts`._

**Other settings:**

-   `WP_USER_TABLE` — Use another WordPress installation (on the same database) to manage user data
-   `WP_USER_META_TABLE` — Use another WordPress installation (on the same database) to manage user metadata
-   `WP_MEMORY_LIMIT`

[phpdotenv]: https://github.com/vlucas/phpdotenv
