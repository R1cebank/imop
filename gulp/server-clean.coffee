module.exports = (gulp, config) ->

  gulp.task 'server:clean', ->

    clean = require 'gulp-clean'

    gulp.src ['dist'], read: false
      .pipe(clean())
