const std = @import("std");

// Datatypes
pub fn Result(comptime T:type, comptime U:type) type {
    return union(enum){
        success: T,
        failure: U
    };
}


pub fn Maybe(comptime T:type) type {
    return union(enum){
        just: T,
        none
    };
}

// Right biased
pub fn Either(comptime T:type, comptime U:type) type {
    return union(enum){
        left: T,
        right: U
    };
}


// data structures
pub fn Stack(comptime T:type, comptime capacity: usize) type {
    return struct {
        const Self = @This();

        // attributes
        top : usize,
        stack : [capacity]*T,
        allocator : std.mem.Allocator,

        // traits
        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .top = 0,
                .stack = undefined,
                .allocator = allocator
            };
        }

        pub fn push(self : *Self, item : T) !void {
            if (self.top >= capacity){
                return error.StackOverflow;
            } else {
                const heap_obj = try self.allocator.create(T);
                heap_obj.* = item;
                self.stack[self.top] = heap_obj;
                self.top += 1;
            }
        }
        pub fn pop(self : *Self) !T {
            if (self.top == 0){
                return error.StackUnderflow;
            } else {
                self.top -= 1;
                const heap_obj = self.stack[self.top];
                defer self.allocator.destroy(heap_obj);
                const value = heap_obj.*;
                return value;
            }
        }
        pub fn peek(self : *Self) !T {
            if (self.top == 0) return error.EmptyStack;
            return self.stack[self.top - 1].*;
        }

        pub fn deinit(self: *Self) void {
            // Clean up any remaining heap objects
            while (self.top > 0) {
                _ = self.pop() catch {};
            }
        }
    };
}