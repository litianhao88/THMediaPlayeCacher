//
//  THMediaDataProvider.h
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/20.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>

@interface THMediaDataProvider : NSObject <AVAssetResourceLoaderDelegate>

@property (nonatomic,copy) void(^updateProgressCallback)(NSValue *progressValue , CGFloat totalValue);
@property (nonatomic,assign) BOOL shouldCancelPreRequest;
@property (nonatomic,assign) NSInteger currentRequestOffset;

- (void) reloadAll;
- (void)resumeSomeRequest;
- (void)cancelAndSave;
@end
