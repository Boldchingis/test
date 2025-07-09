#include "DCG.h"

U8 *fractal_buffer = NULL;
I64 fractal_width, fractal_height;

U0 InitFractalBuffer(I64 width, I64 height)
{
    fractal_width = width;
    fractal_height = height;
    fractal_buffer = MAlloc(width * height * 4);
}

U0 MandelbrotSet(F64 center_x, F64 center_y, F64 zoom, I64 max_iter)
{
    F64 scale = 4.0 / zoom;
    F64 offset_x = center_x - scale / 2.0;
    F64 offset_y = center_y - scale / 2.0;
    
    for (I64 y = 0; y < fractal_height; y++) {
        for (I64 x = 0; x < fractal_width; x++) {
            F64 cx = offset_x + (F64)x * scale / fractal_width;
            F64 cy = offset_y + (F64)y * scale / fractal_height;
            
            F64 zx = 0.0, zy = 0.0;
            I64 iter = 0;
            
            while (zx * zx + zy * zy < 4.0 && iter < max_iter) {
                F64 temp = zx * zx - zy * zy + cx;
                zy = 2.0 * zx * zy + cy;
                zx = temp;
                iter++;
            }
            
            U32 color;
            if (iter == max_iter) {
                color = 0x00000000;
            } else {
                F64 t = (F64)iter / max_iter;
                U8 r = (U8)(t * 255);
                U8 g = (U8)((1.0 - t) * 255);
                U8 b = (U8)(Sin(t * 3.14159) * 255);
                color = 0xFF000000 | (r << 16) | (g << 8) | b;
            }
            
            fractal_buffer[(y * fractal_width + x) * 4] = color & 0xFF;
            fractal_buffer[(y * fractal_width + x) * 4 + 1] = (color >> 8) & 0xFF;
            fractal_buffer[(y * fractal_width + x) * 4 + 2] = (color >> 16) & 0xFF;
            fractal_buffer[(y * fractal_width + x) * 4 + 3] = (color >> 24) & 0xFF;
        }
    }
}

U0 JuliaSet(F64 cx, F64 cy, F64 zoom, I64 max_iter)
{
    F64 scale = 4.0 / zoom;
    F64 offset_x = -scale / 2.0;
    F64 offset_y = -scale / 2.0;
    
    for (I64 y = 0; y < fractal_height; y++) {
        for (I64 x = 0; x < fractal_width; x++) {
            F64 zx = offset_x + (F64)x * scale / fractal_width;
            F64 zy = offset_y + (F64)y * scale / fractal_height;
            
            I64 iter = 0;
            
            while (zx * zx + zy * zy < 4.0 && iter < max_iter) {
                F64 temp = zx * zx - zy * zy + cx;
                zy = 2.0 * zx * zy + cy;
                zx = temp;
                iter++;
            }
            
            U32 color;
            if (iter == max_iter) {
                color = 0x00000000;
            } else {
                F64 t = (F64)iter / max_iter;
                U8 r = (U8)(Sin(t * 6.28) * 127 + 128);
                U8 g = (U8)(Cos(t * 6.28) * 127 + 128);
                U8 b = (U8)(t * 255);
                color = 0xFF000000 | (r << 16) | (g << 8) | b;
            }
            
            fractal_buffer[(y * fractal_width + x) * 4] = color & 0xFF;
            fractal_buffer[(y * fractal_width + x) * 4 + 1] = (color >> 8) & 0xFF;
            fractal_buffer[(y * fractal_width + x) * 4 + 2] = (color >> 16) & 0xFF;
            fractal_buffer[(y * fractal_width + x) * 4 + 3] = (color >> 24) & 0xFF;
        }
    }
}

U0 SierpinskiTriangle(I64 x, I64 y, I64 size, I64 depth)
{
    if (depth == 0) {
        for (I64 i = 0; i < size; i++) {
            for (I64 j = 0; j <= i; j++) {
                I64 px = x + j;
                I64 py = y + i;
                if (px >= 0 && px < fractal_width && py >= 0 && py < fractal_height) {
                    U32 color = 0xFFFFFFFF;
                    fractal_buffer[(py * fractal_width + px) * 4] = color & 0xFF;
                    fractal_buffer[(py * fractal_width + px) * 4 + 1] = (color >> 8) & 0xFF;
                    fractal_buffer[(py * fractal_width + px) * 4 + 2] = (color >> 16) & 0xFF;
                    fractal_buffer[(py * fractal_width + px) * 4 + 3] = (color >> 24) & 0xFF;
                }
            }
        }
    } else {
        SierpinskiTriangle(x, y, size/2, depth-1);
        SierpinskiTriangle(x + size/2, y, size/2, depth-1);
        SierpinskiTriangle(x + size/4, y + size/2, size/2, depth-1);
    }
}

U0 KochSnowflake(I64 x, I64 y, I64 size, I64 depth)
{
    if (depth == 0) {
        for (I64 i = 0; i < size; i++) {
            I64 px = x + i;
            I64 py = y;
            if (px >= 0 && px < fractal_width && py >= 0 && py < fractal_height) {
                U32 color = 0xFFFFFFFF;
                fractal_buffer[(py * fractal_width + px) * 4] = color & 0xFF;
                fractal_buffer[(py * fractal_width + px) * 4 + 1] = (color >> 8) & 0xFF;
                fractal_buffer[(py * fractal_width + px) * 4 + 2] = (color >> 16) & 0xFF;
                fractal_buffer[(py * fractal_width + px) * 4 + 3] = (color >> 24) & 0xFF;
            }
        }
    } else {
        KochSnowflake(x, y, size/3, depth-1);
        KochSnowflake(x + size/3, y, size/3, depth-1);
        KochSnowflake(x + 2*size/3, y, size/3, depth-1);
    }
}

U0 DrawFractalToScreen(U8 *screen, I64 screen_width)
{
    for (I64 y = 0; y < fractal_height; y++) {
        for (I64 x = 0; x < fractal_width; x++) {
            U32 color = *(U32*)&fractal_buffer[(y * fractal_width + x) * 4];
            GrPlot(screen, screen_width, x, y, color);
        }
    }
}

U0 FreeFractalBuffer()
{
    if (fractal_buffer) {
        Free(fractal_buffer);
        fractal_buffer = NULL;
    }
} 