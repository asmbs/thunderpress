module.exports = function(grunt) {

  // Load all tasks automatically
  require('grunt-load-tasks')(grunt);

  // Show elapsed task time when running
  require('time-grunt')(grunt);

  grunt.initConfig({
    // Read package.json file
    pkg: grunt.file.readJSON('package.json'),

    // Define base folder paths
    basepath: {
      plugins: 'web/app/plugins',
      muplugins: 'web/app/mu-plugins',
      themes: 'web/app/themes'
    },

    // Define more specific paths here
    path: {
      /*
      Example:
      theme: {
        root: '<%= basepath.themes %>/your-theme-folder',
        css: '<%= path.theme.root %>/assets/css',
        js: '<%= path.theme.root %>/assets/js',
        less: '<%= path.theme.root %>/assets/less'
      }
      */
    }//,

    // Configure tasks (don't forget to uncomment the comma above)
    // ...
  });

  // Register the default task
  grunt.registerTask('default', []);

  // Register your own tasks here
  // Example:
  // grunt.registerTask('taskname', ['tasks', 'to', 'run']);

};
