
import std.algorithm;
import std.container;
import std.conv;
import std.file;
import std.path;
import std.stdio;

import deimos.freeimage;
import std.experimental.logger;

import config;
import image_sorter;


int main(string[] args) {

    log("Initialising freeimage library");
    FreeImage_Initialise();
    scope(exit) {
        log("Freeing up freeimage library");
        FreeImage_DeInitialise();
    }

    AppConfig config = AppConfig();
    try {
        config.check_and_parse(args);
    } catch (Exception e) {
        return 1;
    }

    logf("Working in directory %s", config.source_dir);

    ImageFileSorter sorter = new ImageFileSorter(
        config.source_dir,
        config.target_dir);
    sorter.process_files(config.dry_run);

    return 0;
}
