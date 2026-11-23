#include <stdio.h>
#include <dirent.h>
#include <sys/stat.h>
#import <Foundation/Foundation.h>

void scan(const char *path, int *count) {
    DIR *dir = opendir(path);
    if (!dir) return;
    struct dirent *ent;
    while ((ent = readdir(dir)) != NULL) {
        if (ent->d_name[0] == '.') continue;
        char full[1024];
        snprintf(full, sizeof(full), "%s/%s", path, ent->d_name);
        struct stat st;
        stat(full, &st);
        (*count)++;
        if (ent->d_type == DT_DIR) {
            scan(full, count);
        }
    }
    closedir(dir);
}

int main() {
    @autoreleasepool {
        NSDate *s1 = [NSDate date];
        int count = 0;
        scan("/Users/yoto/Output/2024", &count);
        NSLog(@"scan + stat took %f seconds for %d files", [[NSDate date] timeIntervalSinceDate:s1], count);
    }
    return 0;
}
