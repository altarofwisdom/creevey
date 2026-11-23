#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *dir = @"/usr/bin";
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *files = [fm subpathsOfDirectoryAtPath:dir error:nil];
        NSMutableArray *arr = [NSMutableArray array];
        for (NSString *f in files) {
            [arr addObject:[dir stringByAppendingPathComponent:f]];
        }
        
        NSMutableArray *bigArr = [NSMutableArray array];
        while (bigArr.count < 31742) {
            [bigArr addObjectsFromArray:arr];
        }
        [bigArr removeObjectsInRange:NSMakeRange(31742, bigArr.count - 31742)];
        
        NSLog(@"Testing Spotlight for %lu files...", (unsigned long)bigArr.count);
        NSDate *s1 = [NSDate date];
        dispatch_apply(bigArr.count, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^(size_t i) {
            @autoreleasepool {
                NSString *path = bigArr[i];
                MDItemRef mdItem = MDItemCreate(NULL, (__bridge CFStringRef)path);
                if (mdItem) {
                    CFTypeRef date = MDItemCopyAttribute(mdItem, kMDItemDateAdded);
                    if (date) CFRelease(date);
                    CFRelease(mdItem);
                }
            }
        });
        NSLog(@"Spotlight took %f seconds", [[NSDate date] timeIntervalSinceDate:s1]);
    }
    return 0;
}
