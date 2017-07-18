//
// MHVThingKey.m
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
#import "MHVThingKey.h"
#import "MHVValidator.h"

static const xmlChar *x_attribute_version = XMLSTRINGCONST("version-stamp");
static NSString *const c_localIDPrefix = @"L";

@implementation MHVThingKey

- (BOOL)hasVersion
{
    return ![NSString isNilOrEmpty:self.version];
}

- (instancetype)initWithID:(NSString *)thingID
{
    return [self initWithID:thingID andVersion:nil];
}

- (instancetype)initWithID:(NSString *)thingID andVersion:(NSString *)version
{
    if (!thingID)
    {
        MHVASSERT_PARAMETER(thingID);
        return nil;
    }

    self = [super init];
    
    if (self)
    {
        self.thingID = thingID;
        if (version)
        {
            self.version = version;
        }
    }

    return self;
}

- (instancetype)initWithKey:(MHVThingKey *)key
{
    if (!key)
    {
        MHVASSERT_PARAMETER(key);
        return nil;
    }

    return [self initWithID:key.thingID andVersion:key.version];
}

- (instancetype)initNew
{
    return [self initWithID:[[NSUUID UUID] UUIDString]];
}

+ (MHVThingKey *)newLocal
{
    NSString *thingID =  [c_localIDPrefix stringByAppendingString:[[NSUUID UUID] UUIDString]];
    NSString *version = [[NSUUID UUID] UUIDString];

    return [[MHVThingKey alloc] initWithID:thingID andVersion:version];
}

+ (MHVThingKey *)local
{
    return [MHVThingKey newLocal];
}

- (BOOL)isVersion:(NSString *)version
{
    return [self.version isEqualToString:version];
}

- (BOOL)isLocal
{
    return [self.thingID hasPrefix:c_localIDPrefix];
}

- (BOOL)isEqualToKey:(MHVThingKey *)key
{
    if (!key)
    {
        MHVASSERT_PARAMETER(key);
        return NO;
    }

    return [self.thingID isEqualToString:key.thingID] &&
           (self.version && key.version) &&
           [self.version isEqualToString:key.version]
    ;
}

- (MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN

    MHVVALIDATE_STRING(self.thingID, MHVClientError_InvalidThingKey);

    MHVVALIDATE_STRING(self.version, MHVClientError_InvalidThingKey);

    MHVVALIDATE_SUCCESS
}

- (NSString *)description
{
    return self.thingID;
}

- (void)serializeAttributes:(XWriter *)writer
{
    [writer writeAttributeXmlName:x_attribute_version value:self.version];
}

- (void)serialize:(XWriter *)writer
{
    [writer writeText:self.thingID];
}

- (void)deserializeAttributes:(XReader *)reader
{
    self.version = [reader readAttributeWithXmlName:x_attribute_version];
}

- (void)deserialize:(XReader *)reader
{
    self.thingID = [reader readValue];
}

@end

static NSString *const c_element_key = @"thing-id";

@interface MHVThingKeyCollectionInternal ()

@property (nonatomic, strong) NSMutableArray *inner;

@end

@implementation MHVThingKeyCollectionInternal

- (instancetype)init
{
    return [self initWithKey:nil];
}

- (instancetype)initWithKey:(MHVThingKey *)key
{
    self = [super init];

    if (self)
    {
        _inner = [NSMutableArray new];

        self.type = [MHVThingKey class];

        if (key)
        {
            [self addObject:key];
        }
    }

    return self;
}

- (MHVThingKey *)firstKey
{
    return [self objectAtIndex:0];
}

- (MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN

    MHVVALIDATE_ARRAY(self, MHVClientError_InvalidThingList);

    MHVVALIDATE_SUCCESS
}

- (void)serializeAttributes:(XWriter *)writer
{
}

- (void)deserializeAttributes:(XReader *)reader
{
}

- (void)serialize:(XWriter *)writer
{
    [writer writeElementArray:c_element_key elements:self.inner];
}

- (void)deserialize:(XReader *)reader
{
    _inner = [reader readElementArray:c_element_key asClass:[MHVThingKey class]];
}

@end
