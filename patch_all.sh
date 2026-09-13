cat << 'INNER_EOF' > /tmp/diag_nsfile.m
	} else if ([extension isEqualToString:@"png"]) {
		NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:aPath];
		if (file) {
			NSData *fileData = [file readDataOfLength:1024 * 1024]; // Read first 1MB
			[file closeFile];
			if (fileData) {
				const unsigned char *bytes = fileData.bytes;
				NSUInteger len = fileData.length;
				if (len > 8 && bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
					NSUInteger offset = 8;
					while (offset + 8 <= len) {
						uint32_t chunkLen = (bytes[offset] << 24) | (bytes[offset+1] << 16) | (bytes[offset+2] << 8) | bytes[offset+3];
						offset += 4;
						char type[5] = { (char)bytes[offset], (char)bytes[offset+1], (char)bytes[offset+2], (char)bytes[offset+3], 0 };
						offset += 4;
						
						if (strcmp(type, "tEXt") == 0 || strcmp(type, "iTXt") == 0) {
							if (offset + chunkLen <= len) {
								char *chunk = malloc(chunkLen);
								if (chunk) {
									memcpy(chunk, bytes + offset, chunkLen);
									for (uint32_t j = 0; j < chunkLen; j++) {
										if (chunk[j] == '\0') chunk[j] = ' ';
									}
									NSString *text = [[NSString alloc] initWithBytes:chunk length:chunkLen encoding:NSUTF8StringEncoding];
									if (!text) text = [[NSString alloc] initWithBytes:chunk length:chunkLen encoding:NSASCIIStringEncoding];
									if (text) { [result appendString:text]; [result appendString:@"\n"]; }
									free(chunk);
								}
							}
						}
						offset += chunkLen + 4; // skip chunk data and CRC
					}
				}
			}
		}
INNER_EOF
awk '
/} else if \(\[extension isEqualToString:@"png"\]\) {/ {
    p = 1
    system("cat /tmp/diag_nsfile.m")
    next
}
p && /} else if \(IsHeif\(extension\)\) {/ {
    p = 0
    print $0
    next
}
!p { print $0 }
' exiftags/DYExiftags.m > /tmp/DYExiftags_new.m
mv /tmp/DYExiftags_new.m exiftags/DYExiftags.m

cat << 'INNER_EOF2' > /tmp/diag_ui.m
                                if ((++i & 127) == 0)
                                    [self updateStatusOnMainThread:^NSString *{
                                        return [NSString stringWithFormat:@"%@ (%lu)", loadingMsg, i];
                                    }];
                                
                                static NSTimeInterval lastUIDate = 0;
                                NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
                                if (now - lastUIDate > 0.3) {
                                    lastUIDate = now;
                                    NSArray *currentFilenames = [filenames copy];
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        if (self->currCat == 0) {
                                            [self->displayedFilenames setArray:currentFilenames];
                                            [self reloadMatrix];
                                        }
                                    });
                                }
                            }
INNER_EOF2
awk '
/if \(\(\+\+i & 127\) == 0\)/ {
    p = 1
    system("cat /tmp/diag_ui.m")
    next
}
p && /                            }/ {
    p = 0
    next
}
!p { print $0 }
' CreeveyMainWindowController.m > /tmp/CreeveyMainWindowController_new.m
mv /tmp/CreeveyMainWindowController_new.m CreeveyMainWindowController.m

/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild build -project creevey.xcodeproj -scheme "Phoenix Slides" -configuration Release CODE_SIGN_IDENTITY= CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO > /dev/null
rm -rf "/Applications/Phoenix Slides.app" 
cp -R "DerivedData/creevey/Build/Products/Release/Phoenix Slides.app" "/Applications/"
