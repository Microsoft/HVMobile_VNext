//
// MHVCodableValue.m
// MHVLib
//
// Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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
#import "MHVCodableValue.h"

static const xmlChar *x_element_text = XMLSTRINGCONST("text");
static NSString *const c_element_code = @"code";
static const xmlChar *x_element_code = XMLSTRINGCONST("code");

@implementation MHVCodableValue

- (BOOL)hasCodes
{
    return ![MHVCollection isNilOrEmpty:self.codes];
}

- (MHVCodedValueCollection *)codes
{
    if (!_codes)
    {
        _codes = [[MHVCodedValueCollection alloc] init];
    }
    
    return _codes;
}

- (MHVCodedValue *)firstCode
{
    return (self.hasCodes) ? [self.codes objectAtIndex:0] : nil;
}

- (id)initWithText:(NSString *)textValue
{
    return [self initWithText:textValue andCode:nil];
}

- (id)initWithText:(NSString *)textValue andCode:(MHVCodedValue *)code
{
    MHVCHECK_STRING(textValue);
    
    self = [super init];
    if (self)
    {
        _text = textValue;
        _codes = [[MHVCodedValueCollection alloc] init];
        
        if (code)
        {
            [_codes addObject:code];
        }
    }
    
    return self;
}

- (id)initWithText:(NSString *)textValue code:(NSString *)code andVocab:(NSString *)vocab
{
    MHVCodedValue *codedValue = [[MHVCodedValue alloc] initWithCode:code andVocab:vocab];
    
    MHVCHECK_NOTNULL(codedValue);
    
    self = [self initWithText:textValue andCode:codedValue];
    
    return self;
}

+ (MHVCodableValue *)fromText:(NSString *)textValue
{
    return [[MHVCodableValue alloc] initWithText:textValue];
}

+ (MHVCodableValue *)fromText:(NSString *)textValue andCode:(MHVCodedValue *)code
{
    return [[MHVCodableValue alloc] initWithText:textValue andCode:code];
}

+ (MHVCodableValue *)fromText:(NSString *)textValue code:(NSString *)code andVocab:(NSString *)vocab
{
    return [[MHVCodableValue alloc] initWithText:textValue code:code andVocab:vocab];
}

- (BOOL)matchesDisplayText:(NSString *)text
{
    return [self.text caseInsensitiveCompare:[text trim]] == NSOrderedSame;
}

- (BOOL)containsCode:(MHVCodedValue *)code
{
    if (!self.codes)
    {
        return FALSE;
    }
    
    return [self.codes containsCode:code];
}

- (BOOL)addCode:(MHVCodedValue *)code
{
    [self.codes addObject:code];
    
    return TRUE;
}

- (void)clearCodes
{
    if (self.codes)
    {
        [self.codes removeAllObjects];
    }
}

- (MHVCodableValue *)clone
{
    MHVCodableValue *cloned = [[MHVCodableValue alloc] initWithText:self.text];
    
    MHVCHECK_NOTNULL(cloned);
    
    if (self.hasCodes)
    {
        MHVCodedValueCollection *codes = self.codes;
        for (NSUInteger i = 0; i < codes.count; ++i)
        {
            MHVCodedValue *clonedCode = [[codes objectAtIndex:i] clone];
            MHVCHECK_NOTNULL(clonedCode);
            
            [cloned addCode:clonedCode];
        }
    }
    
    return cloned;
}

- (NSString *)description
{
    return [self toString];
}

- (NSString *)toString
{
    return self.text;
}

- (NSString *)toStringWithFormat:(NSString *)format
{
    return [NSString stringWithFormat:format, self.text];
}

- (MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN;
    
    MHVVALIDATE_STRING(self.text, MHVClientError_InvalidCodableValue);
    if (self.hasCodes)
    {
        for (MHVCodedValue *code in self.codes)
        {
            MHVVALIDATE(code, MHVClientError_InvalidCodableValue);
        }
    }
    
    MHVVALIDATE_SUCCESS;
}

- (void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_text value:self.text];
    [writer writeElementArray:c_element_code elements:self.codes.toArray];
}

- (void)deserialize:(XReader *)reader
{
    self.text = [reader readStringElementWithXmlName:x_element_text];
    self.codes = (MHVCodedValueCollection *)[reader readElementArrayWithXmlName:x_element_code asClass:[MHVCodedValue class] andArrayClass:[MHVCodedValueCollection class]];
}

@end

@implementation MHVCodableValueCollection

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.type = [MHVCodableValue class];
    }
    
    return self;
}

@end
