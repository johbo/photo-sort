module image;

import std.string;


class Image {

    string _path;

    this(string path) {
        _path = path;
    }

    override
    string toString() {
        return "Image(%s)".format(_path);
    }

}
