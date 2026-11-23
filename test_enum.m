#import <Foundation/Foundation.h>

int main() {
    @autoreleasepool {
        NSString *dir = @"/tmp/test_unique";
        NSURL *dirURL = [NSURL fileURLWithPath:dir];
        NSFileManager *fm = [NSFileManager defaultManager];
        
        NSLog(@"Testing NSDirectoryEnumerator on 31742 files...");
        NSDate *s1 = [NSDate date];
        NSDirectoryEnumerator *enumr = [fm enumeratorAtURL:dirURL
                                includingPropertiesForKeys:@[NSURLAddedToDirectoryDateKey]
                                                   options:NSDirectoryEnumerationSkipsHiddenFiles
                                              errorHandler:nil];
        NSUInteger count = 0;
        for (NSURL *url in enumr) {
            NSDate *date;
            [url getResourceValue:&date forKey:NSURLAddedToDirectoryDateKey error:nil];
            count++;
        }
        NSLog(@"Took %f seconds for %lu files", [[NSDate date] timeIntervalSinceDate:s1], (unsigned long)count);
    }
    return 0;
}
