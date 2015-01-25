module store;

import std.file;
import std.path;

import std.experimental.logger;

import image;


class ImageStore(StorageStrategy) {

    private {
        string targetPath;
        StorageStrategy storeStrategy;
        bool dry_run = false;

        // Holds the chosen file handling method
        void delegate(string source, string target) addFileIntoStore;
    }

    this(string targetPath, bool dry_run=false, bool moveFiles=false) {
        this.targetPath = targetPath;
        this.storeStrategy = StorageStrategy(targetPath);
        this.dry_run = dry_run;

        // decide on how to handle file additions
        if (dry_run) {
            this.addFileIntoStore = &skipFile;
        } else if (moveFiles) {
            this.addFileIntoStore = &moveFileIntoStore;
        } else {
            this.addFileIntoStore = &copyFileIntoStore;
        }
    }

    void add(Image image) {
        auto storePath = storeStrategy.targetPath(image);

        auto target_path = buildPath(storePath[0..$-1]);
        if (! dry_run) {
            ensure_path_exists(target_path);
        }

        auto target_filename = buildPath(storePath);
        if (! target_filename.exists()) {
            addFileIntoStore(image.filename, target_filename);
        } else {
            infof(
                "Skipping %s, this file already exists.",
                target_filename);
        }
    }

    // TODO: these operations not really have to be inside of the class
    private
    void moveFileIntoStore(string sourceFilename, string targetFilename) {
        infof("moving file %s to %s", sourceFilename, targetFilename);
        rename(sourceFilename, targetFilename);
    }

    private
    void copyFileIntoStore(string sourceFilename, string targetFilename) {
        infof("copying file %s to %s", sourceFilename, targetFilename);
        copy(sourceFilename, targetFilename);
    }

    private
    void skipFile(string sourceFilename, string targetFilename) {
        infof("dry_run, skipping copy or move of file %s to %s",
              sourceFilename, targetFilename);
    }

}


private
void ensure_path_exists(string path) {
    if (! path.exists()) {
        infof("Creating path %s", path);
        mkdirRecurse(path);
    }
}
