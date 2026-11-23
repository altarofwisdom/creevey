#import <Foundation/Foundation.h>
#include <sys/stat.h>

int main() {
    @autoreleasepool {
        NSString *dir = @"/Users/yoto/Output/2024";
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *files = [fm subpathsOfDirectoryAtPath:dir error:nil];
        NSLog(@"Found %lu files", (unsigned long)files.count);
        
        NSDate *s1 = [NSDate date];
        int statCount = 0;
        for (NSString *file in files) {
            NSString *full = [dir stringByAppendingPathComponent:file];
            struct stat aBuf;
            if (stat(full.fileSystemRepresentation, &aBuf) == 0) {
                statCount++;
            }
        }
        NSLog(@"Stat took %f seconds for %d files", [[NSDate date] timeIntervalSinceDate:s1], statCount);
        
        NSDate *s2 = [NSDate date];
        NSArray *sorted = [files sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
        NSLog(@"localizedStandardCompare took %f seconds", [[NSDate date] timeIntervalSinceDate:s2]);
    }
    return 0;
}
