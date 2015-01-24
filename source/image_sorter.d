
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
        auto images = imageSource(_source_dir);
        auto store = ImageStore!TimeBasedStorage(_target_dir, dry_run);
        foreach(image; images) {
            logf("Working on %s", image);
            store.add(image);
        }
    }

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
        writefln("%s, %s", image, image.timeCreated);
    }
    assert(foundImage, "Needs a test image in \"work\"");
}


bool should_process(DirEntry item) {
    auto supported = [".jpg", ".jpeg", ".cr2"];
    return supported.canFind(item.name.toLower().extension());
}


struct TimeBasedStorage {

    private string _targetDirectory;

    this (string targetDirectory) {
        _targetDirectory = targetDirectory;
    }

    string[] targetPath(Image img) {
        auto created = img.timeCreated;

        return [
            _targetDirectory,
            created.year.to!string,
            format("%02d", created.month),
            format("%02d", created.day),
            img.baseFilename];
    }

}


unittest {
    auto storeStrategy = TimeBasedStorage("target");
    auto img = new Image("work/test-image.jpg");


    // test: Creates target path based on image time
    string[] result = storeStrategy.targetPath(img);
    writeln(result);
    assert(result[0] == "target");
    // TODO: check that the middle contains correct time based fragments
    assert(result.length == 5);
    assert(result[$-1] == "test-image.jpg");
}


struct ImageStore(StorageStrategy) {

    string targetPath;

    private StorageStrategy storeStrategy;
    private bool dry_run = false;

    this(string targetPath, bool dry_run=false) {
        this.targetPath = targetPath;
        this.storeStrategy = StorageStrategy(targetPath);
        this.dry_run = dry_run;
    }

    void add(Image image) {
        auto storePath = storeStrategy.targetPath(image);

        auto target_path = buildPath(storePath[0..$-1]);
        if (! dry_run) {
            ensure_path_exists(target_path);
        }

        auto target_filename = buildPath(storePath);
        if (! target_filename.exists()) {
            infof("moving file %s to %s",
                  image.baseFilename, target_filename);
            if (! dry_run) {
                rename(image.filename, target_filename);
            }
        } else {
            infof(
                "Skipping %s, this file already exists.",
                target_filename);
        }
    }

}


void ensure_path_exists(string path) {
    if (! path.exists()) {
        infof("Creating path %s", path);
        mkdirRecurse(path);
    }
}
