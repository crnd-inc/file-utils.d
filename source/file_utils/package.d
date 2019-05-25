module file_utils;

private import std.string : toStringz, fromStringz;
private import std.file: exists, copy, DirEntry, dirEntries, isDir, isFile, mkdirRecurse, SpanMode, readLink, tempDir;
private import std.path: absolutePath, buildNormalizedPath, buildPath;
private import std.exception : enforce;
private import std.conv : to;

// Posix-specific
private import core.sys.posix.stdlib : mkdtemp;


// Based on https://forum.dlang.org/thread/n7hc17$19jg$1@digitalmars.com
void copyRecurse(string src, string dst)
{
    src = absolutePath(buildNormalizedPath(src));
    dst = absolutePath(buildNormalizedPath(dst));

    if (isDir(src))
    {
        mkdirRecurse(dst);

        foreach (entry; dirEntries(src, SpanMode.breadth))
        {
            auto dst = buildPath(dst, entry.name[src.length + 1 .. $]);
                // + 1 for the directory separator
            if (entry.isFile) {
                copy(entry.name, dst);
            } else if (entry.isSymlink) {
                if (exists(readLink(entry.name))) {
                    copy(readLink(entry.name), dst);
                //} else {
                    // Log info about broken symlink
                }
            } else {
                mkdirRecurse(dst);
            }
        }
    }
    else copy(src, dst);
}


string createTempDirectory(string prefix="tmp") {
    return createTempDirectory(tempDir, prefix);
}

string createTempDirectory(string path, string prefix="tmp") {
    string tempdir_template= path.buildNormalizedPath(prefix ~ "-XXXXXX");
    char[] tempname_str = tempdir_template.dup ~ "\0";
    char* res = mkdtemp(tempname_str.ptr);
    enforce(res !is null, "Cannot create temporary directory");
    return to!string(res.fromStringz);
}
