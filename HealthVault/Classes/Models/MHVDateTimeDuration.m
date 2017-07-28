//
// MHVDateTimeDuration.m
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

#import <Foundation/Foundation.h>
#import "MHVDateTimeDuration.h"

@implementation MHVDateTimeDuration

- (NSString*)dateFormatString
{
    return @"HH:mm:ss";
}

- (NSInteger)durationInMinutes
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitMinute | NSCalendarUnitHour
                                               fromDate:self.date];

    return components.minute + components.hour * 60;
}

- (NSInteger)durationInSeconds
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitSecond
                                               fromDate:self.date];
    
    return components.second + ((components.minute + components.hour * 60) * 60);
}

@end
