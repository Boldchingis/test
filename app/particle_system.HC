#include "DCG.h"

typedef struct Particle {
    F64 x, y;
    F64 vx, vy;
    F64 life;
    F64 max_life;
    U32 color;
    struct Particle *next;
} Particle;

Particle *particle_list = NULL;

U0 CreateParticle(F64 x, F64 y, F64 vx, F64 vy, F64 life, U32 color)
{
    Particle *p = MAlloc(sizeof(Particle));
    p->x = x;
    p->y = y;
    p->vx = vx;
    p->vy = vy;
    p->life = life;
    p->max_life = life;
    p->color = color;
    p->next = particle_list;
    particle_list = p;
}

U0 UpdateParticles()
{
    Particle **p = &particle_list;
    while (*p) {
        (*p)->x += (*p)->vx;
        (*p)->y += (*p)->vy;
        (*p)->vy += 0.1;
        (*p)->life -= 1.0;
        
        if ((*p)->life <= 0) {
            Particle *to_remove = *p;
            *p = (*p)->next;
            Free(to_remove);
        } else {
            p = &(*p)->next;
        }
    }
}

U0 DrawParticles(U8 *screen, I64 width)
{
    Particle *p = particle_list;
    while (p) {
        F64 alpha = p->life / p->max_life;
        U32 color = (U32)(alpha * 255) << 24 | (p->color & 0xFFFFFF);
        GrPlot(screen, width, p->x, p->y, color);
        p = p->next;
    }
}

U0 CreateExplosion(F64 x, F64 y, I64 count)
{
    for (I64 i = 0; i < count; i++) {
        F64 angle = (RandU16 % 360) * 3.14159 / 180.0;
        F64 speed = 1.0 + (RandU16 % 50) / 10.0;
        F64 vx = Cos(angle) * speed;
        F64 vy = Sin(angle) * speed;
        F64 life = 30.0 + (RandU16 % 30);
        U32 color = 0xFF0000 + (RandU16 % 0xFFFF);
        CreateParticle(x, y, vx, vy, life, color);
    }
}

U0 CreateFirework(F64 x, F64 y)
{
    for (I64 i = 0; i < 20; i++) {
        F64 angle = (RandU16 % 360) * 3.14159 / 180.0;
        F64 speed = 2.0 + (RandU16 % 30) / 10.0;
        F64 vx = Cos(angle) * speed;
        F64 vy = Sin(angle) * speed;
        F64 life = 60.0 + (RandU16 % 40);
        U32 color = 0xFFFF00 + (RandU16 % 0xFF);
        CreateParticle(x, y, vx, vy, life, color);
    }
}

U0 FreeAllParticles()
{
    while (particle_list) {
        Particle *p = particle_list;
        particle_list = particle_list->next;
        Free(p);
    }
} 