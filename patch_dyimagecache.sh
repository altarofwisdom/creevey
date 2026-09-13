sed -i '' -e '/result.image = _fallbackImage;/a\
	if (result.exifTags == nil) {\
		result.exifTags = [DYExiftags tagsForFile:s moreTags:YES];\
		if (result.exifTags == nil) result.exifTags = @"";\
	}\
' DYImageCache.m
