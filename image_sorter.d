
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
import deimos.libexif.exif_data;
import deimos.libexif.exif_loader;


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
  if (image_type == ".jpg" || image_type == ".jpeg") {
    return get_jpeg_time(item);
  } else if (image_type == ".cr2") {
    return get_cr2_time(item);
  } else {
    throw new Exception("Not supported");
  }
}


private SysTime get_jpeg_time(DirEntry item) {

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

    auto ascii_date = to!string(cast(ExifAscii) entry.data);
    return parse_ascii_date(ascii_date);

  }

  // logging
  writeln("INFO: Did not find an EXIF date, using file date.");
  return item.timeLastModified();
}


private SysTime get_cr2_time(DirEntry item) {

  auto image = FreeImage_Load(FIF_RAW,
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
    auto tag_str = to!string(FreeImage_TagToString(FIF_RAW, tag));
    return parse_ascii_date(tag_str);
  } else {
    // TODO: Dump tags should be kind of verbose mode only
    auto iter = FreeImage_FindFirstMetadata(FIMD_EXIF_MAIN,
					    image,
					    &tag);
    writefln("TAG: %s", FreeImage_GetTagKey(tag).fromStringz());
    if (iter) {
      while (FreeImage_FindNextMetadata(iter, &tag)) {
	writefln("TAG: %s", FreeImage_GetTagKey(tag).fromStringz());
      }
    }
  }

  
  // logging
  writeln("INFO: Did not find date in metadata, using file date.");
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
