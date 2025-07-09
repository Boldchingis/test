#include "DCG.h"

typedef struct Vector3D {
    F64 x, y, z;
} Vector3D;

typedef struct Sphere {
    Vector3D center;
    F64 radius;
    U32 color;
    F64 reflectivity;
} Sphere;

typedef struct Light {
    Vector3D position;
    F64 intensity;
} Light;

Sphere *spheres = NULL;
I64 num_spheres = 0;
Light *lights = NULL;
I64 num_lights = 0;
U8 *ray_buffer = NULL;
I64 ray_width, ray_height;

U0 Vector3DAdd(Vector3D *result, Vector3D *a, Vector3D *b)
{
    result->x = a->x + b->x;
    result->y = a->y + b->y;
    result->z = a->z + b->z;
}

U0 Vector3DSubtract(Vector3D *result, Vector3D *a, Vector3D *b)
{
    result->x = a->x - b->x;
    result->y = a->y - b->y;
    result->z = a->z - b->z;
}

U0 Vector3DScale(Vector3D *result, Vector3D *v, F64 scalar)
{
    result->x = v->x * scalar;
    result->y = v->y * scalar;
    result->z = v->z * scalar;
}

F64 Vector3DDot(Vector3D *a, Vector3D *b)
{
    return a->x * b->x + a->y * b->y + a->z * b->z;
}

F64 Vector3DLength(Vector3D *v)
{
    return Sqrt(v->x * v->x + v->y * v->y + v->z * v->z);
}

U0 Vector3DNormalize(Vector3D *result, Vector3D *v)
{
    F64 length = Vector3DLength(v);
    if (length > 0.0001) {
        result->x = v->x / length;
        result->y = v->y / length;
        result->z = v->z / length;
    } else {
        result->x = 0.0;
        result->y = 0.0;
        result->z = 0.0;
    }
}

U0 InitRaytracer(I64 width, I64 height)
{
    ray_width = width;
    ray_height = height;
    ray_buffer = MAlloc(width * height * 4);
}

U0 AddSphere(F64 x, F64 y, F64 z, F64 radius, U32 color, F64 reflectivity)
{
    spheres = ReAlloc(spheres, (num_spheres + 1) * sizeof(Sphere));
    spheres[num_spheres].center.x = x;
    spheres[num_spheres].center.y = y;
    spheres[num_spheres].center.z = z;
    spheres[num_spheres].radius = radius;
    spheres[num_spheres].color = color;
    spheres[num_spheres].reflectivity = reflectivity;
    num_spheres++;
}

U0 AddLight(F64 x, F64 y, F64 z, F64 intensity)
{
    lights = ReAlloc(lights, (num_lights + 1) * sizeof(Light));
    lights[num_lights].position.x = x;
    lights[num_lights].position.y = y;
    lights[num_lights].position.z = z;
    lights[num_lights].intensity = intensity;
    num_lights++;
}

F64 RaySphereIntersection(Vector3D *ray_origin, Vector3D *ray_direction, Sphere *sphere)
{
    Vector3D oc;
    Vector3DSubtract(&oc, ray_origin, &sphere->center);
    
    F64 a = Vector3DDot(ray_direction, ray_direction);
    F64 b = 2.0 * Vector3DDot(&oc, ray_direction);
    F64 c = Vector3DDot(&oc, &oc) - sphere->radius * sphere->radius;
    
    F64 discriminant = b * b - 4 * a * c;
    if (discriminant < 0) return -1.0;
    
    F64 t1 = (-b - Sqrt(discriminant)) / (2.0 * a);
    F64 t2 = (-b + Sqrt(discriminant)) / (2.0 * a);
    
    if (t1 > 0.0001) return t1;
    if (t2 > 0.0001) return t2;
    return -1.0;
}

U32 TraceRay(Vector3D *ray_origin, Vector3D *ray_direction, I64 depth)
{
    if (depth > 5) return 0x00000000;
    
    F64 closest_t = 1e10;
    Sphere *closest_sphere = NULL;
    
    for (I64 i = 0; i < num_spheres; i++) {
        F64 t = RaySphereIntersection(ray_origin, ray_direction, &spheres[i]);
        if (t > 0.0001 && t < closest_t) {
            closest_t = t;
            closest_sphere = &spheres[i];
        }
    }
    
    if (!closest_sphere) return 0x00000000;
    
    Vector3D hit_point;
    Vector3DScale(&hit_point, ray_direction, closest_t);
    Vector3DAdd(&hit_point, ray_origin, &hit_point);
    
    Vector3D normal;
    Vector3DSubtract(&normal, &hit_point, &closest_sphere->center);
    Vector3DNormalize(&normal, &normal);
    
    U32 color = 0x00000000;
    
    for (I64 i = 0; i < num_lights; i++) {
        Vector3D light_dir;
        Vector3DSubtract(&light_dir, &lights[i].position, &hit_point);
        Vector3DNormalize(&light_dir, &light_dir);
        
        F64 diffuse = Vector3DDot(&normal, &light_dir);
        if (diffuse < 0) diffuse = 0;
        
        F64 distance = Vector3DLength(&light_dir);
        F64 attenuation = 1.0 / (1.0 + distance * distance);
        
        U8 r = (U8)((closest_sphere->color >> 16) & 0xFF);
        U8 g = (U8)((closest_sphere->color >> 8) & 0xFF);
        U8 b = (U8)(closest_sphere->color & 0xFF);
        
        r = (U8)(r * diffuse * attenuation * lights[i].intensity);
        g = (U8)(g * diffuse * attenuation * lights[i].intensity);
        b = (U8)(b * diffuse * attenuation * lights[i].intensity);
        
        color |= (r << 16) | (g << 8) | b;
    }
    
    if (closest_sphere->reflectivity > 0.0) {
        Vector3D reflection;
        F64 dot = Vector3DDot(ray_direction, &normal);
        Vector3DScale(&reflection, &normal, 2.0 * dot);
        Vector3DSubtract(&reflection, ray_direction, &reflection);
        
        U32 reflected_color = TraceRay(&hit_point, &reflection, depth + 1);
        U32 final_color = 0;
        
        for (I64 i = 0; i < 3; i++) {
            U8 c1 = (color >> (i * 8)) & 0xFF;
            U8 c2 = (reflected_color >> (i * 8)) & 0xFF;
            U8 final = (U8)(c1 * (1.0 - closest_sphere->reflectivity) + 
                           c2 * closest_sphere->reflectivity);
            final_color |= final << (i * 8);
        }
        
        color = final_color;
    }
    
    return color;
}

U0 RenderScene()
{
    Vector3D camera_pos = {0.0, 0.0, -5.0};
    F64 fov = 0.5;
    
    for (I64 y = 0; y < ray_height; y++) {
        for (I64 x = 0; x < ray_width; x++) {
            F64 px = (F64)(x - ray_width/2) / ray_width * fov;
            F64 py = (F64)(y - ray_height/2) / ray_height * fov;
            
            Vector3D ray_direction = {px, py, 1.0};
            Vector3DNormalize(&ray_direction, &ray_direction);
            
            U32 color = TraceRay(&camera_pos, &ray_direction, 0);
            
            ray_buffer[(y * ray_width + x) * 4] = color & 0xFF;
            ray_buffer[(y * ray_width + x) * 4 + 1] = (color >> 8) & 0xFF;
            ray_buffer[(y * ray_width + x) * 4 + 2] = (color >> 16) & 0xFF;
            ray_buffer[(y * ray_width + x) * 4 + 3] = (color >> 24) & 0xFF;
        }
    }
}

U0 DrawRaytracerToScreen(U8 *screen, I64 screen_width)
{
    for (I64 y = 0; y < ray_height; y++) {
        for (I64 x = 0; x < ray_width; x++) {
            U32 color = *(U32*)&ray_buffer[(y * ray_width + x) * 4];
            GrPlot(screen, screen_width, x, y, color);
        }
    }
}

U0 SetupDemoScene()
{
    AddSphere(0.0, 0.0, 0.0, 1.0, 0xFF0000FF, 0.3);
    AddSphere(2.0, 0.0, 0.0, 0.5, 0x00FF00FF, 0.5);
    AddSphere(-2.0, 0.0, 0.0, 0.7, 0x0000FFFF, 0.2);
    AddSphere(0.0, -2.0, 0.0, 0.8, 0xFFFF00FF, 0.4);
    
    AddLight(5.0, 5.0, -5.0, 1.0);
    AddLight(-5.0, 3.0, -3.0, 0.5);
}

U0 FreeRaytracer()
{
    if (spheres) {
        Free(spheres);
        spheres = NULL;
    }
    if (lights) {
        Free(lights);
        lights = NULL;
    }
    if (ray_buffer) {
        Free(ray_buffer);
        ray_buffer = NULL;
    }
    num_spheres = 0;
    num_lights = 0;
} 