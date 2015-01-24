
import std.algorithm;
import std.container;
import std.conv;
import std.file;
import std.path;
import std.stdio;

import std.experimental.logger;

import application;
import config;


int main(string[] args) {

    globalLogLevel = LogLevel.info;

    auto config = AppConfig();
    config.check_and_parse(args);

    auto app = new Application(config);
    app.initialise();
    scope(exit) {
        app.deInitialise();
    }
    app.run();

    return 0;
}
