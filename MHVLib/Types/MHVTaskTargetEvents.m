//
//  MHVTaskTargetEvents.m
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

#import "MHVTaskTargetEvents.h"

static NSString *const c_element_element_xpath = @"element-xpath";
static NSString *const c_element_is_negated = @"is-negated";
static NSString *const c_element_element_values = @"element-values";

@implementation MHVTaskTargetEvent

- (void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_element_xpath content:self.elementXPath];
    [writer writeElement:c_element_is_negated content:self.isNegated];
    [writer writeElementArray:c_element_element_values elements:self.elementValues.toArray];
}

- (void)deserialize:(XReader *)reader
{
    self.elementXPath = [reader readElement:c_element_element_xpath asClass:[MHVStringNZNW class]];
    self.isNegated = [reader readElement:c_element_is_negated asClass:[MHVBool class]];
    self.elementValues = [reader readStringElementArray:c_element_element_values];
}

@end

static NSString *const c_element_target_event = @"target-event";

@implementation MHVTaskTargetEvents

- (void)serialize:(XWriter *)writer
{
    [writer writeElementArray:c_element_target_event elements:self.targetEvent.toArray];
}

- (void) deserialize:(XReader *)reader
{
    self.targetEvent = (MHVTaskTargetEventCollection *)[reader readElementArray:c_element_target_event asClass:[MHVTaskTargetEvent class] andArrayClass:[MHVTaskTargetEventCollection class]];
}

@end

@implementation MHVTaskTargetEventCollection

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.type = [MHVTaskTargetEvent class];
    }
    
    return self;
}

@end
