module image;

import std.datetime;
import std.file;
import std.string;

import image_sorter;


class Image {

    string _path;

    this(string path) {
        _path = path;
    }

    override
    string toString() {
        return "Image(%s)".format(_path);
    }

    @property
    SysTime timeCreated() {
        // TODO: Move full implementation into this place
        DirEntry entry = DirEntry(_path);
        return get_time_old(entry);
    }

}


unittest {
    import std.conv;
    import std.stdio;

    // TODO: provide a test image automatically
    auto testImagePath = "work/test-image.jpg";
    assert(exists(testImagePath),
           "Make sure to have a test image available to run the tests.");
    auto img = new Image(testImagePath);


    // test: to string includes the path of the image
    assert(to!string(img) == "Image(%s)".format(testImagePath));


    // test: allows to read creation time
    // TODO: Assert the time value, but this needs a test image first ;-)
    writeln(img.timeCreated);
}
