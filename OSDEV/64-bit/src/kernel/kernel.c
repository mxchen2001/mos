extern void k_start() {
    int *p = (int*)0xb8000;
    *p = 0x50505050;
    return;
}