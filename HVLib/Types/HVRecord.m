//
//  HVRecord.m
//  HVLib
//
//  Copyright (c) 2012 Microsoft Corporation. All rights reserved.
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

#import "HVCommon.h"
#import "HVRecord.h"
#import "HVPersonalImage.h"
#import "HVBlobPayloadItem.h"

static NSString* const c_element_displayname = @"display-name";
static NSString* const c_element_relationship = @"rel-name";

@implementation HVRecord

@synthesize name = m_name;
@synthesize displayName = m_displayName;
@synthesize relationship = m_relationship;

-(id)initWithRecord:(HealthVaultRecord *)record
{
    HVCHECK_NOTNULL(record);
    
    self = [super init];
    HVCHECK_SELF;
    
    self.ID = record.recordId;
    self.personID = record.personId;
    self.name = record.recordName;
    self.displayName = record.displayName;
    self.relationship = record.relationship;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void) dealloc
{
    [m_name release];
    [m_displayName release];
    [m_relationship release];
    
    [super dealloc];
}

-(HVGetPersonalImageTask *)downloadPersonalImageWithCallback:(HVTaskCompletion)callback
{
    HVGetPersonalImageTask* task = [[HVGetPersonalImageTask alloc] initWithRecord:self andCallback:callback];
    HVCHECK_NOTNULL(task);
    
    [task start];
    return task;
    
LError:
    return nil;
}

-(HVClientResult *)validate
{    
    HVVALIDATE_BEGIN;
    
    HVCHECK_RESULT([super validate]);
    
    HVVALIDATE_STRING(m_name, HVClientError_InvalidRecord);
    
    HVVALIDATE_SUCCESS;
    
LError:
    HVVALIDATE_FAIL;
   
}

-(void) serializeAttributes:(XWriter *)writer
{
    [super serializeAttributes:writer];
    
    [writer writeAttribute:c_element_displayname value:m_displayName];
    [writer writeAttribute:c_element_relationship value:m_relationship];
}

-(void)serialize:(XWriter *)writer
{
    [writer writeText:m_name];
}

-(void) deserializeAttributes:(XReader *)reader
{
    [super deserializeAttributes:reader];
    
    m_displayName = [[reader readAttribute:c_element_displayname] retain];
    m_relationship = [[reader readAttribute:c_element_relationship] retain];
}

-(void)deserialize:(XReader *)reader
{
    m_name = [[reader readValue] retain];
}

@end

@implementation HVRecordCollection

-(id) init
{
    return [self initWithRecordArray:nil];
}

-(id)initWithRecordArray:(NSArray *)records
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [HVRecord class];
    
    if (records)
    {
        for (HealthVaultRecord* record in records) 
        {
            HVRecord *hvRecord = [[HVRecord alloc] initWithRecord:record];
            [self addObject:hvRecord];
            [hvRecord release];
        }
    }
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(HVRecord *)itemAtIndex:(NSUInteger)index
{
    return (HVRecord *) [m_inner objectAtIndex:index];
}

-(NSInteger)indexOfRecordID:(NSString *)recordID
{
    for (NSUInteger i = 0, count = self.count; i < count; ++i)
    {
        HVRecord* record = [self itemAtIndex:i];
        if ([record.ID isEqualToString:recordID])
        {
            return i;
        }
    }
    
    return NSNotFound;
}

@end

