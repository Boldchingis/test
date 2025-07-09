#include "DCG.h"
#include "particle_system.HC"
#include "audio_system.HC"
#include "fractal_generator.HC"
#include "physics_engine.HC"

U8 *screen;
I64 width = 800, height = 600;
I64 demo_state = 0;
I64 frame_count = 0;

U0 DemoMain()
{
    screen = DCGInit(width, height, "HolyC Demo");
    if (!screen) {
        "Failed to initialize graphics!\n";
        return;
    }
    
    RandSeed(GetTime());
    InitFractalBuffer(width, height);
    
    I64 running = 1;
    while (running) {
        MemSet(screen, 0, width * height * 4);
        
        switch (demo_state) {
            case 0:
                DrawMenu();
                break;
            case 1:
                ParticleDemo();
                break;
            case 2:
                FractalDemo();
                break;
            case 3:
                PhysicsDemo();
                break;
            case 4:
                AudioDemo();
                break;
        }
        
        if (KeyHit) {
            if (KeyScan == SC_ESC) {
                running = 0;
            } else if (KeyScan == SC_1) {
                demo_state = 1;
                frame_count = 0;
            } else if (KeyScan == SC_2) {
                demo_state = 2;
                frame_count = 0;
            } else if (KeyScan == SC_3) {
                demo_state = 3;
                frame_count = 0;
            } else if (KeyScan == SC_4) {
                demo_state = 4;
                frame_count = 0;
            } else if (KeyScan == SC_0) {
                demo_state = 0;
                frame_count = 0;
            }
        }
        
        DCGUpdate();
        MSleep(16);
        frame_count++;
    }
    
    FreeAllParticles();
    FreeFractalBuffer();
    FreePhysics();
    FreeAllAudio();
    DCGClose();
}

U0 DrawMenu()
{
    GrPrint(screen, width, width/2 - 100, 100, "HOLY C DEMO", 0xFFFFFF00);
    GrPrint(screen, width, width/2 - 80, 200, "Press 1 - Particle System", 0xFFFFFF00);
    GrPrint(screen, width, width/2 - 80, 230, "Press 2 - Fractal Generator", 0xFFFFFF00);
    GrPrint(screen, width, width/2 - 80, 260, "Press 3 - Physics Engine", 0xFFFFFF00);
    GrPrint(screen, width, width/2 - 80, 290, "Press 4 - Audio System", 0xFFFFFF00);
    GrPrint(screen, width, width/2 - 80, 350, "ESC to quit", 0xFFFFFF00);
}

U0 ParticleDemo()
{
    if (frame_count % 30 == 0) {
        CreateExplosion(width/2 + (RandU16 % 200 - 100), height/2 + (RandU16 % 200 - 100), 20);
    }
    
    if (frame_count % 60 == 0) {
        CreateFirework(RandU16 % width, RandU16 % height);
    }
    
    UpdateParticles();
    DrawParticles(screen, width);
    
    GrPrint(screen, width, 20, 20, "Particle System Demo", 0xFFFFFF00);
    GrPrint(screen, width, 20, 50, "Press 0 for menu", 0xFFFFFF00);
}

U0 FractalDemo()
{
    static F64 zoom = 1.0;
    static F64 center_x = -0.5;
    static F64 center_y = 0.0;
    
    if (frame_count == 0) {
        MandelbrotSet(center_x, center_y, zoom, 100);
    }
    
    if (frame_count % 300 == 0) {
        zoom *= 1.5;
        MandelbrotSet(center_x, center_y, zoom, 100);
    }
    
    DrawFractalToScreen(screen, width);
    
    GrPrint(screen, width, 20, 20, "Fractal Demo - Mandelbrot Set", 0xFFFFFF00);
    GrPrint(screen, width, 20, 50, "Press 0 for menu", 0xFFFFFF00);
}

U0 PhysicsDemo()
{
    static I64 initialized = 0;
    
    if (!initialized) {
        for (I64 i = 0; i < 10; i++) {
            CreateBody(100 + i * 60, 100, 1.0, 15, 0xFF0000FF);
        }
        initialized = 1;
    }
    
    UpdatePhysics(0.016);
    UpdateSprings();
    CheckCollisions();
    
    DrawBodies(screen, width);
    DrawSprings(screen, width);
    
    GrPrint(screen, width, 20, 20, "Physics Engine Demo", 0xFFFFFF00);
    GrPrint(screen, width, 20, 50, "Press 0 for menu", 0xFFFFFF00);
}

U0 AudioDemo()
{
    static I64 last_play = 0;
    
    if (frame_count - last_play > 60) {
        I64 frequencies[] = {440, 554, 659, 880};
        I64 durations[] = {200, 200, 200, 400};
        PlayMelody(frequencies, durations, 4);
        last_play = frame_count;
    }
    
    for (I64 i = 0; i < 5; i++) {
        I64 x = 100 + i * 120;
        I64 y = 200 + Sin(frame_count * 0.1 + i) * 50;
        GrPrint(screen, width, x, y, "♪", 0xFFFF00FF);
    }
    
    GrPrint(screen, width, 20, 20, "Audio System Demo", 0xFFFFFF00);
    GrPrint(screen, width, 20, 50, "Press 0 for menu", 0xFFFFFF00);
}

U0 Main()
{
    DemoMain();
} 