#import <Foundation/Foundation.h>

@interface FastScanner : NSObject
+ (NSArray<NSURL *> *)scanDirectory:(NSString *)path recurse:(BOOL)recurse revealedDirectories:(NSSet<NSURL*>*)revealed stop:(volatile char *)stopFlag;
@end
