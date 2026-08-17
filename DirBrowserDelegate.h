//Copyright 2005-2023 Dominic Yu. Some rights reserved.
//This work is licensed under the Creative Commons
//Attribution-NonCommercial-ShareAlike License. To view a copy of this
//license, visit http://creativecommons.org/licenses/by-nc-sa/2.0/ or send
//a letter to Creative Commons, 559 Nathan Abbott Way, Stanford,
//California 94305, USA.

@import Cocoa;

@interface DirBrowserDelegate : NSObject
- (NSString*)path;
@property (nonatomic, readonly) NSString *unresolvedPath;
- (void)setPath:(NSString *)s;
@property (nonatomic, weak) IBOutlet NSBrowser *b;
@property (nonatomic, weak) NSMutableSet *revealedDirectories;
@property (readonly) NSString *currentResolvedPath; // basically a thread-safe copy saved from the last time the action was sent
@property (nonatomic, strong) NSMutableSet<NSString *> *customSelectedPaths;
@property (nonatomic, assign) NSInteger customSelectedColumn;
- (void)toggleSelectionForRow:(NSNumber *)rowObj inColumn:(NSNumber *)colObj;
- (void)clearCustomSelection;
@property (nonatomic, readonly) NSArray<NSString *> *selectedPaths;
@end
