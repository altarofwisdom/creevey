sed -i '' -e '/} else if (IsHeif(extension)) {/i\
	} else if ([extension isEqualToString:@"png"]) {\
		NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:aPath];\
		if (file) {\
			NSData *sig = [file readDataOfLength:8];\
			if (sig.length == 8) {\
				const unsigned char *sigBytes = sig.bytes;\
				if (sigBytes[0] == 0x89 && sigBytes[1] == 0x50 && sigBytes[2] == 0x4E && sigBytes[3] == 0x47) {\
					while (YES) {\
						NSData *lenData = [file readDataOfLength:4];\
						if (lenData.length != 4) break;\
						uint32_t length;\
						[lenData getBytes:\&length length:4];\
						length = CFSwapInt32BigToHost(length);\
						NSData *typeData = [file readDataOfLength:4];\
						if (typeData.length != 4) break;\
						NSString *type = [[NSString alloc] initWithData:typeData encoding:NSASCIIStringEncoding];\
						if ([type isEqualToString:@"tEXt"] || [type isEqualToString:@"iTXt"]) {\
							NSData *chunkData = [file readDataOfLength:length];\
							if (chunkData.length == length) {\
								NSString *text = [[NSString alloc] initWithData:chunkData encoding:NSUTF8StringEncoding];\
								if (!text) text = [[NSString alloc] initWithData:chunkData encoding:NSASCIIStringEncoding];\
								if (text) { [result appendString:text]; [result appendString:@"\\n"]; }\
							}\
						} else {\
							[file seekToFileOffset:[file offsetInFile] + length];\
						}\
						[file seekToFileOffset:[file offsetInFile] + 4];\
					}\
				}\
			}\
			[file closeFile];\
		}\
' exiftags/DYExiftags.m
