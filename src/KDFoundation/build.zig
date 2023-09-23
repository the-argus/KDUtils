const std = @import("std");

const here = "src/KDFoundation/";

pub fn sources(ally: std.mem.Allocator, target: std.zig.CrossTarget) []const []const u8 {
    var srcs = std.ArrayList([]const u8).init(ally);
    srcs.appendSlice(&.{
        here ++ "core_application.cpp",
        here ++ "event.cpp",
        here ++ "file_descriptor_notifier.cpp",
        here ++ "object.cpp",
        here ++ "postman.cpp",
        here ++ "timer.cpp",
    }) catch @panic("OOM");

    switch (target.getOsTag()) {
        .linux => {
            srcs.appendSlice(&.{
                here ++ "platform/linux/linux_platform_event_loop.cpp",
                here ++ "platform/linux/linux_platform_integration.cpp",
                here ++ "platform/linux/linux_platform_timer.cpp",
            }) catch @panic("OOM");
        },
        .windows => {
            srcs.appendSlice(&.{
                here ++ "platform/win32/win32_platform_event_loop.cpp",
                here ++ "platform/win32/win32_platform_integration.cpp",
                here ++ "platform/win32/win32_platform_timer.cpp",
            }) catch @panic("OOM");
        },
        .macos => {
            @panic("macos not implemented, TODO");
        },
        else => {
            @panic("unsupported OS");
        },
    }

    return srcs.toOwnedSlice() catch @panic("OOM");
}

pub fn headers(ally: std.mem.Allocator, target: std.zig.CrossTarget) []const []const u8 {
    var h = std.ArrayList([]const u8).init(ally);
    h.appendSlice(&.{
        here ++ "constexpr_sort.h",
        here ++ "core_application.h",
        here ++ "destruction_helpers.h",
        here ++ "event_queue.h",
        here ++ "event_receiver.h",
        here ++ "event.h",
        here ++ "file_descriptor_notifier.h",
        here ++ "formatters.h",
        here ++ "hashutils.h",
        here ++ "kdfoundation_global.h",
        here ++ "logging.h",
        here ++ "object.h",
        here ++ "postman.h",
        here ++ "timer.h",
        here ++ "utils.h",
        here ++ "vector_helper.h",
        here ++ "platform/abstract_platform_event_loop.h",
        here ++ "platform/abstract_platform_integration.h",
        here ++ "platform/abstract_platform_timer.h",
    }) catch @panic("OOM");

    switch (target.getOsTag()) {
        .linux => {
            h.appendSlice(&.{
                here ++ "platform/linux/linux_platform_event_loop.h",
                here ++ "platform/linux/linux_platform_integration.h",
                here ++ "platform/linux/linux_platform_timer.h",
            }) catch @panic("OOM");
        },
        .windows => {
            h.appendSlice(&.{
                here ++ "platform/win32/win32_platform_event_loop.h",
                here ++ "platform/win32/win32_platform_integration.h",
                here ++ "platform/win32/win32_platform_timer.h",
            }) catch @panic("OOM");
        },
        else => {
            @panic("unsupported OS");
        },
    }
    return h.toOwnedSlice() catch @panic("OOM");
}
