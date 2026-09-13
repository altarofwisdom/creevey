with open('/Users/yoto/Projects/creevey/DYImageCache.m', 'r') as f:
    content = f.read()

# Remove NSCacheDelegate from interface
content = content.replace('@interface DYImageCache () <NSCacheDelegate>', '@interface DYImageCache ()')

# Remove properties
content = content.replace("""	NSUInteger _count;
	NSUInteger _totalCost;
	
""", "")

# Remove count, totalCost, willEvictObject
methods_to_remove = """- (NSUInteger)count {
    NSUInteger c;
    @synchronized(self) { c = _count; }
    return c;
}

- (NSUInteger)totalCost {
    NSUInteger c;
    @synchronized(self) { c = _totalCost; }
    return c;
}

- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
    @synchronized(self) {
        if (_count > 0) _count--;
        if ([obj isKindOfClass:[DYImageInfo class]]) {
            NSImage *img = [(DYImageInfo *)obj image];
            if (img) {
                NSUInteger c = (NSUInteger)(img.size.width * img.size.height * 4);
                if (c < 1024) c = 1024;
                if (_totalCost >= c) _totalCost -= c; else _totalCost = 0;
            }
        }
    }
}
"""
content = content.replace(methods_to_remove, "")

# Fix initWithCapacity
old_init = """- (instancetype)initWithCapacity:(NSUInteger)n {
	if (self = [super init]) {
		images = [[NSCache alloc] init];
        images.delegate = self;
		images.totalCostLimit = n * 1024 * 1024;
		images.countLimit = 0; // Remove limit on number of images
		images.evictsObjectsWithDiscardedContent = YES;
		pending = [[NSMutableSet alloc] init];
		_maxCount = n;
"""
new_init = """- (instancetype)initWithCapacity:(NSUInteger)n {
	if (self = [super init]) {
		images = [[NSCache alloc] init];
		images.countLimit = n;
		images.evictsObjectsWithDiscardedContent = YES;
		pending = [[NSMutableSet alloc] init];
		_maxCount = n;
"""
content = content.replace(old_init, new_init)

# Remove setCacheLimitMB
set_cache = """- (void)setCacheLimitMB:(NSNumber *)mb {
    images.totalCostLimit = [mb unsignedIntegerValue] * 1024 * 1024;
}

"""
content = content.replace(set_cache, "")

# Fix setObject block
old_set = """			[images setObject:imgInfo forKey:s cost:cost];
            if (!wasInCache) {
                @synchronized(self) { _count++; _totalCost += cost; }
            } else {
                @synchronized(self) { _totalCost += cost; }
            }"""
new_set = """			[images setObject:imgInfo forKey:s];"""
content = content.replace(old_set, new_set)

# Remove cost calculation
cost_calc = """            BOOL wasInCache = ([images objectForKey:s] != nil);
            NSUInteger cost = 0;
            if (imgInfo.image) {
                NSSize size = imgInfo.image.size;
                cost = (NSUInteger)(size.width * size.height * 4);
                // Si l'image n'a pas de taille définie correctement, mettre un minimum
                if (cost < 1024) cost = 1024;
            }
"""
content = content.replace(cost_calc, "")

# Remove removeObjectForKey additions
old_rem = """        BOOL wasInCache = ([images objectForKey:s] != nil);
		[images removeObjectForKey:s];
        if (wasInCache) {
            @synchronized(self) { if (_count > 0) _count--; }
        }"""
new_rem = """		[images removeObjectForKey:s];"""
content = content.replace(old_rem, new_rem)

# Remove removeAllObjects addition
old_remall = """	_stupidCacheWorkaround = nil;
    @synchronized(self) { _count = 0; _totalCost = 0; }"""
new_remall = """	_stupidCacheWorkaround = nil;"""
content = content.replace(old_remall, new_remall)


with open('/Users/yoto/Projects/creevey/DYImageCache.m', 'w') as f:
    f.write(content)
print("Restored DYImageCache.m without losing Zip support!")

