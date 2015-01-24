module store;

import std.file;
import std.path;

import std.experimental.logger;

import image;



// TODO: Make "move" vs "copy" possible
struct ImageStore(StorageStrategy) {

    private string targetPath;
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


private
void ensure_path_exists(string path) {
    if (! path.exists()) {
        infof("Creating path %s", path);
        mkdirRecurse(path);
    }
}

