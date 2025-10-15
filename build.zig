const std = @import("std");

const src_files = [_][]const u8{
    "callbacks.c",
    "compress.c",
    "host.c",
    "list.c",
    "packet.c",
    "peer.c",
    "protocol.c",
    "unix.c",
    "win32.c",
};

pub const Options = struct {
    has_fcntl: bool,
    has_poll: bool,
    has_getaddrinfo: bool,
    has_getnameinfo: bool,
    has_gethostbyname_r: bool,
    has_gethostbyaddr_r: bool,
    has_inet_pton: bool,
    has_inet_ntop: bool,
    has_offsetof: bool,
    has_msghdr_flags: bool,
    has_socklen_t: bool,

    const defaults = Options{};

    pub fn getOptions(b: *std.Build) Options {
        return .{
            .has_fcntl = b.option(bool, "fcntl", "Has fcntl support") orelse true,
            .has_poll = b.option(bool, "poll", "Has poll support") orelse true,
            .has_getaddrinfo = b.option(bool, "getaddrinfo", "Has getaddrinfo support") orelse true,
            .has_getnameinfo = b.option(bool, "getnameinfo", "Has getnameinfo support") orelse true,
            .has_gethostbyname_r = b.option(bool, "gethostbyname_r", "Has gethostbyname_r support") orelse true,
            .has_gethostbyaddr_r = b.option(bool, "gethostbyaddr_r", "Has gethostbyaddr_r support") orelse true,
            .has_inet_pton = b.option(bool, "inet_pton", "Has inet_pton support") orelse true,
            .has_inet_ntop = b.option(bool, "inet_ntop", "Has inet_ntop support") orelse true,
            .has_offsetof = b.option(bool, "offsetof", "Has offsetof support") orelse true,
            .has_msghdr_flags = b.option(bool, "msghdr_flags", "Has msghdr_flags support") orelse true,
            .has_socklen_t = b.option(bool, "socklen_t", "Has socklen_t support") orelse true,
        };
    }
};

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const options = Options.getOptions(b);

    const lib = b.addLibrary(.{
        .name = "enet",
        .linkage = .static,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });

    switch (target.result.os.tag) {
        .windows => {
            lib.linkSystemLibrary("winmm");
            lib.linkSystemLibrary("ws2_32");
        },
        else => {}
    }

    lib.addIncludePath(b.path("include"));

    lib.installHeader(b.path("include/enet/callbacks.h"), "enet/callbacks.h");
    lib.installHeader(b.path("include/enet/enet.h"), "enet/enet.h");
    lib.installHeader(b.path("include/enet/list.h"), "enet/list.h");
    lib.installHeader(b.path("include/enet/protocol.h"), "enet/protocol.h");
    lib.installHeader(b.path("include/enet/time.h"), "enet/time.h");
    lib.installHeader(b.path("include/enet/types.h"), "enet/types.h");
    lib.installHeader(b.path("include/enet/unix.h"), "enet/unix.h");
    lib.installHeader(b.path("include/enet/utility.h"), "enet/utility.h");
    lib.installHeader(b.path("include/enet/win32.h"), "enet/win32.h");

    lib.root_module.addCSourceFiles(.{
        .files = &src_files,
    });

    if (options.has_fcntl) {
        lib.root_module.addCMacro("HAS_FCNTL", "1");
    }
    if (options.has_poll) {
        lib.root_module.addCMacro("HAS_POLL", "1");
    }
    if (options.has_getaddrinfo) {
        lib.root_module.addCMacro("HAS_GETNAMEINFO", "1");
    }
    if (options.has_getnameinfo) {
        lib.root_module.addCMacro("HAS_GETADDRINFO", "1");
    }
    if (options.has_gethostbyname_r) {
        lib.root_module.addCMacro("HAS_GETHOSTBYNAME_R", "1");
    }
    if (options.has_gethostbyaddr_r) {
        lib.root_module.addCMacro("HAS_GETHOSTBYADDR_R", "1");
    }
    if (options.has_inet_pton) {
        lib.root_module.addCMacro("HAS_INET_PTON", "1");
    }
    if (options.has_inet_ntop) {
        lib.root_module.addCMacro("HAS_INET_NTOP", "1");
    }
    if (options.has_offsetof) {
        lib.root_module.addCMacro("HAS_OFFSETOF", "1");
    }
    if (options.has_msghdr_flags) {
        lib.root_module.addCMacro("HAS_MSGHDR_FLAGS", "1");
    }
    if (options.has_socklen_t) {
        lib.root_module.addCMacro("HAS_SOCKLEN_T", "1");
    }

    b.installArtifact(lib);
}
