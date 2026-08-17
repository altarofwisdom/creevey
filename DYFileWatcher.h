//
//  DYFileWatcher.h
//  Phoenix Slides
//
//  Created by 祥 on 12/6/23.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@protocol DYFileWatcherDelegate <NSObject>
- (void)watcherFiles:(NSArray *)files deleted:(NSArray *)deleted;
- (void)watcherRootChanged:(NSURL *)fileRef;
@optional
- (void)watcherDirectoryNeedsRescan:(NSString *)dirPath;
@end

@interface DYFileWatcher : NSObject
@property (nonatomic) BOOL wantsSubfolders;
@property (nonatomic, readonly) NSArray<NSString *> *paths;
- (instancetype)initWithDelegate:(id <DYFileWatcherDelegate>)delegate NS_DESIGNATED_INITIALIZER;
- (void)watchDirectories:(NSArray<NSString *> *)paths;
- (void)stop;
@end

NS_ASSUME_NONNULL_END
