module tests.config;

import unit_threaded;

import config;



// TODO: Find out how to assign names to tests

// TODO: How to test that it tries to exit if I do not provide
// valid command line options?


void testAdjustsLogLevelBasedOnParameters() {
    auto config = getParsedConfig(["--verbose"]);
    checkTrue(config.verbose);
}


void testProvidesWorkingDirectoryAsSourceAndTarget() {
    auto config = getParsedConfig();
    checkEqual(config.source_dir, "fake-directory");
    checkEqual(config.target_dir, "fake-directory");
}


void testAllowsToSetDryRunFlag() {
    auto config = getParsedConfig();
    checkFalse(config.dry_run);

    config = getParsedConfig(["--dry-run"]);
    checkTrue(config.dry_run);
}


void testAllowsToSelectToMoveFiles() {
    auto config = getParsedConfig();
    checkFalse(config.moveFiles);

    foreach(moveParam; ["-m", "--move"]) {
        config = getParsedConfig([moveParam]);
        checkTrue(config.moveFiles);
    }
}


// Fixtures

auto getParsedConfig(string[] extra_args=[]) {
    auto config = new AppConfig();
    auto args = ["program-name", "fake-directory"];
    config.check_and_parse(args ~ extra_args);
    return config;
}
