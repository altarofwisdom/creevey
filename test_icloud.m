#import <Foundation/Foundation.h>
#include <fcntl.h>
#include <unistd.h>

int main() {
    @autoreleasepool {
        int fd = open("test.png", O_RDONLY | O_NONBLOCK);
        if (fd != -1) {
            NSLog(@"Opened");
            close(fd);
        }
    }
    return 0;
}
