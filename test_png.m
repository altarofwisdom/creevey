#import <Foundation/Foundation.h>
int main() {
    @autoreleasepool {
        NSData *fileData = [NSData dataWithBytes:"\x89\x50\x4E\x47\x0D\x0A\x1A\x0A\x00\x00\x00\x00IEND\xAE\x42\x60\x82" length:16];
        const unsigned char *bytes = fileData.bytes;
        NSUInteger len = fileData.length;
        if (len > 8 && bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
            NSUInteger offset = 8;
            while (offset + 8 <= len) {
                uint32_t chunkLen = (bytes[offset] << 24) | (bytes[offset+1] << 16) | (bytes[offset+2] << 8) | bytes[offset+3];
                offset += 4;
                char type[5] = { (char)bytes[offset], (char)bytes[offset+1], (char)bytes[offset+2], (char)bytes[offset+3], 0 };
                offset += 4;
                NSLog(@"chunk %s, len %u, offset %lu", type, chunkLen, offset);
                offset += chunkLen + 4;
                NSLog(@"next offset %lu, len %lu", offset, len);
            }
        }
    }
    return 0;
}
