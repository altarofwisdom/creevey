#import <Foundation/Foundation.h>
int main() {
    @autoreleasepool {
        NSString *path = @"/tmp/test_seek.txt";
        [@"hello" writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:path];
        @try {
            NSData *d = [file readDataOfLength:4000000000U];
            NSLog(@"Read length: %lu", (unsigned long)d.length);
        } @catch (NSException *e) {
            NSLog(@"Exception: %@", e);
        }
    }
    return 0;
}
