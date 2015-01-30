module tests.conftest;

import std.conv;
import std.file;
import std.string;
import std.path;

import deimos.freeimage;
import std.experimental.logger;

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


    // TODO: Add relevant EXIF information
    FITAG* tag = FreeImage_CreateTag();
    assert(tag != null, "Could not create tag");
    scope(exit) {
        FreeImage_DeleteTag(tag);
    }

    auto value = "2015:01:22 11:05:11";
    uint length = to!uint(value.length + 1);
    FreeImage_SetTagKey(tag, "DateTime".toStringz());
    FreeImage_SetTagLength(tag, length);
    FreeImage_SetTagCount(tag, length);
    FreeImage_SetTagType(tag, FIDT_ASCII);
    FreeImage_SetTagValue(tag, value.toStringz());

    auto tag_success = FreeImage_SetMetadata(
        FIMD_EXIF_MAIN,
        testImage,
        FreeImage_GetTagKey(tag),
        tag);
    if (!tag_success) {
        throw new Exception("Writing the creation date failed");
    }


    FreeImage_Save(FIF_JPEG, testImage, testingFile.toStringz());

    // TODO: provide a test image automatically
    assert(exists(testImagePath),
           "Make sure to have a test image available to run the tests.");
    return new Image(testImagePath);
}

