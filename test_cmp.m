#import <Foundation/Foundation.h>
int main() {
    @autoreleasepool {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:31742];
        for (int i = 0; i < 31742; i++) {
            [arr addObject:[NSString stringWithFormat:@"/Users/yoto/Output/2024/file_%d.mp3", arc4random()]];
        }
        NSDate *s1 = [NSDate date];
        [arr sortUsingSelector:@selector(localizedStandardCompare:)];
        NSLog(@"localizedStandardCompare took %f seconds", [[NSDate date] timeIntervalSinceDate:s1]);
    }
    return 0;
}
