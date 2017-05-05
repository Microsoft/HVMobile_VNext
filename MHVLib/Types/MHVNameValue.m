//
//  MHVNameValue.m
//  MHVLib
//
//  Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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

#import "MHVCommon.h"
#import "MHVNameValue.h"

static NSString* const c_element_name = @"name";
static NSString* const c_element_value = @"value";

@implementation MHVNameValue

@synthesize name = m_name;
@synthesize value = m_value;

-(double)measurementValue
{
    return (m_value) ? m_value.value : NAN;
}

-(void)setMeasurementValue:(double)measurementValue
{
    MHVENSURE(m_value, MHVMeasurement);
    m_value.value = measurementValue;
}

-(id)initWithName:(MHVCodedValue *)name andValue:(MHVMeasurement *)value
{
    MHVCHECK_NOTNULL(name);
    MHVCHECK_NOTNULL(value);
    
    self = [super init];
    MHVCHECK_SELF;
    
    self.name = name;
    self.value = value;
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}


+(MHVNameValue *)fromName:(MHVCodedValue *)name andValue:(MHVMeasurement *)value
{
    return [[MHVNameValue alloc] initWithName:name andValue:value];
}

-(MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN;
    
    MHVVALIDATE(m_name, MHVClientError_InvalidNameValue);
    MHVVALIDATE(m_value, MHVClientError_InvalidNameValue);
    
    MHVVALIDATE_SUCCESS;
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_name content:m_name];
    [writer writeElement:c_element_value content:m_value];
}

-(void)deserialize:(XReader *)reader
{
    m_name = [reader readElement:c_element_name asClass:[MHVCodedValue class]];
    m_value = [reader readElement:c_element_value asClass:[MHVMeasurement class]];
}

@end

@implementation MHVNameValueCollection

-(id) init
{
    self = [super init];
    MHVCHECK_SELF;
    
    self.type = [MHVNameValue class];
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}

-(MHVNameValue *)itemAtIndex:(NSUInteger)index
{
    return (MHVNameValue *) [self objectAtIndex:index];
}

-(NSUInteger)indexOfItemWithName:(MHVCodedValue *)code
{
    for (NSUInteger i = 0, count = self.count; i < count; ++i)
    {
        if ([[self itemAtIndex:i].name isEqualToCodedValue:code])
        {
            return i;
        }
     }     
    
    return NSNotFound;
}

-(NSUInteger)indexOfItemWithNameCode:(NSString *)nameCode
{
    for (NSUInteger i = 0, count = self.count; i < count; ++i)
    {
        if ([[self itemAtIndex:i].name.code isEqualToString:nameCode])
        {
            return i;
        }
    }     
    
    return NSNotFound;   
}

-(MHVNameValue *)getItemWithNameCode:(NSString *)nameCode
{
    NSUInteger index = [self indexOfItemWithNameCode:nameCode];
    if (index == NSNotFound)
    {
        return nil;
    }
    
    return [self itemAtIndex:index];
}

-(void)addOrUpdate:(MHVNameValue *)value
{
    NSUInteger indexOf = [self indexOfItemWithName:value.name];
    if (indexOf != NSNotFound)
    {
        [self replaceObjectAtIndex:indexOf withObject:value];
    }
    else
    {
        [super addObject:value];
    }
}

@end