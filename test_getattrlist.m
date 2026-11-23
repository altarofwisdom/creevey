#import <Foundation/Foundation.h>
#import <sys/attr.h>
#import <sys/stat.h>

typedef struct {
	u_int32_t length;
	struct timespec c, a;
} __attribute__((aligned(4), packed)) times_buf_t;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *dir = @"/System/Library/Fonts";
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *files = [fm subpathsOfDirectoryAtPath:dir error:nil];
        NSLog(@"Found %lu files", (unsigned long)files.count);
        
        NSDate *start = [NSDate date];
        for (NSString *file in files) {
            NSString *path = [dir stringByAppendingPathComponent:file];
            struct attrlist attrlist;
            memset(&attrlist, 0, sizeof(attrlist));
            attrlist.bitmapcount = ATTR_BIT_MAP_COUNT;
            attrlist.commonattr = ATTR_CMN_CRTIME|ATTR_CMN_ADDEDTIME;
            times_buf_t aBuf;
            getattrlist(path.fileSystemRepresentation, &attrlist, &aBuf, sizeof(aBuf), 0);
        }
        NSLog(@"getattrlist took %f seconds", [[NSDate date] timeIntervalSinceDate:start]);
    }
    return 0;
}
