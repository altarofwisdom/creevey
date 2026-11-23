#import <Foundation/Foundation.h>

int main() {
    @autoreleasepool {
        NSMutableArray *filenames = [NSMutableArray array];
        for (int i=0; i<5; i++) {
            [filenames addObject:[NSString stringWithFormat:@"file%d.png", i]];
        }
        
        NSArray *retainedFilenames = [filenames copy];
        int64_t vals[5] = {5, 2, 4, 1, 3};
        
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:5];
        for (NSUInteger i = 0; i < 5; i++) {
            [items addObject:@[ retainedFilenames[i], @(vals[i]) ]];
        }
        
        BOOL descending = NO;
        [items sortWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(NSArray *a, NSArray *b) {
            int64_t valA = [a[1] longLongValue];
            int64_t valB = [b[1] longLongValue];
            if (valA != valB) {
                if (descending) return valA < valB ? NSOrderedDescending : NSOrderedAscending;
                return valA > valB ? NSOrderedDescending : NSOrderedAscending;
            }
            if (descending) return [b[0] localizedStandardCompare:a[0]];
            return [a[0] localizedStandardCompare:b[0]];
        }];
        
        [filenames removeAllObjects];
        for (NSUInteger i = 0; i < 5; i++) {
            [filenames addObject:items[i][0]];
        }
        
        NSLog(@"%@", filenames);
    }
    return 0;
}
