module tests.image_sorter;

import std.stdio;

import unit_threaded;

import image;
import image_sorter;
import tests.conftest;


void testTimeBasedStorage_creates_target_path_based_on_image_time() {
    auto storeStrategy = TimeBasedStorage("target");
    auto img = getTestImage();

    string[] result = storeStrategy.targetPath(img);
    checkEqual(result, ["target", "2014", "12", "28", "test-image.jpg"]);
}
