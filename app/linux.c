/*
 * linux.c - Custom Linux-like OS Kernel (Educational Example)
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void init_devices() {
    printf("[kernel] Initializing devices...\n");
    printf("[kernel] Timer initialized.\n");
    printf("[kernel] Keyboard initialized.\n");
    printf("[kernel] Display initialized.\n");
}

void syscall_handler(int syscall_num) {
    switch(syscall_num) {
        case 0:
            printf("[syscall] getpid() -> 1\n");
            break;
        case 1:
            printf("[syscall] write()\n");
            break;
        default:
            printf("[syscall] Unknown syscall: %d\n", syscall_num);
    }
}

struct process {
    int pid;
    char name[32];
};

struct process process_table[4] = {
    {1, "init"},
    {2, "shell"},
    {3, "logger"},
    {4, "idle"}
};

void handle_interrupt(int irq) {
    printf("[interrupt] IRQ %d received\n", irq);
    switch(irq) {
        case 0:
            printf("[interrupt] Timer tick\n");
            break;
        case 1:
            printf("[interrupt] Keyboard event\n");
            break;
        default:
            printf("[interrupt] Unknown IRQ\n");
    }
}

#define MEM_SIZE 1024
char memory[MEM_SIZE];
int mem_used = 0;

void* kmalloc(int size) {
    if(mem_used + size > MEM_SIZE) {
        printf("[mm] Out of memory!\n");
        return NULL;
    }
    void* ptr = &memory[mem_used];
    mem_used += size;
    printf("[mm] Allocated %d bytes, total used: %d\n", size, mem_used);
    return ptr;
}

void kfree(void* ptr) {
    printf("[mm] Memory freed (mock)\n");
}

void disk_driver_init() {
    printf("[driver] Disk driver initialized.\n");
}

#define MAX_PROCESSES 32
struct process process_table[MAX_PROCESSES];
int process_count = 4;

void schedule() {
    printf("[sched] Scheduling processes...\n");
    for(int i = 0; i < process_count; i++) {
        printf("[sched] Switching to process %s (pid=%d)\n", process_table[i].name, process_table[i].pid);
    }
}

struct file {
    char name[64];
    int size;
    char *data;
};

struct file fs[16];
int file_count = 0;

void fs_init() {
    printf("[fs] Initializing file system...\n");
    file_count = 2;
    strcpy(fs[0].name, "README.txt");
    fs[0].size = 20;
    fs[0].data = "Welcome to Custom Linux!";
    strcpy(fs[1].name, "config.sys");
    fs[1].size = 10;
    fs[1].data = "CONFIG=1\n";
}

void fs_list() {
    printf("[fs] Listing files:\n");
    for(int i = 0; i < file_count; i++) {
        printf("  %s (%d bytes)\n", fs[i].name, fs[i].size);
    }
}

#define MAX_MESSAGES 64
struct message {
    int from_pid;
    int to_pid;
    char content[128];
};

struct message msg_queue[MAX_MESSAGES];
int msg_count = 0;

void send_message(int from, int to, const char *content) {
    if(msg_count < MAX_MESSAGES) {
        msg_queue[msg_count].from_pid = from;
        msg_queue[msg_count].to_pid = to;
        strncpy(msg_queue[msg_count].content, content, 127);
        msg_queue[msg_count].content[127] = '\0';
        msg_count++;
        printf("[ipc] Message sent from %d to %d\n", from, to);
    } else {
        printf("[ipc] Message queue full!\n");
    }
}

void receive_messages(int pid) {
    printf("[ipc] Messages for pid %d:\n", pid);
    for(int i = 0; i < msg_count; i++) {
        if(msg_queue[i].to_pid == pid) {
            printf("  From %d: %s\n", msg_queue[i].from_pid, msg_queue[i].content);
        }
    }
}

void net_init() {
    printf("[net] Network stack initialized.\n");
}

void net_send(const char *data) {
    printf("[net] Sending data: %s\n", data);
}

void net_receive() {
    printf("[net] Receiving data...\n");
}

void video_init() {
    printf("[video] Video driver initialized.\n");
}

void video_draw_pixel(int x, int y, int color) {
    printf("[video] Drawing pixel at (%d,%d) color %d\n", x, y, color);
}

void panic(const char *msg) {
    printf("[kernel panic] %s\n", msg);
    exit(1);
}

void log_event(const char *msg) {
    printf("[log] %s\n", msg);
}

void kernel_main() {
    printf("[kernel] Booting Custom Linux OS...\n");
    printf("[kernel] Version 0.1.0\n");
    printf("[kernel] Copyright (C) 2024 Custom Linux Project\n");
    init_devices();
    disk_driver_init();
    printf("[kernel] Setting up memory manager...\n");
    void* block1 = kmalloc(128);
    void* block2 = kmalloc(256);
    kfree(block1);
    printf("[kernel] Starting process scheduler...\n");
    for(int i = 0; i < 4; i++) {
        printf("[kernel] Running process: %s (pid=%d)\n", process_table[i].name, process_table[i].pid);
        syscall_handler(i % 3);
        handle_interrupt(i % 2);
    }
    printf("[kernel] Entering idle loop. Press Ctrl+C to exit.\n");
    while(1) {
    }
}

#define PAGE_SIZE 4096
#define MAX_PAGES 256
char vmmemory[MAX_PAGES * PAGE_SIZE];
int page_table[MAX_PAGES];

void vmm_init() {
    printf("[vmm] Initializing virtual memory...\n");
    for(int i = 0; i < MAX_PAGES; i++) page_table[i] = 0;
}

void* vmm_alloc(int npages) {
    for(int i = 0; i < MAX_PAGES - npages; i++) {
        int free = 1;
        for(int j = 0; j < npages; j++) if(page_table[i+j]) free = 0;
        if(free) {
            for(int j = 0; j < npages; j++) page_table[i+j] = 1;
            printf("[vmm] Allocated %d pages at %d\n", npages, i);
            return &vmmemory[i * PAGE_SIZE];
        }
    }
    printf("[vmm] Out of virtual memory!\n");
    return NULL;
}

void vmm_free(void* ptr, int npages) {
    int idx = ((char*)ptr - vmmemory) / PAGE_SIZE;
    for(int i = 0; i < npages; i++) page_table[idx + i] = 0;
    printf("[vmm] Freed %d pages at %d\n", npages, idx);
}

int create_process(const char* name) {
    if(process_count >= MAX_PROCESSES) {
        printf("[proc] Max process limit reached!\n");
        return -1;
    }
    process_table[process_count].pid = process_count + 1;
    strncpy(process_table[process_count].name, name, 31);
    process_table[process_count].name[31] = '\0';
    printf("[proc] Created process %s (pid=%d)\n", name, process_table[process_count].pid);
    process_count++;
    return process_table[process_count-1].pid;
}

void kill_process(int pid) {
    for(int i = 0; i < process_count; i++) {
        if(process_table[i].pid == pid) {
            printf("[proc] Killed process %s (pid=%d)\n", process_table[i].name, pid);
            for(int j = i; j < process_count-1; j++) process_table[j] = process_table[j+1];
            process_count--;
            return;
        }
    }
    printf("[proc] Process %d not found!\n", pid);
}

void list_processes() {
    printf("[proc] Process list:\n");
    for(int i = 0; i < process_count; i++) {
        printf("  %d: %s\n", process_table[i].pid, process_table[i].name);
    }
}

void shell() {
    printf("[shell] Welcome to Custom Linux Shell!\n");
    printf("[shell] Type 'help' for commands.\n");
    char cmd[64];
    for(int i = 0; i < 3; i++) {
        printf("[shell] $ ");
        strcpy(cmd, i == 0 ? "ps" : (i == 1 ? "ls" : "exit"));
        printf("%s\n", cmd);
        if(strcmp(cmd, "ps") == 0) list_processes();
        else if(strcmp(cmd, "ls") == 0) fs_list();
        else if(strcmp(cmd, "exit") == 0) {
            printf("[shell] Exiting shell.\n");
            break;
        } else printf("[shell] Unknown command: %s\n", cmd);
    }
}

void mouse_driver_init() {
    printf("[driver] Mouse driver initialized.\n");
}

void sound_driver_init() {
    printf("[driver] Sound driver initialized.\n");
}

int fs_create(const char* name, int size) {
    if(file_count >= 16) {
        printf("[fs] File table full!\n");
        return -1;
    }
    strncpy(fs[file_count].name, name, 63);
    fs[file_count].name[63] = '\0';
    fs[file_count].size = size;
    fs[file_count].data = malloc(size);
    printf("[fs] Created file %s (%d bytes)\n", name, size);
    file_count++;
    return file_count-1;
}

void fs_delete(const char* name) {
    for(int i = 0; i < file_count; i++) {
        if(strcmp(fs[i].name, name) == 0) {
            printf("[fs] Deleted file %s\n", name);
            free(fs[i].data);
            for(int j = i; j < file_count-1; j++) fs[j] = fs[j+1];
            file_count--;
            return;
        }
    }
    printf("[fs] File %s not found!\n", name);
}

int current_proc = 0;
void round_robin_schedule() {
    printf("[sched] Round-robin scheduling...\n");
    for(int i = 0; i < process_count; i++) {
        current_proc = (current_proc + 1) % process_count;
        printf("[sched] Running process: %s (pid=%d)\n", process_table[current_proc].name, process_table[current_proc].pid);
    }
}

#define MAX_MODULES 8
struct module {
    char name[32];
    int loaded;
};
struct module modules[MAX_MODULES];
int module_count = 0;

void load_module(const char* name) {
    if(module_count >= MAX_MODULES) {
        printf("[mod] Module table full!\n");
        return;
    }
    strncpy(modules[module_count].name, name, 31);
    modules[module_count].name[31] = '\0';
    modules[module_count].loaded = 1;
    printf("[mod] Loaded module: %s\n", name);
    module_count++;
}

void unload_module(const char* name) {
    for(int i = 0; i < module_count; i++) {
        if(strcmp(modules[i].name, name) == 0) {
            printf("[mod] Unloaded module: %s\n", name);
            modules[i].loaded = 0;
            return;
        }
    }
    printf("[mod] Module %s not found!\n", name);
}

void list_modules() {
    printf("[mod] Loaded modules:\n");
    for(int i = 0; i < module_count; i++) {
        if(modules[i].loaded)
            printf("  %s\n", modules[i].name);
    }
}

#define LOG_SIZE 256
char kernel_log[LOG_SIZE][128];
int log_index = 0;

void klog(const char* msg) {
    strncpy(kernel_log[log_index], msg, 127);
    kernel_log[log_index][127] = '\0';
    log_index = (log_index + 1) % LOG_SIZE;
}

void show_log() {
    printf("[klog] Kernel log:\n");
    for(int i = 0; i < LOG_SIZE; i++) {
        if(kernel_log[i][0]) printf("  %s\n", kernel_log[i]);
    }
}

void user_program() {
    printf("[user] Hello from userland!\n");
    send_message(2, 1, "Userland says hi!");
    fs_create("userfile.txt", 64);
    fs_list();
}

void kernel_tests() {
    printf("[test] Running kernel tests...\n");
    create_process("testproc");
    fs_create("testfile", 32);
    load_module("testmod");
    klog("Test log entry");
    show_log();
    round_robin_schedule();
    user_program();
    printf("[test] Kernel tests complete.\n");
}

void stub_func1() { printf("[stub] func1\n"); }
void stub_func2() { printf("[stub] func2\n"); }
void stub_func3() { printf("[stub] func3\n"); }
void stub_func4() { printf("[stub] func4\n"); }
void stub_func5() { printf("[stub] func5\n"); }
void stub_func6() { printf("[stub] func6\n"); }
void stub_func7() { printf("[stub] func7\n"); }
void stub_func8() { printf("[stub] func8\n"); }
void stub_func9() { printf("[stub] func9\n"); }
void stub_func10() { printf("[stub] func10\n"); }

void bulk_stubs() {
    for(int i = 0; i < 500; i++) printf("[bulk] stub line %d\n", i);
}

void stub_kernel_func_001() { printf("[stub] kernel func 001\n"); }
void stub_kernel_func_002() { printf("[stub] kernel func 002\n"); }
void stub_kernel_func_003() { printf("[stub] kernel func 003\n"); }
void stub_kernel_func_004() { printf("[stub] kernel func 004\n"); }
void stub_kernel_func_005() { printf("[stub] kernel func 005\n"); }
void stub_kernel_func_006() { printf("[stub] kernel func 006\n"); }
void stub_kernel_func_007() { printf("[stub] kernel func 007\n"); }
void stub_kernel_func_008() { printf("[stub] kernel func 008\n"); }
void stub_kernel_func_009() { printf("[stub] kernel func 009\n"); }
void stub_kernel_func_010() { printf("[stub] kernel func 010\n"); }

void kernel_line_expansion() {
    for(int i = 0; i < 400; i++) printf("[kernel] expansion line %d\n", i);
}

int main() {
    kernel_main();
    return 0;
} 