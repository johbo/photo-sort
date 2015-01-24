
module config;

import std.algorithm;
import std.stdio;

import docopt;
import std.experimental.logger;


auto usageText = "Usage: photo-sort [options] <work_dir>

Photo sort is an experiment primarily intended as an example
application to learn the D programming language.

Options:
    -h, --help   Show this usage information.
    --verbose    Activate debug logging.
    --dry-run    Dry run to find out what would happen.

";


struct AppConfig {

    string source_dir;
    string target_dir;

    bool dry_run = false;

    void check_and_parse(string[] args) {

        auto arguments = docopt.docopt(
            usageText, args[1..$], true, "Photo sorter");

        if (arguments["--verbose"].isTrue()) {
            globalLogLevel = LogLevel.all;
        }

        source_dir = arguments["<work_dir>"].toString();
        target_dir = source_dir;

        dry_run = arguments["--dry-run"].isTrue();
    }
}


unittest {

    // TODO: Find out how to assign names to tests

    // TODO: How to test that it tries to exit if I do not provide
    // valid command line options?


    // test: adjusts log level based on parameters

    // TODO: avoiding to leave the globalLogLevel changed, better ways
    // to achieve that?

    auto oldLogLevel = globalLogLevel;
    scope(exit) { globalLogLevel = oldLogLevel; }

    auto config = new AppConfig();
    auto args = ["program-name", "fake-directory"];
    config.check_and_parse(args ~ ["--verbose"]);
    assert(globalLogLevel == LogLevel.all);


    // test: provides working directory as source and target
    config.check_and_parse(args);
    assert(config.source_dir == "fake-directory");
    assert(config.target_dir == "fake-directory");


    // test: allows to set the dry_run flag
    config.check_and_parse(args);
    assert(! config.dry_run);

    config.check_and_parse(args ~ ["--dry-run"]);
    assert(config.dry_run);
}
