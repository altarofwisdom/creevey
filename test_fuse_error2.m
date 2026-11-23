#import <Foundation/Foundation.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <stdatomic.h>

int main() {
    @autoreleasepool {
        NSString *bigDir = @"/Users/yoto/Output/2024";
        NSFileManager *fm = [NSFileManager defaultManager];
        
        printf("Scanning FUSE directory...\n");
        NSDirectoryEnumerator *enumerator = [fm enumeratorAtURL:[NSURL fileURLWithPath:bigDir]
                                     includingPropertiesForKeys:nil
                                                        options:NSDirectoryEnumerationSkipsHiddenFiles
                                                   errorHandler:nil];
        
        NSMutableArray *filenames = [NSMutableArray array];
        for (NSURL *fileURL in enumerator) {
            NSNumber *isDir;
            [fileURL getResourceValue:&isDir forKey:NSURLIsDirectoryKey error:nil];
            if (![isDir boolValue]) {
                [filenames addObject:fileURL.path];
                if (filenames.count >= 20000) break; 
            }
        }
        
        printf("Starting assault on %lu files...\n", (unsigned long)filenames.count);
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
                }
            } else {
                atomic_fetch_add_explicit(&success, 1, memory_order_relaxed);
                close(fd);
            }
        });
        printf("Assault done. Success: %d, Failures: %d\n", success, printed);
    }
    return 0;
}
