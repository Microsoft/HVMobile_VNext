//
//  MHVLocalVocabStore.m
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

#import "MHVCommon.h"
#import "MHVLocalVocabStore.h"

@interface MHVLocalVocabStore (MHVPrivate)

-(BOOL) isStaleVocabWithID:(MHVVocabularyIdentifier *) vocabID maxAge:(NSTimeInterval) maxAgeSeconds;

-(MHVGetVocabTask *) newDownloadVocabTaskForVocab:(MHVVocabularyIdentifier *) vocabID;
-(void) downloadTaskComplete:(MHVTask *) task forVocabID:(MHVVocabularyIdentifier *) vocabID;

-(MHVGetVocabTask *) newDownloadVocabTaskForVocabs:(MHVVocabularyIdentifierCollection *) vocabIDs;
-(void) downloadTaskComplete:(MHVTask *) task forVocabs:(MHVVocabularyIdentifierCollection *) vocabIDs;

@end

@implementation MHVLocalVocabStore

@synthesize store = m_objectStore;

-(id)initWithObjectStore:(id<MHVObjectStore>)store
{
    MHVCHECK_NOTNULL(store);
    
    self = [super init];
    MHVCHECK_SELF;
    
    m_objectStore = store;
    
    return self;
    
LError:
    MHVALLOC_FAIL;
}


-(BOOL)containsVocabWithID:(MHVVocabularyIdentifier *)vocabID
{
    NSString* key = [vocabID toKeyString];
    return [m_objectStore keyExists:key];
}

-(MHVVocabularyCodeSet *)getVocabWithID:(MHVVocabularyIdentifier *)vocabID
{
    NSString* key = [vocabID toKeyString];
    return [m_objectStore getObjectWithKey:key name:@"vocab" andClass:[MHVVocabularyCodeSet class]];
}

-(BOOL)putVocab:(MHVVocabularyCodeSet *)vocab withID:(MHVVocabularyIdentifier *)vocabID
{
    NSString* key = [vocabID toKeyString];
    return [m_objectStore putObject:vocab withKey:key andName:@"vocab"];
}

-(void)removeVocabWithID:(MHVVocabularyIdentifier *)vocabID
{
    NSString* key = [vocabID toKeyString];
    [m_objectStore deleteKey:key];
}

-(MHVTask *)downloadVocab:(MHVVocabularyIdentifier *)vocab withCallback:(MHVTaskCompletion)callback
{
    MHVGetVocabTask* getVocab = [self newDownloadVocabTaskForVocab:vocab];
    MHVCHECK_NOTNULL(getVocab);
    
    MHVTask* downloadTask = [[MHVTask alloc] initWithCallback:callback andChildTask:getVocab];
    
    MHVCHECK_NOTNULL(downloadTask);
    
    [downloadTask start];
    
    return downloadTask;
    
LError:
    return nil;
}

-(MHVTask *)downloadVocabs:(MHVVocabularyIdentifierCollection *)vocabIDs withCallback:(MHVTaskCompletion)callback
{
    MHVCHECK_NOTNULL(vocabIDs);
    
    MHVGetVocabTask* getVocab = [self newDownloadVocabTaskForVocabs:vocabIDs];
    MHVCHECK_NOTNULL(getVocab);
    
    MHVTask* downloadTask = [[MHVTask alloc] initWithCallback:callback andChildTask:getVocab];
    
    MHVCHECK_NOTNULL(downloadTask);
    
    [downloadTask start];
    
    return downloadTask;
    
LError:
    return nil;
}

-(void)ensureVocabDownloaded:(MHVVocabularyIdentifier *)vocab
{
    [self ensureVocabDownloaded:vocab maxAge:60 * 24 * 3600]; // Every 60 days - these many seconds
}

-(void)ensureVocabDownloaded:(MHVVocabularyIdentifier *)vocab maxAge:(NSTimeInterval)ageInSeconds
{
    if ([self isStaleVocabWithID:vocab maxAge:ageInSeconds])
    {
        MHVGetVocabTask* task = [self newDownloadVocabTaskForVocab:vocab];
        [task start];
    }
}

-(BOOL)ensureVocabsDownloaded:(MHVVocabularyIdentifierCollection *)vocabIDs maxAge:(NSTimeInterval)ageInSeconds
{
    MHVCHECK_NOTNULL(vocabIDs);
    
    MHVVocabularyIdentifierCollection* vocabsToDownload = nil;
    
    for (NSUInteger i = 0, count = vocabIDs.count; i < count; ++i)
    {
        MHVVocabularyIdentifier* vocabID = [vocabIDs objectAtIndex:i];
        if ([self isStaleVocabWithID:vocabID maxAge:ageInSeconds])
        {
            if (!vocabsToDownload)
            {
                vocabsToDownload = [[MHVVocabularyIdentifierCollection alloc] init];
            }
            
            [vocabsToDownload addObject:vocabID];
        }
    }
    
    if (![MHVCollection isNilOrEmpty:vocabsToDownload])
    {
        MHVGetVocabTask* task = [self newDownloadVocabTaskForVocabs:vocabsToDownload];
        
        MHVCHECK_NOTNULL(task);
        
        [task start];
    }
    
    return TRUE;
    
LError:
    return FALSE;
}

-(MHVVocabularyCodeItem *)getVocabThingForCode:(NSString *)code inVocab:(MHVVocabularyIdentifier *)vocabID
{
    MHVVocabularyCodeSet* vocab  = [self getVocabWithID:vocabID];
    if (!vocab)
    {
        return nil;
    }
    
    return [vocab.vocabularyCodeItems getThingWithCode:code];
}

-(NSString *)getDisplayTextForCode:(NSString *)code inVocab:(MHVVocabularyIdentifier *)vocabID
{
    MHVVocabularyCodeItem* vocabThing = [self getVocabThingForCode:code inVocab:vocabID];
    if (!vocabThing)
    {
        return nil;
    }
    
    return vocabThing.displayText;
}

@end

@implementation MHVLocalVocabStore (MHVPrivate)

-(BOOL)isStaleVocabWithID:(MHVVocabularyIdentifier *)vocabID maxAge:(NSTimeInterval)maxAgeSeconds
{
    NSString* key = [vocabID toKeyString];
    NSDate* lastUpdate = [m_objectStore updateDateForKey:key];
    if (!lastUpdate || [lastUpdate offsetFromNow] >= maxAgeSeconds)
    {
        return TRUE;
    }
    
    return FALSE;
    
}

-(MHVGetVocabTask *)newDownloadVocabTaskForVocab:(MHVVocabularyIdentifier *)vocabID
{
    return [[MHVGetVocabTask alloc] initWithVocabID:vocabID andCallback:^(MHVTask *task) {
        
        [self downloadTaskComplete:task forVocabID:vocabID];
        
    }];
}
-(void)downloadTaskComplete:(MHVTask *)task forVocabID:(MHVVocabularyIdentifier *)vocabID
{
    @try
    {
        MHVGetVocabTask* getVocab = (MHVGetVocabTask *) task;
        [self putVocab:getVocab.vocabulary withID:vocabID];
    }
    @catch (id exception)
    {
        [exception log];
    }
}

-(MHVGetVocabTask *)newDownloadVocabTaskForVocabs:(MHVVocabularyIdentifierCollection *)vocabIDs
{
    MHVGetVocabTask* task = [[MHVGetVocabTask alloc] initWithCallback:^(MHVTask *task) {
        
        [self downloadTaskComplete:task forVocabs:vocabIDs];
        
    }];
    
    MHVVocabularyParams* params = [[MHVVocabularyParams alloc] initWithVocabIDs:vocabIDs];
    task.params = params;
    
    return task;
}

-(void)downloadTaskComplete:(MHVTask *)task forVocabs:(MHVVocabularyIdentifierCollection *)vocabIDs
{
    @try
    {
        MHVGetVocabTask* getVocab = (MHVGetVocabTask *) task;
        MHVVocabularyCodeSetCollection* downloadedVocabs = getVocab.vocabResults.vocabs;
        for (NSUInteger i = 0, count = downloadedVocabs.count; i < count; ++i)
        {
            MHVVocabularyCodeSet* vocab = [downloadedVocabs objectAtIndex:i];
            if (vocab.isTruncated)
            {
                continue;
            }
            [self putVocab:vocab withID:[vocab getVocabularyID]];
        }
    }
    @catch (id exception)
    {
        [exception log];
    }
}
@end
