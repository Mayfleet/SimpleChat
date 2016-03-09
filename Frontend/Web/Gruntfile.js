'use strict';

module.exports = function (grunt) {

    require('load-grunt-tasks')(grunt);

    grunt.initConfig({
        pkg: grunt.file.readJSON('./package.json'),

        clean: {
            dist: ['dist/**/*'],
            static: {
                options: {
                    force: true
                }
            }
        },

        copy: {
            dist: {
                files: [
                    {
                        expand: true,
                        cwd: 'src/',
                        src: [ '**/*' ],
                        dest: 'dist'
                    }
                ]
            }
        },

        watch: {
            options: {
                livereload: 9124
            },
            scripts: {
                files: 'src/**/*',
                tasks: [ 'play:started', 'clean', 'default', 'play:finished' ]
            }
        },

        play: {
            started: { file: './misc/started.wav' },
            finished: { file: './misc/finished.wav' }
        },

        connect: {
            options: {
                livereload: 9124,
                hostname: '*'
            },
            livereload: {
                options: {
                    open: true,
                    port: 8085,
                    base: 'dist'
                }
            }
        }
    });

    grunt.registerTask('default', ['clean', 'copy' ]);

    grunt.registerTask('server', [ 'default', 'connect:livereload', 'watch' ]);

};