module tests.example;

import std.stdio;

import unit_threaded;


@ShouldFail("Failing example")
void testSomethingFails() {
    writeln("Something fails here");
    checkTrue(false);
}


void testPassing() {
    writeln("This should work out");
    checkTrue(true);
}
