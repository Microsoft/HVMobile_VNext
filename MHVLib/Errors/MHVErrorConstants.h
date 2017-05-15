//
//  MHVErrorConstants.h
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

#ifndef MHVErrorConstants_h
#define MHVErrorConstants_h

static NSString *const kMHVErrorDomain = @"com.microsoft.healthvault";

typedef NS_ENUM(NSUInteger, MHVErrorType)
{
    MHVErrorTypeRequiredParameter = 0,
    MHVErrorTypeOperationCannotBePerformed,
    MHVErrorTypeIOError,
    MHVErrorTypeUnauthorized,
    MHVErrorTypeOperationCancelled,
    MHVErrorTypeUnknown,
};

#endif /* MHVErrorConstants_h */
