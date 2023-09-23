const std = @import("std");

const here = "src/KDGui/";

pub fn sources(ally: std.mem.Allocator, target: std.zig.CrossTarget) []const []const u8 {
    var srcs = std.ArrayList([]const u8).init(ally);
    srcs.appendSlice(&.{
        here ++ "abstract_platform_window.cpp",
        here ++ "gui_application.cpp",
        here ++ "window.cpp",
    }) catch @panic("OOM");

    switch (target.getOsTag()) {
        .linux => {
            srcs.appendSlice(&.{
                here ++ "platform/linux/xcb/linux_xcb_platform_event_loop.cpp",
                here ++ "platform/linux/xcb/linux_xcb_platform_integration.cpp",
                here ++ "platform/linux/xcb/linux_xcb_platform_window.cpp",
                here ++ "platform/linux/xcb/linux_xkb_keyboard.cpp",
                here ++ "platform/linux/common/linux_xkb.cpp",
                here ++ "platform/linux/common/linux_xkb_keyboard_map.cpp",
            }) catch @panic("OOM");
        },
        .windows => {
            srcs.appendSlice(&.{
                here ++ "platform/win32/win32_gui_platform_integration.cpp",
                here ++ "platform/win32/win32_platform_window.cpp",
                here ++ "platform/win32/win32_utils.cpp",
                here ++ "platform/win32/win32_keyboard_map.cpp",
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
        here ++ "abstract_gui_platform_integration.h",
        here ++ "abstract_platform_window.h",
        here ++ "gui_application.h",
        here ++ "gui_events.h",
        here ++ "kdgui_global.h",
        here ++ "kdgui_keys.h",
        here ++ "window.h",
        here ++ "position.h",
    }) catch @panic("OOM");

    switch (target.getOsTag()) {
        .linux => {
            h.appendSlice(&.{
                here ++ "platform/linux/xcb/linux_xcb_platform_event_loop.h",
                here ++ "platform/linux/xcb/linux_xcb_platform_integration.h",
                here ++ "platform/linux/xcb/linux_xcb_platform_window.h",
                here ++ "platform/linux/xcb/linux_xkb_keyboard.h",
                here ++ "platform/linux/common/linux_xkb.h",
                here ++ "platform/linux/common/linux_xkb_keyboard_map.h",
            }) catch @panic("OOM");
        },
        .windows => {
            h.appendSlice(&.{
                here ++ "platform/win32/win32_gui_platform_integration.h",
                here ++ "platform/win32/win32_keyboard_map.h",
                here ++ "platform/win32/win32_platform_window.h",
                here ++ "platform/win32/win32_utils.h",
            }) catch @panic("OOM");
        },
        else => {
            @panic("unsupported OS");
        },
    }
    return h.toOwnedSlice() catch @panic("OOM");
}
