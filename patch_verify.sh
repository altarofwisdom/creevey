cat << 'INNER_EOF' > /tmp/diag_verify.m
	} else if ([extension isEqualToString:@"png"]) {
		FILE *f = fopen(aPath.fileSystemRepresentation, "rb");
		if (f) {
			unsigned char sig[8];
			if (fread(sig, 1, 8, f) == 8) {
				if (sig[0] == 0x89 && sig[1] == 0x50 && sig[2] == 0x4E && sig[3] == 0x47) {
					while (YES) {
						uint32_t length;
						if (fread(&length, 4, 1, f) != 1) break;
						length = CFSwapInt32BigToHost(length);
						char type[5] = {0};
						if (fread(type, 1, 4, f) != 1) break;
						if (strcmp(type, "tEXt") == 0 || strcmp(type, "iTXt") == 0) {
							char *chunk = malloc(length);
							if (chunk) {
								if (fread(chunk, 1, length, f) == length) {
                                    for (uint32_t i = 0; i < length; i++) {
                                        if (chunk[i] == '\0') chunk[i] = ' ';
                                    }
									NSString *text = [[NSString alloc] initWithBytes:chunk length:length encoding:NSUTF8StringEncoding];
									if (!text) text = [[NSString alloc] initWithBytes:chunk length:length encoding:NSASCIIStringEncoding];
									if (text) { [result appendString:text]; [result appendString:@"\n"]; }
								} else {
                                    if ([aPath.lastPathComponent isEqualToString:@"Krea2_2026-08-17-130205_323732324843832.png"]) NSLog(@"[VERIFY] fread chunk failed! length=%u, ferror=%d", length, ferror(f));
                                }
								free(chunk);
							} else {
								fseeko(f, length, SEEK_CUR);
							}
						} else {
							fseeko(f, length, SEEK_CUR);
						}
						fseeko(f, 4, SEEK_CUR); // CRC
					}
				} else {
                    if ([aPath.lastPathComponent isEqualToString:@"Krea2_2026-08-17-130205_323732324843832.png"]) NSLog(@"[VERIFY] sig mismatch!");
                }
			} else {
                if ([aPath.lastPathComponent isEqualToString:@"Krea2_2026-08-17-130205_323732324843832.png"]) NSLog(@"[VERIFY] fread sig failed!");
            }
			fclose(f);
		} else {
            if ([aPath.lastPathComponent isEqualToString:@"Krea2_2026-08-17-130205_323732324843832.png"]) NSLog(@"[VERIFY] fopen failed! errno=%d (%s)", errno, strerror(errno));
        }
INNER_EOF
awk '
/} else if \(\[extension isEqualToString:@"png"\]\) {/ {
    p = 1
    system("cat /tmp/diag_verify.m")
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
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild build -project creevey.xcodeproj -scheme "Phoenix Slides" -configuration Release CODE_SIGN_IDENTITY= CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO > /dev/null
rm -rf "/Applications/Phoenix Slides.app" && cp -R "DerivedData/creevey/Build/Products/Release/Phoenix Slides.app" "/Applications/"
