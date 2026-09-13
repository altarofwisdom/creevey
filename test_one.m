#import <Foundation/Foundation.h>

@interface DYExiftags : NSObject
+ (NSString *)tagsForFile:(NSString *)aPath moreTags:(BOOL)showMore;
@end

@implementation DYExiftags
+ (NSString *)tagsForFile:(NSString *)aPath moreTags:(BOOL)showMore {
	NSMutableString *result = [NSMutableString stringWithCapacity:100];
	NSString *extension = aPath.pathExtension.lowercaseString;
	if ([extension isEqualToString:@"png"]) {
		FILE *f = fopen(aPath.fileSystemRepresentation, "rb");
		if (f) {
			unsigned char sig[8];
			if (fread(sig, 1, 8, f) == 8) {
				if (sig[0] == 0x89 && sig[1] == 0x50 && sig[2] == 0x4E && sig[3] == 0x47) {
					while (YES) {
						uint32_t length;
						if (fread(&length, 4, 1, f) != 1) break;
						length = CFSwapInt32BigToHost(length);
						char type[5] = {0};
						if (fread(type, 1, 4, f) != 1) break;
						if (strcmp(type, "tEXt") == 0 || strcmp(type, "iTXt") == 0) {
							char *chunk = malloc(length);
							if (chunk) {
								if (fread(chunk, 1, length, f) == length) {
									NSString *text = [[NSString alloc] initWithBytes:chunk length:length encoding:NSUTF8StringEncoding];
									if (!text) text = [[NSString alloc] initWithBytes:chunk length:length encoding:NSASCIIStringEncoding];
									if (text) { [result appendString:text]; [result appendString:@"\n"]; }
								}
								free(chunk);
							} else {
								fseeko(f, length, SEEK_CUR);
							}
						} else {
							fseeko(f, length, SEEK_CUR);
						}
						fseeko(f, 4, SEEK_CUR); // CRC
					}
				}
			}
			fclose(f);
		}
	}
	if (result.length == 0) return nil;
	return result;
}
@end

int main() {
    @autoreleasepool {
        NSString *path = @"/Volumes/ai/ComfyUI/output/CivitAI/professional photo shot of a skinny young tall wom_fff747/Krea2_2026-08-17-130205_323732324843832.png";
        NSString *tags = [DYExiftags tagsForFile:path moreTags:YES];
        if ([tags rangeOfString:@"heels" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            NSLog(@"FOUND");
        } else {
            NSLog(@"NOT FOUND. Tags: %@", tags);
        }
    }
    return 0;
}
