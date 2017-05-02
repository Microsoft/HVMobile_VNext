//
//  HVVocabSearch.m
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
#import "HVVocabSearchParams.h"

static NSString* const c_element_text = @"search-string";
static NSString* const c_element_max = @"max-results";

@implementation HVVocabSearchParams

@synthesize text = m_text;
@synthesize maxResults = m_maxResults;

-(id)initWithText:(NSString *)text
{
    HVCHECK_STRING(text);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_text = [[HVVocabSearchText alloc] initWith:text];
    HVCHECK_NOTNULL(m_text);
    
    m_maxResults = 25;
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_text release];
    [super dealloc];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN

    HVVALIDATE(m_text, HVClientError_InvalidVocabSearch);
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElement:c_element_text content:m_text];
    if (m_maxResults > 0)
    {
        [writer writeElement:c_element_max intValue:(int)m_maxResults];
    }
}

-(void)deserialize:(XReader *)reader
{
    m_text = [[reader readElement:c_element_text asClass:[HVVocabSearchText class]] retain];
    m_maxResults = [reader readIntElement:c_element_max];
}

@end
