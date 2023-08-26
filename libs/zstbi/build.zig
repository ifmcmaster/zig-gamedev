const std = @import("std");

pub const Package = struct {
    zstbi: *std.Build.Module,
    zstbi_c_cpp: *std.Build.CompileStep,

    pub fn build(
        b: *std.Build,
        target: std.zig.CrossTarget,
        optimize: std.builtin.Mode,
        _: struct {},
    ) Package {
        const zstbi = b.createModule(.{
            .source_file = .{ .path = thisDir() ++ "/src/zstbi.zig" },
        });

        const zstbi_c_cpp = b.addStaticLibrary(.{
            .name = "zstbi",
            .target = target,
            .optimize = optimize,
        });
        if (optimize == .Debug) {
            // TODO: Workaround for Zig bug.
            zstbi_c_cpp.addCSourceFile(thisDir() ++ "/libs/stbi/stb_image.c", &.{});
        } else {
            zstbi_c_cpp.addCSourceFile(thisDir() ++ "/libs/stbi/stb_image.c", &.{});
        }
        zstbi_c_cpp.linkLibC();

        return .{
            .zstbi = zstbi,
            .zstbi_c_cpp = zstbi_c_cpp,
        };
    }

    pub fn link(zstbi_pkg: Package, exe: *std.Build.CompileStep) void {
        exe.linkLibrary(zstbi_pkg.zstbi_c_cpp);
    }
};

pub fn build(_: *std.Build) void {}

pub fn buildTests(
    b: *std.Build,
    optimize: std.builtin.Mode,
    target: std.zig.CrossTarget,
) *std.Build.RunStep {
    const tests = b.addTest(.{
        .name = "zstbi-tests",
        .root_source_file = .{ .path = thisDir() ++ "/src/zstbi.zig" },
        .target = target,
        .optimize = optimize,
    });

    const zstbi_pkg = Package.build(b, target, optimize, .{});
    zstbi_pkg.link(tests);

    return tests.run();
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
