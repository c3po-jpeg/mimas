const std = @import("std");

// row major order
pub const Mat4x4 = struct {
    d: [4][4]f32, // data is stored in column-major order

    pub fn identity() Mat4x4 {
        return .{
            .d = .{
                .{ 1.0, 0.0, 0.0, 0.0 },
                .{ 0.0, 1.0, 0.0, 0.0 },
                .{ 0.0, 0.0, 1.0, 0.0 },
                .{ 0.0, 0.0, 0.0, 1.0 },
            },
        };
    }

    pub fn new(data: [4][4]f32) Mat4x4 {
        return .{ .d = data };
    }

    pub fn transpose(self: Mat4x4) Mat4x4 {
        return .{ .d = .{
            .{
                self.d[0][0],
                self.d[1][0],
                self.d[2][0],
                self.d[3][0],
            },
            .{
                self.d[0][1],
                self.d[1][1],
                self.d[2][1],
                self.d[3][1],
            },
            .{
                self.d[0][2],
                self.d[1][2],
                self.d[2][2],
                self.d[3][2],
            },
            .{
                self.d[0][3],
                self.d[1][3],
                self.d[2][3],
                self.d[3][3],
            },
        } };
    }

    pub fn add(lhs: Mat4x4, rhs: Mat4x4) Mat4x4 {
        return .{ .d = .{
            .{
                lhs.d[0][0] + rhs.d[0][0],
                lhs.d[0][1] + rhs.d[0][1],
                lhs.d[0][2] + rhs.d[0][2],
                lhs.d[0][3] + rhs.d[0][3],
            },
            .{
                lhs.d[1][0] + rhs.d[1][0],
                lhs.d[1][1] + rhs.d[1][1],
                lhs.d[1][2] + rhs.d[1][2],
                lhs.d[1][3] + rhs.d[1][3],
            },
            .{
                lhs.d[2][0] + rhs.d[2][0],
                lhs.d[2][1] + rhs.d[2][1],
                lhs.d[2][2] + rhs.d[2][2],
                lhs.d[2][3] + rhs.d[2][3],
            },
            .{
                lhs.d[3][0] + rhs.d[3][0],
                lhs.d[3][1] + rhs.d[3][1],
                lhs.d[3][2] + rhs.d[3][2],
                lhs.d[3][3] + rhs.d[3][3],
            },
        } };
    }

    pub fn sub(lhs: Mat4x4, rhs: Mat4x4) Mat4x4 {
        return .{ .d = .{
            .{
                lhs.d[0][0] - rhs.d[0][0],
                lhs.d[0][1] - rhs.d[0][1],
                lhs.d[0][2] - rhs.d[0][2],
                lhs.d[0][3] - rhs.d[0][3],
            },
            .{
                lhs.d[1][0] - rhs.d[1][0],
                lhs.d[1][1] - rhs.d[1][1],
                lhs.d[1][2] - rhs.d[1][2],
                lhs.d[1][3] - rhs.d[1][3],
            },
            .{
                lhs.d[2][0] - rhs.d[2][0],
                lhs.d[2][1] - rhs.d[2][1],
                lhs.d[2][2] - rhs.d[2][2],
                lhs.d[2][3] - rhs.d[2][3],
            },
            .{
                lhs.d[3][0] - rhs.d[3][0],
                lhs.d[3][1] - rhs.d[3][1],
                lhs.d[3][2] - rhs.d[3][2],
                lhs.d[3][3] - rhs.d[3][3],
            },
        } };
    }

    pub fn mul_scalar(lhs: Mat4x4, scalar: f32) Mat4x4 {
        return .{ .d = .{
            .{
                lhs.d[0][0] * scalar,
                lhs.d[0][1] * scalar,
                lhs.d[0][2] * scalar,
                lhs.d[0][3] * scalar,
            },
            .{
                lhs.d[1][0] * scalar,
                lhs.d[1][1] * scalar,
                lhs.d[1][2] * scalar,
                lhs.d[1][3] * scalar,
            },
            .{
                lhs.d[2][0] * scalar,
                lhs.d[2][1] * scalar,
                lhs.d[2][2] * scalar,
                lhs.d[2][3] * scalar,
            },
            .{
                lhs.d[3][0] * scalar,
                lhs.d[3][1] * scalar,
                lhs.d[3][2] * scalar,
                lhs.d[3][3] * scalar,
            },
        } };
    }

    pub fn mul(lhs: Mat4x4, rhs: Mat4x4) Mat4x4 {
        const rxc = struct {
            pub fn call(
                m1: Mat4x4,
                m2: Mat4x4,
                row: usize,
                col: usize,
            ) f32 {
                var sum: f32 = 0.0;
                sum += m1.d[row][0] * m2.d[0][col];
                sum += m1.d[row][1] * m2.d[1][col];
                sum += m1.d[row][2] * m2.d[2][col];
                sum += m1.d[row][3] * m2.d[3][col];
                return sum;
            }
        }.call;

        return .{ .d = .{
            .{
                rxc(lhs, rhs, 0, 0),
                rxc(lhs, rhs, 0, 1),
                rxc(lhs, rhs, 0, 2),
                rxc(lhs, rhs, 0, 3),
            },
            .{
                rxc(lhs, rhs, 1, 0),
                rxc(lhs, rhs, 1, 1),
                rxc(lhs, rhs, 1, 2),
                rxc(lhs, rhs, 1, 3),
            },
            .{
                rxc(lhs, rhs, 2, 0),
                rxc(lhs, rhs, 2, 1),
                rxc(lhs, rhs, 2, 2),
                rxc(lhs, rhs, 2, 3),
            },
            .{
                rxc(lhs, rhs, 3, 0),
                rxc(lhs, rhs, 3, 1),
                rxc(lhs, rhs, 3, 2),
                rxc(lhs, rhs, 3, 3),
            },
        } };
    }

    pub fn translation(x: f32, y: f32, z: f32) Mat4x4 {
        return .{ .d = .{
            .{ 1.0, 0.0, 0.0, x },
            .{ 0.0, 1.0, 0.0, y },
            .{ 0.0, 0.0, 1.0, z },
            .{ 0.0, 0.0, 0.0, 1.0 },
        } };
    }

    pub fn scaling(x: f32, y: f32, z: f32) Mat4x4 {
        return .{ .d = .{
            .{ x, 0.0, 0.0, 0.0 },
            .{ 0.0, y, 0.0, 0.0 },
            .{ 0.0, 0.0, z, 0.0 },
            .{ 0.0, 0.0, 0.0, 1.0 },
        } };
    }

    pub fn rotation_x(angle_rad: f32) Mat4x4 {
        return .{ .d = .{
            .{ 1.0, 0.0, 0.0, 0.0 },
            .{ 0.0, @cos(angle_rad), @sin(angle_rad), 0.0 },
            .{ 0.0, -@sin(angle_rad), @cos(angle_rad), 0.0 },
            .{ 0.0, 0.0, 0.0, 1.0 },
        } };
    }

    pub fn rotation_y(angle_rad: f32) Mat4x4 {
        return .{ .d = .{
            .{ @cos(angle_rad), 0.0, -@sin(angle_rad), 0.0 },
            .{ 0.0, 1.0, 0.0, 0.0 },
            .{ @sin(angle_rad), 0.0, @cos(angle_rad), 0.0 },
            .{ 0.0, 0.0, 0.0, 1.0 },
        } };
    }

    pub fn rotation_z(angle_rad: f32) Mat4x4 {
        return .{ .d = .{
            .{ @cos(angle_rad), @sin(angle_rad), 0.0, 0.0 },
            .{ -@sin(angle_rad), @cos(angle_rad), 0.0, 0.0 },
            .{ 0.0, 0.0, 1.0, 0.0 },
            .{ 0.0, 0.0, 0.0, 1.0 },
        } };
    }

    pub fn look_at(eye: Vec3, center: Vec3, up: Vec3) Mat4x4 {}
};

const Vec3 = @import("vec3.zig").Vec3;
