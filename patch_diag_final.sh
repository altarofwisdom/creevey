cat << 'INNER_EOF' > /tmp/diag_patch.m
                            if (self.searchString.length > 0) {
                                NSArray *terms = [self.searchString componentsSeparatedByString:@" "];
                                NSString *exifTags = [DYExiftags tagsForFile:aPath moreTags:YES];
                                if (!exifTags) exifTags = @"";
                                for (NSString *term in terms) {
                                    if (term.length > 0 && [exifTags rangeOfString:term options:NSCaseInsensitiveSearch].location == NSNotFound) {
                                        passesFilter = NO;
                                        break;
                                    }
                                }
                                if ([aPath.lastPathComponent isEqualToString:@"Krea2_2026-08-17-130205_323732324843832.png"]) {
                                    NSLog(@"[DIAGNOSTIC_FINAL] search=%@, tags_length=%lu, passesFilter=%d", self.searchString, (unsigned long)exifTags.length, passesFilter);
                                    if (exifTags.length > 0) {
                                        NSLog(@"[DIAGNOSTIC_FINAL] prefix: %@", [exifTags substringToIndex:MIN(100, exifTags.length)]);
                                        NSLog(@"[DIAGNOSTIC_FINAL] range of heels: %d", (int)[exifTags rangeOfString:@"heels" options:NSCaseInsensitiveSearch].location);
                                    }
                                }
                            }
INNER_EOF
awk '
/if \(self\.searchString\.length > 0\) {/ {
    p = 1
    system("cat /tmp/diag_patch.m")
    next
}
p && /} else if \(IsHeif\(extension\)\) {/ { # wait, this is CreeveyMainWindowController.m!
    # skip lines until the end of the block
}
'
# I need to use replace_file_content or perl for CreeveyMainWindowController.m
