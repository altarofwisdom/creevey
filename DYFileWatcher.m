//
//  DYFileWatcher.m
//  Phoenix Slides
//
//  Created by 祥 on 12/6/23.
//

#import "DYFileWatcher.h"
#import "DYCarbonGoodies.h"
#import "CreeveyController.h"

@interface DYFileWatcher ()
@property (nonatomic, copy) NSString *path;
@property (nonatomic) NSURL *fileRef;
- (instancetype)init NS_UNAVAILABLE;
- (void)gotEventPaths:(NSArray *)eventPaths flags:(const FSEventStreamEventFlags *)eventFlags count:(size_t)n;
@end

static void fseventCallback(ConstFSEventStreamRef streamRef, void *info, size_t n, void *p, const FSEventStreamEventFlags flags[], const FSEventStreamEventId eventIds[])
{
	[(__bridge DYFileWatcher *)info gotEventPaths:(__bridge NSArray *)(p) flags:flags count:n];
	// NB: the CFArrayRef of event paths gets released after this returns
}

@implementation DYFileWatcher
{
	FSEventStreamRef stream;
	id <DYFileWatcherDelegate> __weak _delegate;
	CreeveyController * __weak appDelegate;
}

- (instancetype)initWithDelegate:(id <DYFileWatcherDelegate>)d {
	if (self = [super init]) {
		_delegate = d;
	}
	return self;
}

- (void)dealloc {
	[self stop];
}

- (void)watchDirectory:(NSString *)s {
	if (stream)
		[self stop];
	if ([s.stringByDeletingLastPathComponent isEqualToString:@"/"])
		return; // just refuse to watch top level directories for now
	
	self.path = s;
	self.fileRef = [NSURL fileURLWithPath:s isDirectory:YES].fileReferenceURL;
	appDelegate = (CreeveyController *)NSApp.delegate;

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		FSEventStreamRef newStream = FSEventStreamCreate(NULL, &fseventCallback, &(FSEventStreamContext){0,(__bridge void *)self,NULL,NULL,NULL}, (__bridge CFArrayRef)@[s], kFSEventStreamEventIdSinceNow, 2.0,
									 kFSEventStreamCreateFlagFileEvents
									 |kFSEventStreamCreateFlagUseCFTypes
									 |kFSEventStreamCreateFlagIgnoreSelf
									 |kFSEventStreamCreateFlagMarkSelf
									 |kFSEventStreamCreateFlagWatchRoot
									 );
		if (newStream) {
			FSEventStreamSetDispatchQueue(newStream, dispatch_get_main_queue());
			if (!FSEventStreamStart(newStream)) {
				FSEventStreamInvalidate(newStream);
				FSEventStreamRelease(newStream);
				newStream = NULL;
			}
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			if (![self.path isEqualToString:s]) {
				// The path changed while we were creating the stream
				if (newStream) {
					FSEventStreamStop(newStream);
					FSEventStreamInvalidate(newStream);
					FSEventStreamRelease(newStream);
				}
			} else {
				self->stream = newStream;
			}
		});
	});
}

- (void)gotEventPaths:(NSArray *)eventPaths flags:(const FSEventStreamEventFlags *)eventFlags count:(size_t)n	 {
	NSMutableSet *files = [[NSMutableSet alloc] init];
	NSMutableSet *deleted = [[NSMutableSet alloc] init];
	BOOL rootChanged = NO;
	for (size_t i=0; i<n; ++i) {
		NSString *s = eventPaths[i];
		FSEventStreamEventFlags f = eventFlags[i];
		if (f & (kFSEventStreamEventFlagItemCreated|kFSEventStreamEventFlagItemModified|kFSEventStreamEventFlagItemRemoved|kFSEventStreamEventFlagItemRenamed|kFSEventStreamEventFlagItemInodeMetaMod)) {
			if (f & kFSEventStreamEventFlagItemIsDir) continue;
			if (_wantsSubfolders ? [s hasPrefix:_path] : [s.stringByDeletingLastPathComponent isEqualToString:_path]) {
				NSURL *url = [NSURL fileURLWithPath:s isDirectory:NO];
				if (![appDelegate shouldShowFile:url]) continue;
				if (0 == access(s.fileSystemRepresentation, R_OK))
					[files addObject:s];
				else
					[deleted addObject:s];
			}
		} else if (f & kFSEventStreamEventFlagRootChanged) {
			rootChanged = YES;
		}
	}
	if (files.count || deleted.count)
		[_delegate watcherFiles:files.allObjects deleted:deleted.allObjects];
	if (rootChanged) {
		[_delegate watcherRootChanged:_fileRef];
		if (_fileRef.path != nil) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self watchDirectory:_fileRef.path];
			});
		}
	}
}

- (void)stop {
	if (stream) {
		FSEventStreamStop(stream);
		FSEventStreamInvalidate(stream);
		FSEventStreamRelease(stream);
		stream = NULL;
	}
}


@end
