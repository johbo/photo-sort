
module image_sorter;

import std.algorithm;
import std.array;
import std.conv;
import std.datetime;
import std.file;
import std.path;
import std.stdio;
import std.string;

import deimos.freeimage;
import std.experimental.logger;

import image;


class ImageFileSorter {

    private string _source_dir;
    private string _target_dir;

    this(string source_dir, string target_dir) {
	_source_dir = source_dir;
        _target_dir = target_dir;
    }

    void process_files(bool dry_run=false) {

        logf("Processing files in %s", _source_dir);

        // Images in current directory
        auto files = dirEntries(_source_dir, SpanMode.shallow);
        auto filtered_files = filter!should_process(files);

        foreach(filename; filtered_files) {
            logf("Working on file %s", filename);

            auto created = get_time(filename);
            auto path = get_target_path(created);

            auto target_path = buildPath(_target_dir, path);
            if (! dry_run) {
                ensure_path_exists(target_path);
            }

            auto target_filename = buildPath(target_path,
                                             get_target_filename(filename));
            if (! target_filename.exists()) {
                infof("moving file %s to %s", filename, target_filename);
                if (! dry_run) {
                    rename(filename, target_filename);
                }
            } else {
                infof(
                    "Skipping %s, this file already exists.",
                    target_filename);
            }
        }

    }

}


bool should_process(DirEntry item) {
    auto supported = [".jpg", ".jpeg", ".cr2"];
    return supported.canFind(item.name.toLower().extension());
}


SysTime get_time(DirEntry item) {
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


private SysTime get_image_time(FREE_IMAGE_FORMAT image_format, DirEntry item) {

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


private SysTime parse_ascii_date(string ascii_date) {
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


string get_target_path(SysTime time) {
    return buildPath(
        time.year.to!string,
        format("%02d", time.month),
        format("%02d", time.day));
}


void ensure_path_exists(string path) {
    if (! path.exists()) {
        infof("Creating path %s", path);
        mkdirRecurse(path);
    }
}


string get_target_filename(string filename) {
    return baseName(filename.toLower());
}


auto imageSource(string sourcePath) {
    auto files = dirEntries(sourcePath, SpanMode.shallow);
    auto filtered_files = filter!should_process(files);

    // TODO: Find out how to do this in a better way
    // It did not work out when trying to create the struct instance
    // directly.
    auto wrapInImageSourceResult(Range)(Range r) {
        return ImageSourceResult!Range(r);
    }

    return wrapInImageSourceResult(filtered_files);
}


struct ImageSourceResult(Range) {

    Range _input;

    this(Range imageFilenames) {
        _input = imageFilenames;
    }

    @property
    bool empty() {
        return _input.empty;
    }

    @property
    Image front() {
        auto path = _input.front;
        return new Image(path);
    }

    void popFront() {
        _input.popFront();
    }

}


unittest {
    // test: Can create an image source based on a directory
    // TODO: Have a test directory provided somehow
    auto imagesToProcess = imageSource("work");
    bool foundImage = false;
    foreach (Image image; imagesToProcess) {
        foundImage = true;
        writeln(image);
    }
    assert(foundImage);
}
