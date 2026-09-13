#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *inPath = @"test_in.png";
        NSString *outPath = @"test_out.png";
        
        // create a sample png
        system("screencapture -x test_in.png");
        
        NSURL *url = [NSURL fileURLWithPath:inPath];
        CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
        if (source) {
            CFStringRef type = CGImageSourceGetType(source);
            NSMutableData *destData = [NSMutableData data];
            CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)destData, type, 1, NULL);
            if (destination) {
                NSDictionary *metadata = (__bridge_transfer NSDictionary *)CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
                NSMutableDictionary *mutableMetadata = [metadata mutableCopy];
                mutableMetadata[(NSString *)kCGImagePropertyOrientation] = @(2);
                
                CGError err = kCGErrorSuccess;
                CGImageDestinationAddImageFromSource(destination, source, 0, (__bridge CFDictionaryRef)mutableMetadata);
                if (CGImageDestinationFinalize(destination)) {
                    [destData writeToFile:outPath atomically:YES];
                    NSLog(@"Success");
                }
                CFRelease(destination);
            }
            CFRelease(source);
        }
        
        system("ls -l test_in.png test_out.png");
    }
    return 0;
}
