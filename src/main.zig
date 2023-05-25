const std = @import("std");
const mem = std.mem;
const Thread = std.Thread;
const http = std.http;

// var serial_thread: ?Thread = null;
var http_thread: ?Thread = null;

pub fn main() !void {
    // serial_thread = try Thread.spawn(.{}, serial_run, .{});
    http_thread = try Thread.spawn(.{}, http_run, .{});

    http_thread.?.join();
}

fn serial_run() !void {}

fn http_run() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var server = http.Server.init(arena.allocator(), .{
        .reuse_address = true,
        .reuse_port = true,
    });
    defer server.deinit();
    try server.listen(std.net.Address.initIp4(.{ 127, 0, 0, 1 }, 8000));
    while (true) {
        serve_request(&server) catch |err| {
            std.log.err("Request response error {any}", .{err});
        };
    }
}

const Resource = struct {
    data: [] const u8,
    content_type: [] const u8,
    status: http.Status,
};

const data_index: Resource = .{
    .data = @embedFile("index.html"),
    .content_type = "text/html",
    .status = .ok,
};

const data_error: Resource = .{
    .data = "server error",
    .content_type = "text/html",
    .status = .internal_server_error,
};

const data_js:Resource = .{
    .data = @embedFile("main.js"),
    .content_type = "text/javascript",
    .status = .ok,
};

const data_css:Resource = .{
    .data = @embedFile("main.css"),
    .content_type = "text/css",
    .status = .ok,
};

fn serve_request(server: *std.http.Server) !void {
    var res_arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer res_arena.deinit();
    var res = try server.accept(.{ .allocator = res_arena.allocator() });
    try res.wait();
    const path = res.request.target;
    const resource = data: {
        if (mem.eql(u8, path, "/")) {
            break :data data_index;
        } else if (mem.eql(u8, path, "/main.css")) {
            break :data data_css;
        } else if (mem.eql(u8, path, "/main.js")) {
            break :data data_js;
        } else {
            break :data data_error;
        }
    };
    res.transfer_encoding = .{ .content_length = resource.data.len };
    res.status = resource.status;
    try res.headers.append("content-type", resource.content_type);
    try res.headers.append("connection", "close");
    try res.do();
    try res.writeAll(resource.data);
    try res.finish();
}

// test "simple test" {
//     var list = std.ArrayList(i32).init(std.testing.allocator);
//     defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
//     try list.append(42);
//     try std.testing.expectEqual(@as(i32, 42), list.pop());
// }
