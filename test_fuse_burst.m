#import <Foundation/Foundation.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdatomic.h>

int main() {
    @autoreleasepool {
        NSString *testFile = @"/Users/yoto/Output/2024/2024-03-15 OK/1.jpg"; // Using a dummy path to test stress
        // To ensure we hit FUSE, let's just ask for root directory of encfs
        NSString *targetPath = @"/Users/yoto/Output/2024";
        
        int totalRequests = 30000;
        __block atomic_int successCount = 0;
        __block atomic_int failCount = 0;
        __block atomic_int readFailCount = 0;
        
        NSLog(@"Starting dispatch_apply burst of %d requests on FUSE...", totalRequests);
        NSDate *start = [NSDate date];
        
        dispatch_apply(totalRequests, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^(size_t i) {
            struct stat st;
            if (stat(targetPath.fileSystemRepresentation, &st) == 0) {
                atomic_fetch_add_explicit(&successCount, 1, memory_order_relaxed);
            } else {
                atomic_fetch_add_explicit(&failCount, 1, memory_order_relaxed);
            }
            
            // Simuler DYImageCache
            if (i % 50 == 0) {
                int fd = open(targetPath.fileSystemRepresentation, O_RDONLY);
                if (fd < 0) {
                    atomic_fetch_add_explicit(&readFailCount, 1, memory_order_relaxed);
                } else {
                    close(fd);
                }
            }
        });
        
        NSLog(@"Burst done in %f seconds.", [[NSDate date] timeIntervalSinceDate:start]);
        NSLog(@"Stat Success: %d, Stat Fail: %d", successCount, failCount);
        NSLog(@"Image Open Failures during burst: %d", readFailCount);
    }
    return 0;
}
