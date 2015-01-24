
import std.algorithm;
import std.container;
import std.conv;
import std.file;
import std.path;
import std.stdio;

import deimos.freeimage;
import std.experimental.logger;

import application;
import config;
import image_sorter;


int main(string[] args) {

    globalLogLevel = LogLevel.info;

    auto config = AppConfig();
    config.check_and_parse(args);

    auto app = new Application();
    app.initialise();
    scope(exit) {
        app.deInitialise();
    }

    logf("Working in directory %s", config.source_dir);
    ImageFileSorter sorter = new ImageFileSorter(
        config.source_dir,
        config.target_dir);
    sorter.process_files(config.dry_run);

    return 0;
}
