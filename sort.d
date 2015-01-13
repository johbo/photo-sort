
import std.algorithm;
import std.file;
import std.stdio;
import std.string;


int main(string[] args) {

  if (args.length != 2) {
    stderr.writefln("Usage: %s FILENAME", args[0]);
    return 1;
  }

  auto source_dir = args[1];

  // TODO: How is logging done in D?
  stdout.writefln("Working in directory %s", source_dir);

  // Images in current directory
  auto files = dirEntries(source_dir, SpanMode.shallow);
  auto filtered_files = filter!should_process(files);

  foreach(filename; filtered_files) {
    writefln("Working on file %s", filename);
  }

  // Done, return success
  return 0;
  
}


bool should_process(DirEntry item) {
  return item.name.toLower().endsWith(".jpg");
}
