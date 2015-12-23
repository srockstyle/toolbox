#!gbin/bash
## USAGE
# sh ./application_template.sh [PROJECTNAME]
#
## Local Project Directory
PROJECTDIR=$1
##-----------------------------------------
## Create Template  Directory
##-----------------------------------------
/bin/mkdir -p $PROJECTDIR
/bin/cd $PROJECTDIR

## Create Project Directory
dir=(
  "app/assets"
  "app/assets/stylesheets"
  "app/assets/stylesheets/foundation"
  "app/assets/stylesheets/layout"
  "app/assets/stylesheets/object"
  "app/assets/stylesheets/object/component"
  "app/assets/stylesheets/object/project"
  "app/assets/stylesheets/object/utility"
  "app/assets/javascripts"
  "app/assets/fonts"
  "app/assets/images"
  "app/views"
  "app/views/layouts"
  "app/views/shared"
  "app/models"
  "app/models/concerns"
  "public"
  "public/stylesheets"
  "public/javascripts"
  "public/fonts"
  "test"
  "config"
  "config/environments"
  "config/initializers"
  "bin"
  "lib"
)
for ((i = 0; i < ${#dir[@]}; i++)) {
  /bin/mkdir -p "$PROJECTDIR/${dir[i]}"
  echo ${dir[i]}
}
## Config File Template
cat << EOS > $PROJECTDIR/package.json
{
  "name": "$1",
  "version": "0.0.0",
  "description": "description text",
  "main": "index.js",
  "scripts": {
    "react": "gulp react",
    "watch": "gulp watch"
  },
  "repository": {
    "type": "git",
    "url": "git@github.com:repo/repo.git"
  },
  "author": "",
  "license": "ISC",
  "devDependencies": {
    "browser-sync": "^2.6.5",
    "del": "^1.1.1",
    "gulp": "^3.8.11",
    "gulp-coffee": "^2.3.1",
    "gulp-compass": "^2.0.3",
    "gulp-concat": "^2.5.2",
    "gulp-connect": "^2.2.0",
    "gulp-csscomb": "^3.0.3",
    "gulp-cssmin": "^0.1.7",
    "gulp-data": "^1.2.0",
    "gulp-front-matter": "^1.2.2",
    "gulp-header": "^1.2.2",
    "gulp-jade": "^1.0.0",
    "gulp-layout": "0.0.3",
    "gulp-markdown": "^1.0.0",
    "gulp-pleeease": "^1.2.0",
    "gulp-plumber": "^1.0.0",
    "gulp-react": "^2.0.0",
    "gulp-ruby-sass": "^1.0.1",
    "gulp-sass": "^1.3.3",
    "gulp-uglify": "^1.2.0",
    "gulp-using": "0.0.1",
    "gulp-util": "^3.0.4",
    "gulp-watch": "^4.2.0",
    "gulp-webserver": "^0.8.7",
    "jade": "^1.9.2",
    "node-sass": "^2.1.1",
    "run-sequence": "^1.1.0"
  },
  "dependencies": {
    "gulp-haml": "^0.1.5",
    "react": "^0.12.0"
  }
}
EOS

cd $PROJECTDIR

## Module Install
/usr/local/bin/npm install

## Gulpfile Template
cat << EOS > gulpfile.js
var gulp = require('gulp');
var gutil = require('gulp-util');
var browserSync = require('browser-sync');
var reload = browserSync.reload;
var data = require('gulp-data');
var plumber = require('gulp-plumber');
var sass = require('gulp-sass');
var pleeease = require('gulp-pleeease');
var csscomb = require('gulp-csscomb');
var cssmin = require('gulp-cssmin');
var jade = require('gulp-jade');
var del = require('del');
var runSequence = require('run-sequence');
var header  = require('gulp-header');
var coffee  = require('gulp-coffee');
var concat  = require('gulp-concat');
var uglify  = require('gulp-uglify');
var layout = require('gulp-layout');
var frontMatter = require('gulp-front-matter');
var markdown = require('gulp-markdown');


//-----------------------------------
// 変数的なの
//-----------------------------------
var BANNER = [
  '@charset "utf-8";',
  '/**',
  ' * <%= pkg.name %> - <%= pkg.description %>',
  ' * @link <%= pkg.url %>',
  ' * @version v<%= pkg.version %>',
  ' * @Author <%= pkg.author %>',
  ' * @Author URI <%= pkg.author %>',
  ' */',
  ''
].join('\n');

//-----------------------------------
// デフォルトタスク
//-----------------------------------
gulp.task('default', function () {
  browserSync({
    notify: false,
    port: 3333,
    server: {
      baseDir: ['./public/']
    }
  });
  gulp.watch(['./app/assets/stylesheets/*.sass','./app/assets/stylesheets/**/_*.sass'],['sass']);
  gulp.watch(['./app/views/*.jade','./app/views/**/*.jade','./app/views/**/_*.jade','./app/views/layouts/*.jade'],['jade']);
  gulp.watch(['./app/assets/javascripts/*.coffee','./app/assets/javascripts/**/_*.coffee'],['coffee']);
  console.log("tesuto")
  gulp.watch(['./app/assets/javascripts/*.js'],['compile-js']);
});


//-----------------------------------
// JADE
//-----------------------------------
gulp.task('jade', function () {
  gulp.src(['./app/views/*.jade','./app/views/**/*.jade','!src/jade/**/_*.jade','!src/jade/layouts/*.jade'])
    .pipe(plumber())
    // .pipe(data(function(file) {
    //   return require('./data/' + path.basename(file.path) + '.json');
    // }))
    .pipe(frontMatter())
    .pipe(layout(function(file) {
      return file.frontMatter;
    }))
    .pipe(jade({
      pretty: true
    }))
    .pipe(gulp.dest('./public/'))
    .on('end', reload);
});


//-----------------------------------
// SASS
//-----------------------------------
gulp.task('sass', function () {
  gulp.src(['./app/assets/stylesheets/*.scss','./app/assets/stylesheets/**/_*.scss'])
    .pipe(plumber())
    .pipe(sass())
    .pipe(pleeease({
      minifier: false,
      autoprefixer: 'chrome >= 39'
    }))
    .on('error', console.error.bind(console))
    .pipe(header('@charset "utf-8";\n'))
    .pipe(gulp.dest('./public/stylesheets'))
    .on('end', reload);
});

gulp.task('sass:deproy', function () {
  gulp.src(['./app/assets/stylesheets/*.scss','./app/assets/stylesheets/**/_*.scss'])
    .pipe(sass())
    .pipe(pleeease({
      autoprefixer: AUTOPREFIXER_BROWSERS,
      minifier: false
    }))
    .pipe(csscomb())
    .pipe(cssmin())
    .pipe(header(BANNER, { pkg : pkg } ))
    .pipe(gulp.dest('./public/stylesheets'));
});


//-----------------------------------
// Coffee Script
//-----------------------------------
gulp.task('coffee', function () {
  gulp.src(['./app/assets/javascripts/*.coffee','./app/assets/javascripts/**/_*.coffee'])
    .pipe(plumber())
    .pipe(coffee({ bare: true }))
    .on('error', console.error.bind(console))
    .pipe(gulp.dest('./public/js/'))
});

gulp.task('compile-js',function () {
  var compileFileName = 'application.js'
  gulp.src(['./public/javascripts/*.js','!publc/javascripts/' + compileFileName])
    .pipe(uglify())
    .pipe(concat(compileFileName))
    .pipe(gulp.dest('./public/javascripts/libs'))
    .on('end', reload);
});
EOS

## Sass
cat << EOS > app/assets/stylesheets/application.css.sass
/* =============================
 * reset styles import compass/reset
 * =============================

/* =============================
 * global style
 * =============================
@import lib/*

/* =============================
 * common styles
 * =============================
@import common

/* =============================
 * main layout styles
 * =============================

@import shared/header
@import shared/footer

/* =============================
 * each page layout styles
 * =============================

@import pages/*%
EOS

## Bower Template
cat << EOS > bower.json
{
  "name": 'common',
  "version": '0.0.0',
  "authors": [
    'srockstyle <kobayashi_shohei@srockstyle.com>'
  ],
  "license": 'MIT',
  "ignore" [
    '**/.*',
    'node_modules',
    'bower_components',
    'test',
    'tests'
  ]
}
EOS

## JSフレームワーク選択
create_backborn() {
  /usr/local/bin/bower install backbone --save-dev
  /usr/local/bin/bower install underscore --save-dev
  /usr/local/bin/bower install jquery --save-dev
}
