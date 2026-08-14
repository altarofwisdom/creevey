#import "ArchiveManager.h"
#import <XADMaster/XADArchive.h>
#import <ApplicationServices/ApplicationServices.h>

NSString * const ArchiveVirtualPathSeparator = @"::";

@implementation ArchiveManager

+ (BOOL)isSupportedArchive:(NSString *)path {
    NSString *ext = [path pathExtension].lowercaseString;
    NSSet *supported = [NSSet setWithObjects:@"zip", @"cbz", @"rar", @"cbr", @"7z", @"cb7", @"tar", nil];
    return [supported containsObject:ext];
}

+ (NSURL *)virtualURLForArchive:(NSString *)archivePath internalPath:(NSString *)internalPath {
    NSString *combined = [NSString stringWithFormat:@"%@%@%@", archivePath, ArchiveVirtualPathSeparator, internalPath];
    // On utilise un scheme personnalisé 'creevey://' pour éviter que macOS tente de le résoudre comme un fichier normal.
    // L'URL conservera le chemin entier dans sa partie 'path'.
    NSString *urlString = [NSString stringWithFormat:@"creevey://%@", [combined stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]]];
    return [NSURL URLWithString:urlString];
}

+ (BOOL)parseVirtualURL:(NSURL *)url archivePath:(NSString * __autoreleasing *)outArchivePath internalPath:(NSString * __autoreleasing *)outInternalPath {
    if (![url.scheme isEqualToString:@"creevey"]) {
        return NO;
    }
    NSString *fullPath = [url.path stringByRemovingPercentEncoding];
    NSRange separatorRange = [fullPath rangeOfString:ArchiveVirtualPathSeparator];
    if (separatorRange.location == NSNotFound) {
        return NO;
    }
    if (outArchivePath) {
        *outArchivePath = [fullPath substringToIndex:separatorRange.location];
    }
    if (outInternalPath) {
        *outInternalPath = [fullPath substringFromIndex:NSMaxRange(separatorRange)];
    }
    return YES;
}

+ (NSArray<NSURL *> *)scanArchive:(NSString *)archivePath {
    NSMutableArray<NSURL *> *results = [NSMutableArray array];
    NSString *ext = [archivePath pathExtension].lowercaseString;
    
    // Optimisation énorme pour les ZIP/CBZ sur lecteurs FUSE/Samba (jusqu'à 30x plus rapide que XADArchive)
    if ([ext isEqualToString:@"zip"] || [ext isEqualToString:@"cbz"]) {
        @try {
            NSTask *task = [[NSTask alloc] init];
            task.launchPath = @"/usr/bin/unzip";
            task.arguments = @[@"-Z1", archivePath];
            NSPipe *pipe = [NSPipe pipe];
            task.standardOutput = pipe;
            task.standardError = [NSPipe pipe]; // Ignore errors
            
            [task launch];
            [task waitUntilExit];
            
            if (task.terminationStatus == 0) {
                NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
                NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                // Fallback encodings if UTF8 fails
                if (!output && data.length > 0) {
                    output = [[NSString alloc] initWithData:data encoding:NSWindowsCP1252StringEncoding];
                }
                
                if (output) {
                    NSArray *lines = [output componentsSeparatedByString:@"\n"];
                    NSSet *imageExts = [NSSet setWithObjects:@"jpg", @"jpeg", @"png", @"gif", @"webp", @"tif", @"tiff", @"heic", nil];
                    
                    for (NSString *line in lines) {
                        NSString *internalName = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        if (internalName.length == 0) continue;
                        
                        NSString *lineExt = [internalName pathExtension].lowercaseString;
                        if ([imageExts containsObject:lineExt]) {
                            NSURL *virtualURL = [self virtualURLForArchive:archivePath internalPath:internalName];
                            if (virtualURL) {
                                [results addObject:virtualURL];
                            }
                        }
                    }
                    return results;
                }
            }
        } @catch (NSException *e) {
            NSLog(@"[ArchiveManager] unzip failed for %@, falling back to XADArchive", archivePath);
        }
    }
    
    // Fallback pour les RAR, 7Z, CBR, ou si unzip échoue
    @try {
        XADArchive *archive = [XADArchive archiveForFile:archivePath];
        if (!archive) return nil;
        
        if ([archive isSolid]) {
            NSLog(@"[ArchiveManager] Skipping solid archive: %@", archivePath);
            return nil;
        }
        
        int count = [archive numberOfEntries];
        for (int i = 0; i < count; i++) {
            if ([archive entryIsEncrypted:i]) {
                continue;
            }
            if (![archive entryHasSize:i]) {
                continue;
            }
            
            NSString *internalName = [archive nameOfEntry:i];
            if (!internalName) continue;
            
            NSString *entryExt = [internalName pathExtension].lowercaseString;
            NSSet *imageExts = [NSSet setWithObjects:@"jpg", @"jpeg", @"png", @"gif", @"webp", @"tif", @"tiff", @"heic", nil];
            if ([imageExts containsObject:entryExt]) {
                NSURL *virtualURL = [self virtualURLForArchive:archivePath internalPath:internalName];
                if (virtualURL) {
                    [results addObject:virtualURL];
                }
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"[ArchiveManager] Exception while parsing archive %@: %@", archivePath, exception);
    }
    return results;
}

+ (NSData *)dataForVirtualURL:(NSURL *)url {
    NSString *archivePath = nil;
    NSString *internalPath = nil;
    if (![self parseVirtualURL:url archivePath:&archivePath internalPath:&internalPath]) {
        return nil;
    }
    
    static NSCache<NSString *, XADArchive *> *archiveCache = nil;
    static NSMutableDictionary<NSString *, NSNumber *> *parsingStatus = nil;
    static NSMutableDictionary *locks = nil;
    static dispatch_queue_t serialParseQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        archiveCache = [[NSCache alloc] init];
        archiveCache.countLimit = 100; // Ne pas garder trop de descripteurs de fichiers ouverts
        parsingStatus = [NSMutableDictionary dictionary];
        locks = [NSMutableDictionary dictionary];
        serialParseQueue = dispatch_queue_create("com.creevey.archiveParsing", DISPATCH_QUEUE_SERIAL);
    });
    
    NSLock *archiveLock = nil;
    @synchronized (locks) {
        archiveLock = locks[archivePath];
        if (!archiveLock) {
            archiveLock = [[NSLock alloc] init];
            locks[archivePath] = archiveLock;
        }
    }
    
    NSData *resultData = nil;
    NSString *ext = [archivePath pathExtension].lowercaseString;
    
    [archiveLock lock];
    @try {
        BOOL isZip = [ext isEqualToString:@"zip"] || [ext isEqualToString:@"cbz"];
        XADArchive *archive = [archiveCache objectForKey:archivePath];
        
        if (archive && ![archive isSolid]) {
            // Chemin rapide : XADArchive est en cache (20ms)
            int count = [archive numberOfEntries];
            for (int i = 0; i < count; i++) {
                NSString *name = [archive nameOfEntry:i];
                if ([name isEqualToString:internalPath] || [[name stringByReplacingOccurrencesOfString:@"\\" withString:@"/"] isEqualToString:internalPath]) {
                    resultData = [archive contentsOfEntry:i];
                    break;
                }
            }
        } else if (isZip) {
            // Fallback rapide pour ZIP : unzip -p (130ms) sans bloquer 8 secondes
            // No background parsing for ZIPs, unzip -p is sufficient and background parsing saturates FUSE
            
            NSTask *task = [[NSTask alloc] init];
            task.launchPath = @"/usr/bin/unzip";
            task.arguments = @[@"-p", archivePath, internalPath];
            NSPipe *pipe = [NSPipe pipe];
            task.standardOutput = pipe;
            task.standardError = [NSPipe pipe];
            
            [task launch];
            
            NSMutableData *data = [NSMutableData data];
            NSFileHandle *readHandle = [pipe fileHandleForReading];
            NSData *chunk = nil;
            while ((chunk = [readHandle availableData]) && [chunk length] > 0) {
                [data appendData:chunk];
            }
            [task waitUntilExit];
            
            if (task.terminationStatus == 0 && data.length > 0) {
                resultData = data;
            } else {
                NSLog(@"[ArchiveManager] unzip -p failed for %@, internalPath %@", archivePath, internalPath);
            }
        } else {
            // Non-ZIP (RAR, etc.) : on attend XADArchive de manière synchrone
            archive = [XADArchive archiveForFile:archivePath];
            if (archive && ![archive isSolid]) {
                [archiveCache setObject:archive forKey:archivePath];
                int count = [archive numberOfEntries];
                for (int i = 0; i < count; i++) {
                    NSString *name = [archive nameOfEntry:i];
                    if ([name isEqualToString:internalPath] || [[name stringByReplacingOccurrencesOfString:@"\\" withString:@"/"] isEqualToString:internalPath]) {
                        resultData = [archive contentsOfEntry:i];
                        break;
                    }
                }
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"[ArchiveManager] Exception while extracting data from %@: %@", archivePath, exception);
    } @finally {
        [archiveLock unlock];
    }
    if (!resultData) {
        NSLog(@"[ArchiveManager] Failed to get data for %@", url);
    } else {
        NSLog(@"[ArchiveManager] Extracted data of length %lu", (unsigned long)resultData.length);
    }
    return resultData;
}

+ (CGImageSourceRef)imageSourceForPath:(NSString *)path {
    NSData *data = nil;
    NSRange separatorRange = [path rangeOfString:ArchiveVirtualPathSeparator];
    if (separatorRange.location != NSNotFound) {
        NSString *archivePath = [path substringToIndex:separatorRange.location];
        NSString *internalPath = [path substringFromIndex:separatorRange.location + separatorRange.length];
        NSLog(@"[ArchiveManager] Loading image from archive: %@, internal: %@", archivePath, internalPath);
        data = [self dataForVirtualURL:[self virtualURLForArchive:archivePath internalPath:internalPath]];
        if (data) return CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    } else {
        return CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:path], NULL);
    }
    NSLog(@"[ArchiveManager] imageSourceForPath returning NULL for path: %@", path);
    return NULL;
}

+ (unsigned long long)fileSizeForVirtualPath:(NSString *)path {
    // Avoid parsing entire ZIP files over FUSE just to get the uncompressed size.
    // The fileSize is only used to prevent NSImage crashes on 0-byte files,
    // but unzip -p will return empty NSData for 0-byte files anyway.
    return 1000000; 
}

@end
