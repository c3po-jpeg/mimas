const std = @import("std");

pub const Vec3 = struct {
    x: f32,
    y: f32,
    z: f32,

    pub fn new(x: f32, y: f32, z: f32) Vec3 {
        return .{
            .x = x,
            .y = y,
            .z = z,
        };
    }

    pub fn len_sqrd(self: Vec3) f32 {
        return self.x * self.x + self.y * self.y + self.z * self.z;
    }

    pub fn len(self: Vec3) f32 {
        return std.math.sqrt(self.len_sqrd());
    }

    pub fn normalize(self: Vec3) Vec3 {
        const length = self.len();
        return .{
            .x = self.x / length,
            .y = self.y / length,
            .z = self.z / length,
        };
    }

    pub fn cross(self: Vec3, other: Vec3) Vec3 {
        return .{
            .x = self.y * other.z - self.z * other.y,
            .y = self.z * other.x - self.x * other.z,
            .z = self.x * other.y - self.y * other.x,
        };
    }

    pub fn reflect(self: Vec3, normal: Vec3) Vec3 {
        const dot_product = self.dot(normal);
        return .{
            .x = self.x - 2.0 * dot_product * normal.x,
            .y = self.y - 2.0 * dot_product * normal.y,
            .z = self.z - 2.0 * dot_product * normal.z,
        };
    }

    pub fn dot(self: Vec3, other: Vec3) f32 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }

    pub fn add(self: Vec3, other: Vec3) Vec3 {
        return .{
            .x = self.x + other.x,
            .y = self.y + other.y,
            .z = self.z + other.z,
        };
    }

    pub fn sub(self: Vec3, other: Vec3) Vec3 {
        return .{
            .x = self.x - other.x,
            .y = self.y - other.y,
            .z = self.z - other.z,
        };
    }

    pub fn scale(self: Vec3, scalar: f32) Vec3 {
        return .{
            .x = self.x * scalar,
            .y = self.y * scalar,
            .z = self.z * scalar,
        };
    }
};
