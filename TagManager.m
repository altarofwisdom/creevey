#import "TagManager.h"
#import <sys/xattr.h>

@interface TagManager ()
@property (nonatomic, strong) NSOperationQueue *tagQueue;
@end

@implementation TagManager

+ (instancetype)sharedManager {
    static TagManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _tagQueue = [[NSOperationQueue alloc] init];
        _tagQueue.name = @"com.creevey.TagScanQueue";
        // 32 concurrent operations to maximize SMB gigabit throughput without burning CPU
        _tagQueue.maxConcurrentOperationCount = 32;
        _tagQueue.qualityOfService = NSQualityOfServiceUtility;
    }
    return self;
}

- (void)fetchTagsForURL:(NSURL *)url completion:(void (^)(NSArray<NSString *> *tags))completion {
    if (!url || !completion) return;
    
    [self.tagQueue addOperationWithBlock:^{
        const char *fsPath = [url.path fileSystemRepresentation];
        if (!fsPath) {
            if (completion) completion(nil);
            return;
        }
        
        ssize_t size = getxattr(fsPath, "com.apple.metadata:_kMDItemUserTags", NULL, 0, 0, 0);
        if (size <= 0) {
            if (completion) completion(nil);
            return;
        }
        
        char *buffer = malloc(size);
        if (!buffer) {
            if (completion) completion(nil);
            return;
        }
        
        size_t bytesRead = getxattr(fsPath, "com.apple.metadata:_kMDItemUserTags", buffer, size, 0, 0);
        if (bytesRead > 0) {
            NSData *plistData = [NSData dataWithBytesNoCopy:buffer length:bytesRead freeWhenDone:YES];
            NSError *error = nil;
            id plist = [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListImmutable format:nil error:&error];
            
            if ([plist isKindOfClass:[NSArray class]]) {
                NSArray *tagsArray = (NSArray *)plist;
                NSMutableArray *cleanedTags = [NSMutableArray array];
                for (NSString *tagEntry in tagsArray) {
                    if ([tagEntry isKindOfClass:[NSString class]]) {
                        // Tag entries in bplist are often in format "TagName\nColorID"
                        NSArray *components = [tagEntry componentsSeparatedByString:@"\n"];
                        if (components.count > 0) {
                            [cleanedTags addObject:components.firstObject];
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{ completion([cleanedTags copy]); });
                return;
            }
        } else {
            free(buffer);
        }
        
        if (completion) completion(nil);
    }];
}

- (void)writeTags:(NSArray<NSString *> *)tags toURL:(NSURL *)url completion:(void (^)(BOOL success, NSError *error))completion {
    if (!url) {
        if (completion) completion(NO, nil);
        return;
    }
    
    // Writing tags is done via NSURLTagNamesKey to ensure Finder and macOS get notified properly
    [self.tagQueue addOperationWithBlock:^{
        NSError *error = nil;
        BOOL success = [url setResourceValue:tags forKey:NSURLTagNamesKey error:&error];
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(success, error);
            });
        }
    }];
}

@end
