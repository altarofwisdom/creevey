with open('/Users/yoto/Projects/creevey/SlideshowWindow.m', 'r') as f:
    m_content = f.read()

m_content = m_content.replace("""@interface SlideshowWindow ()
- (void)updateCachingIndicator
@end""", "")

interface_code = """
@interface SlideshowWindow () {
	NSTextField *cachingIndicatorFld;
	NSTimer *cachingIndicatorTimer;
}
- (void)updateCachingIndicator;
@end
"""
if "@interface SlideshowWindow () {" not in m_content:
    m_content = m_content.replace('@implementation SlideshowWindow', f'{interface_code}\n@implementation SlideshowWindow')

with open('/Users/yoto/Projects/creevey/SlideshowWindow.m', 'w') as f:
    f.write(m_content)
