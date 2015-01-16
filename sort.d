
import std.algorithm;
import std.container;
import std.conv;
import std.file;
import std.path;
import std.stdio;

import deimos.freeimage;

import config;
import image_sorter;


int main(string[] args) {

    FreeImage_Initialise();
    scope(exit) {
        FreeImage_DeInitialise();
    }

    AppConfig config = AppConfig();
    try {
        config.check_and_parse(args);
    } catch (Exception e) {
        return 1;
    }

    // TODO: How is logging done in D?
    stdout.writefln("Working in directory %s", config.source_dir);

    ImageFileSorter sorter = new ImageFileSorter(
        config.source_dir,
        config.target_dir);
    sorter.process_files(config.dry_run);

    // Done, return success
    return 0;

}
