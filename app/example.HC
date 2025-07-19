U0 main() {
    I32 n = 10, t1 = 0, t2 = 1, next, i;
    "Fibonacci Series up to 10 terms:\n";
    for (i = 1; i <= n; ++i) {
        "%d\n", t1;
        next = t1 + t2;
        t1 = t2;
        t2 = next;
    }
} 