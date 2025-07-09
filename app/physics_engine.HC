#include "DCG.h"

typedef struct Vector2D {
    F64 x, y;
} Vector2D;

typedef struct RigidBody {
    Vector2D position;
    Vector2D velocity;
    Vector2D acceleration;
    F64 mass;
    F64 radius;
    U32 color;
    struct RigidBody *next;
} RigidBody;

typedef struct Spring {
    RigidBody *body1;
    RigidBody *body2;
    F64 rest_length;
    F64 spring_constant;
    F64 damping;
} Spring;

RigidBody *bodies = NULL;
Spring *springs = NULL;
I64 num_springs = 0;
Vector2D gravity = {0.0, 9.81};

U0 VectorAdd(Vector2D *result, Vector2D *a, Vector2D *b)
{
    result->x = a->x + b->x;
    result->y = a->y + b->y;
}

U0 VectorSubtract(Vector2D *result, Vector2D *a, Vector2D *b)
{
    result->x = a->x - b->x;
    result->y = a->y - b->y;
}

U0 VectorScale(Vector2D *result, Vector2D *v, F64 scalar)
{
    result->x = v->x * scalar;
    result->y = v->y * scalar;
}

F64 VectorLength(Vector2D *v)
{
    return Sqrt(v->x * v->x + v->y * v->y);
}

U0 VectorNormalize(Vector2D *result, Vector2D *v)
{
    F64 length = VectorLength(v);
    if (length > 0.0001) {
        result->x = v->x / length;
        result->y = v->y / length;
    } else {
        result->x = 0.0;
        result->y = 0.0;
    }
}

U0 CreateBody(F64 x, F64 y, F64 mass, F64 radius, U32 color)
{
    RigidBody *body = MAlloc(sizeof(RigidBody));
    body->position.x = x;
    body->position.y = y;
    body->velocity.x = 0.0;
    body->velocity.y = 0.0;
    body->acceleration.x = 0.0;
    body->acceleration.y = 0.0;
    body->mass = mass;
    body->radius = radius;
    body->color = color;
    body->next = bodies;
    bodies = body;
}

U0 ApplyForce(RigidBody *body, Vector2D *force)
{
    body->acceleration.x += force->x / body->mass;
    body->acceleration.y += force->y / body->mass;
}

U0 UpdatePhysics(F64 dt)
{
    RigidBody *body = bodies;
    while (body) {
        body->velocity.x += body->acceleration.x * dt;
        body->velocity.y += body->acceleration.y * dt;
        body->position.x += body->velocity.x * dt;
        body->position.y += body->velocity.y * dt;
        
        body->acceleration.x = 0.0;
        body->acceleration.y = 0.0;
        
        ApplyForce(body, &gravity);
        
        body = body->next;
    }
}

U0 CheckCollisions()
{
    RigidBody *body1 = bodies;
    while (body1) {
        RigidBody *body2 = body1->next;
        while (body2) {
            Vector2D diff;
            VectorSubtract(&diff, &body1->position, &body2->position);
            F64 distance = VectorLength(&diff);
            F64 min_distance = body1->radius + body2->radius;
            
            if (distance < min_distance && distance > 0.0001) {
                Vector2D normal;
                VectorNormalize(&normal, &diff);
                
                F64 overlap = min_distance - distance;
                Vector2D correction;
                VectorScale(&correction, &normal, overlap * 0.5);
                
                body1->position.x += correction.x;
                body1->position.y += correction.y;
                body2->position.x -= correction.x;
                body2->position.y -= correction.y;
                
                Vector2D relative_velocity;
                VectorSubtract(&relative_velocity, &body1->velocity, &body2->velocity);
                F64 velocity_along_normal = relative_velocity.x * normal.x + relative_velocity.y * normal.y;
                
                if (velocity_along_normal < 0) {
                    F64 restitution = 0.8;
                    F64 j = -(1.0 + restitution) * velocity_along_normal;
                    j /= 1.0/body1->mass + 1.0/body2->mass;
                    
                    Vector2D impulse;
                    VectorScale(&impulse, &normal, j);
                    
                    body1->velocity.x += impulse.x / body1->mass;
                    body1->velocity.y += impulse.y / body1->mass;
                    body2->velocity.x -= impulse.x / body2->mass;
                    body2->velocity.y -= impulse.y / body2->mass;
                }
            }
            body2 = body2->next;
        }
        body1 = body1->next;
    }
}

U0 UpdateSprings()
{
    for (I64 i = 0; i < num_springs; i++) {
        Spring *spring = &springs[i];
        Vector2D diff;
        VectorSubtract(&diff, &spring->body2->position, &spring->body1->position);
        F64 distance = VectorLength(&diff);
        
        if (distance > 0.0001) {
            Vector2D force;
            VectorNormalize(&force, &diff);
            F64 displacement = distance - spring->rest_length;
            VectorScale(&force, &force, displacement * spring->spring_constant);
            
            Vector2D damping_force;
            Vector2D relative_velocity;
            VectorSubtract(&relative_velocity, &spring->body2->velocity, &spring->body1->velocity);
            VectorScale(&damping_force, &force, -spring->damping);
            
            VectorAdd(&force, &force, &damping_force);
            
            ApplyForce(spring->body1, &force);
            Vector2D negative_force;
            VectorScale(&negative_force, &force, -1.0);
            ApplyForce(spring->body2, &negative_force);
        }
    }
}

U0 DrawBodies(U8 *screen, I64 width)
{
    RigidBody *body = bodies;
    while (body) {
        for (I64 y = -body->radius; y <= body->radius; y++) {
            for (I64 x = -body->radius; x <= body->radius; x++) {
                if (x*x + y*y <= body->radius*body->radius) {
                    I64 px = body->position.x + x;
                    I64 py = body->position.y + y;
                    if (px >= 0 && px < width && py >= 0 && py < 600) {
                        GrPlot(screen, width, px, py, body->color);
                    }
                }
            }
        }
        body = body->next;
    }
}

U0 DrawSprings(U8 *screen, I64 width)
{
    for (I64 i = 0; i < num_springs; i++) {
        Spring *spring = &springs[i];
        GrLine(screen, width, 
               spring->body1->position.x, spring->body1->position.y,
               spring->body2->position.x, spring->body2->position.y, 
               0xFFFF0000);
    }
}

U0 AddSpring(RigidBody *body1, RigidBody *body2, F64 rest_length, F64 spring_constant, F64 damping)
{
    springs = ReAlloc(springs, (num_springs + 1) * sizeof(Spring));
    springs[num_springs].body1 = body1;
    springs[num_springs].body2 = body2;
    springs[num_springs].rest_length = rest_length;
    springs[num_springs].spring_constant = spring_constant;
    springs[num_springs].damping = damping;
    num_springs++;
}

U0 FreePhysics()
{
    while (bodies) {
        RigidBody *body = bodies;
        bodies = bodies->next;
        Free(body);
    }
    if (springs) {
        Free(springs);
        springs = NULL;
    }
    num_springs = 0;
} 