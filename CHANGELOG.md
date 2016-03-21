# Changelog

## 2.1.0
- Built an improved salt generator that:
    - _Replaces_ salt keys if they already exist in the file, instead of always appending them.
    - If keys _are_ being appended to the end of the file, ensures there is a newline so the new key doesn't get tacked onto the end of the last one in the file.
- Renamed the Dotenv _distributed_ file to `.env.dist`.

-----

### 2.0.0
- Unforked from [roots/bedrock](https://github.com/roots/bedrock) so Thunderpress can be maintained as its own project.
- Removed NPM and Grunt at the root level—these tools should be used independently within plugins and themes.
- Removed all explicit repository definitions; dependencies are now fully installable via Packagist.
- General code cleanup.

### 1.3.0
- Update composer dependencies
- Update grunt dependencies

### 1.2.2
- Add Roots developers and James to composer authors propery
- Updated refs to bundled packages  
    - WordPress 4.3.*
    - phpdotenv 2.0.1
- Add wp-mail-smtp mu-plugin ref to composer  
    - wp-mail-smtp 0.9.5
- Added named constants to `.env.example` and `application.php`  
    - Custom user tables
    - GA Tracking Propery ID
    - WP Mail SMTP
- Updated gitignore to exclude IDE related properies and exports from WP-CLI utlities  
- Added wp-cli.yml from Bedrook source updates


### 1.2.1

- Merged latest release of **roots/bedrock** ([3369fe4](https://github.com/roots/bedrock/tree/3369fe4))
- Updated refs to bundled packages

### 1.2.0

- Add embedded Google Analytics plugin to print the GA tracking script automatically with the use of the `GA_PROPERTY_ID` environment variable.

### 1.1.0

- Move to WordPress 4.1.x release channel
- Add default shared paths to Mina deploy configuration
- Add [Deblogifier](https://github.com/asmbs/wp-deblogify) and [P3 Profiler](https://wordpress.org/plugins/p3-profiler/) plugins

### 1.0.1

- Restore Mina example configurations
- Update the core Mina deploy configuration

### 1.0

- Initial package release
