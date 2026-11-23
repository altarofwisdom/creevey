#import <Foundation/Foundation.h>
#import <sys/attr.h>

typedef struct {
    u_int32_t length;
    struct timespec c, a;
} __attribute__((aligned(4), packed)) times_buf_t;

int main() {
    @autoreleasepool {
        NSString *dir = @"/tmp/test_unique";
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:31742];
        for (int i = 0; i < 31742; i++) {
            [arr addObject:[dir stringByAppendingPathComponent:[NSString stringWithFormat:@"file_%d", i]]];
        }
        
        NSLog(@"Testing sequential getattrlist on 31742 unique files...");
        NSDate *s1 = [NSDate date];
        for (NSString *path in arr) {
            @autoreleasepool {
                struct attrlist attrlist;
                memset(&attrlist, 0, sizeof(attrlist));
                attrlist.bitmapcount = ATTR_BIT_MAP_COUNT;
                attrlist.commonattr = ATTR_CMN_CRTIME|ATTR_CMN_ADDEDTIME;
                times_buf_t aBuf;
                getattrlist(path.fileSystemRepresentation, &attrlist, &aBuf, sizeof(aBuf), 0);
            }
        }
        NSLog(@"Took %f seconds", [[NSDate date] timeIntervalSinceDate:s1]);
    }
    return 0;
}
