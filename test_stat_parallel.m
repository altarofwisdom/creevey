#import <Foundation/Foundation.h>
#include <sys/stat.h>

int main() {
    @autoreleasepool {
        NSString *dir = @"/Users/yoto/Output/2024";
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *files = [fm subpathsOfDirectoryAtPath:dir error:nil];
        NSLog(@"Found %lu files", (unsigned long)files.count);
        
        NSDate *s1 = [NSDate date];
        __block int statCount = 0;
        dispatch_apply(files.count, dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^(size_t i) {
            NSString *full = [dir stringByAppendingPathComponent:files[i]];
            struct stat aBuf;
            if (stat(full.fileSystemRepresentation, &aBuf) == 0) {
                __atomic_fetch_add(&statCount, 1, __ATOMIC_RELAXED);
            }
        });
        NSLog(@"Parallel Stat took %f seconds for %d files", [[NSDate date] timeIntervalSinceDate:s1], statCount);
    }
    return 0;
}
