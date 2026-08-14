#import <Foundation/Foundation.h>

@interface TagManager : NSObject

+ (instancetype)sharedManager;

// Fetches the tags for a given file URL. This method operates asynchronously
// and will call the completion block on the main thread when finished.
- (void)fetchTagsForURL:(NSURL *)url completion:(void (^)(NSArray<NSString *> *tags))completion;

// Writes a set of tags to the given file URL.
// Operates asynchronously and calls the completion block on the main thread.
- (void)writeTags:(NSArray<NSString *> *)tags toURL:(NSURL *)url completion:(void (^)(BOOL success, NSError *error))completion;

// The asynchronous operation queue used for fetching and writing tags
@property (nonatomic, strong, readonly) NSOperationQueue *tagQueue;

@end
