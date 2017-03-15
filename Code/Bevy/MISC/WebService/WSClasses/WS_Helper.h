//
//  WS_Helper.h
//  PhotoBud
//
//  Created by CompanyName
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "WS_Urls.h"
#import "AFHTTPClient.h"
#import "NSURL+URL.h"
@class WS_Helper;
@protocol ParseWSDelegate <NSObject>
@optional

- (void)parserImageUploadProgress:(float) progress;
- (void)parserImageUploadedFile;
- (void)parserAddressSuccess:(id)response;
- (void)parserAddressFail;
- (void)parserDidSuccessWithHelper:(WS_Helper *)helper andResponse:(id )response;
- (void)parserDidFailPostWithHelper:(WS_Helper *)helper andError:(NSError*)error;
- (void)parserUploadingHelper:(WS_Helper *)helper andValue:(float)value;
- (void)parserDownloadingHelper:(WS_Helper *)helper andValue:(float)value;
-(void)queCompletedWithFailed:(NSMutableArray*)arrFailed;
- (void)parserDidDownloadItem:(NSString*)responseString;
- (void)parserDidFailToDownloadItem:(NSError*)error;

@end

@interface  WS_Helper : NSObject

@property (strong, nonatomic) id <ParseWSDelegate> target;
@property (strong, nonatomic) NSString *serviceName;
@property (nonatomic, assign) NSInteger tagNumber;
@property (nonatomic, strong) NSMutableArray *sucessIndexes;

@property (nonatomic, retain)  NSOperationQueue *operationQueue;


-(id)initWithDelegate:(id)delegate;

- (void) sendRequestWithURL:(NSString *)urlValue;
- (void) sendRequestWithURL:(NSString *)urlValue withTag:(NSInteger)tag;

- (void) sendRequestWithPostURL:(NSString *)urlPath andParametrers:(NSDictionary *)dict;
- (void) sendRequestWithPostURL:(NSString *)urlPath andParametrers:(NSDictionary *)dict andData:(NSData *)fileData andFileKey:(NSString *)fileKey andExtention:(NSString *)ext andMymeTye:(NSString *)mimeType;
- (void) sendRequestWithMultiplePostURL:(NSString *)urlPath andParametrers:(NSMutableDictionary *)dict andData:(NSMutableArray *)fileDataArr andFileKey:(NSMutableArray *)fileKeyArr andExtention:(NSString *)ext andMymeTye:(NSString *)mimeType;

- (void) sendRequestWithDeleteURL:(NSString *)urlPath andParametrers:(NSDictionary *)dict;
- (void)downloadFileFromURL:(NSString *)fileUrl toPath:(NSString*)destPath;

@end