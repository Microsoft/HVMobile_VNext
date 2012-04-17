//
//  Provisioner.h
//  HealthVault Mobile Library for iOS
//
// Copyright 2011 Microsoft Corp.
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

@class HealthVaultService;

/// Implements the application authorization process.
@interface Provisioner : NSObject

/// Authorizes other records.
/// @param service - the HealthVaultService instance.
/// @param target - callback method owner.
/// @param authCompleted - method that is called when the authentication process is complete.
/// @param shellAuthRequired - method that is called when the application needs to perform authorization.
+ (void)authorizeRecords: (HealthVaultService *)service
                  target: (NSObject *)target
 authenticationCompleted: (SEL)authCompleted
       shellAuthRequired: (SEL)shellAuthRequired;

/// Checks that the application is authenticated.
/// @param service - the HealthVaultService instance.
/// @param target - callback method owner.
/// @param authCompleted - method that is called when the authentication process is complete.
/// @param shellAuthRequired - method that is called when the application needs to perform authorization.
+ (void)performAuthenticationCheck: (HealthVaultService *)service
                            target: (NSObject *)target
           authenticationCompleted: (SEL)authCompleted
                 shellAuthRequired: (SEL)shellAuthRequired;

@end
