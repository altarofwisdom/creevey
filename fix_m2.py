with open('/Users/yoto/Projects/creevey/SlideshowWindow.m', 'r') as f:
    m_content = f.read()

# Remove the broken method implementations
broken1 = """- (void)updateCachingIndicator {
    BOOL isCaching = _upcomingQueue.operationCount > 0;
    NSUInteger cacheSize = imgCache.count;
    
    static BOOL blinkState = NO;
    blinkState = !blinkState;
    
    NSString *cacheWord = (isCaching && blinkState) ? @"caching..." : (isCaching ? @"           " : @"          ");
    cachingIndicatorFld.stringValue = [NSString stringWithFormat:@"%@ [%lu images]", cacheWord, (unsigned long)cacheSize];
    cachingIndicatorFld.hidden = NO;
}
"""
m_content = m_content.replace(broken1, "")

broken2 = """	NSTextField *infoFld, *catsFld, *cachingIndicatorFld; BOOL hideInfoFld, moreExif;
	NSTextView *exifFld;
	NSTimer *cachingIndicatorTimer;"""
m_content = m_content.replace(broken2, """	NSTextField *infoFld, *catsFld; BOOL hideInfoFld, moreExif;
	NSTextView *exifFld;""")

with open('/Users/yoto/Projects/creevey/SlideshowWindow.m', 'w') as f:
    f.write(m_content)
