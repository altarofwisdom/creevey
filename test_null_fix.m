#import <Foundation/Foundation.h>
#import <sys/attr.h>

typedef struct {
    u_int32_t length;
    struct timespec c, a;
} __attribute__((aligned(4), packed)) times_buf_t;

int main() {
    struct attrlist attrlist;
    memset(&attrlist, 0, sizeof(attrlist));
    attrlist.bitmapcount = ATTR_BIT_MAP_COUNT;
    attrlist.commonattr = ATTR_CMN_CRTIME|ATTR_CMN_ADDEDTIME;
    times_buf_t aBuf;
    int res = getattrlist(NULL, &attrlist, &aBuf, sizeof(aBuf), 0);
    NSLog(@"Result: %d", res);
    return 0;
}
