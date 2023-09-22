const std = @import("std");
const zcc = @import("compile_commands");
const interface = @import("build_interface.zig");

const srcdir = "src/";
const foundationdir = "KDFoundation/";
const utilsdir = "KDUtils/";
const guidir = "KDGui/";

fn foundationSrcs(ally: std.mem.Allocator, target: std.zig.CrossTarget) []const []const u8 {
    var srcs = std.ArrayList([]const u8).init(ally);
    srcs.appendSlice(&.{
        srcdir ++ foundationdir ++ "core_application.cpp",
        srcdir ++ foundationdir ++ "event.cpp",
        srcdir ++ foundationdir ++ "file_descriptor_notifier.cpp",
        srcdir ++ foundationdir ++ "object.cpp",
        srcdir ++ foundationdir ++ "postman.cpp",
        srcdir ++ foundationdir ++ "timer.cpp",
    }) catch @panic("OOM");

    switch (target.getOsTag()) {
        .linux => {
            srcs.appendSlice(&.{
                srcdir ++ foundationdir ++ "platform/linux/linux_platform_event_loop.cpp",
                srcdir ++ foundationdir ++ "platform/linux/linux_platform_integration.cpp",
                srcdir ++ foundationdir ++ "platform/linux/linux_platform_timer.cpp",
            });
        },
        .windows => {
            srcs.appendSlice(&.{
                srcdir ++ foundationdir ++ "platform/win32/win32_platform_event_loop.cpp",
                srcdir ++ foundationdir ++ "platform/win32/win32_platform_integration.cpp",
                srcdir ++ foundationdir ++ "platform/win32/win32_platform_timer.cpp",
            });
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

fn foundationHeaders(ally: std.mem.Allocator, target: std.zig.CrossTarget) []const []const u8 {
    var headers = std.ArrayList([]const u8).init(ally);
    headers.appendSlice(&.{
        srcdir ++ foundationdir ++ "constexpr_sort.h",
        srcdir ++ foundationdir ++ "core_application.h",
        srcdir ++ foundationdir ++ "destruction_helpers.h",
        srcdir ++ foundationdir ++ "event_queue.h",
        srcdir ++ foundationdir ++ "event_receiver.h",
        srcdir ++ foundationdir ++ "event.h",
        srcdir ++ foundationdir ++ "file_descriptor_notifier.h",
        srcdir ++ foundationdir ++ "formatters.h",
        srcdir ++ foundationdir ++ "hashutils.h",
        srcdir ++ foundationdir ++ "kdfoundation_global.h",
        srcdir ++ foundationdir ++ "logging.h",
        srcdir ++ foundationdir ++ "object.h",
        srcdir ++ foundationdir ++ "postman.h",
        srcdir ++ foundationdir ++ "timer.h",
        srcdir ++ foundationdir ++ "utils.h",
        srcdir ++ foundationdir ++ "vector_helper.h",
        srcdir ++ foundationdir ++ "platform/abstract_platform_event_loop.h",
        srcdir ++ foundationdir ++ "platform/abstract_platform_integration.h",
        srcdir ++ foundationdir ++ "platform/abstract_platform_timer.h",
    }) catch @panic("OOM");

    switch (target.getOsTag()) {
        .linux => {
            headers.appendSlice(&.{
                srcdir ++ foundationdir ++ "platform/linux/linux_platform_event_loop.h",
                srcdir ++ foundationdir ++ "platform/linux/linux_platform_integration.h",
                srcdir ++ foundationdir ++ "platform/linux/linux_platform_timer.h",
            });
        },
        .windows => {
            headers.appendSlice(&.{
                srcdir ++ foundationdir ++ "platform/win32/win32_platform_event_loop.h",
                srcdir ++ foundationdir ++ "platform/win32/win32_platform_integration.h",
                srcdir ++ foundationdir ++ "platform/win32/win32_platform_timer.h",
            });
        },
        else => {
            @panic("unsupported OS");
        },
    }
    return headers.toOwnedSlice() catch @panic("OOM");
}

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const build_static = b.option(bool, "build_static_libs", "build and install static versions of the libraries");
    _ = build_static;

    var targets = std.ArrayList(*std.Build.Step.Compile).init(b.allocator);

    const kdutils_shared = b.addSharedLibrary(.{
        .target = target,
        .optimize = optimize,
        .name = "KDUtils",
    });
    const kdfoundation_shared = b.addSharedLibrary(.{
        .target = target,
        .optimize = optimize,
        .name = "KDFoundation",
    });
    const kdgui_shared = b.addSharedLibrary(.{
        .target = target,
        .optimize = optimize,
        .name = "KDGui",
    });

    kdfoundation_shared.addIncludePath(.{ .path = srcdir ++ foundationdir });
    kdfoundation_shared.addCSourceFiles(foundationSrcs(b.allocator, target), &.{});

    targets.append(kdgui_shared) catch @panic("OOM");
    targets.append(kdfoundation_shared) catch @panic("OOM");
    targets.append(kdutils_shared) catch @panic("OOM");

    for (targets.items) |t| {
        t.linkLibC();
        t.linkLibCpp();
        b.installArtifact(t);
    }

    zcc.createStep(b, "cdb", try targets.toOwnedSlice());
}
