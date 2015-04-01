<?php
/**
 * Plugin Name: Thunderpress – Google Analytics
 * Version:     1.2.0
 * Description: Enables Google Analytics tracking independent of themes or other plugins by use of an environment variable.
 * Plugin URI:  https://github.com/asmbs/thunderpress
 * Author:      The A-TEAM (ASMBS)
 * Author URI:  https://github.com/asmbs
 * License:     MIT License
 */

namespace Thunderpress\Plugin\GoogleAnalytics;

// Protect from direct access
if (!defined('ABSPATH'))
  exit;

add_action('init', function() {
  if (!current_user_can('edit_posts') && getenv('GA_PROPERTY_ID'))
  {
    add_action('wp_head', __NAMESPACE__ .'\\print_ga_script');
  }  
});

function print_ga_script()
{
  printf(
    '<script>
(function(i,s,o,g,r,a,m){i[\'GoogleAnalyticsObject\']=r;i[r]=i[r]||function(){(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)})(window,document,\'script\',\'//www.google-analytics.com/analytics.js\',\'ga\');
ga(\'create\', \'%s\', \'auto\');
ga(\'send\', \'pageview\');
</script>',
    getenv('GA_PROPERTY_ID')
  );
}
