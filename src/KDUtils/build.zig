const std = @import("std");

const here = "src/KDUtils/";

pub fn sources(ally: std.mem.Allocator, target: std.zig.CrossTarget) []const []const u8 {
    _ = ally;
    _ = target;
    return &.{
        here ++ "bytearray.cpp",
        here ++ "dir.cpp",
        here ++ "elapsedtimer.cpp",
        here ++ "file.cpp",
        here ++ "file_mapper.cpp",
        here ++ "url.cpp",
    };
}

pub fn headers(ally: std.mem.Allocator, target: std.zig.CrossTarget) []const []const u8 {
    _ = ally;
    _ = target;
    return &.{
        here ++ "bytearray.h",
        here ++ "dir.h",
        here ++ "elapsedtimer.h",
        here ++ "file.h",
        here ++ "file_mapper.h",
        here ++ "flags.h",
        here ++ "logger.h",
        here ++ "url.h",
        here ++ "kdutils_global.h",
    };
}
