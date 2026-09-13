with open('/Users/yoto/Projects/creevey/SlideshowWindow.h', 'r') as f:
    h_content = f.read()

h_content = h_content.replace("""
@interface SlideshowWindow () {
	NSTextField *cachingIndicatorFld;
	NSTimer *cachingIndicatorTimer;
}
@end

@end
""", "@end")

with open('/Users/yoto/Projects/creevey/SlideshowWindow.h', 'w') as f:
    f.write(h_content)
