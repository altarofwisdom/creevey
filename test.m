#import <Foundation/Foundation.h>
int main() {
    @autoreleasepool {
        NSString *s = @"hello";
        NSLog(@"count: %lu", (unsigned long)[(id)s count]);
    }
    return 0;
}
