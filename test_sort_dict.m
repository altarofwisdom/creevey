#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:31742];
        NSMutableDictionary *cache = [NSMutableDictionary dictionaryWithCapacity:31742];
        for (int i=0; i<31742; i++) {
            NSString *s = [NSString stringWithFormat:@"/tmp/file_%05d.png", i];
            [arr addObject:s];
            cache[s] = @(i);
        }
        
        NSDate *start = [NSDate date];
        [arr sortUsingComparator:^NSComparisonResult(NSString *a, NSString *b) {
            NSNumber *na = cache[a];
            NSNumber *nb = cache[b];
            return [na compare:nb];
        }];
        NSLog(@"Sort with dict took %f seconds", [[NSDate date] timeIntervalSinceDate:start]);
    }
    return 0;
}
