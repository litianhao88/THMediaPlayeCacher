//
//  THMediaDataDownloadTask.h
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/20.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class THMediaDataDownloader ;

@protocol THMediaDataDownloaderDelegate <NSObject>

- (void)mediaDataDownloader:(THMediaDataDownloader *)downlaoder didReceiveVideoLength:(NSUInteger)videoLength mimeType:(NSString *)mimeType;
- (void)didReceiveVideoDataWithTask:(THMediaDataDownloader *)downlaoder progress:(NSValue *)progressValue totalValue:(CGFloat)totalValue;
- (void)didFinishLoadingWithTask:(THMediaDataDownloader *)downlaoder;
- (void)didFailLoadingWithTask:(THMediaDataDownloader *)downlaoder withError:(NSInteger )errorCode;
- (void)didCompleteAllTaskWithDownloader:(THMediaDataDownloader *)downloader ;

@end

@interface THMediaDataDownloader : NSObject

@property (nonatomic, strong, readonly) NSURL  *url;
@property (nonatomic, strong, readonly) NSString   * mimeType;


@property (nonatomic, readonly) NSUInteger  offset;
@property (nonatomic, readonly) NSUInteger  videoLength;
@property (nonatomic, readonly) NSUInteger    downLoadingOffset;

@property (nonatomic, assign)           BOOL   isFinishLoad;

@property (nonatomic, weak) id <THMediaDataDownloaderDelegate> delegate;


- (void)setUrl:(NSURL *)url offset:(NSUInteger)offset length:(NSUInteger)length;
- (void)cancelALL;
- (NSString *)tempFilePath;

@end


