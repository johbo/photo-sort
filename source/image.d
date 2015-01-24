module image;

import std.algorithm;
import std.array;
import std.conv;
import std.datetime;
import std.file;
import std.path;
import std.string;

import deimos.freeimage;
import std.experimental.logger;

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


private
SysTime get_time_old(DirEntry item) {
    auto image_type = item.name.toLower().extension();
    FREE_IMAGE_FORMAT[string] image_formats = [
        ".jpg": FIF_JPEG,
        ".jpeg": FIF_JPEG,
        ".cr2": FIF_RAW,
        ];

    try {
        return get_image_time(image_formats[image_type], item);
    } catch (RangeError err) {
        throw new Exception("Not supported image format");
    }
}


private
SysTime get_image_time(FREE_IMAGE_FORMAT image_format, DirEntry item) {

    auto image = FreeImage_Load(image_format,
                                item.name.toStringz(),
                                FIF_LOAD_NOPIXELS);
    scope(exit) {
        FreeImage_Unload(image);
    }

    FITAG* tag;
    if (FreeImage_GetMetadata(FIMD_EXIF_MAIN,
                              image,
                              "DateTime".toStringz(),
                              &tag)) {
        auto tag_str = to!string(FreeImage_TagToString(image_format, tag));
        return parse_ascii_date(tag_str);
    } else {
        logf("Did not find the date in %s", item);
        auto iter = FreeImage_FindFirstMetadata(FIMD_EXIF_MAIN,
                                                image,
                                                &tag);
        if (iter) {
            logf("TAG %s", FreeImage_GetTagKey(tag).fromStringz());
            while (FreeImage_FindNextMetadata(iter, &tag)) {
                logf("TAG %s", FreeImage_GetTagKey(tag).fromStringz());
            }
        }
    }

    logf("Did not find an EXIF date, using file date.");
    return item.timeLastModified();
}


private
SysTime parse_ascii_date(string ascii_date) {
    ascii_date = ascii_date.replace(" ", ":");

    auto parts = map!(to!int)(ascii_date.split(":"));

    if (parts.length == 6) {
        return SysTime(DateTime(parts[0], parts[1], parts[2],
                                parts[3], parts[4], parts[5]));
    } else {
        warningf(
            "Parsed date into %s parts. Original value %s.",
            parts.length, ascii_date);
        throw new Exception("Cannot parse date");
    }
}
