//
//  MHVThingClient.m
//  MHVLib
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
//

#import "MHVThingClient.h"
#import "MHVCommon.h"
#import "MHVMethod.h"
#import "MHVServiceResponse.h"
#import "MHVTypes.h"
#import "NSError+MHVError.h"
#import "MHVConnectionProtocol.h"

@interface MHVThingClient ()

@property (nonatomic, weak) id<MHVConnectionProtocol>     connection;

@end

@implementation MHVThingClient

- (instancetype)initWithConnection:(id<MHVConnectionProtocol>)connection
{
    MHVASSERT_PARAMETER(connection);
    
    self = [super init];
    if (self)
    {
        _connection = connection;
    }
    return self;
}

- (void)getThingWithThingId:(NSUUID *)thingId
                   recordId:(NSUUID *)recordId
                 completion:(void(^)(MHVThing *_Nullable thing, NSError *_Nullable error))completion
{
    if (!recordId)
    {
        recordId = self.connection.personInfo.selectedRecordID;
    }
    
    MHVASSERT_PARAMETER(thingId);
    MHVASSERT_PARAMETER(recordId);
    MHVASSERT_PARAMETER(completion);
    
    if (!completion)
    {
        return;
    }
    
    if (!thingId || !recordId)
    {
        completion(nil, [NSError MVHInvalidParameter]);
        return;
    }
    
    [self getThingsWithQuery:[[MHVThingQuery alloc] initWithThingID:[thingId UUIDString]]
                    recordId:recordId
                  completion:^(MHVThingCollection * _Nullable things, NSError * _Nullable error)
     {
         if (error)
         {
             completion(nil, error);
         }
         else
         {
             completion(things.firstObject, nil);
         }
     }];
}

- (void)getThingsWithQuery:(MHVThingQuery *)query
                  recordId:(NSUUID *)recordId
                completion:(void(^)(MHVThingCollection *_Nullable things, NSError *_Nullable error))completion
{
    if (!recordId)
    {
        recordId = self.connection.personInfo.selectedRecordID;
    }
    
    MHVASSERT_PARAMETER(query);
    MHVASSERT_PARAMETER(recordId);
    MHVASSERT_PARAMETER(completion);
    
    if (!completion)
    {
        return;
    }
    
    if (!query || !recordId)
    {
        completion(nil, [NSError MVHInvalidParameter]);
        return;
    }
    
    [self getThingsWithQueries:[[MHVThingQueryCollection alloc] initWithObject:query]
                      recordId:recordId
                    completion:^(MHVThingQueryResultCollection * _Nullable results, NSError * _Nullable error)
     {
         if (error)
         {
             completion(nil, error);
         }
         else
         {
             completion(results.firstObject.things, nil);
         }
     }];
    
}

- (void)getThingsWithQueries:(MHVThingQueryCollection *)queries
                    recordId:(NSUUID *)recordId
                  completion:(void(^)(MHVThingQueryResultCollection *_Nullable results, NSError *_Nullable error))completion
{
    if (!recordId)
    {
        recordId = self.connection.personInfo.selectedRecordID;
    }
    
    MHVASSERT_PARAMETER(queries);
    MHVASSERT_PARAMETER(recordId);
    MHVASSERT_PARAMETER(completion);
    
    if (!completion)
    {
        return;
    }
    
    if (!queries || !recordId)
    {
        completion(nil, [NSError MVHInvalidParameter]);
        return;
    }
    
    MHVMethod *method = [MHVMethod getThings];
    method.recordId = recordId;
    method.parameters = [self bodyForQueryCollection:queries];
    
    [self.connection executeMethod:method
                        completion:^(MHVServiceResponse * _Nullable response, NSError * _Nullable error)
     {
         if (error)
         {
             completion(nil, error);
         }
         else
         {
             MHVThingQueryResults *queryResults = [self thingQueryResultsFromResponse:response];
             if (queryResults.results)
             {
                 completion(queryResults.results, nil);
             }
             else
             {
                 completion(nil, [NSError error:[NSError MHVUnknownError] withDescription:@"The GetThings results could not be extracted."]);
             }
         }
     }];
}

- (void)getThingsForThingClass:(Class )thingClass
                         query:(MHVThingQuery *_Nullable)query
                      recordId:(NSUUID *)recordId
                    completion:(void(^)(MHVThingCollection *_Nullable things, NSError *_Nullable error))completion
{
    if (!recordId)
    {
        recordId = self.connection.personInfo.selectedRecordID;
    }
    
    MHVASSERT_PARAMETER(thingClass);
    MHVASSERT_PARAMETER(recordId);
    MHVASSERT_PARAMETER(completion);
    
    if (!completion)
    {
        return;
    }
    
    if (!thingClass || !recordId)
    {
        completion(nil, [NSError MVHInvalidParameter]);
        return;
    }
    
    MHVThingFilter *filter = [[MHVThingFilter alloc] initWithTypeClass:thingClass];    
    if (!filter)
    {
        completion(nil, [NSError MVHInvalidParameter:[NSString stringWithFormat:@"%@ not found in HealthVault thing types", NSStringFromClass(thingClass)]]);
        return;
    }
    
    //Add filter to query argument, or create if argument is nil
    if (query)
    {
        [query.filters addObject:filter];
    }
    else
    {
        query = [[MHVThingQuery alloc] initWithFilter:filter];
    }
    
    [self getThingsWithQuery:query recordId:recordId completion:completion];
}

#pragma mark - Create Things

- (void)createNewThing:(MHVThing *)thing
              recordId:(NSUUID *)recordId
            completion:(void(^_Nullable)(NSError *_Nullable error))completion
{
    if (!recordId)
    {
        recordId = self.connection.personInfo.selectedRecordID;
    }
    
    MHVASSERT_PARAMETER(thing);
    MHVASSERT_PARAMETER(recordId);
    
    if (!thing || !recordId)
    {
        if (completion)
        {
            completion([NSError MVHInvalidParameter]);
        }
        return;
    }
    
    [self createNewThings:[[MHVThingCollection alloc] initWithThing:thing]
                 recordId:recordId
               completion:completion];
}

- (void)createNewThings:(MHVThingCollection *)things
               recordId:(NSUUID *)recordId
             completion:(void(^_Nullable)(NSError *_Nullable error))completion
{
    if (!recordId)
    {
        recordId = self.connection.personInfo.selectedRecordID;
    }
    
    MHVASSERT_PARAMETER(things);
    MHVASSERT_PARAMETER(recordId);
    
    if (!things || !recordId)
    {
        if (completion)
        {
            completion([NSError MVHInvalidParameter]);
        }
        return;
    }
    
    for (MHVThing *thing in things)
    {
        [thing prepareForNew];        
    }
    
    MHVMethod *method = [MHVMethod putThings];
    method.recordId = recordId;
    method.parameters = [self bodyForThingCollection:things];
    
    [self.connection executeMethod:method
                        completion:^(MHVServiceResponse * _Nullable response, NSError * _Nullable error)
     {
         if (completion)
         {
             completion(error);
         }
     }];
}

#pragma mark - Update Things

- (void)updateThing:(MHVThing *)thing
           recordId:(NSUUID *)recordId
         completion:(void(^_Nullable)(NSError *_Nullable error))completion
{
    if (!recordId)
    {
        recordId = self.connection.personInfo.selectedRecordID;
    }
    
    MHVASSERT_PARAMETER(thing);
    MHVASSERT_PARAMETER(recordId);
    
    if (!thing || !recordId)
    {
        if (completion)
        {
            completion([NSError MVHInvalidParameter]);
        }
        return;
    }
    
    [self updateThings:[[MHVThingCollection alloc] initWithThing:thing]
              recordId:recordId
            completion:completion];
}

- (void)updateThings:(MHVThingCollection *)things
            recordId:(NSUUID *)recordId
          completion:(void(^_Nullable)(NSError *_Nullable error))completion
{
    if (!recordId)
    {
        recordId = self.connection.personInfo.selectedRecordID;
    }
    
    MHVASSERT_PARAMETER(things);
    MHVASSERT_PARAMETER(recordId);
    
    if (!things || !recordId)
    {
        if (completion)
        {
            completion([NSError MVHInvalidParameter]);
        }
        return;
    }

    for (MHVThing *thing in things)
    {
        [thing prepareForUpdate];
    }

    MHVMethod *method = [MHVMethod putThings];
    method.recordId = recordId;
    method.parameters = [self bodyForThingCollection:things];
    
    [self.connection executeMethod:method
                        completion:^(MHVServiceResponse * _Nullable response, NSError * _Nullable error)
     {
         if (completion)
         {
             completion(error);
         }
     }];
}

#pragma mark - Remove Things

- (void)removeThing:(MHVThing *)thing
           recordId:(NSUUID *)recordId
         completion:(void(^_Nullable)(NSError *_Nullable error))completion
{
    if (!recordId)
    {
        recordId = self.connection.personInfo.selectedRecordID;
    }
    
    MHVASSERT_PARAMETER(thing);
    MHVASSERT_PARAMETER(recordId);
    
    if (!thing || !recordId)
    {
        if (completion)
        {
            completion([NSError MVHInvalidParameter]);
        }
        return;
    }
    
    [self removeThings:[[MHVThingCollection alloc] initWithThing:thing]
              recordId:recordId
            completion:completion];
}

- (void)removeThings:(MHVThingCollection *)things
            recordId:(NSUUID *)recordId
          completion:(void(^_Nullable)(NSError *_Nullable error))completion
{
    if (!recordId)
    {
        recordId = self.connection.personInfo.selectedRecordID;
    }
    
    MHVASSERT_PARAMETER(things);
    MHVASSERT_PARAMETER(recordId);
    
    if (!things || !recordId)
    {
        if (completion)
        {
            completion([NSError MVHInvalidParameter]);
        }
        return;
    }
    
    MHVMethod *method = [MHVMethod removeThings];
    method.recordId = recordId;
    method.parameters = [self bodyForThingIdsFromThingCollection:things];
    
    [self.connection executeMethod:method
                        completion:^(MHVServiceResponse * _Nullable response, NSError * _Nullable error)
     {
         if (completion)
         {
             completion(error);
         }
     }];
}

#pragma mark - Internal methods

- (MHVThingQueryResults *)thingQueryResultsFromResponse:(MHVServiceResponse *)response
{
    XReader *reader = [[XReader alloc] initFromString:response.infoXml];
    return (MHVThingQueryResults *)[NSObject newFromReader:reader withRoot:@"info" asClass:[MHVThingQueryResults class]];
}

- (NSString *)bodyForQueryCollection:(MHVThingQueryCollection *)queries
{
    XWriter *writer = [[XWriter alloc] initWithBufferSize:2048];
    
    [writer writeStartElement:@"info"];
    
    for (MHVThingQuery* query in queries)
    {
        if ([self isValidObject:query])
        {
            [XSerializer serialize:query withRoot:@"group" toWriter:writer];
        }
    }

    [writer writeEndElement];
    
    return [writer newXmlString];
}

- (NSString *)bodyForThingCollection:(MHVThingCollection *)things
{
    XWriter *writer = [[XWriter alloc] initWithBufferSize:2048];
    
    [writer writeStartElement:@"info"];
    {
        for (MHVThing *thing in things)
        {
            if ([self isValidObject:thing])
            {
                [XSerializer serialize:thing withRoot:@"thing" toWriter:writer];
            }
        }
    }
    [writer writeEndElement];
    
    return [writer newXmlString];
}

- (NSString *)bodyForThingIdsFromThingCollection:(MHVThingCollection *)things
{
    XWriter *writer = [[XWriter alloc] initWithBufferSize:2048];
    
    [writer writeStartElement:@"info"];
    {
        for (MHVThing *thing in things)
        {
            if ([self isValidObject:thing.key])
            {
                [XSerializer serialize:thing.key withRoot:@"thing-id" toWriter:writer];
            }
        }
    }
    [writer writeEndElement];
    
    return [writer newXmlString];
}

- (BOOL)isValidObject:(id)obj
{
    if ([obj respondsToSelector:@selector(validate)])
    {
        MHVClientResult* validationResult = [obj validate];
        if (validationResult.isError)
        {
            return NO;
        }
    }
    return YES;
}

@end
