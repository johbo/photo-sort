
import std.algorithm;
import std.container;
import std.conv;
import std.file;
import std.path;
import std.stdio;

import deimos.freeimage;
import docopt;
import std.experimental.logger;

import config;
import image_sorter;


auto helpText = "Usage: photo-sort [options] <work_dir>

Photo sort is an experiment primarily intended as an example
application to learn the D programming language.

Options:
    -h, --help   Show this usage information.
    --dry-run    Dry run to find out what would happen.

";

int main(string[] args) {

    // TODO: Support an option to set the logging level
    globalLogLevel = LogLevel.info;

    auto arguments = docopt.docopt(helpText, args[1..$], true, "Photo sorter");
    writeln(arguments);

    log("Initialising freeimage library");
    FreeImage_Initialise();
    scope(exit) {
        log("Freeing up freeimage library");
        FreeImage_DeInitialise();
    }

    auto source_dir = arguments["<work_dir>"].toString();
    auto target_dir = source_dir;
    
    logf("Working in directory %s", source_dir);
    ImageFileSorter sorter = new ImageFileSorter(source_dir, target_dir);
    sorter.process_files(arguments["--dry-run"].isTrue());

    return 0;
}
