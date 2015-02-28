var gulp = require('gulp');

var es = require('event-stream');
var serve = require('gulp-serve');
var livereload = require('gulp-livereload');
var less = require('gulp-less');
var concat = require('gulp-concat');
var plumber = require('gulp-plumber');
var browserify = require('browserify');
var coffeeify = require('coffeeify');
var source = require('vinyl-source-stream');
var rimraf = require('rimraf');

var lessSrc = 'src/**/*.less';
var coffeeSrc = 'src/**/*.coffee';
var coffeeMain = 'src/index.coffee';

var previewDestDir = '.tmp/preview';

function getMainScript() {
    var b = browserify({ basedir: __dirname });
    b.add('./' + coffeeMain);
    b.transform(coffeeify);

    var output = b.bundle();

    output.on('error', function (e) { console.log('browserify error: ' + e); });

    return output
        .pipe(source('bundle.js'));
}

function getMainStylesheet() {
    return gulp.src(lessSrc)
        .pipe(less())
        .pipe(concat('bundle.css'));
}

function getPreviewAssets() {
    return es.merge(
        gulp.src([ 'index.html', 'sample.md' ]),
        getMainScript(),
        getMainStylesheet()
    );
}

gulp.task('default', function () {
    livereload.listen();

    rimraf(previewDestDir, function () {
        gulp.watch([ coffeeSrc, lessSrc, 'index.html', 'sample.md' ], function () {
            getPreviewAssets()
                .pipe(plumber())
                .pipe(gulp.dest(previewDestDir))
                .pipe(livereload())
        });

        es.concat(
            getPreviewAssets()
                .pipe(plumber())
                .pipe(gulp.dest(previewDestDir))
        ).on('end', function () {
            serve({ root: [__dirname + '/' + previewDestDir] })();
        });
    });
});
