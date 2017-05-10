//
// MHVHttpService.m
// MHVLib
//
//  Copyright (c) 2017 Microsoft Corporation. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "MHVHttpService.h"
#import "MHVHttpServiceResponse.h"
#import "Logger.h"
#import "MHVBlobSource.h"
#import "MHVValidator.h"

@interface MHVHttpService () <NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) NSOperationQueue *certificateCheckQueue;

@property (nonatomic, assign) NSInteger requestCount;

@end

@implementation MHVHttpService

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                    delegate:self
                                               delegateQueue:nil];
        
        _certificateCheckQueue = [[NSOperationQueue alloc] init];
    }
    
    return self;
}

- (instancetype)initWithURLSession:(NSURLSession *)urlSession
{
    MHVASSERT_PARAMETER(urlSession);
    
    self = [super init];
    if (self)
    {
        _urlSession = urlSession;
        
        _certificateCheckQueue = [[NSOperationQueue alloc] init];
    }
    
    return self;
}

- (void)sendRequestForURL:(NSURL *)url
                     body:(NSString *_Nullable)body
               completion:(void (^)(MHVHttpServiceResponse *_Nullable response, NSError *_Nullable error))completion
{
    [self sendRequestForURL:url body:body headers:nil completion:completion];
}

- (void)sendRequestForURL:(NSURL *)url
                     body:(NSString *_Nullable)body
                  headers:(NSDictionary<NSString *, NSString *> *_Nullable)headers
               completion:(void (^)(MHVHttpServiceResponse *_Nullable response, NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(url);
    MHVASSERT([url.scheme isEqualToString:@"https"]);
    
    if (!url)
    {
        return;
    }
    
    NSMutableURLRequest *request = [[self requestWithUrl:url body:body] mutableCopy];
    
    for (NSString *key in headers.allKeys)
    {
        [request setValue:headers[key] forHTTPHeaderField:key];
    }
    
    NSInteger currentRequest = (++self.requestCount);
    NSDate *startDate = [NSDate date];

    [Logger write:[NSString stringWithFormat:@"Begin request #%li", (long)currentRequest]];

    [[self.urlSession dataTaskWithRequest:(NSURLRequest *)request
                        completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
      {
          NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
          
          [Logger write:[NSString stringWithFormat:@"Response for #%li has status code: %li (%0.4f seconds)",
                         (long)currentRequest, (long)statusCode, [[NSDate date] timeIntervalSinceDate:startDate]]];
          
          if (error)
          {
              if (completion)
              {
                  completion(nil, error);
              }
          }
          else
          {
              if (completion)
              {
                  completion([self responseFromData:data urlResponse:response], nil);
              }
          }
      }] resume];
}

- (void)downloadFileWithUrl:(NSURL *)url
                 toFilePath:(NSString *)path
                 completion:(void (^)(NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(url);
    MHVASSERT_PARAMETER(path);
    
    if (!url || !path)
    {
        return;
    }

    NSURLRequest *request = [self requestWithUrl:url body:nil];
    
    [[self.urlSession downloadTaskWithRequest:request
                            completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error)
      {
          if (error)
          {
              if (completion)
              {
                  completion(error);
              }
              return;
          }
          
          NSError *fileError;
          if (![[NSFileManager defaultManager] copyItemAtURL:location toURL:[NSURL fileURLWithPath:path] error:&fileError])
          {
              if (completion)
              {
                  completion(fileError);
              }
          }
          else
          {
              [[NSFileManager defaultManager] setAttributes:@{
                                                              NSFileProtectionKey : NSFileProtectionCompleteUntilFirstUserAuthentication
                                                              }
                                               ofItemAtPath:path
                                                      error:nil];
              if (completion)
              {
                  completion(nil);
              }
          }
      }] resume];
}

- (void)uploadBlobSource:(id<MHVBlobSourceProtocol>)blobSource
                   toUrl:(NSURL *)url
               chunkSize:(NSUInteger)chunkSize
              completion:(void (^)(MHVHttpServiceResponse *_Nullable response, NSError *_Nullable error))completion
{
    [self uploadBlobSource:blobSource toUrl:url chunkOffset:0 chunkSize:chunkSize completion:completion];
}

- (void)uploadBlobSource:(id<MHVBlobSourceProtocol>)blobSource
                   toUrl:(NSURL *)url
             chunkOffset:(NSUInteger)chunkOffset
               chunkSize:(NSUInteger)chunkSize
              completion:(void (^)(MHVHttpServiceResponse *_Nullable response, NSError *_Nullable error))completion
{
    MHVASSERT_PARAMETER(blobSource);
    MHVASSERT_PARAMETER(url);
    MHVASSERT([url.scheme isEqualToString:@"https"]);
    MHVASSERT(chunkSize != 0);
    
    if (!blobSource || !url)
    {
        return;
    }

    NSUInteger thisChunkSize = MIN(chunkSize, (blobSource.length - chunkOffset));
    
    NSData *data = [blobSource readStartAt:chunkOffset chunkSize:thisChunkSize];

    NSURLRequest *request = [self requestWithUrl:url
                                            data:data
                                     chunkOffset:chunkOffset
                                       totalSize:blobSource.length];
    
    [Logger write:[NSString stringWithFormat:@"Blob upload chunk at offset %li", (long)chunkOffset]];
    NSDate *startDate = [NSDate date];

    [[self.urlSession dataTaskWithRequest:(NSURLRequest *)request
                        completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
      {
          if (!error)
          {
              [Logger write:[NSString stringWithFormat:@"Blob upload chunk size %li in %0.4f seconds", (long)thisChunkSize, [[NSDate date] timeIntervalSinceDate:startDate]]];
          }

          if (!error && chunkOffset + thisChunkSize < blobSource.length)
          {
              //Update offset and call this method again to send the next chunk
              [self uploadBlobSource:blobSource
                               toUrl:url
                         chunkOffset:chunkOffset + thisChunkSize
                           chunkSize:chunkSize
                          completion:completion];
              return;
          }
          else
          {
              if (error)
              {
                  [Logger write:[NSString stringWithFormat:@"Blob upload error: %@", error.localizedDescription]];
                  
                  if (completion)
                  {
                      completion(nil, error);
                  }
              }
              else
              {
                  [Logger write:[NSString stringWithFormat:@"Blob upload complete"]];
                  
                  if (completion)
                  {
                      completion([self responseFromData:data urlResponse:response], nil);
                  }
              }
          }
      }] resume];
}

#pragma mark - Helpers

- (NSURLRequest *)requestWithUrl:(NSURL *)url
                            body:(NSString *)body
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
    if (body)
    {
        NSData *bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
        
        request.HTTPMethod = @"POST";
        request.HTTPBody = bodyData;
        
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)bodyData.length] forHTTPHeaderField:@"Content-Length"];
    }
    
    return request;
}

- (NSURLRequest *)requestWithUrl:(NSURL *)url
                            data:(NSData *)data
                     chunkOffset:(NSUInteger)chunkOffset
                       totalSize:(NSUInteger)totalSize
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    request.HTTPMethod = @"POST";
    request.HTTPBody = data;

    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];

    NSString *contentRange = [NSString stringWithFormat:@"bytes %lu-%lu/*", (unsigned long)chunkOffset, (unsigned long)chunkOffset + data.length - 1];
    [request setValue:contentRange forHTTPHeaderField:@"Content-Range"];

    //Last chunk, add the "complete" header
    if (chunkOffset + data.length == totalSize)
    {
        [request setValue:@"1" forHTTPHeaderField:@"x-hv-blob-complete"];
    }

    return request;
}

- (MHVHttpServiceResponse *)responseFromData:(NSData *)data urlResponse:(NSURLResponse *)response
{
    NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
    
    return [[MHVHttpServiceResponse alloc] initWithResponseData:data
                                                     statusCode:statusCode];
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *_Nullable credential))completionHandler
{
    // Check if certificate chain is valid or returns an error (SecTrustEvaluate is syncronous, so perform check on a Queue)
    [self.certificateCheckQueue addOperationWithBlock:^
     {
         SecTrustResultType result;
         SecTrustEvaluate([challenge.protectionSpace serverTrust], &result);
         
         // Unspecified is a valid certificate, but not specifically accepted in the keychain (iOS's normal response)
         if (result == kSecTrustResultUnspecified ||
             result == kSecTrustResultProceed)
         {
             completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
         }
         else
         {
             [Logger write:[NSString stringWithFormat:@"SecTrustEvaluate failed %li", (long)result]];
             
             completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
         }
     }];
}

@end
