//
//  THMediaDataDownloadTask.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/20.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THMediaDataDownloader.h"

#import "NSURL+THEx.h"
#import "THMediaDataCacheManager.h"
#import "CommonMarco.pch"


@interface THMediaDataDownloader () < NSURLSessionDelegate , NSURLSessionDataDelegate>
@property (nonatomic,weak) id test;
@property (nonatomic,assign) NSInteger newOffset;
@property (nonatomic,assign) NSUInteger requestCount;
@property (nonatomic,assign) BOOL isCompletionOperating;
@property (nonatomic,assign) BOOL cacelCompletion;
@property (nonatomic,assign) long long totalLength;
@property (nonatomic,strong) NSValue *currentDownloadProgress;
@property (nonatomic, strong) NSURL           *url;
@property (nonatomic , assign) NSUInteger      offset;

@property (nonatomic , assign) NSUInteger      videoLength;
@property (nonatomic, strong) NSString        *mimeType;

@property (nonatomic, strong) NSMutableArray  *taskArr;

@property (nonatomic, assign) NSUInteger      downLoadingOffset;

@property (nonatomic, strong) NSFileHandle    *fileHandle;
@property (nonatomic,strong) NSURLSessionDataTask *preTask;

@property (nonatomic,strong) NSURLSessionDataTask *currentTask;
@property (nonatomic,strong) NSURLSession *urlSession;

@end

@implementation THMediaDataDownloader

- (instancetype)init
{
    self = [super init];
    if (self) {
        _taskArr = [NSMutableArray array];
        
        
        if ([kTHFILEMANAGER fileExistsAtPath:[self tempFilePath]]) {
            [kTHFILEMANAGER removeItemAtPath:self.tempFilePath error:nil];
        }
        
            [kTHFILEMANAGER createFileAtPath:self.tempFilePath contents:nil attributes:nil];

        self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.tempFilePath];
    }
    return self;
}


- (void)setUrl:(NSURL *)url offset:(NSUInteger)offset length:(NSUInteger)length
{
    self.requestCount ++ ;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url th_UrlByReplaceSchemeName:@"http"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0];
    if (offset != 0 ) {
        NSUInteger endOffset = length == -1 ? (unsigned long)self.videoLength - 1:MIN((unsigned long)self.videoLength - 1, (offset + length - 1 ));
        [request addValue:[NSString stringWithFormat:@"bytes=%zd-%zd",(unsigned long)offset, endOffset] forHTTPHeaderField:@"Range"];
        if (self.requestCount == 1) {
            NSLog(@"%zd 起始 %zd 结尾" , offset , endOffset);
        }
    }

   
    if (self.requestCount > 1) {
        self.preTask = self.currentTask ;
        self.currentTask =   [self.urlSession dataTaskWithRequest:request ];
        [self.taskArr addObject:self.currentTask];
        if (self.preTask.state == NSURLSessionTaskStateRunning) {
            [self.preTask cancel];
        }else
        {
            [self.currentTask resume ];
        }
    }else if(self.requestCount == 1)
    {
        self.fileHandle  = [NSFileHandle fileHandleForWritingAtPath:self.tempFilePath];
        self.currentTask =   [self.urlSession dataTaskWithRequest:request ];

        [self.currentTask resume];
        if (self.currentTask) {
            [self.taskArr addObject:self.currentTask];
        }
        _offset = offset ;
    }
    _url = url;
    _newOffset = offset;
    [UIApplication sharedApplication].networkActivityIndicatorVisible =  YES;
    
 }


- (NSURLSession *)urlSession
{
    if (!_urlSession) {
        _urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];

    }
    return  _urlSession ;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{

    [self.fileHandle seekToEndOfFile];
    [self.fileHandle writeData:data];

    _downLoadingOffset += data.length ;
    static NSUInteger localOffset = -1 ;
    if (localOffset != self.offset) {
        NSLog(@"%zd 改变了 ofset %.3f%%百分比" , self.offset , self.offset/(CGFloat)self.videoLength);
        localOffset = self.offset;
    }

    self.currentDownloadProgress = [NSValue valueWithRange:NSMakeRange(self.offset, self.downLoadingOffset)];
    if ([self.delegate respondsToSelector:@selector(didReceiveVideoDataWithTask:progress:totalValue:)]) {
        [self.delegate didReceiveVideoDataWithTask:self progress:self.currentDownloadProgress totalValue:0];
    }

}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (self.currentTask == self.preTask) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO ;
    }

    if (error) {

        if ([self.delegate respondsToSelector:@selector(didFailLoadingWithTask:withError:)]) {
            [self.delegate didFailLoadingWithTask:self withError:error.code];
        }
    }

    [self.fileHandle closeFile];
    if ( self.downLoadingOffset &&  [kTHFILEMANAGER fileExistsAtPath: self.tempFilePath])
    {
        NSURL *httpUrl = [task.response.URL th_UrlByReplaceSchemeName:@"http"] ;
        NSRange bufferedRange = NSMakeRange(self.offset, self.downLoadingOffset) ;
        [THMediaDataCacheManager setCurrentExtName:self.mimeType];

        [THMediaDataCacheManager moveFileAtPath:self.tempFilePath toDirectoryPathCaculateUsingUrl:httpUrl rangeInTotalFile:bufferedRange];
    }
    _downLoadingOffset = 0 ;
    _offset = _newOffset ;
    
    //如果建立第二次请求，先移除原来文件，再创建新的
    if (self.preTask != self.currentTask) {
        if ([kTHFILEMANAGER fileExistsAtPath:self.tempFilePath]) {
            [kTHFILEMANAGER removeItemAtPath:self.tempFilePath error:nil];
        }
        [kTHFILEMANAGER createFileAtPath:self.tempFilePath contents:nil attributes:nil];
        self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.tempFilePath];
        [self.currentTask resume];
        self.preTask = self.currentTask ;
    }
    
    if (self.currentTask == task) {
        if ([self.delegate respondsToSelector:@selector(didCompleteAllTaskWithDownloader:)]) {
            [self.delegate didCompleteAllTaskWithDownloader:self];
        }
    }
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{

        NSURL *httpUrl = [response.URL th_UrlByReplaceSchemeName:@"http"] ;

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        
        NSDictionary *dic = (NSDictionary *)[httpResponse allHeaderFields] ;
        
        NSString *content = [dic valueForKey:@"Content-Range"];
        NSArray *array = [content componentsSeparatedByString:@"/"];
        NSString *length = array.lastObject;
        
        NSUInteger videoLength;
        
        if ([length integerValue] == 0) {
            videoLength = (NSUInteger)httpResponse.expectedContentLength;
        } else {
            videoLength = [length integerValue];
        }
        self.videoLength = videoLength;
        self.mimeType = response.MIMEType;
        

        [THMediaDataCacheManager bingdingTotalLength:self.videoLength extensionTypeName:self.mimeType toModelOfUrl:httpUrl];

    
        if ([self.delegate respondsToSelector:@selector(didReceiveVideoDataWithTask:progress:totalValue:)]) {
        self.currentDownloadProgress = [NSValue valueWithRange:NSMakeRange(self.offset, self.downLoadingOffset)];
            [self.delegate didReceiveVideoDataWithTask:self progress:self.currentDownloadProgress totalValue:self.videoLength];
            self.totalLength = self.videoLength ;
        }
    
    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.tempFilePath];
            _isFinishLoad = NO;
              if ([self.delegate respondsToSelector:@selector(mediaDataDownloader:didReceiveVideoLength:mimeType:)]) {
            [self.delegate mediaDataDownloader:self didReceiveVideoLength:self.videoLength mimeType:self.mimeType];
        }
    if (completionHandler) {
        completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)cancelALL
{
    dispatch_async(dispatch_get_main_queue(), ^{
    [self.taskArr removeAllObjects];
    [self.currentTask cancel];
    self.preTask = self.currentTask = nil ;
    
    self.fileHandle = nil ;
    });

}

- (NSString *)tempFilePath
{
    return [kTempPath_NSString stringByAppendingPathComponent:@"temp"];
}
- (void)dealloc
{
    NSLog(@"%s" , __func__);
}

@end
