with open('/Users/yoto/Projects/creevey/SlideshowWindow.h', 'r') as f:
    content = f.read()

content = content.replace("NSTextField *cachingIndicatorFld;", "")
content = content.replace("NSTimer *cachingIndicatorTimer;", "")

with open('/Users/yoto/Projects/creevey/SlideshowWindow.h', 'w') as f:
    f.write(content)
