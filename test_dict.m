#import <Foundation/Foundation.h>
#import <sys/attr.h>
#import <sys/stat.h>

typedef struct {
	u_int32_t length;
	struct timespec c, a;
} __attribute__((aligned(4), packed)) times_buf_t;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:31742];
        for (int i=0; i<31742; i++) {
            [arr addObject:[NSString stringWithFormat:@"/tmp/file_%05d.png", i]];
        }
        
        NSDate *start = [NSDate date];
        NSMutableDictionary *cache = [NSMutableDictionary dictionaryWithCapacity:arr.count];
        for (NSString *path in arr) {
            cache[path] = @(123456789);
        }
        NSLog(@"dictionary population took %f seconds", [[NSDate date] timeIntervalSinceDate:start]);
    }
    return 0;
}
