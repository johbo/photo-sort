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
        void function(string source, string target) addFileIntoStore;
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
        auto target_filename = buildPath(storePath);
        if (! target_filename.exists()) {
            addFileIntoStore(image.filename, target_filename);
        } else {
            infof("Skipping %s, this file already exists.",
                  target_filename);
        }
    }

}


private
void moveFileIntoStore(string sourceFilename, string targetFilename) {
    infof("moving file %s to %s", sourceFilename, targetFilename);
    ensurePathExists(dirName(targetFilename));
    rename(sourceFilename, targetFilename);
}


private
void copyFileIntoStore(string sourceFilename, string targetFilename) {
    infof("copying file %s to %s", sourceFilename, targetFilename);
    ensurePathExists(dirName(targetFilename));
    copy(sourceFilename, targetFilename);
}


private
void skipFile(string sourceFilename, string targetFilename) {
    infof("dry_run, skipping copy or move of file %s to %s",
          sourceFilename, targetFilename);
}


private
void ensurePathExists(string path) {
    if (! path.exists()) {
        infof("Creating path %s", path);
        mkdirRecurse(path);
    }
}


unittest {
    // setup
    auto testPath = "testing";
    if (testPath.exists()) {
        throw new Exception("Directory testing already exists!");
    }
    auto sourcePath = buildPath(testPath, "source");
    auto targetPath = buildPath(testPath, "target");
    auto sourceFile = buildPath(sourcePath, "file");
    auto targetFile = buildPath(targetPath, "file");

    mkdir(testPath);
    scope(exit) {
        rmdirRecurse(testPath);
    }
    mkdir(sourcePath);
    mkdir(targetPath);


    // test: skipFile does nothing
    write(sourceFile, "content");
    skipFile(sourceFile, targetFile);
    assert(sourceFile.exists());
    assert(!targetFile.exists());


    // test: copyFile creates a copy of the file
    copyFileIntoStore(sourceFile, targetFile);
    assert(sourceFile.exists());
    assert(targetFile.exists());
    // TODO: automatic cleanup
    targetFile.remove();


    // test: moveFile moves the file into the store
    moveFileIntoStore(sourceFile, targetFile);
    assert(!sourceFile.exists());
    assert(targetFile.exists());
}
