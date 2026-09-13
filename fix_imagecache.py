import re

with open('/Users/yoto/Projects/creevey/DYImageCache.m', 'r') as f:
    content = f.read()

# Replace NSCache with NSMutableDictionary + NSMutableArray
old_decl = """	NSCache<NSString *, DYImageInfo *> *images;
	NSMutableSet<NSString *> *pending;"""
new_decl = """	NSMutableDictionary<NSString *, DYImageInfo *> *images;
	NSMutableArray<NSString *> *cacheKeys;
	NSMutableSet<NSString *> *pending;"""
content = content.replace(old_decl, new_decl)

old_init = """		images = [[NSCache alloc] init];
		images.countLimit = n;
		images.evictsObjectsWithDiscardedContent = YES;
		pending = [[NSMutableSet alloc] init];"""
new_init = """		images = [[NSMutableDictionary alloc] init];
		cacheKeys = [[NSMutableArray alloc] init];
		pending = [[NSMutableSet alloc] init];"""
content = content.replace(old_init, new_init)

old_add = """		if (!cachingShouldStop) {
			// for some reason, very occasionally you can add an object to the cache but it doesn't stick. This results in sort of infinite looping in the slideshow as it creates a cached image which gets immediately discarded, over and over. The slideshow just shows a blank screen with the message "loading...".
			// This could also happen to the thumbnail cache, in which case you'll get a broken doc even if it's a valid file.
			// To work around this we call setObject: repeatedly until it does stick. In testing this appears to be successful with just one additional attempt.
			NSUInteger i = 0;
			do {
				[images setObject:imgInfo forKey:s];
			} while ([images objectForKey:s] == nil && i++ < 10000);
			// If after myriad attempts it is still unsuccessful, hang on to the object to return on the subsequent call to infoForKey/imageForKey. I don't expect this to ever be necessary, but better to avoid any infinite loop.
			if ([images objectForKey:s] == nil)
				_stupidCacheWorkaround = imgInfo;
		}"""
new_add = """		if (!cachingShouldStop) {
			if (!images[s]) {
				[cacheKeys addObject:s];
			}
			images[s] = imgInfo;
			
			while (cacheKeys.count > _maxCount) {
				NSString *oldest = cacheKeys.firstObject;
				[images removeObjectForKey:oldest];
				[cacheKeys removeObjectAtIndex:0];
			}
		}"""
content = content.replace(old_add, new_add)

old_remove = """		if (CacheContains(s)) {
			if (PendingContains(s)) {
				[cacheLock unlock];
				[pendingLock lockWhenCondition:s.hash];
				[pendingLock unlock];
				[cacheLock lock];
			}
			[images removeObjectForKey:s];
		}"""
new_remove = """		if (CacheContains(s)) {
			if (PendingContains(s)) {
				[cacheLock unlock];
				[pendingLock lockWhenCondition:s.hash];
				[pendingLock unlock];
				[cacheLock lock];
			}
			[images removeObjectForKey:s];
			[cacheKeys removeObject:s];
		}"""
content = content.replace(old_remove, new_remove)

old_removeall = """	[cacheLock lock];
	[images removeAllObjects];
	[pending removeAllObjects];"""
new_removeall = """	[cacheLock lock];
	[images removeAllObjects];
	[cacheKeys removeAllObjects];
	[pending removeAllObjects];"""
content = content.replace(old_removeall, new_removeall)

# Add count method
count_method = """- (NSUInteger)count {
	[cacheLock lock];
	NSUInteger c = images.count;
	[cacheLock unlock];
	return c;
}

- (void)beginAccess:(NSString *)key {"""
content = content.replace("- (void)beginAccess:(NSString *)key {", count_method)

with open('/Users/yoto/Projects/creevey/DYImageCache.m', 'w') as f:
    f.write(content)
