import std.stdio;

import unit_threaded.runner;


int main(string[] args) {
    return runTests!(
        "application",
        "config",
        "image",
        "image_sorter",
        "tests.example",
        "tests.image",
        )(args);
}
