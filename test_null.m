#import <Foundation/Foundation.h>
int main() {
    @autoreleasepool {
        char bytes[] = "parameters\0a woman wearing high heels";
        NSString *s = [[NSString alloc] initWithBytes:bytes length:sizeof(bytes)-1 encoding:NSUTF8StringEncoding];
        if ([s rangeOfString:@"heels"].location != NSNotFound) {
            NSLog(@"FOUND: rangeOfString works across null bytes.");
        } else {
            NSLog(@"NOT FOUND: rangeOfString stops at null bytes.");
        }
    }
    return 0;
}
