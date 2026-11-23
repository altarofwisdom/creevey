#import <Foundation/Foundation.h>
#include <sys/attr.h>
#include <sys/vnode.h>
#include <unistd.h>
#include <fcntl.h>

typedef struct {
    uint32_t length;
    attribute_set_t returned;
    uint32_t error;
    attrreference_t name_info;
    struct timespec added_time;
} __attribute__((aligned(4), packed)) BulkAttrBuf;

int main() {
    @autoreleasepool {
        NSString *dir = @"/Users/yoto/Output/2024";
        NSLog(@"Testing getattrlistbulk on %@", dir);
        NSDate *s1 = [NSDate date];
        
        int fd = open(dir.UTF8String, O_RDONLY);
        if (fd < 0) {
            NSLog(@"Failed to open dir");
            return 1;
        }
        
        struct attrlist attrList;
        memset(&attrList, 0, sizeof(attrList));
        attrList.bitmapcount = ATTR_BIT_MAP_COUNT;
        attrList.commonattr = ATTR_CMN_NAME | ATTR_CMN_ADDEDTIME | ATTR_CMN_ERROR;
        
        char buf[65536];
        int count = 0;
        int total = 0;
        
        while ((count = getattrlistbulk(fd, &attrList, &buf, sizeof(buf), 0)) > 0) {
            char *ptr = buf;
            for (int i = 0; i < count; i++) {
                BulkAttrBuf *attr = (BulkAttrBuf *)ptr;
                char *name = ((char *)&attr->name_info) + attr->name_info.attr_dataoffset;
                total++;
                ptr += attr->length;
            }
        }
        close(fd);
        NSLog(@"Took %f seconds for %d files", [[NSDate date] timeIntervalSinceDate:s1], total);
    }
    return 0;
}
