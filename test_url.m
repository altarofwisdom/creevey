#import <Foundation/Foundation.h>
int main() {
    @autoreleasepool {
        NSString *dir = @"/tmp";
        NSDirectoryEnumerator *enumr = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL fileURLWithPath:dir]
                                includingPropertiesForKeys:@[NSURLAddedToDirectoryDateKey]
                                                   options:NSDirectoryEnumerationSkipsHiddenFiles
                                              errorHandler:nil];
        NSURL *firstUrl = nil;
        for (NSURL *u in enumr) {
            firstUrl = u; break;
        }
        if (firstUrl) {
            NSDate *d;
            [firstUrl getResourceValue:&d forKey:NSURLAddedToDirectoryDateKey error:nil];
            NSLog(@"Date: %@", d);
        }
    }
    return 0;
}
