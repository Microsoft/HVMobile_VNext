//
//  HVVocabItem.m
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
#import "HVVocabItem.h"

static const xmlChar* x_element_code = XMLSTRINGCONST("code-value");
static const xmlChar* x_element_displaytext = XMLSTRINGCONST("display-text");
static const xmlChar* x_element_abbrv = XMLSTRINGCONST("abbreviation-text");
static NSString* const c_element_data = @"info-xml";

@implementation HVVocabItem

@synthesize code = m_code;
@synthesize displayText = m_displayText;
@synthesize abbreviation = m_abbrv;
@synthesize dataXml = m_data;

-(void)dealloc
{
    [m_code release];
    [m_displayText release];
    [m_abbrv release];
    [m_data release];
    [super dealloc];
}

-(NSString *)toString
{
    return m_displayText;
}

-(NSString *)description
{
    return [self toString];
}

-(BOOL) matchesDisplayText:(NSString *)text
{
    return ([m_displayText caseInsensitiveCompare:[text trim]] == NSOrderedSame);
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE_STRING(m_code, HVClientError_InvalidVocabIdentifier);
    
    HVVALIDATE_SUCCESS;
    
LError:
    HVVALIDATE_FAIL;    
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_code value:m_code];
    [writer writeElementXmlName:x_element_displaytext value:m_displayText];
    [writer writeElementXmlName:x_element_abbrv value:m_abbrv];
    [writer writeRaw:m_data];
}

-(void)deserialize:(XReader *)reader
{
    m_code = [[reader readStringElementWithXmlName:x_element_code] retain];
    m_displayText = [[reader readStringElementWithXmlName:x_element_displaytext] retain];
    m_abbrv = [[reader readStringElementWithXmlName:x_element_abbrv] retain];
    m_data = [[reader readElementRaw:c_element_data] retain];    
}

@end

@implementation HVVocabItemCollection

-(id) init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [HVVocabItem class];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(HVVocabItem *)itemAtIndex:(NSUInteger)index
{
    return (HVVocabItem *) [self objectAtIndex:index];
}

-(void)sortByDisplayText
{
    [self sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        HVVocabItem* x = (HVVocabItem *) obj1;
        HVVocabItem* y = (HVVocabItem *) obj2;
        
        return [x.displayText compare:y.displayText];
        
    } ];
}

-(void)sortByCode
{
    [self sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        HVVocabItem* x = (HVVocabItem *) obj1;
        HVVocabItem* y = (HVVocabItem *) obj2;
        
        return [x.code compare:y.code];
    }];
}

-(NSUInteger)indexOfVocabCode:(NSString *)code
{
    for (NSUInteger i = 0, count = self.count; i < count; ++i)
    {
        HVVocabItem* item = [self itemAtIndex:i];
        if ([item.code isEqualToString:code])
        {
            return i;
        }
    }
    
    return NSNotFound;
}

-(HVVocabItem *)getItemWithCode:(NSString *)code
{
    NSUInteger index = [self indexOfVocabCode:code];
    if (index == NSNotFound)
    {
        return nil;
    }
    
    return [self itemAtIndex:index];
}

-(NSString *)displayTextForCode:(NSString *)code
{
    HVVocabItem* vocabItem = [self getItemWithCode:code];
    if (!vocabItem)
    {
        return nil;
    }
    
    return vocabItem.displayText;
}

-(NSArray *)displayStrings
{
    NSMutableArray* strings = [[[NSMutableArray alloc]initWithCapacity:self.count] autorelease];
    [self addDisplayStringsTo:strings];
    return strings;
}

-(void)addDisplayStringsTo:(NSMutableArray *)strings
{
    for (NSUInteger i = 0, count = self.count; i < count; ++i)
    {
        [strings addObject:[self itemAtIndex:i].displayText];
    }    
}

@end
