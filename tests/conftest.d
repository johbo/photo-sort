module tests.conftest;

import std.file;

import image;


auto testImagePath = "work/test-image.jpg";

Image getTestImage() {
    // TODO: provide a test image automatically
    assert(exists(testImagePath),
           "Make sure to have a test image available to run the tests.");
    return new Image(testImagePath);
}

