
import std.algorithm;
import std.conv;
import std.datetime;
import std.file;
import std.path;
import std.stdio;
import std.string;


int main(string[] args) {

  // TODO: Probably there is a utility in D to parse command line
  // arguments
  if (args.length != 2) {
    stderr.writefln("Usage: %s FILENAME", args[0]);
    return 1;
  }

  auto source_dir = args[1];
  auto target_dir = source_dir;

  // TODO: How is logging done in D?
  stdout.writefln("Working in directory %s", source_dir);

  // Images in current directory
  auto files = dirEntries(source_dir, SpanMode.shallow);
  auto filtered_files = filter!should_process(files);

  foreach(filename; filtered_files) {
    writefln("Working on file %s", filename);

    auto created = get_time(filename);
    writefln("    created at: %s", created);

    auto path = get_target_path(created);
    writefln("    target path: %s", path);

    auto target_path = buildPath(target_dir, path);
    ensure_path_exists(target_path);

    auto target_filename = buildPath(target_path,
				     get_target_filename(filename));
    if (! target_filename.exists()) {
      writefln("    moving file to %s", target_filename);
      rename(filename, target_filename);
    } else {
      writefln("    SKIPPING, file %s already exists!", target_filename);
    }
  }

  // Done, return success
  return 0;
  
}


bool should_process(DirEntry item) {
  return item.name.toLower().endsWith(".jpg");
}


SysTime get_time(DirEntry item) {
  return item.timeLastModified();
}


string get_target_path(SysTime time) {
  return buildPath(time.year.to!string,
		   format("%02d", time.month),
		   format("%02d", time.day));
}


void ensure_path_exists(string path) {
  if (! path.exists()) {
    // TODO: logging
    writefln("Creating path %s", path);
    mkdirRecurse(path);
  }
}


string get_target_filename(string filename) {
  return baseName(filename.toLower());
}
