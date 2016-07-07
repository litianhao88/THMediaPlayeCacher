//
//  THMediaDataProvider.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/20.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THMediaDataProvider.h"
#import "CommonMarco.pch"
#import "THMediaDataCacheManager.h"
#import "MBProgressHUD+Show.h"
#import "THMediaDataDownloader.h"
#import <MobileCoreServices/MobileCoreServices.h>


#import "THMediaDataCacheManager.h"
#import "MediaCacheMap.h"
#import "THNetWorkManager.h"
#import "THMediaPlayer.h"

@interface THMediaDataProvider ()<THMediaDataDownloaderDelegate>

@property (nonatomic,strong) NSMutableArray<AVAssetResourceLoadingRequest *> *requests;
@property (nonatomic,strong) THMediaDataDownloader *mediaDataDownLoader;
@property (nonatomic,strong) AVAssetResourceLoadingRequest *currentLoadngRequest;
@end

@implementation THMediaDataProvider


#pragma mark - resourceLoader 等待代理

- (void)didFailLoadingWithTask:(THMediaDataDownloader *)downlaoder withError:(NSInteger)errorCode
{
}
/**
 *  必须返回Yes，如果返回NO，则resourceLoader将会加载出现故障的数据
 *  这里会出现很多个loadingRequest请求， 需要为每一次请求作出处理
 *  @param resourceLoader 资源管理器
 *  @param loadingRequest 每一小块数据的请求
 *
 */

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest
{

//    if (self.shouldCancelPreRequest) {
//        self.shouldCancelPreRequest = NO;
//        [self.requests enumerateObjectsUsingBlock:^(AVAssetResourceLoadingRequest * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            [obj finishLoading];
//        }];
//        [self.mediaDataDownLoader cancelALL];
//        
//        [self.requests removeAllObjects];
//    }
//    if (loadingRequest.dataRequest.currentOffset < self.currentRequestOffset) {
//        return NO;
//    }
    if (loadingRequest.dataRequest.currentOffset < self.currentRequestOffset - 1024) {
        return NO ;
    }
    NSLog(@"loadingRequestOffset %zd" , loadingRequest.dataRequest.currentOffset);
    [self.currentLoadngRequest finishLoading];
    self.currentLoadngRequest = loadingRequest ;
    [self dealWithLoadingRequest:loadingRequest];
    return  YES ;
    if (loadingRequest.dataRequest.currentOffset > self.currentLoadngRequest.dataRequest.currentOffset) {
        [self.requests addObject:loadingRequest];
        return YES;
    }else if (loadingRequest.dataRequest.currentOffset)
    if (self.currentLoadngRequest) {
        [self.requests addObject:self.currentLoadngRequest];
    }
    self.currentLoadngRequest = loadingRequest ;
    self.currentRequestOffset = self.currentLoadngRequest.dataRequest.currentOffset ;
    [self.currentLoadngRequest finishLoading];
    self.currentLoadngRequest = loadingRequest;
  return  [self dealWithLoadingRequest:loadingRequest];
}

#pragma mark - 取消代理 avplayer 有时会自动取消数据请求 就会调这个通知 在数组中移除被取消的请求
- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    
    [self.requests removeObject:loadingRequest];
}

#pragma mark - 分析请求的偏移量 得出是否网络下载的结果
- (BOOL)dealWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{

    NSURL *interceptedURL = [loadingRequest.request URL];
    NSURL *HTTPUrl = [ interceptedURL th_UrlByReplaceSchemeName:@"http"]  ;
    NSString *extName = [THMediaDataCacheManager mediaCacheMapOfUrl:HTTPUrl].extensionTypeName;

    NSRange loadingRequestRange = NSMakeRange((NSUInteger)loadingRequest.dataRequest.currentOffset, (NSUInteger)(loadingRequest.dataRequest.requestedLength - loadingRequest.dataRequest.currentOffset + loadingRequest.dataRequest.requestedOffset));
    //3 ~ 8   6  5
    BOOL enough = NO ;
    NSRange usefulRange = NSMakeRange(0, 0) ;
    NSUInteger startOfNextOffset  = 0 ;
    NSString *filePath = [THMediaDataCacheManager filePathOfUrl:HTTPUrl inRange:loadingRequestRange enough:&enough usefulRange:&usefulRange nextFileStartOffset:&startOfNextOffset];
    //有文件  先从文件加载  不够再发网络请求
    if (filePath.length && [kTHFILEMANAGER_InstanceOfNSFileManager fileExistsAtPath:filePath])
    {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        //本地文件满足 request
        if ( enough && data.length )
        {
            AVAssetResourceLoadingContentInformationRequest *contentInformationRequest = loadingRequest.contentInformationRequest ;
            if (contentInformationRequest)
                    {
                        contentInformationRequest.byteRangeAccessSupported = YES;
                        //
                        NSString *mimeType =  extName ;
                        CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(mimeType), NULL);
                        contentInformationRequest.contentType = CFBridgingRelease(contentType);
                        
                        contentInformationRequest.contentLength =  [THMediaDataCacheManager totalLengthOfUrl:HTTPUrl];
                    }
            
            [loadingRequest.dataRequest respondWithData:[data subdataWithRange:usefulRange]];
            [loadingRequest finishLoading];
            
            [self.requests removeObject:loadingRequest];
            
            return YES;
    }else if (data.length && !enough)
        {
            AVAssetResourceLoadingContentInformationRequest *contentInformationRequest = loadingRequest.contentInformationRequest ;
            
            contentInformationRequest.byteRangeAccessSupported = YES;
            NSString *mimeType = extName;
            CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(mimeType), NULL);
            contentInformationRequest.contentType = CFBridgingRelease(contentType);
            contentInformationRequest.contentLength =  [THMediaDataCacheManager totalLengthOfUrl:HTTPUrl];
            if (data.length > usefulRange.location + usefulRange.length - 1 ) {
                [loadingRequest.dataRequest respondWithData:[data subdataWithRange:usefulRange]]; //判断此次请求的数据是否处理完全
            }
            if (self.mediaDataDownLoader.downLoadingOffset > 0)
                {
                    [self processPendingRequests];
                }
            if(  [THNetWorkManager currentNetworkReachabilityStatus] != AFNetworkReachabilityStatusNotReachable && [THNetWorkManager currentNetworkReachabilityStatus] != AFNetworkReachabilityStatusUnknown)
                {
                    if (!self.mediaDataDownLoader)
                        {
                            self.mediaDataDownLoader = [[THMediaDataDownloader alloc] init];
                            self.mediaDataDownLoader.delegate = self;
                        }
                    if (startOfNextOffset != 0)
                        {
                            [self.mediaDataDownLoader setUrl:interceptedURL offset:usefulRange.location + usefulRange.length length:startOfNextOffset - usefulRange.location - usefulRange.length];
                        }
                    else
                        {
                        [self.mediaDataDownLoader setUrl:interceptedURL offset:usefulRange.location + usefulRange.length length: loadingRequestRange.length + loadingRequestRange.location   - usefulRange.location - usefulRange.length];
                        }
                    return  YES ;
            }
        }
    }
    else
            {
                if(  [THNetWorkManager currentNetworkReachabilityStatus] != AFNetworkReachabilityStatusNotReachable && [THNetWorkManager currentNetworkReachabilityStatus] != AFNetworkReachabilityStatusUnknown)
                {
                if (!self.mediaDataDownLoader)
                        {
                            self.mediaDataDownLoader = [[THMediaDataDownloader alloc] init];
                            self.mediaDataDownLoader.delegate = self;
                            
                            if (startOfNextOffset != 0)
                                    {
                                        [self.mediaDataDownLoader setUrl:interceptedURL offset:usefulRange.location + usefulRange.length length:startOfNextOffset - usefulRange.location - usefulRange.length];
                                    }
                            else
                                    {
                                    [self.mediaDataDownLoader setUrl:interceptedURL offset:usefulRange.location + usefulRange.length length: loadingRequestRange.length + loadingRequestRange.location  - usefulRange.location - usefulRange.length];

                                    }
                        }
            
            if (self.mediaDataDownLoader.offset + self.mediaDataDownLoader.downLoadingOffset-1 < loadingRequestRange.location || loadingRequestRange.location < self.mediaDataDownLoader.offset)
                 {
                            if (startOfNextOffset != 0)
                                    {
                                        [self.mediaDataDownLoader setUrl:interceptedURL offset:(NSUInteger)loadingRequest.dataRequest.currentOffset length:(NSUInteger)startOfNextOffset - (NSUInteger)loadingRequest.dataRequest.currentOffset];
                                    }
                            else
                                    {
                                        [self.mediaDataDownLoader setUrl:interceptedURL offset:loadingRequestRange.location length: loadingRequestRange.length];
                                    }
                        }
                    return  YES ;
                }
                
            }
    [MBProgressHUD showErrorWithText:@"当前无网络可用"];

    [ loadingRequest finishLoadingWithError:[NSError errorWithDomain:@"disConnect" code:10000 userInfo:nil]];
    return  YES ;
}


#pragma mark - AVURLAsset resource loader methods

- (BOOL)respondWithDataForRequest:(AVAssetResourceLoadingDataRequest *)dataRequest
{
    long long startOffset = dataRequest.requestedOffset;

    if (dataRequest.currentOffset != 0) {
        startOffset = dataRequest.currentOffset;
    }
    
    if ((self.mediaDataDownLoader.offset +self.mediaDataDownLoader.downLoadingOffset - 1) < startOffset)
    {
        return NO;
    }
    
    if (startOffset < self.mediaDataDownLoader.offset) {
        return NO;
    }
    NSURL *urlPath = [NSURL fileURLWithPath:self.mediaDataDownLoader.tempFilePath]  ;
    NSData *filedata = [NSData dataWithContentsOfURL:urlPath options:NSDataReadingMappedIfSafe error:nil];
    
    // This is the total data we have from startOffset to whatever has been downloaded so far
    NSUInteger unreadBytes = self.mediaDataDownLoader.downLoadingOffset + self.mediaDataDownLoader.offset  - (NSInteger)startOffset ;

    // Respond with whatever is available if we can't satisfy the request fully yet
    NSUInteger numberOfBytesToRespondWith = MIN((NSUInteger)dataRequest.requestedLength, unreadBytes);
    
    if (filedata.length) {

        [dataRequest respondWithData:[filedata subdataWithRange:NSMakeRange((NSUInteger)startOffset- self.mediaDataDownLoader.offset, (NSUInteger)numberOfBytesToRespondWith)]];
            }
 

    long long endOffset = startOffset + dataRequest.requestedLength ;
    BOOL didRespondFully = (self.mediaDataDownLoader.offset + self.mediaDataDownLoader.downLoadingOffset) >= endOffset;
    
    return didRespondFully;
}

- (void)processPendingRequests
{
//    NSLog(@"%s" , __func__ ) ;
    
//    NSMutableArray *requestsCompleted = [NSMutableArray array];  //请求完成的数组
    //每次下载一块数据都是一次请求，把这些请求放到数组，遍历数组
    
    [self fillInContentInformation:self.currentLoadngRequest.contentInformationRequest url:self.currentLoadngRequest.request.URL]; //对每次请求加上长度，文件类型等信息
    
    BOOL didRespondCompletely = [self respondWithDataForRequest:self.currentLoadngRequest.dataRequest]; //判断此次请求的数据是否处理完全

    if (didRespondCompletely) {
        NSLog(@"%zd" , self.currentRequestOffset);
        [self.currentLoadngRequest finishLoading];
            self.currentLoadngRequest = nil ;
        self.currentRequestOffset = self.currentLoadngRequest.dataRequest.currentOffset + 1 ;

    }

//        for (AVAssetResourceLoadingRequest *loadingRequest in self.requests)
//        {
//            
//            [self fillInContentInformation:loadingRequest.contentInformationRequest url:loadingRequest.request.URL]; //对每次请求加上长度，文件类型等信息
//            
//            BOOL didRespondCompletely = [self respondWithDataForRequest:loadingRequest.dataRequest]; //判断此次请求的数据是否处理完全
//            
//            if (didRespondCompletely) {
//                
//                [requestsCompleted addObject:loadingRequest];  //如果完整，把此次请求放进 请求完成的数组
//        
//                [loadingRequest finishLoading];
//            }
//            
//    }
//    [self.requests removeObjectsInArray:requestsCompleted];

}



- (void)mediaDataDownloader:(THMediaDataDownloader *)downlaoder didReceiveVideoLength:(NSUInteger)videoLength mimeType:(NSString *)mimeType
{
    
}

- (void)didReceiveVideoDataWithTask:(THMediaDataDownloader *)downlaoder progress:(NSValue *)progressValue totalValue:(CGFloat)totalValue
{
    if (totalValue ==  0) {
        [self processPendingRequests];
    }
        if (self.updateProgressCallback) {
            self.updateProgressCallback(progressValue , totalValue);
        }
}

- (void)didFinishLoadingWithTask:(THMediaDataDownloader *)downlaoder
{
    
}

- (void)fillInContentInformation:(AVAssetResourceLoadingContentInformationRequest *)contentInformationRequest url:(NSURL *)url
{
      NSString *mimeType   = self.mediaDataDownLoader.mimeType;
//    [THMediaDataCacheManager mediaCacheMapOfUrl:[url th_UrlByReplaceSchemeName:@"http"]].extensionTypeName;

    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(mimeType), NULL);

    contentInformationRequest.byteRangeAccessSupported = YES;
    contentInformationRequest.contentType = CFBridgingRelease(contentType);
    contentInformationRequest.contentLength = self.mediaDataDownLoader.videoLength;
}


- (NSMutableArray<AVAssetResourceLoadingRequest *> *)requests
{
    if (!_requests) {
        _requests = [NSMutableArray array];
    }
    return  _requests ;
}

- (void)reloadAll
{
    if (self.requests.count) {
        [self.requests enumerateObjectsUsingBlock:^(AVAssetResourceLoadingRequest * _Nonnull request, NSUInteger idx, BOOL * _Nonnull stop) {
            [request finishLoading];
        }];
    }
}

- (void)didCompleteAllTaskWithDownloader:(THMediaDataDownloader *)downloader
{
    [self.currentLoadngRequest finishLoading];

}

- (void)resumeSomeRequest
{
    [self.currentLoadngRequest finishLoading];
}

- (void)dealloc
{
    [self.mediaDataDownLoader  cancelALL];
    NSLog(@"%s", __func__);
}

- (void)cancelAndSave
{
    [self.mediaDataDownLoader  cancelALL];

}

@end
