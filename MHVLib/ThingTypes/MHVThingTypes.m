//
// MHVThingTypes.m
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
#import "XLib.h"
#import "MHVThingTypes.h"
/*
 #define MHVDECLARE_GETTOR(type, name) \
 * -(type *) name { \
 *  if (self.hasTypedData) { \
 *          return (type *) self.data.typed; \
 *  } \
 *  return nil; \
 * }
 */

#define MHVDECLARE_GETTOR(type, name) \
    - (type *)name { \
        return (type *)[self getDataOfType:[type typeID]]; \
    }


@implementation MHVThing (MHVTypedExtensions)

- (MHVThingDataTyped *)getDataOfType:(NSString *)typeID
{
    if (!self.hasTypedData)
    {
        return nil;
    }

    MHVASSERT([self.type.typeID isEqualToString:typeID]);
    return self.data.typed;
}

MHVDECLARE_GETTOR(MHVWeight, weight);

MHVDECLARE_GETTOR(MHVBloodPressure, bloodPressure);

MHVDECLARE_GETTOR(MHVCholesterol, cholesterol);

MHVDECLARE_GETTOR(MHVBloodGlucose, bloodGlucose);

MHVDECLARE_GETTOR(MHVHeartRate, heartRate);

MHVDECLARE_GETTOR(MHVPeakFlow, peakFlow);

MHVDECLARE_GETTOR(MHVHeight, height);

MHVDECLARE_GETTOR(MHVExercise, exercise);

MHVDECLARE_GETTOR(MHVDailyMedicationUsage, medicationUsage);

MHVDECLARE_GETTOR(MHVEmotionalState, emotionalState);

MHVDECLARE_GETTOR(MHVAssessment, assessment);

MHVDECLARE_GETTOR(MHVQuestionAnswer, questionAnswer);

MHVDECLARE_GETTOR(MHVDailyDietaryIntake, dailyDietaryIntake);

MHVDECLARE_GETTOR(MHVDietaryIntake, dietaryIntake);

MHVDECLARE_GETTOR(MHVSleepJournalAM, sleepJournalAM);

MHVDECLARE_GETTOR(MHVSleepJournalPM, sleepJournalPM);

MHVDECLARE_GETTOR(MHVAllergy, allergy);

MHVDECLARE_GETTOR(MHVCondition, condition);

MHVDECLARE_GETTOR(MHVImmunization, immunization);

MHVDECLARE_GETTOR(MHVMedication, medication);

MHVDECLARE_GETTOR(MHVProcedure, procedure);

MHVDECLARE_GETTOR(MHVVitalSigns, vitalSigns);

MHVDECLARE_GETTOR(MHVEncounter, encounter);

MHVDECLARE_GETTOR(MHVFamilyHistory, familyHistory);

MHVDECLARE_GETTOR(MHVCCD, ccd);

MHVDECLARE_GETTOR(MHVCCR, ccr);

MHVDECLARE_GETTOR(MHVInsurance, insurance);

MHVDECLARE_GETTOR(MHVMessage, message);

MHVDECLARE_GETTOR(MHVLabTestResults, labResults);

MHVDECLARE_GETTOR(MHVEmergencyOrProviderContact, emergencyOrProviderContact);

MHVDECLARE_GETTOR(MHVPersonalContactInfo, personalContact);

MHVDECLARE_GETTOR(MHVBasicDemographics, basicDemographics);

MHVDECLARE_GETTOR(MHVPersonalDemographics, personalDemographics);

MHVDECLARE_GETTOR(MHVPersonalImage, personalImage);

MHVDECLARE_GETTOR(MHVFile, file);

@end
