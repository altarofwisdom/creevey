#import <Foundation/Foundation.h>
#include <fcntl.h>
#include <unistd.h>
int main() {
    int fd = open("test.png", O_RDONLY | O_NONBLOCK);
    if (fd != -1) {
        unsigned char bytes[65536];
        ssize_t bytesRead = read(fd, bytes, sizeof(bytes));
        NSLog(@"Read %zd bytes", bytesRead);
        close(fd);
    }
    return 0;
}
