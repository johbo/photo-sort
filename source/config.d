
module config;

import std.algorithm;
import std.stdio;

import docopt;


auto usageText = "Usage: photo-sort [options] <work_dir>

Photo sort is an experiment primarily intended as an example
application to learn the D programming language.

Options:
    -h, --help   Show this usage information.
    --dry-run    Dry run to find out what would happen.

";


struct AppConfig {

    string source_dir;
    string target_dir;

    bool dry_run = false;

    void check_and_parse(string[] args) {

        auto arguments = docopt.docopt(
            usageText, args[1..$], true, "Photo sorter");

        source_dir = arguments["<work_dir>"].toString();
        target_dir = source_dir;

        dry_run = arguments["--dry-run"].isTrue();
    }

}
