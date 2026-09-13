with open('/Users/yoto/Projects/creevey/SlideshowWindow.m', 'r') as f:
    content = f.read()

# Remove cachingIndicatorFld initialization
init_code = """
	cachingIndicatorFld = [[NSTextField alloc] initWithFrame:NSMakeRect(0,0,200,20)];
	[self.contentView addSubview:cachingIndicatorFld];
	cachingIndicatorFld.backgroundColor = [NSColor colorWithCalibratedWhite:0.0 alpha:0.5];
	cachingIndicatorFld.textColor = NSColor.whiteColor;
	cachingIndicatorFld.font = [NSFont systemFontOfSize:10];
	cachingIndicatorFld.alignment = NSTextAlignmentRight;
	cachingIndicatorFld.bezeled = NO;
	cachingIndicatorFld.editable = NO;
	cachingIndicatorFld.selectable = NO;
    cachingIndicatorFld.stringValue = @"";
    
    cachingIndicatorTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateCachingIndicator) userInfo:nil repeats:YES];
"""
content = content.replace(init_code, "")

# Remove timer invalidation
timer_kill = """    [cachingIndicatorTimer invalidate];
    cachingIndicatorTimer = nil;
"""
content = content.replace(timer_kill, "")

# Remove resizing
resize = """    NSRect cvBounds = self.contentView.bounds;
    cachingIndicatorFld.frame = NSMakeRect(cvBounds.size.width - 210, 10, 200, 20);
"""
content = content.replace(resize, "")

# Remove method updateCachingIndicator
method = """- (void)updateCachingIndicator {
    BOOL isCaching = _upcomingQueue.operationCount > 0;
    NSUInteger cacheSize = imgCache.count;
    
    // Blinking effect for the word "caching..."
    static BOOL blinkState = NO;
    blinkState = !blinkState;
    
    NSString *cacheWord = (isCaching && blinkState) ? @"caching..." : (isCaching ? @"           " : @"          ");
    cachingIndicatorFld.stringValue = [NSString stringWithFormat:@"%@ [%lu images]", cacheWord, (unsigned long)cacheSize];
    cachingIndicatorFld.hidden = NO;
}
"""
content = content.replace(method, "")

with open('/Users/yoto/Projects/creevey/SlideshowWindow.m', 'w') as f:
    f.write(content)
print("Removed cachingIndicatorFld")
