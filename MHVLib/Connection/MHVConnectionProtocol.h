//
//  MHVConnectionProtocol.h
//  MHVLib
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MHVSessionCredential, MHVPersonInfo, MHVHttpServiceResponse, MHVMethod;

@protocol MHVPersonClientProtocol, MHVPlatformClientProtocol, MHVThingClientProtocol, MHVVocabularyClientProtocol;

NS_ASSUME_NONNULL_BEGIN

/**
 Represents a connection for an application to the HealthVault service for operations.
 */
@protocol MHVConnectionProtocol <NSObject>

/**
 Gets the application identifier.

 @return The application identifier.
 */
- (NSUUID *_Nullable)applicationId;

/**
 Gets session credential.

 @return session credential.
 */
- (MHVSessionCredential *_Nullable)sessionCredential;


/**
 Makes Web request call to HealthVault service for specified method name and method version.

 @param method The method to execute.
 @param version The method version.
 @param parameters Method parameters - Optional.
 @param recordId The record id - Optional.
 @param correlationId The correlation id - Optional.
 @para
 */
- (void)executeMethod:(MHVMethod *)method
              version:(NSInteger)version
           parameters:(NSString *_Nullable)parameters
             recordId:(NSUUID *_Nullable)recordId
        correlationId:(NSUUID *_Nullable)correlationId
           completion:(void (^_Nullable)(MHVHttpServiceResponse *_Nullable response, NSError *_Nullable error))completion;

/**
 Gets the person information for the current account.

 @param completion Envoked when the operation completes. MHVPersonInfo the person info for the current account. NSError object will be nil if there is no error when performing the operation.
 
 @note This includes the list of authorized records for the application instance.
 */
- (void)getPersonInfoWithCompletion:(void (^)(MHVPersonInfo *_Nullable, NSError *_Nullable error))completion;

/**
 Authenticates the connection. Calling authenticate will immediately present an authentication user interface if the connection is not authenticated.

 @param viewController Optional A view controller used to present a user authentication user interface. If the viewController parameter is nil the authentication flow will be presented from the current window's root view controller.
 @param completion Envoked when the operation completes. NSError object will be nil if there is no error when performing the operation.
 */
- (void)authenticateWithViewController:(UIViewController *_Nullable)viewController
                            completion:(void(^_Nullable)(NSError *_Nullable error))completion;

/**
 A client that can be used to access information and records associated with the currently athenticated user.

 @return An instance conforming to MHVPersonClientProtocol.
 */
- (id<MHVPersonClientProtocol> _Nullable)personClient;

/**
 A client that can be used to interact with the HealthVault platform.

 @return An instance conforming to MHVPlatformClientProtocol.
 */
- (id<MHVPlatformClientProtocol> _Nullable)platformClient;

/**
 A client that can be used to access things associated with a particular record.

 @return An instance conforming to MHVThingClientProtocol.
 */
- (id<MHVThingClientProtocol> _Nullable)thingClient;


/**
 A client that can be used to access vocabularies.

 @return An instance conforming to MHVVocabularyClientProtocol.
 */
- (id<MHVVocabularyClientProtocol> _Nullable)vocabularyClient;

@end

NS_ASSUME_NONNULL_END
