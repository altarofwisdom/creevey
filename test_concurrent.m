#import <Foundation/Foundation.h>
#import <sys/attr.h>
#import <sys/stat.h>

typedef struct {
	u_int32_t length;
	struct timespec c, a;
} __attribute__((aligned(4), packed)) times_buf_t;

typedef struct {
    __unsafe_unretained NSString *path;
    int64_t val;
} SortItem;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *dir = @"/usr/bin";
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *files = [fm subpathsOfDirectoryAtPath:dir error:nil];
        NSMutableArray *filenames = [NSMutableArray array];
        for (NSString *f in files) {
            [filenames addObject:[dir stringByAppendingPathComponent:f]];
        }
        
        NSUInteger count = filenames.count;
        SortItem *items = malloc(count * sizeof(SortItem));
        
        NSDate *start = [NSDate date];
        
        dispatch_apply(count, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^(size_t i) {
            NSString *path = filenames[i];
            items[i].path = path;
            items[i].val = 0;
            struct attrlist attrlist;
            memset(&attrlist, 0, sizeof(attrlist));
            attrlist.bitmapcount = ATTR_BIT_MAP_COUNT;
            attrlist.commonattr = ATTR_CMN_CRTIME|ATTR_CMN_ADDEDTIME;
            times_buf_t aBuf;
            if (getattrlist(path.fileSystemRepresentation, &attrlist, &aBuf, sizeof(aBuf), 0) == 0)
                items[i].val = aBuf.a.tv_sec;
        });
        
        qsort_b(items, count, sizeof(SortItem), ^int(const void *a, const void *b) {
            SortItem *itemA = (SortItem *)a;
            SortItem *itemB = (SortItem *)b;
            if (itemA->val != itemB->val) {
                return itemA->val < itemB->val ? 1 : -1;
            }
            return [itemA->path localizedStandardCompare:itemB->path];
        });
        
        [filenames removeAllObjects];
        for (NSUInteger i = 0; i < count; i++) {
            [filenames addObject:items[i].path];
        }
        free(items);
        
        NSLog(@"Concurrent fetch and sort took %f seconds", [[NSDate date] timeIntervalSinceDate:start]);
    }
    return 0;
}
