//
//  MHVThingChangeTable.m
//  MHVLib
//
//  Copyright (c) 2017 Microsoft Corporation. All rights reserved.
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

#import "MHVCommon.h"
#import "MHVThingChangeTable.h"

static NSString* const c_changeObjectRoot = @"change";

@interface MHVThingChangeTable (MHVPrivate)

-(BOOL) partitionHasThings:(NSString *) partitionKey;
-(MHVThingChange *) loadChangeForTypeID:(NSString *) typeID thingID:(NSString *) thingID;

-(NSMutableArray *) getChangeIDsForTypeID:(NSString *)typeID;

-(void) loadAllChangesInto:(NSMutableArray *) array;
-(void) loadChangesForTypeID:(NSString *) typeID into:(NSMutableArray *) array;
-(void) convertChangesToQueue:(NSMutableArray *) array;

@end

@implementation MHVThingChangeTable

-(id)init
{
    return [self initWithObjectStore:nil];
}

-(id)initWithObjectStore:(id<MHVObjectStore>)store
{
    MHVCHECK_NOTNULL(store);
    
    self = [super init];
    MHVCHECK_SELF;
    
    m_store = [[MHVPartitionedObjectStore alloc] initWithRoot:store];
    MHVCHECK_NOTNULL(m_store);
        
    return self;

LError:
    MHVALLOC_FAIL;
}


-(BOOL)hasChangesForTypeID:(NSString *)typeID thingID:(NSString *)thingID
{
    @synchronized(m_store)
    {
        return  [m_store partition:typeID keyExists:thingID];
    }
}

-(BOOL)hasChangesForTypeID:(NSString *)typeID
{
    @synchronized(m_store)
    {
        return [self partitionHasThings:typeID];
    }
}

-(BOOL)hasChanges
{
    @synchronized(m_store)
    {
        NSEnumerator* partitions = [m_store allPartitionKeys];
        for (NSString *typeID in partitions)
        {
            NSEnumerator* keys = [m_store allKeysInPartition:typeID];
            if (keys.nextObject != nil)
            {
                return TRUE;
            }
        }
    }
    return FALSE;
}

-(NSString *) trackChange:(enum MHVThingChangeType)changeType forTypeID:(NSString *)typeID andKey:(MHVThingKey *)key
{
    MHVCHECK_NOTNULL(key);
    
    @synchronized(m_store)
    {
        MHVThingChange* change = [self getForTypeID:typeID thingID:key.thingID];
        if (change)
        {
            MHVCHECK_SUCCESS([MHVThingChange updateChange:change withTypeID:typeID key:key changeType:changeType]);
        }
        else
        {
            change = [[MHVThingChange alloc] initWithTypeID:typeID key:key changeType:changeType];
            MHVCHECK_NOTNULL(change);
        }
 
        MHVCHECK_SUCCESS([self put:change]);
        
        return change.changeID;
    }
    
LError:
    return nil;
}

-(MHVThingChangeQueue *)getQueue
{
    @synchronized(m_store)
    {
        NSMutableArray* changedTypes = [self getAllTypesWithChanges];
        MHVCHECK_NOTNULL(changedTypes);
        
        return [[MHVThingChangeQueue alloc] initWithChangeTable:self andChangedTypes:changedTypes];
        
    LError:
        return nil;
    }
}

-(MHVThingChangeQueue *)getQueueForTypeID:(NSString *)typeID
{
    @synchronized(m_store)
    {
        NSMutableArray* changedTypes = [NSMutableArray arrayWithObject:typeID];
        MHVCHECK_NOTNULL(changedTypes);
        
        return [[MHVThingChangeQueue alloc] initWithChangeTable:self andChangedTypes:changedTypes];
        
    LError:
        return nil;
    }
    
}

-(NSMutableArray *)getAll
{
    @synchronized(m_store)
    {
        NSMutableArray* changes = [[NSMutableArray alloc] init];
        MHVCHECK_NOTNULL(changes);
        @autoreleasepool
        {
            [self loadAllChangesInto:changes];
        }
        
        return changes;
        
    LError:
        return nil;
    }
}

-(NSMutableArray *)getAllTypesWithChanges
{
    @synchronized(m_store)
    {
        NSMutableArray* typeList = [[NSMutableArray alloc] init];
        MHVCHECK_NOTNULL(typeList);
        @autoreleasepool
        {
            NSEnumerator* partitions = [m_store allPartitionKeys];
            for (NSString *typeID in partitions)
            {
                if ([self partitionHasThings:typeID])
                {
                    [typeList addObject:typeID];
                }
            }
        }
        
        return typeList;
        
    LError:
        return nil;
    }
}

-(MHVThingChange *)getForTypeID:(NSString *)typeID thingID:(NSString *)thingID
{
    @synchronized(m_store)
    {
        return [m_store partition:typeID getObjectWithKey:thingID name:c_changeObjectRoot andClass:[MHVThingChange class]];
    }
}

-(BOOL)put:(MHVThingChange *)change
{
    @synchronized(m_store)
    {
        MHVCHECK_NOTNULL(change);
        
        return [m_store partition:change.typeID putObject:change withKey:change.thingID andName:c_changeObjectRoot];
    
    LError:
        return false;
    }
}

-(BOOL)removeForTypeID:(NSString *)typeID thingID:(NSString *)thingID
{
    @synchronized(m_store)
    {
        return [m_store partition:(NSString *) typeID deleteKey:thingID];
    }
}

-(BOOL)removeAllForTypeID:(NSString *)typeID
{
    @synchronized(m_store)
    {
        return [m_store deletePartition:typeID];
    }
}

-(void)removeAll
{
    @synchronized(m_store)
    {
        NSEnumerator* partitionNames = [m_store allPartitionKeys];
        for (NSString* name in partitionNames)
        {
            [m_store deletePartition:name];
        }
    }
}


@end

@implementation MHVThingChangeTable (MHVPrivate)

-(BOOL)partitionHasThings:(NSString *)partitionKey
{
    NSEnumerator* keys = [m_store allKeysInPartition:partitionKey];
    return (keys.nextObject != nil);
}

-(void)loadAllChangesInto:(NSMutableArray *)array
{
    NSEnumerator* partitions = [m_store allPartitionKeys];
    for (NSString *typeID in partitions)
    {
        [self loadChangesForTypeID:typeID into:array];
    }
}

-(void)loadChangesForTypeID:(NSString *)typeID into:(NSMutableArray *)array
{
    NSEnumerator* keys = [m_store allKeysInPartition:typeID];
    for (NSString* key in keys)
    {
        MHVThingChange* change = [self loadChangeForTypeID:typeID thingID:key];
        if (change != nil)
        {
            [array addObject:change];
        }
    }
}

-(MHVThingChange *)loadChangeForTypeID:(NSString *)typeID thingID:(NSString *)thingID
{
    return [m_store partition:typeID getObjectWithKey:thingID name:c_changeObjectRoot andClass:[MHVThingChange class]];
}

-(NSMutableArray *)getChangeIDsForTypeID:(NSString *)typeID
{
    @synchronized(m_store)
    {
        MHVCHECK_STRING(typeID);
        
        NSMutableArray* changes = [[NSMutableArray alloc] init];
        MHVCHECK_NOTNULL(changes);
        
        @autoreleasepool
        {
            NSEnumerator* changeIDs = [m_store allKeysInPartition:typeID];
            [changes addFromEnumerator:changeIDs];
        }
        
        return changes;
        
    LError:
        return nil;
    }    
}

-(void)convertChangesToQueue:(NSMutableArray *)array
{
    if (array.count <= 1)
    {
        return;
    }
    
    [array sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        MHVThingChange* c1 = (MHVThingChange *) obj1;
        MHVThingChange* c2 = (MHVThingChange *) obj2;
        
        return [MHVThingChange compareChange:c1 to:c2];
    }];
}

@end


@interface MHVThingChangeQueue (MHVPrivate)

-(BOOL) loadNextTypeQueue;
-(void) clear;

@end

@implementation MHVThingChangeQueue

-(id)init
{
    return [self initWithChangeTable:nil andChangedTypes:nil];
}

-(id)initWithChangeTable:(MHVThingChangeTable *)changeTable andChangedTypes:(NSMutableArray *)types
{
    MHVCHECK_NOTNULL(changeTable);
    MHVCHECK_NOTNULL(types);
    
    self = [super init];
    MHVCHECK_SELF;
    
    m_changeTable = changeTable;
    m_types = types;
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(id)nextObject
{
    return [self nextChange];
}

-(MHVThingChange *)nextChange
{
    do
    {
        NSString* changeID = nil;
        while (m_currentQueue && ((changeID = [m_currentQueue lastObject]) != nil))
        {
            [m_currentQueue removeObject:changeID];
            
            MHVThingChange* change = [m_changeTable getForTypeID:m_currentType thingID:changeID];
            if (change)
            {
                return change;
            }
        }
    }
    while ([self loadNextTypeQueue]);
    
    return nil;
}

@end

@implementation MHVThingChangeQueue (MHVPrivate)

-(BOOL)loadNextTypeQueue
{
    while (TRUE)
    {
        [self clear];
        
        m_currentType = [m_types lastObject];
        
        if (!m_currentType)
        {
            break;
        }
        
        [m_currentQueue removeObject:m_currentType];
        
        m_currentQueue = [m_changeTable getChangeIDsForTypeID:m_currentType];
        if (m_currentQueue)
        {
            return TRUE;
        }
    }
    
    return FALSE;
}

-(void)clear
{
    m_currentType = nil;
    m_currentQueue = nil;
}

@end

