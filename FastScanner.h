#import <Foundation/Foundation.h>

@interface FastScanner : NSObject
+ (NSArray<NSURL *> *)scanDirectory:(NSString *)path recurse:(BOOL)recurse revealedDirectories:(NSSet<NSURL*>*)revealed stop:(volatile char *)stopFlag;
+ (NSArray<NSURL *> *)scanDirectory:(NSString *)path recurse:(BOOL)recurse revealedDirectories:(NSSet<NSURL*>*)revealed stop:(volatile char *)stopFlag progress:(void (^)(NSUInteger fileCount))progressBlock;
@end
