//
//  MHVProcedure.m
//  MHVLib
//
//  Copyright (c) 2017 Microsoft Corporation. All rights reserved.

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

#import "MHVCommon.h"
#import "MHVProcedure.h"

static NSString* const c_typeid = @"df4db479-a1ba-42a2-8714-2b083b88150f";
static NSString* const c_typename = @"procedure";

static NSString* const c_element_when = @"when";
static NSString* const c_element_name = @"name";
static NSString* const c_element_location = @"anatomic-location";
static NSString* const c_element_primaryprovider = @"primary-provider";
static NSString* const c_element_secondaryprovider = @"secondary-provider";

@implementation MHVProcedure

@synthesize name = m_name;
@synthesize when = m_when;
@synthesize anatomicLocation = m_anatomicLocation;
@synthesize primaryProvider = m_primaryProvider;
@synthesize secondaryProvider = m_secondaryProvider;

-(id)initWithName:(NSString *)name
{
    MHVCHECK_STRING(name);
    
    self = [super init];
    MHVCHECK_SELF;
    
    m_name = [[MHVCodableValue alloc] initWithText:name];
    MHVCHECK_NOTNULL(m_name);
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(NSString *)description
{
    return [self toString];
}

-(NSString *)toString
{
    return (m_name) ? [m_name toString] : c_emptyString;
}

-(NSDate *)getDate
{
    return (m_when) ? [m_when toDate] : nil;
}

-(NSDate *)getDateForCalendar:(NSCalendar *)calendar
{
    return (m_when) ? [m_when toDateForCalendar:calendar] : nil;
}

-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN
    
    MHVVALIDATE(m_name, MHVClientError_InvalidProcedure);
    MHVVALIDATE_OPTIONAL(m_when);
    MHVVALIDATE_OPTIONAL(m_anatomicLocation);
    MHVVALIDATE_OPTIONAL(m_primaryProvider);
    MHVVALIDATE_OPTIONAL(m_secondaryProvider);
    
    MHVVALIDATE_SUCCESS
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_when content:m_when];
    [writer writeElement:c_element_name content:m_name];
    [writer writeElement:c_element_location content:m_anatomicLocation];
    [writer writeElement:c_element_primaryprovider content:m_primaryProvider];
    [writer writeElement:c_element_secondaryprovider content:m_secondaryProvider];
}

-(void)deserialize:(XReader *)reader
{
    m_when = [reader readElement:c_element_when asClass:[MHVApproxDateTime class]];
    m_name = [reader readElement:c_element_name asClass:[MHVCodableValue class]];
    m_anatomicLocation = [reader readElement:c_element_location asClass:[MHVCodableValue class]];
    m_primaryProvider = [reader readElement:c_element_primaryprovider asClass:[MHVPerson class]];
    m_secondaryProvider = [reader readElement:c_element_secondaryprovider asClass:[MHVPerson class]];
}

+(NSString *)typeID
{
    return c_typeid;
}

+(NSString *) XRootElement
{
    return c_typename;
}

+(MHVItem *) newItem
{
    return [[MHVItem alloc] initWithType:[MHVProcedure typeID]];
}

-(NSString *)typeName
{
    return NSLocalizedString(@"Procedure", @"Procedure Type Name");
}

@end