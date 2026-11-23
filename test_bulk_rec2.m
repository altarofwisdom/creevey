#import <Foundation/Foundation.h>
#include <sys/attr.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
int main() {
    int fd = open("/Users/yoto/Output/2024", O_RDONLY);
    struct attrlist attrList;
    memset(&attrList, 0, sizeof(attrList));
    attrList.bitmapcount = ATTR_BIT_MAP_COUNT;
    attrList.commonattr = ATTR_CMN_NAME;
    char buf[65536];
    int ret = getattrlistbulk(fd, &attrList, &buf, sizeof(buf), 0);
    printf("ret=%d\n", ret);
    if (ret < 0) perror("getattrlistbulk");
    close(fd);
    return 0;
}
