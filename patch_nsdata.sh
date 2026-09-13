cat << 'INNER_EOF' > /tmp/diag_nsdata.m
	} else if ([extension isEqualToString:@"png"]) {
		NSData *fileData = [NSData dataWithContentsOfFile:aPath];
		if (fileData) {
			const unsigned char *bytes = fileData.bytes;
			NSUInteger len = fileData.length;
			if (len > 8 && bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
				NSUInteger offset = 8;
				while (offset + 8 <= len) {
					uint32_t chunkLen = (bytes[offset] << 24) | (bytes[offset+1] << 16) | (bytes[offset+2] << 8) | bytes[offset+3];
					offset += 4;
					char type[5] = { bytes[offset], bytes[offset+1], bytes[offset+2], bytes[offset+3], 0 };
					offset += 4;
					
					if (strcmp(type, "tEXt") == 0 || strcmp(type, "iTXt") == 0) {
						if (offset + chunkLen <= len) {
							char *chunk = malloc(chunkLen);
							if (chunk) {
								memcpy(chunk, bytes + offset, chunkLen);
								for (uint32_t i = 0; i < chunkLen; i++) {
									if (chunk[i] == '\0') chunk[i] = ' ';
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
INNER_EOF
awk '
/} else if \(\[extension isEqualToString:@"png"\]\) {/ {
    p = 1
    system("cat /tmp/diag_nsdata.m")
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

# Recompile the app
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild build -project creevey.xcodeproj -scheme "Phoenix Slides" -configuration Release CODE_SIGN_IDENTITY= CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO > /dev/null

# Make sure to deploy and open for the user to test manually (AGENTS.md principle 1)
rm -rf "/Applications/Phoenix Slides.app" 
cp -R "DerivedData/creevey/Build/Products/Release/Phoenix Slides.app" "/Applications/"
open "/Applications/Phoenix Slides.app"
