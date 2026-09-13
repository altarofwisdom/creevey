#import <Foundation/Foundation.h>
#import "exiftags/DYExiftags.m"

int main() {
    @autoreleasepool {
        NSString *path = @"/Volumes/ai/ComfyUI/output/CivitAI/professional photo shot of a skinny young tall wom_fff747/Krea2_2026-08-17-130205_323732324843832.png";
        NSString *tags = [DYExiftags tagsForFile:path moreTags:YES];
        if (!tags) tags = @"";
        NSLog(@"Tags length: %lu", (unsigned long)tags.length);
        if ([tags rangeOfString:@"heels" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            NSLog(@"FOUND heels in extracted tags!");
        } else {
            NSLog(@"NOT FOUND. Tags: %@", tags);
        }
    }
    return 0;
}
