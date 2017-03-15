    //
//  WS_Helper.m
//  PhotoBud
//
//  Created by CompanyName
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WS_Helper.h"
#import "WS_Helper.h"
//#import "SBJson.h"
#import "NSURL+URL.h"
#import "MBProgressHUD.h"
#import "GlobalManager.h"
#import "LoginViewController.h"
#import "ListViewController.h"
#import "LoadingViewController.h"

@implementation WS_Helper

-(id)initWithDelegate:(id)delegate
{
    self = [super init];
    if(self)
    {
        [self setTarget:delegate];
    }
    return self;
}

#pragma mark - Instance methods

-(void) showNetworkNotAvailableAlert
{
    [UIAlertView showErrorWithMessage:kNetworkError myTag:0 handler:nil];
}

#pragma mark - GET methods

- (void)sendRequestWithURL:(NSString *)urlValue
{
    NSLog(@"--------------------------");
    NSLog(@"CURRENT WEBSERVICE URL ---> %@",urlValue);
    NSLog(@"--------------------------");
    if (![GlobalManager checkInternetConnection])
    {
        [MBProgressHUD hideAllHUDsForView:[[GlobalManager getAppDelegateInstance] window] animated:YES];
        [self showNetworkNotAvailableAlert];
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL urlWithEncoding:urlValue]];
    [httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [httpClient setDefaultHeader:@"Accept" value:@"application/json"];
    
    [httpClient setParameterEncoding:AFJSONParameterEncoding];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:@"" parameters:nil];
    [request setTimeoutInterval:300];
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                         {
                                             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                             if ([self.target respondsToSelector:@selector(parserDidSuccessWithHelper:andResponse:)])
                                             {
                                                 
                                                 NSDictionary *dicJson = (NSDictionary *) JSON;
                                                 if([[dicJson valueForKeyPath:@"settings.success"] isEqualToString:@"401"])
                                                 {
                                                     
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         
                                                         [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window  animated:YES];
                                                         for (UIViewController *controller in [GlobalManager getAppDelegateInstance].objNavController.viewControllers)
                                                         {
                                                             if([controller isKindOfClass:[LoginViewController class]])
                                                             {
                                                                 [UIAlertView showWarningWithMessage:[dicJson valueForKeyPath:@"settings.message"] handler:^(UIAlertView *alertView, NSInteger buttonIndex)
                                                                  {
                                                                      if (buttonIndex==0)
                                                                      {
                                                                          LoginViewController *obj = (LoginViewController*)controller;
                                                                          [[GlobalManager getAppDelegateInstance].objNavController popToViewController:obj animated:YES];
                                                                      }
                                                                  }];
                                                                 
                                                             }
                                                             else if([controller isKindOfClass:[ListViewController class]])
                                                             {
                                                                 [UIAlertView showWarningWithMessage:[dicJson valueForKeyPath:@"settings.message"] handler:^(UIAlertView *alertView, NSInteger buttonIndex)
                                                                  {
                                                                      if (buttonIndex==0)
                                                                      {
                                                                          ListViewController *obj = (ListViewController*)controller;
                                                                          [[GlobalManager getAppDelegateInstance].objNavController popToViewController:obj animated:YES];
                                                                      }
                                                                  }];
                                                             }
                                                             else if([controller isKindOfClass:[LoadingViewController class]])
                                                             {
                                                                 LoginViewController *objLoginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                                                                 [[GlobalManager getAppDelegateInstance].objNavController pushViewController:objLoginVC animated:YES];
                                                                 
                                                             }
                                                         }
                                                     });
                                                     
                                                 }
                                                 else
                                                 {
                                                     [self.target parserDidSuccessWithHelper:self andResponse:JSON];
                                                 }
                                             }
                                         } failure:^ (NSURLRequest *request, NSURLResponse *response, NSError *error, id json){
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         if ([self.target respondsToSelector:@selector(parserDidFailPostWithHelper:andError:)])
         {
             [self.target parserDidFailPostWithHelper:self andError:error];
         }
     }];
    [GlobalManager setOperationInstance:operation];
    [operation start];
}


- (void) sendRequestWithURL:(NSString *)urlValue withTag:(NSInteger)tag
{
    self.tagNumber=tag;
    NSLog(@"--------------------------");
    NSLog(@"CURRENT WEBSERVICE URL ---> %@",urlValue);
    NSLog(@"--------------------------");
    if (![GlobalManager checkInternetConnection])
    {
        [MBProgressHUD hideAllHUDsForView:[[GlobalManager getAppDelegateInstance] window] animated:YES];
        [self showNetworkNotAvailableAlert];
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL urlWithEncoding:urlValue]];
    [httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [httpClient setDefaultHeader:@"Accept" value:@"application/json"];
    
    [httpClient setParameterEncoding:AFJSONParameterEncoding];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:@"" parameters:nil];
    [request setTimeoutInterval:300];
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
     {
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         if ([self.target respondsToSelector:@selector(parserDidSuccessWithHelper:andResponse:)])
         {
             NSDictionary *dicJson = (NSDictionary *) JSON;
             if([[dicJson valueForKeyPath:@"settings.success"] isEqualToString:@"401"])
             {
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     [MBProgressHUD hideAllHUDsForView:[GlobalManager getAppDelegateInstance].window  animated:YES];
                     for (UIViewController *controller in [GlobalManager getAppDelegateInstance].objNavController.viewControllers)
                     {
                         if([controller isKindOfClass:[LoginViewController class]])
                         {
                             [UIAlertView showWarningWithMessage:[dicJson valueForKeyPath:@"settings.message"] handler:^(UIAlertView *alertView, NSInteger buttonIndex)
                              {
                                  if (buttonIndex==0)
                                  {
                                      LoginViewController *obj = (LoginViewController*)controller;
                                      [[GlobalManager getAppDelegateInstance].objNavController popToViewController:obj animated:YES];
                                      
                                  }
                              }];
                             
                         }
                         else if([controller isKindOfClass:[ListViewController class]])
                         {
                             [UIAlertView showWarningWithMessage:[dicJson valueForKeyPath:@"settings.message"] handler:^(UIAlertView *alertView, NSInteger buttonIndex)
                              {
                                  if (buttonIndex==0)
                                  {
                                      ListViewController *obj = (ListViewController*)controller;
                                      [[GlobalManager getAppDelegateInstance].objNavController popToViewController:obj animated:YES];
                                  }
                              }];
                         }
                         else if([controller isKindOfClass:[LoadingViewController class]])
                         {
                             LoginViewController *objLoginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                             [[GlobalManager getAppDelegateInstance].objNavController pushViewController:objLoginVC animated:YES];
                         }
                     }
                     
                 });
                 
             }
             else
             {
                 [self.target parserDidSuccessWithHelper:self andResponse:JSON];
             }
         }
     } failure:^ (NSURLRequest *request, NSURLResponse *response, NSError *error, id json){
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         if ([self.target respondsToSelector:@selector(parserDidFailPostWithHelper:andError:)])
         {
             [self.target parserDidFailPostWithHelper:self andError:error];
         }
     }];
    [GlobalManager setOperationInstance:operation];
    [operation start];
}

#pragma mark - POST methods

- (void) sendRequestWithPostURL:(NSString *)urlPath andParametrers:(NSDictionary *)dict
{
    NSLog(@"--------------------------");
    NSLog(@"CURRENT WEBSERVICE URL ---> %@",urlPath);
    NSLog(@"--------------------------");
    if (![GlobalManager checkInternetConnection])
    {
        [MBProgressHUD hideAllHUDsForView:[[GlobalManager getAppDelegateInstance] window] animated:YES];
        [self showNetworkNotAvailableAlert];
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    AFHTTPClient *client = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:[WS_Urls getMainUrl]]];
    NSDictionary *params = dict;
    NSURLRequest *request = [client requestWithMethod:@"POST" path:urlPath parameters:params];
    AFJSONRequestOperation *operation = [self getDealsWithSuccess:request];
    [GlobalManager setOperationInstance:operation];
    [operation start];
}

- (void) sendRequestWithPostURL:(NSString *)urlPath andParametrers:(NSDictionary *)dict andData:(NSData *)fileData andFileKey:(NSString *)fileKey andExtention:(NSString *)ext andMymeTye:(NSString *)mimeType
{
    NSLog(@"--------------------------");
    NSLog(@"CURRENT WEBSERVICE URL ---> %@",urlPath);
    NSLog(@"--------------------------");
    if (![GlobalManager checkInternetConnection])
    {
        [MBProgressHUD hideAllHUDsForView:[[GlobalManager getAppDelegateInstance] window] animated:YES];
        [self showNetworkNotAvailableAlert];
        return;
    }
    AFHTTPClient *client = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:[WS_Urls getMainUrl]]];
    NSMutableURLRequest *afRequest = [client multipartFormRequestWithMethod:@"POST" path:urlPath parameters:dict constructingBodyWithBlock:^(id <AFMultipartFormData>formData)
      {
          int timestamp = [[NSDate date] timeIntervalSince1970];
          [formData appendPartWithFileData:fileData name:fileKey fileName:[NSString stringWithFormat:@"%d.%@", timestamp, ext] mimeType:mimeType];
          
      }];
    
    /*------ If the response is  a json, then Use this code -----*/
    AFJSONRequestOperation *operation = [self getDealsWithSuccess:afRequest];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
     {
         float totalProgress = ((float)totalBytesWritten / (float)totalBytesExpectedToWrite);
         if (self.target != nil)// && [self.target respondsToSelector:@selector(parserUploadingHelper:andValue:)]
         {
             MBProgressHUD *hud = [MBProgressHUD HUDForView:[GlobalManager getAppDelegateInstance].window];
             [hud setProgress:totalProgress];
             [hud setDetailsLabelText:[NSString stringWithFormat:@"Uploading : %i%%",(NSInteger)((totalProgress * 1.0f) * 100)]];
         }
     }];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesReading, long long totalBytesExpectedToRead)
     {
         float totalProgress = ((float)totalBytesReading / (float)totalBytesExpectedToRead);
         if (self.target != nil && [self.target respondsToSelector:@selector(parserDownloadingHelper:andValue:)])
         {
             [self.target parserDownloadingHelper:self andValue:totalProgress];
         }
     }];
    [GlobalManager setOperationInstance:operation];
    [operation start];
}

- (void) sendRequestWithMultiplePostURL:(NSString *)urlPath andParametrers:(NSMutableDictionary *)dict andData:(NSMutableArray *)fileDataArr andFileKey:(NSMutableArray *)fileKeyArr andExtention:(NSString *)ext andMymeTye:(NSString *)mimeType
{
    if (![GlobalManager checkInternetConnection])
    {
        [MBProgressHUD hideAllHUDsForView:[[GlobalManager getAppDelegateInstance] window] animated:YES];
        [self showNetworkNotAvailableAlert];
        return;
    }
    NSMutableDictionary *requestData = [NSMutableDictionary dictionaryWithDictionary:dict];
    NSLog(@"POST REQUEST PARAMETERS---%@", requestData);
    //NSLog(@"POST Data Size-%@--%f MB", fileKey, [fileData length]*1.0 / (1024*1024));
    
    AFHTTPClient *client = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:[WS_Urls getMainUrl]]];
    NSMutableURLRequest *afRequest = [client multipartFormRequestWithMethod:@"POST" path:urlPath parameters:requestData constructingBodyWithBlock:^(id <AFMultipartFormData>formData)
      {
          NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[fileDataArr objectAtIndex:0]];
          for (NSString *key in [dict allKeys])
          {
              NSData *my_imageData = [dict valueForKey:key];
              NSString *fileKey = key;
              [formData appendPartWithFileData:my_imageData name:fileKey fileName:fileKey mimeType:mimeType];
          }
      }];
    
    /*------ If the response is  a json, then Use this code -----*/
    AFJSONRequestOperation *operation = [self getDealsWithSuccess:afRequest];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
     {
         float totalProgress = ((float)totalBytesWritten / (float)totalBytesExpectedToWrite);
         NSLog(@"Progress: %f", totalProgress);
         if (self.target != nil)//&& [self.target respondsToSelector:@selector(parserUploadingHelper:andValue:)]
         {
             MBProgressHUD *hud = [MBProgressHUD HUDForView:[GlobalManager getAppDelegateInstance].window];
             [hud setProgress:totalProgress];
             [hud setDetailsLabelText:[NSString stringWithFormat:@"Uploading : %i%%",(NSInteger)((totalProgress * 1.0f) * 100)]];
         }
     }];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesReading, long long totalBytesExpectedToRead)
     {
         float totalProgress = ((float)totalBytesReading / (float)totalBytesExpectedToRead);
         if (self.target != nil && [self.target respondsToSelector:@selector(parserDownloadingHelper:andValue:)])
         {
             [self.target parserDownloadingHelper:self andValue:totalProgress];
         }
     }];
    [GlobalManager setOperationInstance:operation];
    [operation start];
}

- (void)sendRequestWithDeleteURL:(NSString *)urlPath andParametrers:(NSDictionary *)dict
{
    NSLog(@"%@",urlPath);
    if (![GlobalManager checkInternetConnection])
    {
        [MBProgressHUD hideAllHUDsForView:[[GlobalManager getAppDelegateInstance] window] animated:YES];
        [self showNetworkNotAvailableAlert];
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    AFHTTPClient *client = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:[WS_Urls getMainUrl]]];
    NSDictionary *params = dict;
    NSURLRequest *request = [client requestWithMethod:@"DELETE" path:urlPath parameters:params];
    AFJSONRequestOperation *operation = [self getDealsWithSuccess:request];
    [GlobalManager setOperationInstance:operation];
    [operation start];
}

#pragma mark - AFJSONRequestOperation helper method

- (AFJSONRequestOperation*)getDealsWithSuccess:(NSURLRequest*)myRequest
{
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:myRequest success:^(NSURLRequest *request, NSURLResponse *response, id json)
     {
         if (self.target != nil && [self.target respondsToSelector:@selector(parserDidSuccessWithHelper:andResponse:)])
         {
             [self.target parserDidSuccessWithHelper:self andResponse:json];
         }
     }
    failure:^ (NSURLRequest *request, NSURLResponse *response, NSError *error, id json)
     {
         if (self.target != nil && [self.target respondsToSelector:@selector(parserDidFailPostWithHelper:andError:)])
         {
             if (json) {
                 [self.target parserDidSuccessWithHelper:self andResponse:json];
             }
             else{
                 [self.target parserDidFailPostWithHelper:self andError:error];
             }
             
         }
     }];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    return operation;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.operationQueue && [keyPath isEqualToString:@"operations"]) {
        if ([self.operationQueue.operations count] == 0) {
            // Do something here when your queue has completed
            NSLog(@"queue has completed");
            [self.target queCompletedWithFailed:self.sucessIndexes];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)downloadFileFromURL:(NSString *)fileUrl toPath:(NSString*)destPath
{
    // Init the disk cache
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *diskCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ImageCache"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:diskCachePath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[fileUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:destPath append:NO];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         // Give alert that downloading successful
         [self.target parserDidDownloadItem:destPath];
         //[MBHUDView hudWithBody:[NSString stringWithFormat:@"%@ %i%%",@"Downloading",100] type:MBAlertViewHUDTypeActivityIndicator hidesAfter:0 show:YES];
         //[MBHUDView dismissCurrentHUD];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self.target parserDidFailToDownloadItem:error];
         // [MBHUDView dismissCurrentHUD];
     }];
    [operation setDownloadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
     {
         //float totalProgress = (totalBytesWritten / (totalBytesExpectedToWrite * 1.0f) * 100);
         //[MBHUDView hudWithBody:[NSString stringWithFormat:@"%@ %i%%", @"Downloading", MIN((int)(totalProgress), 99)] type:MBAlertViewHUDTypeActivityIndicator hidesAfter:0 show:YES];
     }];
    [GlobalManager setOperationInstance:(AFJSONRequestOperation *)operation];
    [operation start];
}



@end