#import <Foundation/Foundation.h>
#import <sys/attr.h>

typedef struct {
	u_int32_t length;
	struct timespec c, a;
} __attribute__((aligned(4), packed)) times_buf_t;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *dir = @"/usr/bin"; // We'll test on a known dir
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *files = [fm subpathsOfDirectoryAtPath:dir error:nil];
        NSMutableArray *arr = [NSMutableArray array];
        for (NSString *f in files) {
            [arr addObject:[dir stringByAppendingPathComponent:f]];
        }
        
        // Multiply to simulate 31k files
        NSMutableArray *bigArr = [NSMutableArray array];
        while (bigArr.count < 31742) {
            [bigArr addObjectsFromArray:arr];
        }
        [bigArr removeObjectsInRange:NSMakeRange(31742, bigArr.count - 31742)];
        
        NSLog(@"Testing Sequential getattrlist for %lu files...", (unsigned long)bigArr.count);
        NSDate *s1 = [NSDate date];
        for (NSString *path in bigArr) {
            @autoreleasepool {
                struct attrlist attrlist;
                memset(&attrlist, 0, sizeof(attrlist));
                attrlist.bitmapcount = ATTR_BIT_MAP_COUNT;
                attrlist.commonattr = ATTR_CMN_CRTIME|ATTR_CMN_ADDEDTIME;
                times_buf_t aBuf;
                getattrlist(path.fileSystemRepresentation, &attrlist, &aBuf, sizeof(aBuf), 0);
            }
        }
        NSLog(@"Sequential took %f seconds", [[NSDate date] timeIntervalSinceDate:s1]);
        
        NSLog(@"Testing Concurrent getattrlist...");
        NSDate *s2 = [NSDate date];
        dispatch_apply(bigArr.count, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^(size_t i) {
            @autoreleasepool {
                NSString *path = bigArr[i];
                struct attrlist attrlist;
                memset(&attrlist, 0, sizeof(attrlist));
                attrlist.bitmapcount = ATTR_BIT_MAP_COUNT;
                attrlist.commonattr = ATTR_CMN_CRTIME|ATTR_CMN_ADDEDTIME;
                times_buf_t aBuf;
                getattrlist(path.fileSystemRepresentation, &attrlist, &aBuf, sizeof(aBuf), 0);
            }
        });
        NSLog(@"Concurrent took %f seconds", [[NSDate date] timeIntervalSinceDate:s2]);
    }
    return 0;
}
