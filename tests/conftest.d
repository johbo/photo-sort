module tests.conftest;

import std.file;
import std.string;
import std.path;

import deimos.freeimage;

import image;


auto testImagePath = "work/test-image.jpg";

Image getTestImage() {

    // TODO: use a utility to get a random directory here and clean it
    // up afterwards
    auto testingPath = "testing";
    auto testingFile = buildPath("testing", "test-image.jpg");

    if (! testingPath.exists()) {
        testingPath.mkdirRecurse();
    }

    auto testImage = FreeImage_Allocate(1, 1, 24);
    scope(exit) {
        FreeImage_Unload(testImage);
    }
    FreeImage_Save(FIF_JPEG, testImage, testingFile.toStringz());

    // TODO: Add relevant EXIF information

    // TODO: provide a test image automatically
    assert(exists(testImagePath),
           "Make sure to have a test image available to run the tests.");
    return new Image(testImagePath);
}

