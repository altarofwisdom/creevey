#import <Foundation/Foundation.h>

int main() {
    @autoreleasepool {
        NSString *dir = @"/Users/yoto/Output/2024";
        NSFileManager *fm = [NSFileManager defaultManager];
        
        NSLog(@"Testing NSDirectoryEnumerator on %@", dir);
        NSDirectoryEnumerator *enumr = [fm enumeratorAtURL:[NSURL fileURLWithPath:dir]
                                includingPropertiesForKeys:@[NSURLAddedToDirectoryDateKey]
                                                   options:NSDirectoryEnumerationSkipsHiddenFiles
                                              errorHandler:^BOOL(NSURL *url, NSError *error) {
                                                  NSLog(@"Error: %@", error);
                                                  return YES;
                                              }];
        NSUInteger count = 0;
        for (NSURL *url in enumr) {
            count++;
        }
        NSLog(@"Took %lu files", (unsigned long)count);
    }
    return 0;
}
