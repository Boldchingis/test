#include "DCG.h"

U8 *screen;
I64 width, height;
I64 score = 0;
I64 lives = 3;
F64 player_x, player_y;
F64 player_speed = 5.0;
F64 player_size = 20.0;
U0 PlayerDraw();
U0 EnemyDraw(F64 x, F64 y);
U0 DrawScore();
U0 DrawLives();
U0 DrawBorder();
U0 DrawStars();
U0 GameOver();
U0 ShowMenu();
U0 InitGame();
U0 UpdateGame();
U0 HandleInput();
U0 FireBullet();
U0 SpawnEnemy();
U0 CheckCollisions();

typedef struct Enemy {
    F64 x, y;
    F64 speed;
    I64 health;
    struct Enemy *next;
} Enemy;

Enemy *enemy_list = NULL;

typedef struct Bullet {
    F64 x, y;
    F64 speed;
    struct Bullet *next;
} Bullet;

Bullet *bullet_list = NULL;

typedef struct Star {
    F64 x, y;
    F64 speed;
    struct Star *next;
} Star;

Star *star_list = NULL;

U0 Main()
{
    I64 running = 1;
    I64 game_state = 0;
    width = 800;
    height = 600;
    screen = DCGInit(width, height, "Holy C Game");
    if (!screen) {
        "Failed to initialize graphics!\n";
        return;
    }
    RandSeed(GetTime());
    for (I64 i = 0; i < 100; i++) {
        Star *s = MAlloc(sizeof(Star));
        s->x = RandU16 % width;
        s->y = RandU16 % height;
        s->speed = 1.0 + (RandU16 % 100) / 100.0;
        s->next = star_list;
        star_list = s;
    }
    while (running) {
        MemSet(screen, 0, width * height * 4);
        switch (game_state) {
            case 0:
                ShowMenu();
                if (KeyHit) {
                    if (KeyScan == SC_ESC) {
                        running = 0;
                    } else if (KeyScan == SC_SPACE) {
                        InitGame();
                        game_state = 1;
                    }
                }
                break;
            case 1:
                HandleInput();
                UpdateGame();
                CheckCollisions();
                DrawStars();
                DrawBorder();
                DrawScore();
                DrawLives();
                PlayerDraw();
                Enemy *e = enemy_list;
                while (e) {
                    EnemyDraw(e->x, e->y);
                    e = e->next;
                }
                Bullet *b = bullet_list;
                while (b) {
                    GrLine(screen, width, b->x, b->y, b->x, b->y - 10, 0xFFFFFF00);
                    b = b->next;
                }
                if (lives <= 0) {
                    game_state = 2;
                }
                break;
            case 2:
                GameOver();
                if (KeyHit) {
                    if (KeyScan == SC_ESC) {
                        game_state = 0;
                    } else if (KeyScan == SC_SPACE) {
                        InitGame();
                        game_state = 1;
                    }
                }
                break;
        }
        DCGUpdate();
        if (KeyHit && KeyScan == SC_ESC && game_state == 0) {
            running = 0;
        }
        MSleep(16);
    }
    DCGClose();
}

U0 InitGame()
{
    while (enemy_list) {
        Enemy *e = enemy_list;
        enemy_list = enemy_list->next;
        Free(e);
    }
    while (bullet_list) {
        Bullet *b = bullet_list;
        bullet_list = bullet_list->next;
        Free(b);
    }
    player_x = width / 2;
    player_y = height - 50;
    score = 0;
    lives = 3;
}

U0 ShowMenu()
{
    GrPrint(screen, width, width/2 - 100, height/2 - 50, "HOLY C GAME", 0xFFFFFF00);
    GrPrint(screen, width, width/2 - 80, height/2 + 20, "Press SPACE to start", 0xFFFFFF00);
    GrPrint(screen, width, width/2 - 60, height/2 + 50, "ESC to quit", 0xFFFFFF00);
}

U0 GameOver()
{
    GrPrint(screen, width, width/2 - 80, height/2 - 50, "GAME OVER", 0xFF000000);
    GrPrint(screen, width, width/2 - 100, height/2, "Final Score: %d", score, 0xFFFFFF00);
    GrPrint(screen, width, width/2 - 120, height/2 + 40, "Press SPACE to restart", 0xFFFFFF00);
    GrPrint(screen, width, width/2 - 60, height/2 + 70, "ESC to menu", 0xFFFFFF00);
}

U0 PlayerDraw()
{
    GrLine(screen, width, player_x, player_y - player_size, 
           player_x - player_size/2, player_y + player_size/2, 0x00FF0000);
    GrLine(screen, width, player_x, player_y - player_size, 
           player_x + player_size/2, player_y + player_size/2, 0x00FF0000);
    GrLine(screen, width, player_x - player_size/2, player_y + player_size/2, 
           player_x + player_size/2, player_y + player_size/2, 0x00FF0000);
}

U0 EnemyDraw(F64 x, F64 y)
{
    GrLine(screen, width, x - 15, y - 15, x + 15, y - 15, 0xFF00FF00);
    GrLine(screen, width, x + 15, y - 15, x + 15, y + 15, 0xFF00FF00);
    GrLine(screen, width, x + 15, y + 15, x - 15, y + 15, 0xFF00FF00);
    GrLine(screen, width, x - 15, y + 15, x - 15, y - 15, 0xFF00FF00);
}

U0 DrawScore()
{
    GrPrint(screen, width, 20, 20, "Score: %d", score, 0xFFFFFF00);
}

U0 DrawLives()
{
    GrPrint(screen, width, width - 120, 20, "Lives: %d", lives, 0xFFFFFF00);
}

U0 DrawBorder()
{
    GrLine(screen, width, 0, 0, width-1, 0, 0xFFFFFF00);
    GrLine(screen, width, width-1, 0, width-1, height-1, 0xFFFFFF00);
    GrLine(screen, width, width-1, height-1, 0, height-1, 0xFFFFFF00);
    GrLine(screen, width, 0, height-1, 0, 0, 0xFFFFFF00);
}

U0 DrawStars()
{
    Star *s = star_list;
    while (s) {
        GrPlot(screen, width, s->x, s->y, 0xFFFFFFFF);
        s = s->next;
    }
}

U0 HandleInput()
{
    if (KeyIsDown(SC_LEFT)) {
        player_x -= player_speed;
        if (player_x < player_size/2) player_x = player_size/2;
    }
    if (KeyIsDown(SC_RIGHT)) {
        player_x += player_speed;
        if (player_x > width - player_size/2) player_x = width - player_size/2;
    }
    if (KeyHit && KeyScan == SC_SPACE) {
        FireBullet();
    }
}

U0 FireBullet()
{
    Bullet *b = MAlloc(sizeof(Bullet));
    b->x = player_x;
    b->y = player_y - player_size;
    b->speed = 10.0;
    b->next = bullet_list;
    bullet_list = b;
}

U0 SpawnEnemy()
{
    static I64 spawn_timer = 0;
    if (++spawn_timer > 30) {
        spawn_timer = 0;
        Enemy *e = MAlloc(sizeof(Enemy));
        e->x = 30 + (RandU16 % (width - 60));
        e->y = 30;
        e->speed = 1.0 + (RandU16 % 100) / 50.0;
        e->health = 1;
        e->next = enemy_list;
        enemy_list = e;
    }
}

U0 UpdateGame()
{
    Star *s = star_list;
    while (s) {
        s->y += s->speed;
        if (s->y > height) {
            s->y = 0;
            s->x = RandU16 % width;
        }
        s = s->next;
    }
    SpawnEnemy();
    Enemy **e = &enemy_list;
    while (*e) {
        (*e)->y += (*e)->speed;
        if ((*e)->y > height + 30) {
            Enemy *to_remove = *e;
            *e = (*e)->next;
            Free(to_remove);
            lives--;
        } else {
            e = &(*e)->next;
        }
    }
    Bullet **b = &bullet_list;
    while (*b) {
        (*b)->y -= (*b)->speed;
        if ((*b)->y < -10) {
            Bullet *to_remove = *b;
            *b = (*b)->next;
            Free(to_remove);
        } else {
            b = &(*b)->next;
        }
    }
}

U0 CheckCollisions()
{
    Bullet **b = &bullet_list;
    while (*b) {
        Enemy **e = &enemy_list;
        I64 hit = 0;
        while (*e && !hit) {
            F64 dx = (*b)->x - (*e)->x;
            F64 dy = (*b)->y - (*e)->y;
            F64 dist = Sqrt(dx*dx + dy*dy);
            if (dist < 20) {
                Enemy *enemy_to_remove = *e;
                *e = (*e)->next;
                Free(enemy_to_remove);
                Bullet *bullet_to_remove = *b;
                *b = (*b)->next;
                Free(bullet_to_remove);
                score += 10;
                hit = 1;
            } else {
                e = &(*e)->next;
            }
        }
        if (!hit) {
            b = &(*b)->next;
        }
    }
    Enemy *e = enemy_list;
    while (e) {
        F64 dx = player_x - e->x;
        F64 dy = player_y - e->y;
        F64 dist = Sqrt(dx*dx + dy*dy);
        if (dist < 25) {
            Enemy *next_enemy = e->next;
            Enemy **prev = &enemy_list;
            while (*prev != e) prev = &(*prev)->next;
            *prev = e->next;
            Free(e);
            lives--;
            e = next_enemy;
        } else {
            e = e->next;
        }
    }
}

U0 DrawCircle(I64 x, I64 y, I64 r, U32 color)
{
    for (I64 i = -r; i <= r; i++) {
        for (I64 j = -r; j <= r; j++) {
            if (i*i + j*j <= r*r) {
                GrPlot(screen, width, x + i, y + j, color);
            }
        }
    }
}

U0 DrawRect(I64 x, I64 y, I64 w, I64 h, U32 color)
{
    GrLine(screen, width, x, y, x + w, y, color);
    GrLine(screen, width, x + w, y, x + w, y + h, color);
    GrLine(screen, width, x + w, y + h, x, y + h, color);
    GrLine(screen, width, x, y + h, x, y, color);
}

U0 FillRect(I64 x, I64 y, I64 w, I64 h, U32 color)
{
    for (I64 i = 0; i < h; i++) {
        GrLine(screen, width, x, y + i, x + w, y + i, color);
    }
}

F64 Distance(F64 x1, F64 y1, F64 x2, F64 y2)
{
    F64 dx = x2 - x1;
    F64 dy = y2 - y1;
    return Sqrt(dx*dx + dy*dy);
}

F64 Lerp(F64 a, F64 b, F64 t)
{
    return a + t * (b - a);
}

I64 RandomRange(I64 min, I64 max)
{
    return min + (RandU16 % (max - min + 1));
}

F64 RandomF64(F64 min, F64 max)
{
    return min + (RandU16 % 10000) / 10000.0 * (max - min);
}

U0 FreeEnemies()
{
    while (enemy_list) {
        Enemy *e = enemy_list;
        enemy_list = enemy_list->next;
        Free(e);
    }
}

U0 FreeBullets()
{
    while (bullet_list) {
        Bullet *b = bullet_list;
        bullet_list = bullet_list->next;
        Free(b);
    }
}

U0 FreeStars()
{
    while (star_list) {
        Star *s = star_list;
        star_list = star_list->next;
        Free(s);
    }
}

U0 PrintEnemyCount()
{
    I64 count = 0;
    Enemy *e = enemy_list;
    while (e) {
        count++;
        e = e->next;
    }
    "Enemies: %d\n", count;
}

U0 PrintBulletCount()
{
    I64 count = 0;
    Bullet *b = bullet_list;
    while (b) {
        count++;
        b = b->next;
    }
    "Bullets: %d\n", count;
}

U0 PauseGame()
{
    while (!KeyHit || KeyScan != SC_SPACE) {
        GrPrint(screen, width, width/2 - 50, height/2, "PAUSED", 0xFFFFFF00);
        GrPrint(screen, width, width/2 - 100, height/2 + 40, "Press SPACE to continue", 0xFFFFFF00);
        DCGUpdate();
        MSleep(16);
    }
}

U0 ShowHelp()
{
    GrPrint(screen, width, 50, 50, "CONTROLS:", 0xFFFFFF00);
    GrPrint(screen, width, 50, 80, "LEFT/RIGHT - Move ship", 0xFFFFFF00);
    GrPrint(screen, width, 50, 110, "SPACE - Fire", 0xFFFFFF00);
    GrPrint(screen, width, 50, 140, "ESC - Quit", 0xFFFFFF00);
    GrPrint(screen, width, 50, 200, "OBJECTIVE:", 0xFFFFFF00);
    GrPrint(screen, width, 50, 230, "Shoot enemies to score points", 0xFFFFFF00);
    GrPrint(screen, width, 50, 260, "Avoid being hit by enemies", 0xFFFFFF00);
    GrPrint(screen, width, width/2 - 50, height - 50, "Press any key to continue", 0xFFFFFF00);
    DCGUpdate();
    while (!KeyHit) MSleep(16);
}

U0 DrawTitleScreen()
{
    FillRect(0, 0, width, height, 0x00000000);
    GrPrint(screen, width, width/2 - 150, height/2 - 100, "TEMPLEOS GAME DEMO", 0xFF00FFFF);
    DrawCircle(width/2, height/2, 100, 0x00FF00FF);
    GrPrint(screen, width, width/2 - 80, height/2 + 150, "Press SPACE to start", 0xFFFFFFFF);
    DCGUpdate();
}

U0 DrawLoadingScreen(I64 progress)
{
    FillRect(0, 0, width, height, 0x00000000);
    GrPrint(screen, width, width/2 - 50, height/2 - 20, "LOADING...", 0xFFFFFFFF);
    FillRect(width/4, height/2, width/2 * progress / 100, 20, 0xFF0000FF);
    DrawRect(width/4, height/2, width/2, 20, 0xFFFFFFFF);
    DCGUpdate();
}

U0 PlayBeep(I64 freq, I64 duration)
{
    Beep(freq, duration);
}

U0 PlayShootSound()
{
    PlayBeep(1000, 50);
}

U0 PlayExplosionSound()
{
    PlayBeep(500, 100);
}

U0 PlayGameOverSound()
{
    for (I64 i = 0; i < 3; i++) {
        PlayBeep(300, 200);
        MSleep(100);
    }
}

U0 SpawnPowerup()
{
}

U0 CheckPowerupCollisions()
{
}

U0 ApplyPowerup(I64 type)
{
}

U0 SpawnBigEnemy()
{
}

U0 SpawnFastEnemy()
{
}

U0 UpdateEnemyMovement(Enemy *e)
{
    e->y += e->speed;
}

typedef struct Particle {
    F64 x, y;
    F64 dx, dy;
    I64 life;
    U32 color;
    struct Particle *next;
} Particle;

Particle *particle_list = NULL;

U0 CreateExplosion(F64 x, F64 y, U32 color, I64 count)
{
    for (I64 i = 0; i < count; i++) {
        Particle *p = MAlloc(sizeof(Particle));
        p->x = x;
        p->y = y;
        p->dx = RandomF64(-3, 3);
        p->dy = RandomF64(-3, 3);
        p->life = RandomRange(30, 60);
        p->color = color;
        p->next = particle_list;
        particle_list = p;
    }
}

U0 UpdateParticles()
{
    Particle **p = &particle_list;
    while (*p) {
        (*p)->x += (*p)->dx;
        (*p)->y += (*p)->dy;
        (*p)->life--;
        if ((*p)->life <= 0) {
            Particle *to_remove = *p;
            *p = (*p)->next;
            Free(to_remove);
        } else {
            GrPlot(screen, width, (*p)->x, (*p)->y, (*p)->color);
            p = &(*p)->next;
        }
    }
}

I64 high_score = 0;

U0 LoadHighScore()
{
    high_score = 0;
}

U0 SaveHighScore()
{
}

U0 CheckHighScore()
{
    if (score > high_score) {
        high_score = score;
        SaveHighScore();
    }
}

U0 ShowOptionsMenu()
{
}

U0 ShowHighScores()
{
}

U0 CenterPrint(F64 y, U8 *text, U32 color)
{
    I64 len = StrLen(text);
    GrPrint(screen, width, width/2 - len*4, y, text, color);
}

U0 DrawHealthBar(I64 x, I64 y, I64 w, I64 h, I64 current, I64 max, U32 color)
{
    FillRect(x, y, w * current / max, h, color);
    DrawRect(x, y, w, h, 0xFFFFFF00);
}

U0 ShowLevelComplete()
{
}

U0 ShowCutscene()
{
}

U0 CheckPixelPerfectCollision()
{
}

U0 ImplementShield()
{
}

U0 ImplementWeaponUpgrades()
{
}

U0 ProcessFrame()
{
}

U0 HandleEvents()
{
}

U0 CleanupAll()
{
    FreeEnemies();
    FreeBullets();
    FreeStars();
    while (particle_list) {
        Particle *p = particle_list;
        particle_list = particle_list->next;
        Free(p);
    }
}

U0 _start()
{
    Main();
    CleanupAll();
}