/- \(void\)updateStatusString:\(NSString \*\)s \{/ {
    print $0
    print "\t_statusTime = NSDate.timeIntervalSinceReferenceDate;"
    print "\tself.scanStatusText = s;"
    print "\t[self refreshStatusField];"
    print "}"
    print ""
    print "- (void)refreshStatusField {"
    print "\tif (self.isThumbLoading) {"
    print "\t\tNSUInteger total = MAX(self->imgMatrix.numCells, self->filenames.count);"
    print "\t\tif (self->currCat > 0) total = MAX(self->imgMatrix.numCells, self->displayedFilenames.count);"
    print "\t\tif (total >= 10) {"
    print "\t\t\tNSString *loadingMsg = NSLocalizedString(@\"Loading %lu of %lu...\", @\"\");"
    print "\t\t\tNSString *thumbStr = [NSString stringWithFormat:loadingMsg, (unsigned long)self.thumbProgressCount, (unsigned long)total];"
    print "\t\t\tstatusFld.stringValue = [NSString stringWithFormat:@\"%@ - %@\", self.scanStatusText ?: @\"\", thumbStr];"
    print "\t\t\treturn;"
    print "\t\t}"
    print "\t}"
    print "\tstatusFld.stringValue = self.scanStatusText ?: @\"\";"
    print "}"
    skip = 1
    next
}
skip && /^\}/ { skip = 0; next }
skip { next }

/- \(void\)updateStatusOnMainThread:\(NSString \* \(\^\)\(void\)\)f isThumb:\(BOOL\)isThumb \{/ {
    print "- (void)updateStatusOnMainThread:(NSString * (^)(void))f isThumb:(BOOL)isThumb {"
    print "\tNSTimeInterval timeStamp = _statusTime = NSDate.timeIntervalSinceReferenceDate;"
    print "\tdispatch_async(dispatch_get_main_queue(), ^{"
    print "\t\tif (_statusTime > timeStamp) return;"
    print "\t\tself.scanStatusText = f();"
    print "\t\t[self refreshStatusField];"
    print "\t});"
    print "}"
    skip = 1
    next
}
{print}
