var gulp = require('gulp');
var coffee = require('gulp-coffee');
gulp.task('coffee-script', function() {
  gulp.src('./src/*.coffee')
  	.pipe(coffee({bare: true}))
  	.pipe(gulp.dest('./dist/'));
});
gulp.task('watch', function(){
	gulp.watch('./src/*.coffee', ['coffee-script']);
});