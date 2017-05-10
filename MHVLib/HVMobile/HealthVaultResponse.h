//
//  HealthVaultResponse.h
//  HealthVault Mobile Library for iOS
//
// Copyright 2017 Microsoft Corp.
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

#import <Foundation/Foundation.h>
#import "MHVHttpServiceResponse.h"
#import "HealthVaultRequest.h"

/// OK status
#define RESPONSE_OK  0;

/// App does not exist, app is invalid, app is not active or calling IP is invalid.
#define RESPONSE_INVALID_APPLICATION 6

/// Represents security problem for current app.
#define RESPONSE_ACCESS_DENIED 8

/// Represents that current token has been expired and should be updated. 
#define RESPONSE_AUTH_SESSION_TOKEN_EXPIRED 65

/// Implements HealthVault response.
@interface HealthVaultResponse : NSObject

/// Gets or sets numeric status code of the operation.
@property (assign) int statusCode;

// Gets the Http response code...
@property (assign) int webStatusCode;

/// Gets or sets the informational part of the response.
@property (strong) NSString *infoXml;

/// Gets or sets the raw xml that was returned from the request.
@property (strong) NSString *responseXml;

/// Gets or sets the text of the error that occurred.
/// If the error was returned from the HealthVault service,
/// additional error information may be found in the ResponseXml.
@property (strong) NSString *errorText;

/// Gets or sets a contextual xml description of the the error.
@property (strong) NSString *errorContextXml;

/// Gets or sets the informational part of the response.
@property (strong) NSString *errorInfo;

/// Gets or sets the request that was sent.
@property (strong) HealthVaultRequest *request;

/// Indicates whether the operation has failed.
@property (readonly, getter=getHasError) BOOL hasError;

/// Initializes a new instance of the HealthVaultResponse class.
/// @param response - the web response from server side.
/// @request - the original request.
- (instancetype)initWithWebResponse:(MHVHttpServiceResponse *)response
                            request:(HealthVaultRequest *)request;

@end
