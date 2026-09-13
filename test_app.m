#import <Foundation/Foundation.h>
#import <dlfcn.h>

int main() {
    @autoreleasepool {
        void *handle = dlopen("/Applications/Phoenix Slides.app/Contents/MacOS/Phoenix Slides", RTLD_NOW);
        if (!handle) {
            NSLog(@"Failed to load app: %s", dlerror());
            return 1;
        }
        Class DYExiftagsClass = NSClassFromString(@"DYExiftags");
        if (!DYExiftagsClass) {
            NSLog(@"Failed to find DYExiftags class");
            return 1;
        }
        NSString *path = @"/Volumes/ai/ComfyUI/output/CivitAI/professional photo shot of a skinny young tall wom_fff747/Krea2_2026-08-17-130205_323732324843832.png";
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        NSString *tags = [DYExiftagsClass performSelector:@selector(tagsForFile:moreTags:) withObject:path withObject:@(YES)];
        #pragma clang diagnostic pop
        
        if (!tags) tags = @"";
        NSLog(@"Tags length: %lu", (unsigned long)tags.length);
        if ([tags rangeOfString:@"heels" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            NSLog(@"FOUND heels in extracted tags!");
        } else {
            NSLog(@"NOT FOUND. Tags prefix: %@", [tags substringToIndex:MIN(100, tags.length)]);
        }
    }
    return 0;
}
