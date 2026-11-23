#import <Foundation/Foundation.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <stdatomic.h>
#include <dirent.h>

void scanDirectory(NSString *path, NSMutableArray *filenames, int limit) {
    DIR *dir = opendir(path.fileSystemRepresentation);
    if (!dir) return;
    
    struct dirent *ent;
    while ((ent = readdir(dir)) != NULL) {
        if (filenames.count >= limit) break;
        
        NSString *name = @(ent->d_name);
        if ([name isEqualToString:@"."] || [name isEqualToString:@".."]) continue;
        
        NSString *fullPath = [path stringByAppendingPathComponent:name];
        
        if (ent->d_type == DT_DIR) {
            scanDirectory(fullPath, filenames, limit);
        } else if (ent->d_type == DT_REG) {
            [filenames addObject:fullPath];
            if (filenames.count % 1000 == 0) {
                printf("Trouvé %lu fichiers...\n", (unsigned long)filenames.count);
                fflush(stdout);
            }
        }
    }
    closedir(dir);
}

int main() {
    @autoreleasepool {
        NSString *bigDir = @"/Users/yoto/Output/2024";
        printf("Démarrage du scan ultra-rapide (readdir) sur %s...\n", bigDir.UTF8String);
        fflush(stdout);
        
        NSMutableArray *filenames = [NSMutableArray array];
        scanDirectory(bigDir, filenames, 20000);
        
        printf("Scan terminé : %lu fichiers chargés. Début du test de stress...\n", (unsigned long)filenames.count);
        fflush(stdout);
        
        __block atomic_int printed = 0;
        __block atomic_int success = 0;
        
        dispatch_apply(filenames.count, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^(size_t i) {
            NSString *path = filenames[i];
            struct stat st;
            stat(path.fileSystemRepresentation, &st);
            
            int fd = open(path.fileSystemRepresentation, O_RDONLY);
            if (fd < 0) {
                if (atomic_fetch_add_explicit(&printed, 1, memory_order_relaxed) < 10) {
                    printf("CODE ERREUR = %d | MESSAGE = %s\n", errno, strerror(errno));
                    fflush(stdout);
                }
            } else {
                atomic_fetch_add_explicit(&success, 1, memory_order_relaxed);
                close(fd);
            }
        });
        
        printf("Assaut terminé ! Succès (fichiers lus) : %d, Échecs : %d\n", success, printed);
        fflush(stdout);
    }
    return 0;
}
