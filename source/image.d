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
version(unittest) import unit_threaded;

import image_sorter;


class Image {

    private string _path;

    this(string path) {
        _path = path;
    }

    override
    string toString() {
        return "Image(\"%s\")".format(_path);
    }


    @property
    string filename() {
        return _path;
    }

    @property
    string baseFilename() {
        return baseName(_path);
    }


    @property
    SysTime timeCreated() {
        // TODO: Move full implementation into this place
        DirEntry entry = DirEntry(_path);
        return get_time_old(entry);
    }


    void dumpMetadata() {
        logf("Dumping metadata of %s", _path);
        auto imageFormat = getImageFormat(_path);
        FITAG* tag;
        auto image = FreeImage_Load(
            imageFormat,
            _path.toStringz(),
            FIF_LOAD_NOPIXELS);
        scope(exit) {
            FreeImage_Unload(image);
        }
        FIMETADATA* md = FreeImage_FindFirstMetadata(
            FIMD_EXIF_MAIN, image, &tag);
        do {
            logf("%s: %s",
                 FreeImage_GetTagKey(tag).to!string(),
                 FreeImage_TagToString(FIMD_EXIF_MAIN, tag).to!string());
        } while (FreeImage_FindNextMetadata(md, &tag));
    }

}


private
SysTime get_time_old(DirEntry item) {
    return get_image_time(getImageFormat(item.name), item);
}


private
FREE_IMAGE_FORMAT getImageFormat(string path) {
    auto image_type = path.toLower().extension();
    FREE_IMAGE_FORMAT[string] image_formats = [
        ".jpg": FIF_JPEG,
        ".jpeg": FIF_JPEG,
        ".cr2": FIF_RAW,
        ];
    try {
        return image_formats[image_type];
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
        return parseAsciiDate(tag_str);
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
SysTime parseAsciiDate(string ascii_date) {
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


version (unittest) {

    void testParseAsciiDate() {
        auto value = parseAsciiDate("2014:12:10 11:05:01");
        checkEqual(
            [2014, 12, 10, 11, 5, 1],
            [value.year, value.month, value.day,
             value.hour, value.minute, value.second]);
    }


    void testParseAsciiDate_WrongDate() {
        checkThrown!Exception(parseAsciiDate("test"));
        checkThrown!Exception(parseAsciiDate("2014:12:10"));
        checkThrown!Exception(parseAsciiDate("2014:12:10 11:05"));
    }


    // TODO: This looks rather hacky, but it would allow to test this
    // private function from a different module.

    // auto _test_parseAsciiDate = &parseAsciiDate;

}
