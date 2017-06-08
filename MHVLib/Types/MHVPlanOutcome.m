//
//  MHVPlanOutcome.m
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

#import "MHVPlanOutcome.h"

static NSString *const c_element_name = @"name";
static NSString *const c_element_type = @"type";

@implementation MHVPlanOutcome

- (void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_name content:self.name];
    [writer writeElement:c_element_type value:self.type];
}

- (void)deserialize:(XReader *)reader
{
    self.name = [reader readElement:c_element_name asClass:[MHVStringNZNW class]];
    self.type = [reader readStringElement:c_element_type];
}

@end

@implementation MHVPlanOutcomeCollection

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.type = [MHVPlanOutcome class];
    }
    
    return self;
}

@end
