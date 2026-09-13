#import <Foundation/Foundation.h>

NSString *ExtractPNGText(NSString *path) {
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:path];
    if (!file) return nil;
    
    NSData *sig = [file readDataOfLength:8];
    if (sig.length != 8) return nil;
    const unsigned char *sigBytes = sig.bytes;
    if (sigBytes[0] != 0x89 || sigBytes[1] != 0x50 || sigBytes[2] != 0x4E || sigBytes[3] != 0x47 ||
        sigBytes[4] != 0x0D || sigBytes[5] != 0x0A || sigBytes[6] != 0x1A || sigBytes[7] != 0x0A) {
        return nil;
    }
    
    NSMutableString *result = [NSMutableString string];
    while (YES) {
        NSData *lenData = [file readDataOfLength:4];
        if (lenData.length != 4) break;
        uint32_t length;
        [lenData getBytes:&length length:4];
        length = CFSwapInt32BigToHost(length);
        
        NSData *typeData = [file readDataOfLength:4];
        if (typeData.length != 4) break;
        NSString *type = [[NSString alloc] initWithData:typeData encoding:NSASCIIStringEncoding];
        
        if ([type isEqualToString:@"tEXt"] || [type isEqualToString:@"iTXt"]) {
            NSData *chunkData = [file readDataOfLength:length];
            if (chunkData.length == length) {
                NSString *text = [[NSString alloc] initWithData:chunkData encoding:NSUTF8StringEncoding];
                if (!text) {
                    text = [[NSString alloc] initWithData:chunkData encoding:NSASCIIStringEncoding];
                }
                if (text) {
                    [result appendString:text];
                    [result appendString:@"\n"];
                }
            }
        } else {
            [file seekToFileOffset:[file offsetInFile] + length];
        }
        
        [file seekToFileOffset:[file offsetInFile] + 4]; // skip CRC
    }
    [file closeFile];
    return result.length > 0 ? result : nil;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc > 1) {
            NSString *path = [NSString stringWithUTF8String:argv[1]];
            NSString *text = ExtractPNGText(path);
            if (text) {
                printf("%s\n", [text UTF8String]);
            }
        }
    }
    return 0;
}
