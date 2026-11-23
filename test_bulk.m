#import <Foundation/Foundation.h>

int main() {
    @autoreleasepool {
        NSString *dir = @"/tmp/test_unique";
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:31742];
        for (int i = 0; i < 31742; i++) {
            [arr addObject:[dir stringByAppendingPathComponent:[NSString stringWithFormat:@"file_%d", i]]];
        }
        
        NSLog(@"Testing bulk fetch...");
        NSDate *s1 = [NSDate date];
        
        NSMutableSet *dirs = [NSMutableSet set];
        for (NSString *path in arr) {
            [dirs addObject:[path stringByDeletingLastPathComponent]];
        }
        
        NSMutableDictionary *cache = [NSMutableDictionary dictionaryWithCapacity:arr.count];
        NSFileManager *fm = [NSFileManager defaultManager];
        
        for (NSString *d in dirs) {
            NSURL *url = [NSURL fileURLWithPath:d];
            NSDirectoryEnumerator *enumr = [fm enumeratorAtURL:url
                                    includingPropertiesForKeys:@[NSURLAddedToDirectoryDateKey]
                                                       options:NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsSubdirectoryDescendants
                                                  errorHandler:nil];
            for (NSURL *u in enumr) {
                NSDate *date;
                if ([u getResourceValue:&date forKey:NSURLAddedToDirectoryDateKey error:nil] && date) {
                    cache[u.path] = date;
                }
            }
        }
        NSLog(@"Bulk fetch took %f seconds. Cache size: %lu", [[NSDate date] timeIntervalSinceDate:s1], (unsigned long)cache.count);
    }
    return 0;
}
