
module config;

import std.algorithm;
import std.stdio;

import docopt;
import std.experimental.logger;


auto usageText = "Usage: photo-sort [options] <work_dir>

Photo sort is an experiment primarily intended as an example
application to learn the D programming language.

Options:
    -m, --move   Move files into the right place instead of creating
                 a copy.
    -h, --help   Show this usage information.
    --verbose    Activate debug logging.
    --dry-run    Dry run to find out what would happen.

";


class AppConfig {

    string source_dir;
    string target_dir;

    bool dry_run = false;
    bool moveFiles = false;
    bool verbose = false;

    void check_and_parse(string[] args) {

        auto arguments = docopt.docopt(
            usageText, args[1..$], true, "Photo sorter");

        verbose = arguments["--verbose"].isTrue();
        source_dir = arguments["<work_dir>"].toString();
        target_dir = source_dir;
        dry_run = arguments["--dry-run"].isTrue();
        moveFiles = arguments["--move"].isTrue();
    }
}
