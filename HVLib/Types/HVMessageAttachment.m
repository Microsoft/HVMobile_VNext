//
//  HVMessageAttachment.m
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

#import "HVCommon.h"
#import "HVMessageAttachment.h"

static const xmlChar* x_element_name = XMLSTRINGCONST("name");
static const xmlChar* x_element_blob = XMLSTRINGCONST("blob-name");
static const xmlChar* x_element_inline = XMLSTRINGCONST("inline-display");
static const xmlChar* x_element_contentid = XMLSTRINGCONST("content-id");

@implementation HVMessageAttachment

@synthesize name = m_name;
@synthesize blobName = m_blobName;
@synthesize isInline = m_isInline;
@synthesize contentID = m_contentID;

-(id)initWithName:(NSString *)name andBlobName:(NSString *)blobName
{
    HVCHECK_STRING(name);
    HVCHECK_STRING(blobName);
    
    self = [super init];
    HVCHECK_SELF;
    
    HVRETAIN(m_name, name);
    HVRETAIN(m_blobName, blobName);
    m_isInline = FALSE;
    m_contentID = nil;
    
    return self;

LError:
    HVALLOC_FAIL;
}

-(void)dealloc
{
    [m_name release];
    [m_blobName release];
    [m_contentID release];
    [super dealloc];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE_STRING(m_name, HVClientError_InvalidMessageAttachment);
    HVVALIDATE_STRING(m_blobName, HVClientError_InvalidMessageAttachment);
    
    HVVALIDATE_SUCCESS;
    
LError:
    HVVALIDATE_FAIL;
    
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_name value:m_name];
    [writer writeElementXmlName:x_element_blob value:m_blobName];
    [writer writeElementXmlName:x_element_inline boolValue:m_isInline];
    [writer writeElementXmlName:x_element_contentid value:m_contentID];
}

-(void)deserialize:(XReader *)reader
{
    m_name = [[reader readStringElementWithXmlName:x_element_name] retain];
    m_blobName = [[reader readStringElementWithXmlName:x_element_blob] retain];
    m_isInline = [reader readBoolElementXmlName:x_element_inline];
    m_contentID = [[reader readStringElementWithXmlName:x_element_contentid] retain];
}

@end

@implementation HVMessageAttachmentCollection

-(id) init
{
    self = [super init];
    HVCHECK_SELF;
    
    self.type = [HVMessageAttachment class];
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(HVMessageAttachment *)itemAtIndex:(NSUInteger)index
{
    return (HVMessageAttachment *) [self objectAtIndex:index];
}

@end


