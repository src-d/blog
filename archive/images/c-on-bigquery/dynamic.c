#include <stdio.h>
#include <dlfcn.h>

int main()
{
    int (*sum)(int, int);

    void *dl = dlopen("sum.so", RTLD_LAZY);
    if (!dl)
    {
        fprintf(stderr, "%s\n", dlerror());
        return 1;
    }
    sum = dlsym(dl, "sum");
    printf("%d\n", (*sum)(39, 3));
}