#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:31742];
        for (int i=0; i<31742; i++) {
            [arr addObject:[NSString stringWithFormat:@"/Users/yoto/Documents/AI_Genre_Classifier/dataset/audio/very_long_file_name_which_is_realistic_%05d.wav", 31742 - i]];
        }
        
        NSDate *start = [NSDate date];
        [arr sortUsingComparator:^NSComparisonResult(NSString *a, NSString *b) {
            return [a localizedStandardCompare:b];
        }];
        NSLog(@"localizedStandardCompare took %f seconds", [[NSDate date] timeIntervalSinceDate:start]);
    }
    return 0;
}
