//
//  HVLocalVault.m
//  HVLib
//
//  Copyright (c) 2012 Microsoft Corporation. All rights reserved.
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
#import "HVLocalVault.h"
#import "XLib.h"

@interface HVLocalVault (HVPrivate)
-(void) setRoot:(HVDirectory *) root;
@end

@implementation HVLocalVault

@synthesize root = m_root;

-(id)initWithRoot:(HVDirectory *)root
{
    HVCHECK_NOTNULL(root);
    
    self = [super init];
    HVCHECK_SELF;
    
    self.root = root;
    
    m_recordStores = [[NSMutableDictionary alloc] initWithCapacity:2];
    HVCHECK_NOTNULL(m_recordStores);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(HVLocalRecordStore *)getRecordStore:(HVRecordReference *)record
{
    HVCHECK_NOTNULL(record);
    
    @synchronized(m_recordStores)
    {
        HVLocalRecordStore* recordStore = [m_recordStores objectForKey:record.ID];
        if (!recordStore)
        {
            recordStore = [[HVLocalRecordStore alloc] initForRecord:record overRoot:m_root];
            [m_recordStores setObject:recordStore forKey:record.ID];
        }
        
        return recordStore;
    }

LError:
    return nil;
}

-(void)dealloc
{
    [m_root release];
    [m_recordStores release];
    [super dealloc];
}

@end

@implementation HVLocalVault (HVPrivate)
-(void)setRoot:(HVDirectory *)root
{
    HVRETAIN(m_root, root);
}
@end
