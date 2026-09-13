with open('/Users/yoto/Projects/creevey/SlideshowWindow.h', 'r') as f:
    h_content = f.read()

interface_code = """
@interface SlideshowWindow () {
	NSTextField *cachingIndicatorFld;
	NSTimer *cachingIndicatorTimer;
}
@end
"""
if "@interface SlideshowWindow ()" not in h_content:
    h_content = h_content.replace('@end\n', f'{interface_code}\n@end\n')

with open('/Users/yoto/Projects/creevey/SlideshowWindow.h', 'w') as f:
    f.write(h_content)


with open('/Users/yoto/Projects/creevey/SlideshowWindow.m', 'r') as f:
    m_content = f.read()

# 1. Insert init
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

		catsFld = [[NSTextField alloc]"""
m_content = m_content.replace('catsFld = [[NSTextField alloc]', init_code, 1)

# 2. Insert cleanup
cleanup_code = """[self killTimer];
    [cachingIndicatorTimer invalidate];
    cachingIndicatorTimer = nil;
"""
m_content = m_content.replace('[self killTimer];\n', cleanup_code, 1)

# 3. Insert resize
resize_code = """- (void)imgViewResized:(id)obj {
    NSRect cvBounds = self.contentView.bounds;
    cachingIndicatorFld.frame = NSMakeRect(cvBounds.size.width - 210, 10, 200, 20);
"""
m_content = m_content.replace('- (void)imgViewResized:(id)obj {\n', resize_code, 1)

# 4. Insert method
method_code = """- (void)updateCachingIndicator {
    BOOL isCaching = _upcomingQueue.operationCount > 0;
    NSUInteger cacheSize = imgCache.count;
    
    static BOOL blinkState = NO;
    blinkState = !blinkState;
    
    NSString *cacheWord = (isCaching && blinkState) ? @"caching..." : (isCaching ? @"           " : @"          ");
    cachingIndicatorFld.stringValue = [NSString stringWithFormat:@"%@ [%lu images]", cacheWord, (unsigned long)cacheSize];
    cachingIndicatorFld.hidden = NO;
}

@end"""
m_content = m_content.replace('@end\n', f'{method_code}\n')

with open('/Users/yoto/Projects/creevey/SlideshowWindow.m', 'w') as f:
    f.write(m_content)

