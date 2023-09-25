const std = @import("std");
const zcc = @import("compile_commands");

const foundationdir = "src/KDFoundation/";
const utilsdir = "src/KDUtils/";
const guidir = "src/KDGui/";

const kdfoundation_module = @import("src/KDFoundation/build.zig");
const kdutils_module = @import("src/KDUtils/build.zig");
const kdgui_module = @import("src/KDGui/build.zig");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const wayland_support = b.option(bool, "wayland_support", "whether to enable wayland on linux") orelse true;
    const build_static = b.option(bool, "build_static_libs", "build and install static versions of the libraries") orelse false;
    _ = build_static;

    var targets = std.ArrayList(*std.Build.Step.Compile).init(b.allocator);
    var flags = std.ArrayList([]const u8).init(b.allocator);

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

    const foundation_export_android = .{ .KDFOUNDATION_EXPORT = void{}, .KD_PLATFORM_ANDROID = void{} };
    const foundation_export_linux = .{ .KDFOUNDATION_EXPORT = void{}, .KD_PLATFORM_LINUX = void{} };
    const foundation_export_windows = .{ .KDFOUNDATION_EXPORT = void{}, .KD_PLATFORM_WIN32 = void{} };
    const foundation_export_macos = .{ .KDFOUNDATION_EXPORT = void{}, .KD_PLATFORM_MACOS = void{} };
    const foundation_export_settings = .{
        .style = .blank,
        .include_path = "KDFoundation/kdfoundation_export.h",
    };

    const kdfoundation_export = (if (target.abi == .android) b.addConfigHeader(foundation_export_settings, foundation_export_android) else switch (target.getOsTag()) {
        .linux => b.addConfigHeader(foundation_export_settings, foundation_export_linux),
        .windows => b.addConfigHeader(foundation_export_settings, foundation_export_windows),
        .macos => b.addConfigHeader(foundation_export_settings, foundation_export_macos),
        else => @panic("unsupported OS"),
    });

    const kdutils_export = b.addConfigHeader(
        .{ .style = .blank, .include_path = "KDUtils/kdutils_export.h" },
        .{
            .KDUTILS_EXPORT = void{},
        },
    );

    const kdgui_android = target.abi == .android;
    const kdgui_cocoa = target.getOsTag() == .macos;
    const kdgui_wayland = target.getOsTag() == .linux and wayland_support;
    const kdgui_xcb = target.getOsTag() == .linux;
    const kdgui_win32 = target.getOsTag() == .windows;

    const kdgui_export = b.addConfigHeader(
        .{ .style = .{ .cmake = .{ .path = "src/KDGui/config.h" } }, .include_path = "KDGui/kdgui_export.h" },
        .{
            .KDGUI_PLATFORM_ANDROID = kdgui_android,
            .KDGUI_PLATFORM_COCOA = kdgui_cocoa,
            .KDGUI_PLATFORM_XCB = kdgui_xcb,
            .KDGUI_PLATFORM_WAYLAND = kdgui_wayland,
            .KDGUI_PLATFORM_WIN32 = kdgui_win32,
        },
    );

    const final_flags = flags.toOwnedSlice() catch @panic("OOM");
    kdfoundation_shared.addCSourceFiles(kdfoundation_module.sources(b.allocator, target), final_flags);
    kdutils_shared.addCSourceFiles(kdutils_module.sources(b.allocator, target), final_flags);
    kdgui_shared.addCSourceFiles(kdgui_module.sources(b.allocator, target), final_flags);

    // system libraries
    switch (target.getOsTag()) {
        .linux => {
            kdgui_shared.linkSystemLibrary("xcb");
            if (wayland_support) {
                // TODO: does this work
                kdgui_shared.linkSystemLibrary("wayland");
            }
        },
        .windows => {
            @panic("system libs for windows not set up");
        },
        .macos => {
            @panic("system frameworks for macos not ste up");
        },
        else => @panic("unsupported OS"),
    }

    targets.append(kdgui_shared) catch @panic("OOM");
    targets.append(kdfoundation_shared) catch @panic("OOM");
    targets.append(kdutils_shared) catch @panic("OOM");

    const kdbindings = b.dependency("kdbindings", .{});
    const mio = b.dependency("mio", .{});
    const spdlog = b.dependency("spdlog", .{ .exceptions = true }).artifact("spdlog");
    const whereami = b.dependency("whereami", .{}).artifact("whereami");

    for (targets.items) |t| {
        t.linkLibC();
        t.linkLibCpp();
        b.installArtifact(t);
        t.addIncludePath(.{ .path = "src/" });
        t.addConfigHeader(kdfoundation_export);
        t.addConfigHeader(kdutils_export);
        t.addConfigHeader(kdgui_export);
        t.linkLibrary(spdlog);
        t.linkLibrary(whereami);

        // include kdbindings
        t.step.dependOn(kdbindings.builder.getInstallStep());
        t.addIncludePath(.{ .path = std.fs.path.join(
            b.allocator,
            &.{ kdbindings.builder.install_path, "include" },
        ) catch @panic("OOM") });

        t.step.dependOn(mio.builder.getInstallStep());
        t.addIncludePath(.{ .path = std.fs.path.join(
            b.allocator,
            &.{ mio.builder.install_path, "include" },
        ) catch @panic("OOM") });
    }

    zcc.createStep(b, "cdb", try targets.toOwnedSlice());
}
