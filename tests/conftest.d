module tests.conftest;

import std.conv;
import std.file;
import std.string;
import std.path;

import deimos.freeimage;
import std.experimental.logger;

import image;


// TODO: use a utility to get a random directory here and clean it
// up afterwards
auto testingPath = "testing";

auto testImagePath = "testing/test-image.jpg";


Image getTestImage() {
    auto testingFile = buildPath("testing", "test-image.jpg");
    auto sourceFile = buildPath("data", "test-image.jpg");

    if (! testingPath.exists()) {
        testingPath.mkdirRecurse();
    }

    sourceFile.copy(testingFile);

    // TODO: provide a test image automatically
    assert(exists(testingFile),
           "Make sure to have a test image available to run the tests.");

    return new Image(testingFile);
}


/**
 * This can be used to create a small test image which will
 * have a clone of the EXIF Metadata from `sourceFile`.
 */
private
void createTestImage(string sourceFile="work/test-image.jpg") {

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

    auto tmpImg = FreeImage_Load(FIF_JPEG, sourceFile.toStringz());
    FreeImage_CloneMetadata(testImage, tmpImg);
    FreeImage_Save(FIF_JPEG, testImage, testingFile.toStringz());

    // Dump metadata to compare
    auto img = new Image(sourceFile);
    img.dumpMetadata();

    img = new Image(testingFile);
    img.dumpMetadata();
}
