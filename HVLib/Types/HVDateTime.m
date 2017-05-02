//
//  DateTime.m
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
#import "HVDateTime.h"

static const xmlChar* x_element_date = XMLSTRINGCONST("date");
static const xmlChar* x_element_time = XMLSTRINGCONST("time");
static const xmlChar* x_element_timeZone = XMLSTRINGCONST("tz");

@implementation HVDateTime

@synthesize date = m_date;
@synthesize time = m_time;
@synthesize timeZone = m_timeZone;

-(BOOL) hasTime
{
    return (m_time != nil);
}

-(BOOL) hasTimeZone
{
    return (m_timeZone != nil);
}

-(id) initNow
{
    return [self initWithDate:[NSDate date]];
}

-(id) initWithDate:(NSDate *) dateValue
{
    HVCHECK_NOTNULL(dateValue);
    
    NSDateComponents *components = [NSCalendar componentsFromDate:dateValue];
    HVCHECK_NOTNULL(components);
    
    return [self initwithComponents:components];
    
LError:
    HVALLOC_FAIL;
}

-(id) initwithComponents:(NSDateComponents *)components
{
    HVCHECK_NOTNULL(components);
    
    self = [super init];
    HVCHECK_SELF;
    
    m_date = [[HVDate alloc] initWithComponents:components];
    m_time = [[HVTime alloc] initwithComponents:components];
    
    HVCHECK_TRUE(m_date && m_time);
    
    return self;
    
LError:
    HVALLOC_FAIL;
}

+(HVDateTime *)now
{
    return [[[HVDateTime alloc] initNow] autorelease];
}

+(HVDateTime *)fromDate:(NSDate *)date
{
    return [[[HVDateTime alloc] initWithDate:date] autorelease];
}

-(BOOL) setWithDate:(NSDate *) dateValue
{
    HVCHECK_NOTNULL(dateValue);
    
    NSDateComponents *components = [NSCalendar componentsFromDate:dateValue];
    HVCHECK_NOTNULL(components);
    
    return [self setWithComponents:components];

LError:
    return FALSE;
}

-(BOOL) setWithComponents:(NSDateComponents *)components
{
    HVCHECK_NOTNULL(components);
    
    HVCLEAR(m_date);
    HVCLEAR(m_time);
    
    m_date = [[HVDate alloc] initWithComponents:components];
    m_time = [[HVTime alloc] initwithComponents:components];
    
    HVCHECK_TRUE(m_date && m_time);
    
    return TRUE;
    
LError:
    return FALSE;
}

-(void) dealloc
{
    [m_date release];
    [m_time release];
    [m_timeZone release];
    [super dealloc];
}

-(NSString *)description
{
    return [self toString];
}

-(NSString *) toString
{
    return [self toStringWithFormat:@"MM/dd/yy hh:mm aaa"];
}

-(NSString *)toStringWithFormat:(NSString *)format
{
    NSDate *date = [self toDate];
    return [date toStringWithFormat:format];
}

-(NSDateComponents *) toComponents
{
    NSDateComponents *components = [NSCalendar newComponents];
    HVCHECK_SUCCESS([self getComponents:components]);
    
    return [components autorelease];
    
LError:
    [components release];
    return nil;
}

-(BOOL) getComponents:(NSDateComponents *)components
{
    HVCHECK_NOTNULL(components);
    HVCHECK_NOTNULL(m_date);
    
    [m_date getComponents:components];
    if (m_time)
    {
        [m_time getComponents:components];
    }
    
    return TRUE;
    
LError:
    return FALSE;
}

-(NSDate *)toDate
{
    NSCalendar* calendar = [NSCalendar newGregorian];
    HVCHECK_NOTNULL(calendar);
    
    NSDate *date = [self toDateForCalendar:calendar];
    [calendar release];
    
    return date;
    
LError:
    return nil;
}

-(NSDate *)toDateForCalendar:(NSCalendar *)calendar
{
    if (calendar)
    {
        NSDateComponents *components = [[NSDateComponents alloc] init];
        HVCHECK_NOTNULL(components);
        
        HVCHECK_SUCCESS([self getComponents:components]);
        
        NSDate *date = [calendar dateFromComponents:components];
        [components release];
        
        return date;
        
    LError:
        return nil;
        
    }
    
    return nil;    
}

-(HVClientResult *) validate
{
    HVVALIDATE_BEGIN;
    
    HVVALIDATE(m_date, HVClientError_InvalidDateTime);
    HVVALIDATE_OPTIONAL(m_time);
    
    HVVALIDATE_SUCCESS;
    
LError:
    HVVALIDATE_FAIL;
}

-(void) serialize:(XWriter *)writer
{
    [writer writeElementXmlName:x_element_date content:m_date];
    [writer writeElementXmlName:x_element_time content:m_time];
    [writer writeElementXmlName:x_element_timeZone content:m_timeZone];
}

-(void) deserialize:(XReader *)reader
{
    m_date = [[reader readElementWithXmlName:x_element_date asClass:[HVDate class]] retain];
    m_time = [[reader readElementWithXmlName:x_element_time asClass:[HVTime class]] retain];
    m_timeZone = [[reader readElementWithXmlName:x_element_timeZone asClass:[HVCodableValue class]] retain];
}

@end
