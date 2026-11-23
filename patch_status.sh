#!/bin/bash
sed -i '' 's/@property (nonatomic, strong) NSSearchField \*searchField;/@property (nonatomic, strong) NSSearchField \*searchField;\n@property (nonatomic, strong) NSString \*scanStatusText;\n@property (nonatomic, strong) NSString \*thumbStatusText;/g' CreeveyMainWindowController.m

sed -i '' 's/- (void)updateStatusOnMainThread:(NSString \* (\^)(void))f {/- (void)updateStatusOnMainThread:(NSString \* (\^)(void))f isThumb:(BOOL)isThumb {/g' CreeveyMainWindowController.m

cat << 'INNER' > script.awk
/- \(void\)updateStatusOnMainThread:\(NSString \* \(\^\)\(void\)\)f isThumb:\(BOOL\)isThumb \{/ {
    print $0
    print "\tNSTimeInterval timeStamp = _statusTime = NSDate.timeIntervalSinceReferenceDate;"
    print "\tdispatch_async(dispatch_get_main_queue(), ^{"
    print "\t\tif (_statusTime > timeStamp) return;"
    print "\t\tNSString *s = f();"
    print "\t\tif (isThumb) {"
    print "\t\t\tself.thumbStatusText = s;"
    print "\t\t} else {"
    print "\t\t\tself.scanStatusText = s;"
    print "\t\t}"
    print "\t\tif (self.thumbStatusText.length && self.scanStatusText.length) {"
    print "\t\t\tstatusFld.stringValue = [NSString stringWithFormat:@\"%@ - %@\", self.scanStatusText, self.thumbStatusText];"
    print "\t\t} else if (self.thumbStatusText.length) {"
    print "\t\t\tstatusFld.stringValue = self.thumbStatusText;"
    print "\t\t} else {"
    print "\t\t\tstatusFld.stringValue = self.scanStatusText ?: @\"\";"
    print "\t\t}"
    print "\t});"
    print "}"
    skip = 1
    next
}
skip && /^\}/ { skip = 0; next }
skip { next }

/- \(void\)updateStatusString:\(NSString \*\)s \{/ {
    print $0
    print "\t_statusTime = NSDate.timeIntervalSinceReferenceDate;"
    print "\tself.scanStatusText = s;"
    print "\tif (self.thumbStatusText.length && self.scanStatusText.length) {"
    print "\t\tstatusFld.stringValue = [NSString stringWithFormat:@\"%@ - %@\", self.scanStatusText, self.thumbStatusText];"
    print "\t} else if (self.thumbStatusText.length) {"
    print "\t\tstatusFld.stringValue = self.thumbStatusText;"
    print "\t} else {"
    print "\t\tstatusFld.stringValue = self.scanStatusText ?: @\"\";"
    print "\t}"
    print "}"
    skip = 1
    next
}
{print}
INNER
awk -f script.awk CreeveyMainWindowController.m > tmp.m && mv tmp.m CreeveyMainWindowController.m

# Now we need to update the calls to updateStatusOnMainThread
sed -i '' 's/\[self updateStatusOnMainThread:\^NSString \*{/\[self updateStatusOnMainThread:\^NSString \*{/g' CreeveyMainWindowController.m
# Wait, we need to append isThumb:NO or YES to the end of the block.
