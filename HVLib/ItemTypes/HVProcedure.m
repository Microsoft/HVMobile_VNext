//
//  HVProcedure.m
//  HVLib
//
//  Copyright (c) 2012 Microsoft Corporation. All rights reserved.

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
#import "HVProcedure.h"

static NSString* const c_typeid = @"df4db479-a1ba-42a2-8714-2b083b88150f";
static NSString* const c_typename = @"procedure";

static NSString* const c_element_when = @"when";
static NSString* const c_element_name = @"name";
static NSString* const c_element_location = @"anatomic-location";
static NSString* const c_element_primaryprovider = @"primary-provider";
static NSString* const c_element_secondaryprovider = @"secondary-provider";

@implementation HVProcedure

@synthesize name = m_name;
@synthesize when = m_when;
@synthesize anatomicLocation = m_anatomicLocation;
@synthesize primaryProvider = m_primaryProvider;
@synthesize secondaryProvider = m_secondaryProvider;

-(id)initWithName:(NSString *)name
{
    HVCHECK_STRING(name);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_name = [[HVCodableValue alloc] initWithText:name];
    HVCHECK_NOTNULL(m_name);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_when release];
    [m_name release];
    [m_anatomicLocation release];
    [m_primaryProvider release];
    [m_secondaryProvider release];
    
    [super dealloc];
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

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_name, HVClientError_InvalidProcedure);
    HVVALIDATE_OPTIONAL(m_when);
    HVVALIDATE_OPTIONAL(m_anatomicLocation);
    HVVALIDATE_OPTIONAL(m_primaryProvider);
    HVVALIDATE_OPTIONAL(m_secondaryProvider);
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
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
    m_when = [[reader readElement:c_element_when asClass:[HVApproxDateTime class]] retain];
    m_name = [[reader readElement:c_element_name asClass:[HVCodableValue class]] retain];
    m_anatomicLocation = [[reader readElement:c_element_location asClass:[HVCodableValue class]] retain];
    m_primaryProvider = [[reader readElement:c_element_primaryprovider asClass:[HVPerson class]] retain];
    m_secondaryProvider = [[reader readElement:c_element_secondaryprovider asClass:[HVPerson class]] retain];
}

+(NSString *)typeID
{
    return c_typeid;
}

+(NSString *) XRootElement
{
    return c_typename;
}

+(HVItem *) newItem
{
    return [[HVItem alloc] initWithType:[HVProcedure typeID]];
}

-(NSString *)typeName
{
    return NSLocalizedString(@"Procedure", @"Procedure Type Name");
}

@end
