
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


class ImageFileSorter {

  private string _source_dir;
  private string _target_dir;

  this(string source_dir, string target_dir) {
    _source_dir = source_dir;
    _target_dir = target_dir;
  }

  void process_files(bool dry_run=false) {

    writefln("Source dir: %s", _source_dir);
    
    // Images in current directory
    auto files = dirEntries(_source_dir, SpanMode.shallow);
    auto filtered_files = filter!should_process(files);

    foreach(filename; filtered_files) {
      writefln("Working on file %s", filename);

      auto created = get_time(filename);
      writefln("    created at: %s", created);

      auto path = get_target_path(created);
      writefln("    target path: %s", path);

      auto target_path = buildPath(_target_dir, path);
      ensure_path_exists(target_path);

      auto target_filename = buildPath(target_path,
				       get_target_filename(filename));
      if (! target_filename.exists()) {
	writefln("    moving file to %s", target_filename);
	if (! dry_run) {
	  rename(filename, target_filename);
	}
      } else {
	writefln("    SKIPPING, file %s already exists!", target_filename);
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
  // TODO: Use dict
  
  if (image_type == ".jpg" || image_type == ".jpeg") {
    return get_image_time(FIF_JPEG, item);
  } else if (image_type == ".cr2") {
    return get_image_time(FIF_RAW, item);
  } else {
    throw new Exception("Not supported");
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
    // TODO: Dump tags should be kind of verbose mode only
    auto iter = FreeImage_FindFirstMetadata(FIMD_EXIF_MAIN,
					    image,
					    &tag);
    if (iter) {
      writefln("TAG %s", FreeImage_GetTagKey(tag).fromStringz());
      while (FreeImage_FindNextMetadata(iter, &tag)) {
	writefln("TAG %s", FreeImage_GetTagKey(tag).fromStringz());
      }
    }
  }

  // logging
  writeln("INFO: Did not find an EXIF date, using file date.");
  return item.timeLastModified();
}


private SysTime parse_ascii_date(string ascii_date) {
  ascii_date = ascii_date.replace(" ", ":");

  auto parts = map!(to!int)(ascii_date.split(":"));

  if (parts.length == 6) {
    return SysTime(DateTime(parts[0], parts[1], parts[2],
			    parts[3], parts[4], parts[5]));
  } else {
    // TODO: logging
    writeln("ERROR: Parsed date into %s parts. Original value %s.",
	    parts.length, ascii_date);
    throw new Exception("Cannot parse date");
  }
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
