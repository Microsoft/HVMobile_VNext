//
//  HVMorningSleepJournal.m
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
#import "HVSleepJournalAM.h"

static NSString* const c_typeid = @"11c52484-7f1a-11db-aeac-87d355d89593";
static NSString* const c_typename = @"sleep-am";

static const xmlChar* x_element_when = XMLSTRINGCONST("when");
static const xmlChar* x_element_bedtime = XMLSTRINGCONST("bed-time");
static const xmlChar* x_element_waketime = XMLSTRINGCONST("wake-time");
static const xmlChar* x_element_sleepMins = XMLSTRINGCONST("sleep-minutes");
static const xmlChar* x_element_settlingMins = XMLSTRINGCONST("settling-minutes");
static NSString* const c_element_awakening = @"awakening";
static const xmlChar* x_element_medications = XMLSTRINGCONST("medications");
static const xmlChar* x_element_state = XMLSTRINGCONST("wake-state");

@implementation HVSleepJournalAM

@synthesize when = m_when;
@synthesize bedTime = m_bedTime;
@synthesize wakeTime = m_wakeTime;
@synthesize sleepMinutes = m_sleepMinutes;
@synthesize settlingMinutes = m_settlingMinutes;
@synthesize medicationsBeforeBed = m_medications;

-(enum HVWakeState)wakeState
{
    return (m_wakeState) ? (enum HVWakeState) (m_wakeState.value) : HVWakeState_Unknown;
}

-(void)setWakeState:(enum HVWakeState)wakeState
{
    if (wakeState == HVWakeState_Unknown)
    {
        HVCLEAR(m_wakeState);
    }
    else
    {
        HVENSURE(m_wakeState, HVPositiveInt);
        m_wakeState.value = (int) wakeState;
    }
}

-(HVOccurenceCollection *)awakenings
{
    HVENSURE(m_awakenings, HVOccurenceCollection);
    return m_awakenings;
}

-(void)setAwakenings:(HVOccurenceCollection *)awakenings
{
    HVRETAIN(m_awakenings, awakenings);
}

-(BOOL)hasAwakenings
{
    return ![NSArray isNilOrEmpty:m_awakenings];
}

-(int)sleepMinutesValue
{
    return (m_sleepMinutes) ? m_sleepMinutes.value : -1;
}

-(void)setSleepMinutesValue:(int)sleepMinutesValue
{
    HVENSURE(m_sleepMinutes, HVNonNegativeInt);
    m_sleepMinutes.value = sleepMinutesValue;
}

-(int)settlingMinutesValue
{
    return m_settlingMinutes ? m_settlingMinutes.value : -1;
}

-(void)setSettlingMinutesValue:(int)settlingMinutesValue
{
    HVENSURE(m_settlingMinutes, HVNonNegativeInt);
    m_settlingMinutes.value = settlingMinutesValue;
}

-(void)dealloc
{
    [m_when release];
    [m_bedTime release];
    [m_wakeTime release];
    [m_sleepMinutes release];
    [m_settlingMinutes release];
    [m_awakenings release];
    [m_medications release];
    [m_wakeState release];

    [super dealloc];
}

-(id)initWithBedtime:(NSDate *)bedtime onDate:(NSDate *)date settlingMinutes:(int)settlingMinutes sleepingMinutes:(int)sleepingMinutes wokeupAt:(NSDate *)wakeTime
{
    HVCHECK_NOTNULL(date);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_when = [[HVDateTime alloc] initWithDate:date];
    HVCHECK_NOTNULL(m_when);
    
    m_bedTime = [[HVTime alloc] initWithDate:bedtime];
    HVCHECK_NOTNULL(m_bedTime);
    
    m_settlingMinutes = [[HVNonNegativeInt alloc] initWith:settlingMinutes];
    HVCHECK_NOTNULL(m_settlingMinutes);
    
    m_sleepMinutes = [[HVNonNegativeInt alloc] initWith:sleepingMinutes];
    HVCHECK_NOTNULL(m_sleepMinutes);
    
    m_wakeTime = [[HVTime alloc] initWithDate:wakeTime];
    HVCHECK_NOTNULL(m_wakeTime);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

-(NSDate *)getDate
{
    return [m_when toDate];
}

-(NSDate *)getDateForCalendar:(NSCalendar *)calendar
{
    return [m_when toDateForCalendar:calendar];
}

-(HVClientResult *)validate
{
    HVVALIDATE_BEGIN
    
    HVVALIDATE(m_when, HVClientError_InvalidSleepJournal);
    HVVALIDATE(m_bedTime, HVClientError_InvalidSleepJournal);
    HVVALIDATE(m_settlingMinutes, HVClientError_InvalidSleepJournal);
    HVVALIDATE(m_sleepMinutes, HVClientError_InvalidSleepJournal);
    HVVALIDATE(m_wakeTime, HVClientError_InvalidSleepJournal);
    HVVALIDATE(m_wakeState, HVClientError_InvalidSleepJournal);
    HVVALIDATE_ARRAYOPTIONAL(m_awakenings, HVClientError_InvalidSleepJournal);
    HVVALIDATE_OPTIONAL(m_medications);
    
    HVVALIDATE_SUCCESS
    
LError:
    HVVALIDATE_FAIL
}

-(void)serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_when content:m_when];
    [writer writeElementXmlName:x_element_bedtime content:m_bedTime];
    [writer writeElementXmlName:x_element_waketime content:m_wakeTime];
    [writer writeElementXmlName:x_element_sleepMins content:m_sleepMinutes];
    [writer writeElementXmlName:x_element_settlingMins content:m_settlingMinutes];
    [writer writeElementArray:c_element_awakening elements:m_awakenings];
    [writer writeElementXmlName:x_element_medications content:m_medications];
    [writer writeElementXmlName:x_element_state content:m_wakeState];
}

-(void)deserialize:(XReader *)reader
{
    m_when = [[reader readElementWithXmlName:x_element_when asClass:[HVDateTime class]] retain];
    m_bedTime = [[reader readElementWithXmlName:x_element_bedtime asClass:[HVTime class]] retain];
    m_wakeTime = [[reader readElementWithXmlName:x_element_waketime asClass:[HVTime class]] retain];
    m_sleepMinutes = [[reader readElementWithXmlName:x_element_sleepMins asClass:[HVNonNegativeInt class]] retain];
    m_settlingMinutes = [[reader readElementWithXmlName:x_element_settlingMins asClass:[HVNonNegativeInt class]] retain];
    m_awakenings = (HVOccurenceCollection *)[[reader readElementArray:c_element_awakening asClass:[HVOccurence class] andArrayClass:[HVOccurenceCollection class]] retain];
    m_medications = [[reader readElementWithXmlName:x_element_medications asClass:[HVCodableValue class]] retain];
    m_wakeState = [[reader readElementWithXmlName:x_element_state asClass:[HVPositiveInt class]] retain];
}

+(NSString *)typeID
{
    return c_typeid;
}

+(NSString *) XRootElement
{
    return c_typename;
}

+(HVItem *) newItem
{
    return [[HVItem alloc] initWithType:[HVSleepJournalAM typeID]];
}

-(NSString *)typeName
{
    return NSLocalizedString(@"Sleep Journal", @"Daily sleep journal");
}

@end
