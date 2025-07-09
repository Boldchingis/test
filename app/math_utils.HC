#include "DCG.h"

// Mathematical utility functions for HolyC
F64 PI = 3.14159265358979323846;
F64 E = 2.71828182845904523536;

// Trigonometric functions
F64 Sin(F64 x) {
    return Sin(x);
}

F64 Cos(F64 x) {
    return Cos(x);
}

F64 Tan(F64 x) {
    return Tan(x);
}

// Power and exponential functions
F64 Pow(F64 base, F64 exponent) {
    return Pow(base, exponent);
}

F64 Exp(F64 x) {
    return Exp(x);
}

F64 Log(F64 x) {
    return Log(x);
}

F64 Log10(F64 x) {
    return Log(x) / Log(10.0);
}

// Absolute value and sign
F64 Abs(F64 x) {
    return x < 0 ? -x : x;
}

I64 Sign(F64 x) {
    return x < 0 ? -1 : (x > 0 ? 1 : 0);
}

// Clamping functions
F64 Clamp(F64 value, F64 min, F64 max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
}

I64 ClampI64(I64 value, I64 min, I64 max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
}

// Rounding functions
I64 Round(F64 x) {
    return x >= 0 ? (I64)(x + 0.5) : (I64)(x - 0.5);
}

I64 Floor(F64 x) {
    return (I64)x;
}

I64 Ceil(F64 x) {
    I64 int_part = (I64)x;
    return x > int_part ? int_part + 1 : int_part;
}

// Random number generation
F64 RandomFloat(F64 min, F64 max) {
    return min + (RandU16 % 10000) / 10000.0 * (max - min);
}

I64 RandomInt(I64 min, I64 max) {
    return min + (RandU16 % (max - min + 1));
}

// Vector operations
typedef struct Vec2 {
    F64 x, y;
} Vec2;

typedef struct Vec3 {
    F64 x, y, z;
} Vec3;

Vec2 Vec2Create(F64 x, F64 y) {
    Vec2 v;
    v.x = x;
    v.y = y;
    return v;
}

Vec3 Vec3Create(F64 x, F64 y, F64 z) {
    Vec3 v;
    v.x = x;
    v.y = y;
    v.z = z;
    return v;
}

F64 Vec2Length(Vec2 v) {
    return Sqrt(v.x * v.x + v.y * v.y);
}

F64 Vec3Length(Vec3 v) {
    return Sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
}

Vec2 Vec2Normalize(Vec2 v) {
    F64 length = Vec2Length(v);
    if (length == 0) return Vec2Create(0, 0);
    return Vec2Create(v.x / length, v.y / length);
}

Vec3 Vec3Normalize(Vec3 v) {
    F64 length = Vec3Length(v);
    if (length == 0) return Vec3Create(0, 0, 0);
    return Vec3Create(v.x / length, v.y / length, v.z / length);
}

Vec2 Vec2Add(Vec2 a, Vec2 b) {
    return Vec2Create(a.x + b.x, a.y + b.y);
}

Vec2 Vec2Sub(Vec2 a, Vec2 b) {
    return Vec2Create(a.x - b.x, a.y - b.y);
}

Vec2 Vec2Mul(Vec2 v, F64 scalar) {
    return Vec2Create(v.x * scalar, v.y * scalar);
}

F64 Vec2Dot(Vec2 a, Vec2 b) {
    return a.x * b.x + a.y * b.y;
}

// Matrix operations (2x2)
typedef struct Mat2 {
    F64 m[2][2];
} Mat2;

Mat2 Mat2Identity() {
    Mat2 m;
    m.m[0][0] = 1; m.m[0][1] = 0;
    m.m[1][0] = 0; m.m[1][1] = 1;
    return m;
}

Mat2 Mat2Rotation(F64 angle) {
    Mat2 m;
    F64 c = Cos(angle);
    F64 s = Sin(angle);
    m.m[0][0] = c;  m.m[0][1] = -s;
    m.m[1][0] = s;  m.m[1][1] = c;
    return m;
}

Vec2 Mat2MulVec2(Mat2 m, Vec2 v) {
    return Vec2Create(
        m.m[0][0] * v.x + m.m[0][1] * v.y,
        m.m[1][0] * v.x + m.m[1][1] * v.y
    );
}

// Interpolation functions
F64 Lerp(F64 a, F64 b, F64 t) {
    return a + t * (b - a);
}

Vec2 Vec2Lerp(Vec2 a, Vec2 b, F64 t) {
    return Vec2Create(Lerp(a.x, b.x, t), Lerp(a.y, b.y, t));
}

// Easing functions
F64 EaseInQuad(F64 t) {
    return t * t;
}

F64 EaseOutQuad(F64 t) {
    return t * (2 - t);
}

F64 EaseInOutQuad(F64 t) {
    return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
}

// Noise functions
F64 Noise1D(I64 x) {
    x = (x << 13) ^ x;
    return 1.0 - ((x * (x * x * 15731 + 789221) + 1376312589) & 0x7fffffff) / 1073741824.0;
}

F64 Noise2D(I64 x, I64 y) {
    I64 n = x + y * 57;
    n = (n << 13) ^ n;
    return 1.0 - ((n * (n * n * 15731 + 789221) + 1376312589) & 0x7fffffff) / 1073741824.0;
}

// Color utilities
typedef struct Color {
    U8 r, g, b, a;
} Color;

Color ColorCreate(U8 r, U8 g, U8 b, U8 a) {
    Color c;
    c.r = r;
    c.g = g;
    c.b = b;
    c.a = a;
    return c;
}

U32 ColorToU32(Color c) {
    return (c.a << 24) | (c.r << 16) | (c.g << 8) | c.b;
}

Color U32ToColor(U32 color) {
    Color c;
    c.b = color & 0xFF;
    c.g = (color >> 8) & 0xFF;
    c.r = (color >> 16) & 0xFF;
    c.a = (color >> 24) & 0xFF;
    return c;
}

Color ColorLerp(Color a, Color b, F64 t) {
    return ColorCreate(
        (U8)Lerp(a.r, b.r, t),
        (U8)Lerp(a.g, b.g, t),
        (U8)Lerp(a.b, b.b, t),
        (U8)Lerp(a.a, b.a, t)
    );
} 