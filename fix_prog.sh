cat << 'INNER_EOF' > /tmp/diag_prog.m
							if (passesFilter) {
                                if ([aPath containsString:@"::"]) {
                                    NSLog(@"[MainWindow] Added virtual file to matrix: %@", aPath);
                                }
                                [filenames addObject:aPath];
                                if (startSlideshowWhenReady && [filesBeingOpened containsObject:aPath])
                                    [filesForSlideshow addObject:aPath];
                                
                                if (self.searchString.length > 0) {
                                    // PROGRESSIVE LOADING FOR SEARCH!
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        if (self->currCat == 0) {
                                            [self->displayedFilenames addObject:aPath];
                                            NSImage *cachedImage = [appDelegate.thumbsCache imageForKeyInvalidatingCacheIfNecessary:aPath];
                                            if (cachedImage) {
                                                [appDelegate.thumbsCache beginAccess:aPath];
                                            }
                                            [self->imgMatrix addImage:cachedImage ?: (id)[NSNull null] withFilename:aPath];
                                            [self->imgMatrix setNeedsDisplay:YES];
                                            
                                            if (!cachedImage && !self->imgMatrix.listViewMode) {
                                                [self->imageCacheQueueLock lock];
                                                [self->secondaryImageCacheQueue addObject:[[DYMatrixFileInfo alloc] initWithPath:aPath index:self->displayedFilenames.count - 1]];
                                                [self->imageCacheQueueLock unlockWithCondition:1];
                                            }
                                        }
                                        self.statusFld.stringValue = [NSString stringWithFormat:NSLocalizedString(@"Found %lu images...", @""), (unsigned long)self->displayedFilenames.count];
                                    });
                                } else {
                                    if ((++i & 127) == 0)
                                        [self updateStatusOnMainThread:^NSString *{
                                            return [NSString stringWithFormat:@"%@ (%lu)", loadingMsg, i];
                                        }];
                                }
                            }
INNER_EOF
awk '
/if \(passesFilter\) \{/ {
    p = 1
    system("cat /tmp/diag_prog.m")
    next
}
p && /if \(\(\+\+i & 127\) == 0\)/ {
    skip = 1
    next
}
skip && /                            \}/ {
    skip = 0
    p = 0
    next
}
!p { print $0 }
' CreeveyMainWindowController.m > /tmp/CreeveyMainWindowController_new.m
mv /tmp/CreeveyMainWindowController_new.m CreeveyMainWindowController.m

cat << 'INNER_EOF2' > /tmp/diag_prog2.m
		if (filenames.count && self.searchString.length == 0) {
			[self updateStatusOnMainThread:^NSString *{
				return [NSString stringWithFormat:NSLocalizedString(@"Sorting %lu filenames…", @""), filenames.count];
			}];
			[filenames sortUsingComparator:self.comparator];
		}
		if (currCat) { // currCat > 0 whenever cat changes (see keydown)
			// this means deleting when a cat is displayed will cause unsightly flashing
			// but we can live with that for now. maybe temp set currcat to 0?
			[self clearImageCacheQueue];
			[displayedFilenames removeAllObjects];
			if (currCat == 1) {
				currCat = 0;
				[displayedFilenames addObjectsFromArray:filenames];
			} else {
				for (NSString *path in filenames) {
					if ([appDelegate.cats[currCat-2] containsObject:path])
						[displayedFilenames addObject:path];
				}
			}
		} else if (self.searchString.length == 0) {
			[displayedFilenames setArray:filenames];
		}
INNER_EOF2
awk '
/if \(filenames.count\) \{/ {
    p = 1
    system("cat /tmp/diag_prog2.m")
    next
}
p && /\} else \{/ {
    skip2 = 1
    next
}
skip2 && /\[displayedFilenames setArray:filenames\];/ {
    next
}
skip2 && /^\t\t\}/ {
    skip2 = 0
    p = 0
    next
}
!p { print $0 }
' CreeveyMainWindowController.m > /tmp/CreeveyMainWindowController_new2.m
mv /tmp/CreeveyMainWindowController_new2.m CreeveyMainWindowController.m

cat << 'INNER_EOF3' > /tmp/diag_prog3.m
#pragma mark populate matrix
	@autoreleasepool {
		DYImageCache *thumbsCache = appDelegate.thumbsCache;
		[self removeAllPathsFromAccessedFilesArray];

		NSUInteger i = 0;
		NSMutableIndexSet *selectedIndexes = [NSMutableIndexSet indexSet];
		if (displayedFilenames.count > 0 && self.searchString.length == 0) {
INNER_EOF3
awk '
/#pragma mark populate matrix/ {
    p = 1
    system("cat /tmp/diag_prog3.m")
    next
}
p && /if \(displayedFilenames.count > 0\) \{/ {
    p = 0
    next
}
!p { print $0 }
' CreeveyMainWindowController.m > /tmp/CreeveyMainWindowController_new3.m
mv /tmp/CreeveyMainWindowController_new3.m CreeveyMainWindowController.m

/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild build -project creevey.xcodeproj -scheme "Phoenix Slides" -configuration Release CODE_SIGN_IDENTITY= CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO > /dev/null
rm -rf "/Applications/Phoenix Slides.app" 
cp -R "DerivedData/creevey/Build/Products/Release/Phoenix Slides.app" "/Applications/"
