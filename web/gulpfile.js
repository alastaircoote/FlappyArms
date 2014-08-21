var gulp = require("gulp");
var coffee = require("gulp-coffee");
var clean = require('gulp-rimraf');
var less = require("gulp-less");
var watch = require("gulp-watch");
var server = require("tiny-lr")();
var livereload = require("gulp-livereload");
var rs = require("run-sequence");
var ecstatic = require("ecstatic");
var http = require('http');
var rjs = require('gulp-requirejs');
var uglify = require('gulp-uglify');



gulp.task("lr-listen", function() {
    server.listen(35729);
});

gulp.task("clean", function() {
    gulp.src("./tmp").pipe(clean())
});

gulp.task('copy-static', function() {
  gulp.src('./*.html').pipe(watch()).pipe(gulp.dest("./tmp/")).pipe(livereload(server));
  
  gulp.src('./fonts/*.*').pipe(watch()).pipe(gulp.dest("./tmp/fonts")).pipe(livereload(server));
  gulp.src('./data/*.*').pipe(watch()).pipe(gulp.dest("./tmp/data")).pipe(livereload(server));
  
  gulp.src('./coffee/**/*.js').pipe(watch()).pipe(gulp.dest("./tmp/js/")).pipe(livereload(server));
  gulp.src('./assets/**/*').pipe(watch()).pipe(gulp.dest("./tmp/assets/")).pipe(livereload(server));
  gulp.src('./fonts/*').pipe(watch()).pipe(gulp.dest("./tmp/fonts/")).pipe(livereload(server));
});


gulp.task('compile-coffee', function() {
  gulp.src('./coffee/**/*.coffee').pipe(watch()).pipe(coffee()).pipe(gulp.dest("./tmp" + '/js/')).pipe(livereload(server));
});

gulp.task('compile-less', function() {
  gulp.src('./less/main.less').pipe(less()).pipe(gulp.dest("./tmp" + '/css/')).pipe(livereload(server));
});

gulp.task('watch-less', function() {
  gulp.watch("./less/*",['compile-less'])
})


gulp.task('watchtasks', ['lr-listen','copy-static', 'compile-coffee', 'watch-less']);

gulp.task("watch",["watchtasks"],function() {
    http.createServer(
      ecstatic({ root: './tmp', cache:0 })
    ).listen(8080)
    //rs('clean','watchtasks');
})

gulp.task("clean-build", function() {
  gulp.src("./build").pipe(clean())
})

gulp.task("build",function() {
  //var publisher = awspublish.create(s3Deets);
  gulp.src('./*.html').pipe(gulp.dest("./build/"));
  
  gulp.src('./fonts/*.*').pipe(gulp.dest("./build/fonts"))
  gulp.src('./data/*.*').pipe(gulp.dest("./build/data"))
  
  gulp.src('./coffee/**/*.js').pipe(uglify()).pipe(gulp.dest("./build/js/"))
  gulp.src('./assets/**/*').pipe(gulp.dest("./build/assets/"))
  gulp.src('./fonts/*').pipe(gulp.dest("./build/fonts/"))
  gulp.src('./coffee/**/*.coffee').pipe(coffee()).pipe(uglify()).pipe(gulp.dest("./build" + '/js/'));
  gulp.src('./less/*').pipe(less()).pipe(gulp.dest("./build" + '/css/'));

 

})

gulp.task("build-req", function() {
  rs('build', function() {
    console.log("built")
    rjs({
        baseUrl: './build/js',
        out: 'out.js',
        name: "main",
        paths: {
          "jquery": "vendor/jquery",
          bluebird: "vendor/bluebird",
          jquery: "vendor/jquery"
        },
        shim: {
             "vendor/geojson-utils": {
                exports: "gju"
             },
            "vendor/latlon": {
                exports: "LatLon",
                require:["vendor/geo"]
              }
            // standard require.js shim options
        },
        // ... more require.js options
    })
        .pipe(gulp.dest('./build/js'));
  })
   
})