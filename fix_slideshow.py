import sys

with open('/Users/yoto/Projects/creevey/SlideshowWindow.m', 'r') as f:
    content = f.read()

start_idx = content.find('- (void)displayImage {')
end_marker = "}\n\n- (void)showLoopAnimation {"
end_idx = content.find(end_marker, start_idx) + 1

if start_idx == -1 or end_idx == -1:
    print("Could not find displayImage")
    sys.exit(1)

new_display_image = """- (void)displayImage {
	if (currentIndex == NSNotFound) return; // in case called after slideshow ended
	
	[_upcomingQueue cancelAllOperations];
	
	if (currentIndex == filenames.count) {
		catsFld.hidden = YES;
		infoFld.hidden = NO;
		infoFld.stringValue = NSLocalizedString(@"End of slideshow (last file was deleted)", @"");
		[infoFld sizeToFit];
		exifFld.string = @"";
		for (DYImageView *v in mosaicViews) v.image = nil;
		self.title = NSProcessInfo.processInfo.processName;
		return;
	}
	
	if (randomMode && _mosaicCount > 1 && currentIndex < filenames.count) {
		static NSUInteger lastClusteredIndex = NSNotFound;
		if (currentIndex != lastClusteredIndex) {
			lastClusteredIndex = currentIndex;
			double targetAR = [self fastAspectRatioForFile:filenames[currentIndex]];
			for (NSUInteger m = 1; m < _mosaicCount; m++) {
				NSUInteger slot = currentIndex + m;
				if (slot >= filenames.count) break;
				
				NSUInteger bestIdx = slot;
				double bestDiff = INFINITY;
				NSUInteger searchEnd = MIN(filenames.count, slot + 50);
				for (NSUInteger k = slot; k < searchEnd; k++) {
					double ar = [self fastAspectRatioForFile:filenames[k]];
					double diff = fabs(ar - targetAR);
					if (diff < bestDiff) {
						bestDiff = diff;
						bestIdx = k;
						if (diff < 0.05) break; // good enough
					}
				}
				if (bestIdx != slot) {
					[filenames exchangeObjectAtIndex:slot withObjectAtIndex:bestIdx];
				}
			}
		}
	}
	
	if (imgCache.boundingSize.width == 0) {
		[self layoutMosaic];
	}
	
	BOOL allReady = YES;
	NSMutableArray *loadedImages = [NSMutableArray arrayWithCapacity:_mosaicCount];
	for (NSUInteger m = 0; m < _mosaicCount; m++) {
		NSUInteger idx = currentIndex + m;
		if (idx >= filenames.count) {
			[loadedImages addObject:[NSNull null]];
			continue;
		}
		NSString *theFile = filenames[idx];
		NSString *resolvedPath = ResolveAliasToPath(theFile);
		NSImage *img = [self loadFromCache:resolvedPath];
		if (!img) {
			allReady = NO;
			[loadedImages addObject:[NSNull null]];
		} else {
			[loadedImages addObject:img];
		}
	}
	
	if (!allReady) {
		if (hideInfoFld) infoFld.hidden = NO;
		infoFld.stringValue = [NSString stringWithFormat:NSLocalizedString(@"Loading [%i/%i]...", @""),
			(unsigned int)currentIndex+1, (unsigned int)filenames.count];
		[infoFld sizeToFit];
		return; 
	}
	
	[self layoutMosaic];
	
	for (NSUInteger m = 0; m < _mosaicCount; m++) {
		NSUInteger idx = currentIndex + m;
		if (idx >= filenames.count) {
			if (m < mosaicViews.count) mosaicViews[m].image = nil;
			continue;
		}
		NSString *theFile = filenames[idx];
		NSString *resolvedPath = ResolveAliasToPath(theFile);
		if (m == 0) [self setTitleWithRepresentedFilename:theFile];
		NSImage *img = loadedImages[m];
		if (m == 0) [self displayCats];
		if (img != (id)[NSNull null] && m < mosaicViews.count) {
			DYImageView *v = mosaicViews[m];
			NSNumber *rot = rotations[theFile];
			DYImageViewZoomInfo *zoomInfo = zooms[theFile];
			int r = rot ? rot.intValue : 0;
			BOOL imgFlipped = [flips[theFile] boolValue];
			
			if (m == 0 && hideInfoFld) infoFld.hidden = YES;
			v.preferWhiteBackground = IsNotCGImage(resolvedPath.pathExtension.lowercaseString);
			DYImageInfo *info = [imgCache infoForKey:resolvedPath];
			if (autoRotate && !rot && !imgFlipped && info && info->exifOrientation > 1) {
				exiforientation_to_components(info->exifOrientation, &r, &imgFlipped);
				rotations[theFile] = @(r);
				flips[theFile] = @(imgFlipped);
			}
			if (m == 0) [self resizeWindowToFit];
			if (m == 0) {
				if ((zoomInfo || v.showActualSize) && (!info || !info.hasFullSizeImage))
					[self loadFullSizeImage];
				else if (info && info->quality == DYImageQualityLow)
					[self loadNicerImage];
			}
			[v setImage:img withSize:(info ? info->pixelSize : img.size) rotated:r flipped:imgFlipped zoomInfo:zoomInfo];
			if ([theFile.pathExtension.lowercaseString isEqualToString:@"webp"]) {
				CGImageSourceRef src = [ArchiveManager imageSourceForPath:theFile];
				if (src) {
					if (CGImageSourceGetCount(src) > 1)
						v.webpImageSource = CFBridgingRelease(src);
					else
						CFRelease(src);
				}
			}
			if (m == 0) {
				[self updateInfoFld];
				if (!exifFld.enclosingScrollView.hidden) [self updateExifFld];
				if (timerIntvl) [self runTimer];
			}
		} else {
			if (m < mosaicViews.count) mosaicViews[m].image = nil;
		}
	}
	
	if (keyIsRepeating) return; 
	
	if (self.isMainWindow && !imgView.dragMode)
		[NSCursor setHiddenUntilMouseMoves:YES];

	DYImageQuality q = imgView.showActualSize ? DYImageQualityFull : DYImageQualityHigh;

	for (short i=0; i<MAX(30, _mosaicCount * 6); i++) {
		if (currentIndex + _mosaicCount + i >= filenames.count)
			break;
		NSString *aPath = ResolveAliasToPath(filenames[currentIndex + _mosaicCount + i]);
		[_upcomingQueue addOperationWithBlock:^{
			[imgCache cacheFile:aPath fullSize:q];
		}];
	}
}"""

content = content[:start_idx] + new_display_image + content[end_idx:]

with open('/Users/yoto/Projects/creevey/SlideshowWindow.m', 'w') as f:
    f.write(content)
print("Fixed displayImage!")

