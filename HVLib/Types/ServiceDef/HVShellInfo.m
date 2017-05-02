//
//  HVShellInfo.m
//  HVLib
//
//  Copyright (c) 2013 Microsoft Corporation. All rights reserved.
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
#import "HVShellInfo.h"


static const xmlChar* x_element_url = XMLSTRINGCONST("url");
static const xmlChar* x_element_redirect = XMLSTRINGCONST("redirect-url");

@implementation HVShellInfo

@synthesize url = m_url;
@synthesize redirectUrl = m_redirectUrl;

-(void)dealloc
{
    [m_url release];
    [m_redirectUrl release];
    [super dealloc];
}

-(void)deserialize:(XReader *)reader
{
    m_url = [[reader readStringElementWithXmlName:x_element_url] retain];
    m_redirectUrl = [[reader readStringElementWithXmlName:x_element_redirect] retain];
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_url value:m_url];
    [writer writeElementXmlName:x_element_redirect value:m_redirectUrl];
}

@end
