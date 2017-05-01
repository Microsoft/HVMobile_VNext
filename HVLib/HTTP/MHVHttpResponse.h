//
// MHVHttpResponse.h
// HVLib
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

#import <Foundation/Foundation.h>

@interface MHVHttpResponse : NSObject

// The response data.
@property (nonatomic, strong, readonly, nullable) NSData *responseData;
@property (nonatomic, strong, readonly, nullable) NSString *responseString;

// The localized error text.
@property (nonatomic, strong, readonly, nullable) NSString *errorText;

// Gets error status for response. Returns YES if request has been failed.
@property (nonatomic, assign, readonly) BOOL hasError;

@property (nonatomic, assign, readonly) NSInteger statusCode;

- (instancetype _Nonnull)initWithResponseData:(NSData *_Nullable)responseData
                                   statusCode:(NSInteger)statusCode;

@end