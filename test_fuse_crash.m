#import <Foundation/Foundation.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdatomic.h>

int main() {
    @autoreleasepool {
        NSString *bigDir = @"/Users/yoto/Output/2024";
        NSFileManager *fm = [NSFileManager defaultManager];
        
        NSLog(@"[ETAPE 1] Récupération rigoureuse des fichiers en mémoire via l'API Apple (aucune commande bash)...");
        NSMutableArray *filenames = [NSMutableArray array];
        NSDirectoryEnumerator *enumerator = [fm enumeratorAtURL:[NSURL fileURLWithPath:bigDir]
                                     includingPropertiesForKeys:nil
                                                        options:NSDirectoryEnumerationSkipsHiddenFiles
                                                   errorHandler:nil];
        
        for (NSURL *fileURL in enumerator) {
            NSNumber *isDir;
            [fileURL getResourceValue:&isDir forKey:NSURLIsDirectoryKey error:nil];
            if (![isDir boolValue]) {
                [filenames addObject:fileURL.path];
                if (filenames.count >= 25000) break; // Chargement d'un gros volume pour simuler le crash
            }
        }
        
        NSUInteger count = filenames.count;
        if (count == 0) {
            NSLog(@"Erreur : aucun fichier trouvé.");
            return 1;
        }
        
        NSLog(@"[ETAPE 2] %lu fichiers chargés. Début de l'assaut FUSE (dispatch_apply)...", (unsigned long)count);
        
        __block atomic_int statSuccessCount = 0;
        __block atomic_int statFailCount = 0;
        __block atomic_int readFailCount = 0;
        __block atomic_int readSuccessCount = 0;
        
        NSDate *start = [NSDate date];
        
        dispatch_apply(count, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^(size_t i) {
            NSString *path = filenames[i];
            struct stat st;
            
            // 1. La requête stat() qui surcharge FUSE
            if (stat(path.fileSystemRepresentation, &st) == 0) {
                atomic_fetch_add_explicit(&statSuccessCount, 1, memory_order_relaxed);
            } else {
                atomic_fetch_add_explicit(&statFailCount, 1, memory_order_relaxed);
            }
            
            // 2. Tentative d'ouverture du fichier (Simulation de DYImageCache tentant de lire l'image)
            int fd = open(path.fileSystemRepresentation, O_RDONLY);
            if (fd < 0) {
                atomic_fetch_add_explicit(&readFailCount, 1, memory_order_relaxed);
            } else {
                atomic_fetch_add_explicit(&readSuccessCount, 1, memory_order_relaxed);
                close(fd);
            }
        });
        
        NSLog(@"[ETAPE 3] Assaut terminé en %f secondes.", [[NSDate date] timeIntervalSinceDate:start]);
        NSLog(@"Résultats stat() (Surcharge FUSE) -> Succès : %d | Échecs : %d", statSuccessCount, statFailCount);
        NSLog(@"Résultats open() (DYImageCache) -> Images chargées : %d | IMAGES CASSÉES : %d", readSuccessCount, readFailCount);
    }
    return 0;
}
