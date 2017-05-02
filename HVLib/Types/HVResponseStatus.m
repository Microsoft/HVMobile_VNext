//
//  HVResponseStatus.m
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
#import "HVCommon.h"
#import "HVResponseStatus.h"

static const xmlChar* x_element_code = XMLSTRINGCONST("code");
static const xmlChar* x_element_error = XMLSTRINGCONST("error");

@implementation HVResponseStatus

@synthesize code = m_code;
@synthesize error = m_error;

-(BOOL)hasError
{
    return (m_code != 0 || m_error != nil);
}

-(void)dealloc
{
    [m_error release];
    
    [super dealloc];
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_code intValue:m_code];
    [writer writeElementXmlName:x_element_error content:m_error];
}

-(void)deserialize:(XReader *)reader
{
    m_code = [reader readIntElementXmlName:x_element_code];
    m_error = [[reader readElementWithXmlName:x_element_error asClass:[HVServerError class]] retain];
}

@end
