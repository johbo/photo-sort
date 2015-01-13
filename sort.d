
import std.file;
import std.stdio;

int main(string[] args) {

  if (args.length != 2) {
    stderr.writefln("Usage: %s FILENAME", args[0]);
    return 1;
  }

  auto source_dir = args[1];

  // Images in current directory
  auto files = dirEntries(".", "*.jpg", SpanMode.shallow);
  foreach(filename; files) {
    writeln("Found file: ", filename);
  }

  // Done, return success
  return 0;
  
}
