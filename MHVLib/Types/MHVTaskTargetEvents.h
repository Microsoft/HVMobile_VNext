//
//  MHVTaskTargetEvents.h
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

#import "MHVType.h"
#import "MHVCollection.h"
#import "MHVStringNZNW.h"
#import "MHVBool.h"

@interface MHVTaskTargetEvent : MHVType

@property (readwrite, nonatomic, strong) MHVStringNZNW *elementXPath;
@property (readwrite, nonatomic, strong) MHVBool *isNegated;
@property (readwrite, nonatomic, strong) MHVStringCollection *elementValues;

@end

@interface MHVTaskTargetEventCollection : MHVCollection<MHVTaskTargetEvent *>

@end

@interface MHVTaskTargetEvents : MHVType

@property (readwrite, nonatomic, strong) MHVTaskTargetEventCollection *targetEvent;

@end
