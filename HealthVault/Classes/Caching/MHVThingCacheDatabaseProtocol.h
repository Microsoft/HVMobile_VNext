//
//  MHVThingCacheDatabaseProtocol.h
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@class MHVThingCollection, MHVThingQuery, MHVThingQueryResult;

NS_ASSUME_NONNULL_BEGIN

@protocol MHVThingCacheDatabaseProtocol <NSObject>

/**
 Initialize and setup database if needed.
 This is called after a user has authenticated, and may be called after deleteDatabase
 when signing out and signing in again
 
 @param completion Envoked when the operation is complete
 */
- (void)setupDatabaseWithCompletion:(void (^)(NSError *_Nullable error))completion;

/**
 Delete all contents and resets the current database
 
 @param completion Envoked when the operation is complete
 */
- (void)resetDatabaseWithCompletion:(void (^)(NSError *_Nullable error))completion;

/**
 Ensure records exist for an array of recordIds, creating if needed.
 
 @param recordIds The record IDs
 @param completion Envoked when the operation is complete
 */
- (void)setupRecordIds:(NSArray<NSString *> *)recordIds
            completion:(void (^)(NSError *_Nullable error))completion;

/**
 Delete a record from the current database
 
 @param recordId id of the record to be deleted
 @param completion Envoked when the operation is complete
 */
- (void)deleteRecord:(NSString *)recordId
          completion:(void (^)(NSError *_Nullable error))completion;

/**
 Delete Things given an array of IDs
 
 @param thingIds the IDs of the things to be deleted
 @param recordId the RecordId of the owner of the things
 @param completion Envoked when the operation is complete
 */
- (void)deleteThingIds:(NSArray<NSString *> *)thingIds
              recordId:(NSString *)recordId
            completion:(void (^)(NSError *_Nullable error))completion;

/**
 Update or create things in the cache database for a Thing collection
 If the thingId is found, it will be updated; if not it will be added
 
 @param things collection of Things to be added or updated
 @param recordId the owner record of the Things
 @param lastSequenceNumber the new sequence number to use after updating
 @param completion Envoked when the operation is complete
 */
- (void)addOrUpdateThings:(MHVThingCollection *)things
                 recordId:(NSString *)recordId
       lastSequenceNumber:(NSInteger)lastSequenceNumber
               completion:(void (^)(NSInteger updateItemCount, NSError *_Nullable error))completion;

/**
 Retrieve things for a query
 
 @param query The GetThings query
 @param recordId the owner record of the Things
 @param completion Envoked with the MHVThingQueryResult
 */
- (void)cachedResultsForQuery:(MHVThingQuery *)query
                     recordId:(NSString *)recordId
                   completion:(void(^)(MHVThingQueryResult *_Nullable queryResult, NSError *_Nullable error))completion;

/**
 Fetch all cached records
 
 @param completion Envoked with the array of records
 */
- (void)fetchCachedRecordIds:(void(^)(NSArray<NSString *> *_Nullable records, NSError *_Nullable error))completion;

/**
 Retrieve status information about a cached record
 
 @param recordId The record ID
 @param completion Envoked with the results or error
 */
- (void)cacheStatusForRecordId:(NSString *)recordId
                    completion:(void (^)(NSDate *_Nullable lastSyncDate, NSInteger lastSequenceNumber, BOOL isCacheValid, NSError *_Nullable error))completion;

/**
 Update a record with a new date and/or sequence number
 
 @param recordId The record
 @param lastSyncDate NSDate to update, should not update date on the record if nil
 @param sequenceNumber NSNumber sequence number, should not update number on the record if nil
 @param completion Envoked when the operation is complete
 */
- (void)updateRecordId:(NSString *)recordId
          lastSyncDate:(NSDate *_Nullable)lastSyncDate
        sequenceNumber:(NSNumber *_Nullable)sequenceNumber
            completion:(void (^)(NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
