#import "FastScanner.h"
#include <dirent.h>
#include <sys/stat.h>

@implementation FastScanner

+ (void)scanDirectory:(const char *)path recurse:(BOOL)recurse revealedDirectories:(NSSet<NSURL*>*)revealed group:(dispatch_group_t)group queue:(dispatch_queue_t)queue results:(NSMutableArray<NSURL *> *)results lock:(NSLock *)lock stop:(volatile char *)stopFlag progress:(void (^)(NSUInteger))progress {
    if (stopFlag && *stopFlag) return;
    
    DIR *dir = opendir(path);
    if (!dir) return;
    
    struct dirent *ent;
    NSMutableArray *localURLs = [NSMutableArray arrayWithCapacity:256];
    NSMutableArray *subdirs = recurse ? [NSMutableArray array] : nil;
    
    while ((ent = readdir(dir)) != NULL) {
        if (stopFlag && *stopFlag) break;
        
        char *name = ent->d_name;
        if (name[0] == '.') {
            if (ent->d_type == DT_DIR) {
                if (name[1] == '\0' || (name[1] == '.' && name[2] == '\0')) continue;
                char full_path[1024];
                snprintf(full_path, sizeof(full_path), "%s/%s", path, name);
                NSURL *url = [NSURL fileURLWithPath:[NSString stringWithUTF8String:full_path] isDirectory:YES];
                if (![revealed containsObject:url]) continue;
            } else {
                continue;
            }
        }
        
        char full_path[1024];
        snprintf(full_path, sizeof(full_path), "%s/%s", path, name);
        
        if (ent->d_type == DT_DIR) {
            if (strcmp(name, "Thumbs") == 0) continue;
            if (recurse) {
                [subdirs addObject:[NSString stringWithUTF8String:full_path]];
            }
        } else if (ent->d_type == DT_REG || ent->d_type == DT_UNKNOWN || ent->d_type == DT_LNK) {
            NSURL *url = [NSURL fileURLWithPath:[NSString stringWithUTF8String:full_path] isDirectory:NO];
            [localURLs addObject:url];
        }
    }
    closedir(dir);
    
    if (localURLs.count > 0 && !(stopFlag && *stopFlag)) {
        [lock lock];
        [results addObjectsFromArray:localURLs];
        NSUInteger count = results.count;
        [lock unlock];
        if (progress) progress(count);
    }
    
    for (NSString *subdir in subdirs) {
        if (stopFlag && *stopFlag) break;
        dispatch_group_async(group, queue, ^{
            [self scanDirectory:subdir.UTF8String recurse:recurse revealedDirectories:revealed group:group queue:queue results:results lock:lock stop:stopFlag progress:progress];
        });
    }
}

+ (NSArray<NSURL *> *)scanDirectory:(NSString *)path recurse:(BOOL)recurse revealedDirectories:(NSSet<NSURL*>*)revealed stop:(volatile char *)stopFlag progress:(void (^)(NSUInteger))progress {
    NSMutableArray<NSURL *> *results = [NSMutableArray array];
    NSLock *lock = [[NSLock alloc] init];
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    dispatch_group_async(group, queue, ^{
        [self scanDirectory:path.UTF8String recurse:recurse revealedDirectories:revealed group:group queue:queue results:results lock:lock stop:stopFlag progress:progress];
    });
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    return [results copy];
}

+ (NSArray<NSURL *> *)scanDirectory:(NSString *)path recurse:(BOOL)recurse revealedDirectories:(NSSet<NSURL*>*)revealed stop:(volatile char *)stopFlag {
    return [self scanDirectory:path recurse:recurse revealedDirectories:revealed stop:stopFlag progress:nil];
}

@end
