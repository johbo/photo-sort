module tests.image;

import std.conv;
import std.file;
import std.stdio;
import std.string;

import unit_threaded;

import image;
import tests.conftest;


void testImageToString() {
    checkEqual(
        to!string(getTestImage()),
        "Image(\"%s\")".format(testImagePath));

}


void testImageTimeCreated() {
    // TODO: Could that be filled in automatically? Like dependency
    // injection?
    auto timeCreated = getTestImage().timeCreated;
    checkEqual(
        [timeCreated.year, timeCreated.month, timeCreated.day,
         timeCreated.hour, timeCreated.minute, timeCreated.second],
        [2014, 12, 28, 12, 8, 23]);
}


void testImageFilename() {
    auto img = new Image("example/Path/FileNAME.JpG");
    checkEqual(img.filename, "example/Path/FileNAME.JpG");
    checkEqual(img.baseFilename, "FileNAME.JpG");
}
