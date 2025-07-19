#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int random_func1(int a, int b) { return a + b; }
void random_func2(char *s) { printf("%s\n", s); }
float random_func3(float x) { return x * 3.14f; }

int main() {
    int i, j, sum = 0;
    float f = 0.0f;
    char str[100] = "Hello, World!";
    for(i = 0; i < 10; i++) {
        sum += i;
        printf("i = %d, sum = %d\n", i, sum);
    }
    for(j = 0; j < 5; j++) {
        f += random_func3(j);
        printf("f = %f\n", f);
    }
    random_func2(str);
    srand(sum);
    int arr[50];
    for(i = 0; i < 50; i++) arr[i] = rand() % 1000;
    for(i = 0; i < 50; i++) printf("arr[%d] = %d\n", i, arr[i]);
    for(i = 0; i < 100; i++) {
        printf("Random value: %d\n", rand() % 100);
    }
    double d = 1.23;
    for(i = 0; i < 20; i++) {
        d *= 1.01;
        printf("d = %lf\n", d);
    }
    char *words[] = {"apple", "banana", "cherry", "date"};
    for(i = 0; i < 4; i++) {
        printf("word: %s\n", words[i]);
    }
    int matrix[10][10];
    for(i = 0; i < 10; i++) for(j = 0; j < 10; j++) matrix[i][j] = i * j;
    for(i = 0; i < 10; i++) {
        for(j = 0; j < 10; j++) {
            printf("%d ", matrix[i][j]);
        }
        printf("\n");
    }
    // --- More random code below ---
    int x = 0;
    for(i = 0; i < 200; i++) {
        x += i % 7;
        if(x % 13 == 0) printf("Lucky 13 at i=%d\n", i);
    }
    float arr2[100];
    for(i = 0; i < 100; i++) arr2[i] = (float)i / 3.0f;
    for(i = 0; i < 100; i++) printf("arr2[%d] = %f\n", i, arr2[i]);
    // --- Functions ---
    for(i = 0; i < 50; i++) {
        printf("random_func1(%d, %d) = %d\n", i, i+1, random_func1(i, i+1));
    }
    // --- End main ---
    return 0;
}

// --- More random functions ---
int multiply(int a, int b) { return a * b; }
float divide(float a, float b) { return b != 0 ? a / b : 0; }
void print_array(int *a, int n) {
    for(int i = 0; i < n; i++) printf("%d ", a[i]);
    printf("\n");
}
void fill_array(int *a, int n, int v) {
    for(int i = 0; i < n; i++) a[i] = v;
}
// --- More random code ---
#define PI 3.1415926535
#define SQUARE(x) ((x)*(x))

struct Point {
    int x, y;
};

void print_point(struct Point p) {
    printf("Point(%d, %d)\n", p.x, p.y);
}

void random_points() {
    struct Point pts[10];
    for(int i = 0; i < 10; i++) {
        pts[i].x = rand() % 100;
        pts[i].y = rand() % 100;
        print_point(pts[i]);
    }
}

int random_sum(int n) {
    int s = 0;
    for(int i = 0; i < n; i++) s += rand() % 100;
    return s;
}

void print_table(int rows, int cols) {
    for(int i = 0; i < rows; i++) {
        for(int j = 0; j < cols; j++) {
            printf("%d ", i * cols + j);
        }
        printf("\n");
    }
}

struct Data {
    int id;
    char name[32];
    float value;
};

void fill_data(struct Data *d, int n) {
    for(int i = 0; i < n; i++) {
        d[i].id = i;
        sprintf(d[i].name, "Item%d", i);
        d[i].value = (float)(rand() % 1000) / 10.0f;
    }
}

void print_data(const struct Data *d, int n) {
    for(int i = 0; i < n; i++) {
        printf("ID: %d, Name: %s, Value: %.2f\n", d[i].id, d[i].name, d[i].value);
    }
}

// --- More random loops and arrays ---
void random_matrix() {
    int m[20][20];
    for(int i = 0; i < 20; i++) for(int j = 0; j < 20; j++) m[i][j] = rand() % 100;
    for(int i = 0; i < 20; i++) {
        for(int j = 0; j < 20; j++) printf("%2d ", m[i][j]);
        printf("\n");
    }
}

// --- More random code to increase line count ---
void spam_prints() {
    for(int i = 0; i < 200; i++) printf("Spam line %d\n", i);
}

// --- More random functions ---
int factorial(int n) {
    if(n <= 1) return 1;
    return n * factorial(n-1);
}

void print_factorials(int n) {
    for(int i = 1; i <= n; i++) printf("%d! = %d\n", i, factorial(i));
}

// --- More random code ---
void fill_random_floats(float *a, int n) {
    for(int i = 0; i < n; i++) a[i] = (float)rand() / RAND_MAX;
}

void print_floats(const float *a, int n) {
    for(int i = 0; i < n; i++) printf("%.3f ", a[i]);
    printf("\n");
}

