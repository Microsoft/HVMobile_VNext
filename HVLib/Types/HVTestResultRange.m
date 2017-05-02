//
//  HVTestResultRange.m
//  HVLib
//
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
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
//

#import "HVCommon.h"
#import "HVTestResultRange.h"

static const xmlChar* x_element_type = XMLSTRINGCONST("type");
static const xmlChar* x_element_text = XMLSTRINGCONST("text");
static const xmlChar* x_element_value = XMLSTRINGCONST("value");

@implementation HVTestResultRange

@synthesize type = m_type;
@synthesize text = m_text;
@synthesize value = m_value;

-(void)dealloc
{
    [m_type release];
    [m_text release];
    [m_value release];
    
    [super dealloc];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE(m_type, HVClientError_InvalidTestResultRange);
    HVVALIDATE(m_text, HVClientError_InvalidTestResultRange);
    HVVALIDATE_OPTIONAL(m_value);
    
    HVVALIDATE_SUCCESS;
    
LError:
    HVVALIDATE_FAIL;
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_type content:m_type];
    [writer writeElementXmlName:x_element_text content:m_text];
    [writer writeElementXmlName:x_element_value content:m_value];
}

-(void)deserialize:(XReader *)reader
{
    m_type = [[reader readElementWithXmlName:x_element_type asClass:[HVCodableValue class]] retain];
    m_text = [[reader readElementWithXmlName:x_element_text asClass:[HVCodableValue class]] retain];
    m_value = [[reader readElementWithXmlName:x_element_value asClass:[HVTestResultRangeValue class]] retain];
}

@end

@implementation HVTestResultRangeCollection

-(id) init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [HVTestResultRange class];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)addItem:(HVTestResultRange *)item
{
    [super addObject:item];
}

-(HVTestResultRange *)itemAtIndex:(NSUInteger)index
{
    return [self objectAtIndex:index];
}

@end
