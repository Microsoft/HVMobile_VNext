//
// MHVBlobDownloadRequest.h
// MHVLib
//
// Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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
#import "MHVHttpServiceOperationProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MHVBlobDownloadRequest : NSObject <MHVHttpServiceOperationProtocol>

@property (nonatomic, strong, readonly)           NSURL         *url;
@property (nonatomic, strong, readonly, nullable) NSString      *toFilePath;
@property (nonatomic, assign, readonly)           BOOL          isAnonymous;

/**
 * Create blob download request
 *
 * @param url Source location for downloading blob
 * @param toFilePath Destination location where blob data should be saved
 */
- (instancetype)initWithURL:(NSURL *)url
                 toFilePath:(NSString *_Nullable)toFilePath;

@end

NS_ASSUME_NONNULL_END
