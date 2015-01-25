
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


unittest {

    // TODO: Find out how to assign names to tests

    // TODO: How to test that it tries to exit if I do not provide
    // valid command line options?


    // test: adjusts log level based on parameters
    auto config = new AppConfig();
    auto args = ["program-name", "fake-directory"];
    config.check_and_parse(args ~ ["--verbose"]);
    assert(config.verbose);


    // test: provides working directory as source and target
    config.check_and_parse(args);
    assert(config.source_dir == "fake-directory");
    assert(config.target_dir == "fake-directory");


    // test: allows to set the dry_run flag
    config.check_and_parse(args);
    assert(!config.dry_run);

    config.check_and_parse(args ~ ["--dry-run"]);
    assert(config.dry_run);


    // test: allows to select to move files
    config.check_and_parse(args);
    assert(!config.moveFiles);

    foreach(moveParam; ["-m", "--move"]) {
        config.check_and_parse(args ~ [moveParam]);
        assert(config.moveFiles);
    }
}
