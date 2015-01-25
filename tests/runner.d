import std.stdio;

import unit_threaded.runner;

import application;
import config;
import image;
import image_sorter;
import tests.example;


int main(string[] args) {
    return runTests!(
        application,
        config,
        image,
        image_sorter,
        tests.example)(args);
}
