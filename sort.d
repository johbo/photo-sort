
import std.algorithm;
import std.container;
import std.conv;
import std.file;
import std.path;
import std.stdio;

import image_sorter;


int main(string[] args) {

  AppConfig config = AppConfig();
  config.check_and_parse(args);

  // TODO: How is logging done in D?
  stdout.writefln("Working in directory %s", config.source_dir);

  ImageFileSorter sorter = new ImageFileSorter(config.source_dir,
					       config.target_dir);
  sorter.process_files(config.dry_run);
  
  // Done, return success
  return 0;
  
}


struct AppConfig {

  string source_dir;
  string target_dir;

  bool dry_run = false;

  void check_and_parse(string[] args) {

    // TODO: Want to say 'args.pop("--dry-run")' or similar
    auto idx = args.countUntil("--dry-run");
    if (idx != -1) {
      dry_run = true;
      args = args.remove(idx);
    }
    
    // TODO: Probably there is a utility in D to parse command line
    // arguments
    if (args.length != 2) {
      stderr.writefln("Usage: %s DIRNAME [--dry-run]", args[0]);
      throw new Exception("Directory name missing");
    }

    source_dir = args[1];
    target_dir = source_dir;
  }

}
