//
//  HVRemoveRecordAuthTask.m
//  HVLib
//
// Copyright (c) 2012 Microsoft Corporation. All rights reserved.
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

#import "HVCommon.h"
#import "HVRemoveRecordAuthTask.h"

@implementation HVRemoveRecordAuthTask

-(NSString *)name
{
    return @"RemoveApplicationRecordAuthorization";
}

-(float)version
{
    return 1;
}

-(id)initWithRecord:(HVRecordReference *)record andCallback:(HVTaskCompletion)callback
{
    self = [super initWithCallback:callback];
    HVCHECK_SELF;
    
    self.record = record;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [super dealloc];
}

-(void)prepare
{
    [self ensureRecord];
}

-(void)serializeRequestBodyToWriter:(XWriter *)writer
{
}

-(id)deserializeResponseBodyFromReader:(XReader *)reader
{
    return [[reader readInnerXml] retain];
}

@end
