//
// MHVGoalRange.h
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
//

/**
* NOTE: This class is auto generated by the swagger code generator program.
* https://github.com/swagger-api/swagger-codegen.git
* Do not edit the class manually.
*/


#import <Foundation/Foundation.h>

#import "MHVModelBase.h"
#import "MHVEnum.h"


@protocol MHVGoalRange
@end

NS_ASSUME_NONNULL_BEGIN

@interface MHVGoalRangeUnitsEnum : MHVEnum
+(MHVGoalRangeUnitsEnum *)MHVUnknown;
+(MHVGoalRangeUnitsEnum *)MHVKilograms;
+(MHVGoalRangeUnitsEnum *)MHVCount;
+(MHVGoalRangeUnitsEnum *)MHVCalories;
+(MHVGoalRangeUnitsEnum *)MHVMillimetersOfMercury;
@end

@interface MHVGoalRange : MHVModelBase

/* The name of the range. [optional]
 */
@property(strong,nonatomic,nullable) NSString* name;
/* The description of the range. Allows more detailed information about the range. [optional]
 */
@property(strong,nonatomic,nullable) NSString* descriptionText;
/* The minimum value for the range.  For ranges greater than a specified value with no maximum, specify a minimum but no maximum. [optional]
 */
@property(strong,nonatomic,nullable) NSNumber* minimum;
/* The maximum value for the range.  For ranges less than a specified value with no minimum, specify a maximum but no minimum. [optional]
 */
@property(strong,nonatomic,nullable) NSNumber* maximum;
/* The units of the range. [optional]
 */
@property(strong,nonatomic,nullable) MHVGoalRangeUnitsEnum* units;

@end

NS_ASSUME_NONNULL_END