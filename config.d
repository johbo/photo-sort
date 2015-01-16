
module config;

import std.algorithm;
import std.stdio;


struct AppConfig {

    string source_dir;
    string target_dir;

    bool dry_run = false;

    void check_and_parse(string[] args) {

        // TODO: Want to say 'args.pop("--dry-run")' or similar
        auto idx = args.countUntil("--dry-run");
        if (idx != -1) {
            dry_run = true;
            args = args.remove(idx);
        }

        // TODO: Probably there is a utility in D to parse command line
        // arguments
        if (args.length != 2) {
            stderr.writefln("Usage: %s DIRNAME [--dry-run]", args[0]);
            throw new Exception("Directory name missing");
        }

        source_dir = args[1];
        target_dir = source_dir;
    }


    unittest {
        import std.exception;
        
        auto config = AppConfig();

        // TODO: test names? test runner?
        assertThrown(config.check_and_parse(["a"]));
        assertThrown(config.check_and_parse(["a", "--dry-run"]));
        assertThrown(config.check_and_parse(["a", "b", "c"]));

        assertNotThrown(config.check_and_parse(["a", "dir"]));
        assertNotThrown(config.check_and_parse(["a", "dir", "--dry-run"]));
    }

}
