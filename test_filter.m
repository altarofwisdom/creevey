#import <Foundation/Foundation.h>

extern NSString *ExtractPNGText(NSString *path);

int main() {
    @autoreleasepool {
        NSString *path = @"/Volumes/ai/ComfyUI/output/2026-08-24-095351__0.png"; // known to contain woman
        NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:path];
        if (!file) { NSLog(@"File not found"); return 0; }
        NSData *sig = [file readDataOfLength:8];
        if (sig.length == 8) {
            const unsigned char *sigBytes = sig.bytes;
            if (sigBytes[0] == 0x89 && sigBytes[1] == 0x50 && sigBytes[2] == 0x4E && sigBytes[3] == 0x47) {
                NSMutableString *result = [[NSMutableString alloc] init];
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
                            if (!text) text = [[NSString alloc] initWithData:chunkData encoding:NSASCIIStringEncoding];
                            if (text) { [result appendString:text]; [result appendString:@"\n"]; }
                        }
                    } else {
                        [file seekToFileOffset:[file offsetInFile] + length];
                    }
                    [file seekToFileOffset:[file offsetInFile] + 4];
                }
                NSLog(@"Extracted length: %lu", (unsigned long)result.length);
                if ([result containsString:@"woman"]) {
                    NSLog(@"YES it contains woman!");
                } else {
                    NSLog(@"NO it does not contain woman!");
                    NSLog(@"Extracted text: %@", [result substringToIndex:MIN(200, result.length)]);
                }
            }
        }
    }
    return 0;
}
