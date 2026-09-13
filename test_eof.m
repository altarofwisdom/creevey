#import <Foundation/Foundation.h>
int main() {
    @autoreleasepool {
        NSString *path = @"/tmp/test_seek.txt";
        [@"hello" writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:path];
        [file seekToFileOffset:10000];
        NSData *d = [file readDataOfLength:4];
        NSLog(@"Read length: %lu", (unsigned long)d.length);
    }
    return 0;
}
