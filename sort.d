
import std.algorithm;
import std.conv;
import std.datetime;
import std.file;
import std.path;
import std.stdio;
import std.string;

import deimos.libexif.exif_data;
import deimos.libexif.exif_loader;


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


  /* 
    Tag: 0x9003 ('DateTimeOriginal')
      Format: 2 ('ASCII')
      Components: 20
      Size: 20
      Value: 2014:12:29 12:25:23
  */

  
  // TODO: I think it should be possible to wrap this in a D struct or
  // something similar.
  ExifLoader* loader = exif_loader_new();
  scope(exit) {
    exif_loader_unref(loader);
  }
  exif_loader_write_file(loader, toStringz(item.name));

  ExifData* data = exif_loader_get_data(loader);
  // TODO: should probably free `data`, and could use
  // exif_data_new_from_file to avoid creating the loader on my own.

  // Note: Can be used to dump all EXIF data for inspection
  // exif_data_dump(data);

  
  ExifEntry* entry = exif_content_get_entry(data.ifd[EXIF_IFD_0],
					    EXIF_TAG_DATE_TIME);

  if (entry) {
    // TODO: logging
    writeln("Found EXIF date");

    // TODO: only use the entry if it is of type ASCII
    writeln(to!string(exif_format_get_name(entry.format)));

    string t = to!string(cast(ExifAscii) entry.data);
    writeln(t);

  }
  
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
