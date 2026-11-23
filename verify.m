#import <Foundation/Foundation.h>
#import <sys/attr.h>

typedef struct {
    u_int32_t length;
    struct timespec c, a;
} __attribute__((aligned(4), packed)) times_buf_t;

int main() {
    NSLog(@"Size of times_buf_t: %zu", sizeof(times_buf_t));
    return 0;
}
