module application;

import deimos.freeimage;
import std.experimental.logger;


class Application {

    void initialise() {
        log("Initialising freeimage library");
        FreeImage_Initialise();
    }

    void deInitialise() {
        log("Freeing up freeimage library");
        FreeImage_DeInitialise();
    }

}


unittest {

    // test: initializes the freeimage library
    auto app = new Application();
    app.initialise();
    assert(FreeImage_Initialise.hasBeenCalled);
    app.deInitialise();
    assert(FreeImage_DeInitialise.hasBeenCalled);

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
