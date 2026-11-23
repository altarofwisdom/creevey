#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:31742];
        for (int i=0; i<31742; i++) {
            [arr addObject:[NSString stringWithFormat:@"file_%05d.png", i]];
        }
        
        NSDate *start = [NSDate date];
        [arr sortUsingComparator:^NSComparisonResult(NSString *a, NSString *b) {
            return [a localizedStandardCompare:b];
        }];
        NSLog(@"localizedStandardCompare took %f seconds", [[NSDate date] timeIntervalSinceDate:start]);
    }
    return 0;
}
