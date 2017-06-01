//
// MHVThingQuery.m
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
#import "MHVThingQuery.h"
#import "MHVType.h"
#import "MHVPendingThing.h"

static NSString *const c_attribute_name = @"name";
static NSString *const c_attribute_max = @"max";
static NSString *const c_attribute_maxfull = @"max-full";
static NSString *const c_element_id = @"id";
static NSString *const c_element_key = @"key";
static NSString *const c_element_clientID = @"client-thing-id";
static NSString *const c_element_filter = @"filter";
static NSString *const c_element_view = @"format";

@interface MHVThingQuery ()

@property (readwrite, nonatomic, strong) MHVStringCollection *thingIDs;
@property (readwrite, nonatomic, strong) MHVThingKeyCollection *keys;
@property (readwrite, nonatomic, strong) MHVStringCollection *clientIDs;
@property (readwrite, nonatomic, strong) MHVThingFilterCollection *filters;
@property (readwrite, nonatomic, strong) MHVInt *max;
@property (readwrite, nonatomic, strong) MHVInt *maxFull;

@end

@implementation MHVThingQuery

- (void)setView:(MHVThingView *)view
{
    MHVASSERT(view != nil);
    if (view)
    {
        _view = view;
    }
}

- (int)maxResults
{
    return (self.max) ? self.max.value : -1;
}

- (void)setMaxResults:(int)maxResultsValue
{
    if (maxResultsValue >= 0)
    {
        if (!self.max)
        {
            self.max = [[MHVInt alloc] init];
        }
        
        self.max.value = maxResultsValue;
    }
    else
    {
        self.max = nil;
    }
}

- (int)maxFullResults
{
    return (self.maxFull) ? self.maxFull.value : -1;
}

- (void)setMaxFullResults:(int)maxFullResultsValue
{
    if (maxFullResultsValue >= 0)
    {
        if (!self.maxFull)
        {
            self.maxFull = [[MHVInt alloc] init];
        }
        
        self.maxFull.value = maxFullResultsValue;
    }
    else
    {
        self.maxFull = nil;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _view = [[MHVThingView alloc] init];
        _thingIDs = [[MHVStringCollection alloc] init];
        _keys = [[MHVThingKeyCollection alloc] init];
        _clientIDs = [[MHVStringCollection alloc] init];
        _filters = [[MHVThingFilterCollection alloc] init];
        
        MHVCHECK_TRUE(_view && _thingIDs && _keys && _filters);
    }
    return self;
}

- (instancetype)initWithTypeID:(NSString *)typeID
{
    MHVCHECK_STRING(typeID);
    
    MHVThingFilter *filter = [[MHVThingFilter alloc] initWithTypeID:typeID];
    self = [self initWithFilter:filter];
    
    return self;
}

- (instancetype)initWithFilter:(MHVThingFilter *)filter
{
    MHVCHECK_NOTNULL(filter);
    
    self = [self init];
    if (self)
    {
        [_filters addObject:filter];
        
        if (![MHVCollection isNilOrEmpty:filter.typeIDs])
        {
            [_view.typeVersions addObjectsFromArray:filter.typeIDs.toArray];
        }
    }
    return self;
}

- (instancetype)initWithThingID:(NSString *)thingID
{
    MHVCHECK_STRING(thingID);
    
    self = [self init];
    if (self)
    {
        [_thingIDs addObject:thingID];
    }
    return self;
}

- (instancetype)initWithThingIDs:(NSArray *)ids
{
    MHVCHECK_NOTNULL(ids);
    
    self = [self init];
    if (self)
    {
        [_thingIDs addObjectsFromArray:ids];
    }
    return self;
}

- (instancetype)initWithThingKey:(MHVThingKey *)key
{
    MHVCHECK_NOTNULL(key);
    
    self = [self init];
    if (self)
    {
        [_keys addObject:key];
    }
    
    return self;
}

- (instancetype)initWithThingKeys:(NSArray *)keys
{
    MHVCHECK_NOTNULL(keys);
    
    self = [self init];
    if (self)
    {
        [_keys addObjectsFromArray:keys];
    }
    return self;
}

- (instancetype)initWithPendingThings:(MHVCollection *)pendingThings
{
    MHVCHECK_NOTNULL(pendingThings);
    
    self = [self init];
    if (self)
    {
        for (MHVPendingThing *thing in pendingThings)
        {
            [_keys addObject:thing.key];
        }
    }
    return self;
}

- (instancetype)initWithThingKey:(MHVThingKey *)key andType:(NSString *)typeID
{
    self = [self init];
    if (self)
    {
        [_keys addObject:key];
        if (![NSString isNilOrEmpty:typeID])
        {
            [self.view.typeVersions addObject:typeID];
        }
    }
    return self;
}

- (instancetype)initWithThingID:(NSString *)thingID andType:(NSString *)typeID
{
    MHVCHECK_STRING(thingID);
    
    self = [self init];
    if (self)
    {
        [_thingIDs addObject:thingID];
        if (![NSString isNilOrEmpty:typeID])
        {
            [self.view.typeVersions addObject:typeID];
        }
    }
    return self;
}

- (instancetype)initWithClientID:(NSString *)clientID andType:(NSString *)typeID
{
    MHVCHECK_STRING(clientID);
    
    self = [self init];
    if (self)
    {
        [_clientIDs addObject:clientID];
        if (![NSString isNilOrEmpty:typeID])
        {
            [self.view.typeVersions addObject:typeID];
        }
    }
    return self;
}

- (MHVClientResult *)validate
{
    MHVVALIDATE_BEGIN;
    
    MHVVALIDATE(self.view, MHVClientError_InvalidThingQuery);
    
    MHVVALIDATE_ARRAYOPTIONAL(self.thingIDs, MHVClientError_InvalidThingQuery);
    MHVVALIDATE_ARRAYOPTIONAL(self.keys, MHVClientError_InvalidThingQuery);
    MHVVALIDATE_ARRAYOPTIONAL(self.filters, MHVClientError_InvalidThingQuery);
    
    MHVVALIDATE_OPTIONAL(self.max);
    MHVVALIDATE_OPTIONAL(self.maxFull);
    
    MHVVALIDATE_SUCCESS;
}

- (void)serializeAttributes:(XWriter *)writer
{
    [writer writeAttribute:c_attribute_name value:self.name];
    if (self.max)
    {
        [writer writeAttribute:c_attribute_max intValue:self.max.value];
    }
    
    if (self.maxFull)
    {
        [writer writeAttribute:c_attribute_maxfull intValue:self.maxFull.value];
    }
}

- (void)serialize:(XWriter *)writer
{
    //
    // Query xml schema says - ids are a choice element
    //
    if (![MHVCollection isNilOrEmpty:self.thingIDs])
    {
        [writer writeElementArray:c_element_id elements:self.thingIDs.toArray];
    }
    else if (![MHVCollection isNilOrEmpty:self.keys])
    {
        [writer writeElementArray:c_element_key elements:self.keys.toArray];
    }
    else if (![MHVCollection isNilOrEmpty:self.clientIDs])
    {
        [writer writeElementArray:c_element_clientID elements:self.clientIDs.toArray];
    }
    
    [writer writeElementArray:c_element_filter elements:self.filters.toArray];
    [writer writeElement:c_element_view content:self.view];
}

- (void)deserializeAttributes:(XReader *)reader
{
    self.name = [reader readAttribute:c_attribute_name];
    
    int intValue;
    if ([reader readIntAttribute:c_attribute_max intValue:&intValue])
    {
        self.maxResults = intValue;
    }
    
    if ([reader readIntAttribute:c_attribute_maxfull intValue:&intValue])
    {
        self.maxFullResults = intValue;
    }
}

- (void)deserialize:(XReader *)reader
{
    self.thingIDs = [reader readStringElementArray:c_element_id];
    self.keys = (MHVThingKeyCollection *)[reader readElementArray:c_element_key
                                                         asClass:[MHVThingKey class]
                                                   andArrayClass:[MHVThingKeyCollection class]];
    self.clientIDs = [reader readStringElementArray:c_element_clientID];
    self.filters = (MHVThingFilterCollection *)[reader readElementArray:c_element_filter
                                                               asClass:[MHVThingFilter class]
                                                         andArrayClass:[MHVThingFilterCollection class]];
    self.view = [reader readElement:c_element_view asClass:[MHVThingView class]];
}

@end

@implementation MHVThingQueryCollection

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.type = [MHVThingQuery class];
    }
    return self;
}

- (MHVThingQuery *)queryWithName:(NSString *)name
{
    for (MHVThingQuery *query in self)
    {
        if ([query.name isEqualToString:name])
        {
            return query;
        }
    }
    return nil;
}

@end
