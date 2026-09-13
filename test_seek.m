#import <Foundation/Foundation.h>
int main() {
    @autoreleasepool {
        NSString *path = @"/tmp/test_seek.txt";
        [@"hello" writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:path];
        NSLog(@"File size: %llu", [file seekToEndOfFile]);
        @try {
            [file seekToFileOffset:10000];
            NSLog(@"Seek succeeded, offset: %llu", [file offsetInFile]);
        } @catch (NSException *e) {
            NSLog(@"Exception: %@", e);
        }
    }
    return 0;
}
