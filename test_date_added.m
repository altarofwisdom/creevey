#import <Foundation/Foundation.h>
#include <sys/attr.h>
#include <sys/stat.h>
#include <unistd.h>

int main() {
    @autoreleasepool {
        NSString *file = @"/Users/yoto/Output/2024/2024-03-15 OK";
        struct stat aBuf;
        if (stat(file.fileSystemRepresentation, &aBuf) == 0) {
            printf("stat st_birthtimespec: %ld\n", aBuf.st_birthtimespec.tv_sec);
        } else {
            perror("stat");
        }
        
        struct attrlist attrList;
        memset(&attrList, 0, sizeof(attrList));
        attrList.bitmapcount = ATTR_BIT_MAP_COUNT;
        attrList.commonattr = ATTR_CMN_ADDEDTIME;
        struct {
            uint32_t length;
            struct timespec added_time;
        } attrBuf;
        
        if (getattrlist(file.fileSystemRepresentation, &attrList, &attrBuf, sizeof(attrBuf), 0) == 0) {
            printf("getattrlist ATTR_CMN_ADDEDTIME: %ld\n", attrBuf.added_time.tv_sec);
        } else {
            perror("getattrlist");
        }
    }
    return 0;
}
