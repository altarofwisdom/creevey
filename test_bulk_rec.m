#import <Foundation/Foundation.h>
#include <sys/attr.h>
#include <sys/vnode.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>

typedef struct {
    uint32_t length;
    attribute_set_t returned;
    uint32_t error;
    attrreference_t name_info;
    struct timespec added_time;
    struct timespec mod_time;
    off_t size;
    fsobj_type_t obj_type;
} __attribute__((aligned(4), packed)) BulkAttrBuf;

void scan_bulk(NSString *dir, int *count) {
    int fd = open(dir.UTF8String, O_RDONLY);
    if (fd < 0) return;
    
    struct attrlist attrList;
    memset(&attrList, 0, sizeof(attrList));
    attrList.bitmapcount = ATTR_BIT_MAP_COUNT;
    attrList.commonattr = ATTR_CMN_NAME | ATTR_CMN_ADDEDTIME | ATTR_CMN_MODTIME | ATTR_CMN_OBJTYPE;
    attrList.fileattr = ATTR_FILE_DATALENGTH;
    
    char buf[65536];
    int read_count = 0;
    
    NSMutableArray *subdirs = [NSMutableArray array];
    
    while ((read_count = getattrlistbulk(fd, &attrList, &buf, sizeof(buf), 0)) > 0) {
        char *ptr = buf;
        for (int i = 0; i < read_count; i++) {
            BulkAttrBuf *attr = (BulkAttrBuf *)ptr;
            char *name = ((char *)&attr->name_info) + attr->name_info.attr_dataoffset;
            if (strcmp(name, ".") != 0 && strcmp(name, "..") != 0) {
                (*count)++;
                if (attr->obj_type == VDIR) {
                    NSString *sub = [dir stringByAppendingPathComponent:[NSString stringWithUTF8String:name]];
                    [subdirs addObject:sub];
                }
            }
            ptr += attr->length;
        }
    }
    close(fd);
    
    for (NSString *sub in subdirs) {
        scan_bulk(sub, count);
    }
}

int main() {
    @autoreleasepool {
        NSString *dir = @"/Users/yoto/Output/2024";
        NSDate *s1 = [NSDate date];
        int count = 0;
        scan_bulk(dir, &count);
        NSLog(@"getattrlistbulk recursive took %f seconds for %d files", [[NSDate date] timeIntervalSinceDate:s1], count);
    }
    return 0;
}
