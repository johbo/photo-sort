module application;

import deimos.freeimage;
import std.experimental.logger;

import config;
import image_sorter;


class Application {

    AppConfig config;
    ImageFileSorter sorter;

    this(AppConfig config) {
        this.config = config;
        this.sorter = new ImageFileSorter(
            config.source_dir, config.target_dir);
    }

    void initialise() {
        if (config.verbose) {
            globalLogLevel = LogLevel.all;
        } else {
            globalLogLevel = LogLevel.info;
        }
        log("Initialising freeimage library");
        FreeImage_Initialise();
    }

    void deInitialise() {
        log("Freeing up freeimage library");
        FreeImage_DeInitialise();
    }

    void run() {
        infof("Processing images in directory %s", config.source_dir);
        sorter.process_files(config.dry_run);
    }

}


unittest {

    // TODO: avoiding to leave the globalLogLevel changed, better ways
    // to achieve that?
    auto oldLogLevel = globalLogLevel;
    scope(exit) { globalLogLevel = oldLogLevel; }

    auto config = new AppConfig();
    config.check_and_parse(["program-name", "work", "--dry-run"]);
    auto app = new Application(config);


    // test: initialises the freeimage library
    app.initialise();
    assert(FreeImage_Initialise.hasBeenCalled);
    app.deInitialise();
    assert(FreeImage_DeInitialise.hasBeenCalled);


    // test: sets the log level depending on configuration
    config.verbose = true;
    globalLogLevel = LogLevel.info;
    app.initialise();
    assert(globalLogLevel == LogLevel.all);

    config.verbose = false;
    app.initialise();
    assert(globalLogLevel == LogLevel.info);


    // test: provides run method
    // TODO: have an image in a directory ready
    app = new Application(config);
    // TODO: How to avoid that the sorter actually does something?
    // TODO: Check that it does the initialisation and deinitialisation
    app.run();
}


version (unittest) {

    StubFunction FreeImage_Initialise;
    StubFunction FreeImage_DeInitialise;

    static this() {
        FreeImage_Initialise = new StubFunction();
        FreeImage_DeInitialise = new StubFunction();
    }

    class StubFunction {

        auto hasBeenCalled = false;

        void opCall() {
            hasBeenCalled = true;
        }

    }
}
