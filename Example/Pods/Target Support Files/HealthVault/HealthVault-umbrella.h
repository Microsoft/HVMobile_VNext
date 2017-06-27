#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "MHVAsyncBlockOperation.h"
#import "MHVAsyncOperation.h"
#import "MHVAsyncTask.h"
#import "MHVAsyncTaskCompletionSource.h"
#import "MHVAsyncTaskOperation.h"
#import "MHVAsyncTaskResult.h"
#import "MHVOperationBase.h"
#import "MHVOperationEnums.h"
#import "MHVBrowserAuthBroker.h"
#import "MHVBrowserAuthBrokerProtocol.h"
#import "MHVBrowserController.h"
#import "MHVShellAuthService.h"
#import "MHVShellAuthServiceProtocol.h"
#import "MHVThingCache.h"
#import "MHVClientFactory.h"
#import "MHVClientProtocol.h"
#import "MHVClients.h"
#import "MHVPersonClient.h"
#import "MHVPersonClientProtocol.h"
#import "MHVPlatformClient.h"
#import "MHVPlatformClientProtocol.h"
#import "MHVRemoteMonitoringClient.h"
#import "MHVRemoteMonitoringClientProtocol.h"
#import "MHVThingClient.h"
#import "MHVThingClientProtocol.h"
#import "MHVVocabularyClient.h"
#import "MHVVocabularyClientProtocol.h"
#import "MHVConfiguration.h"
#import "MHVConfigurationConstants.h"
#import "MHVConnection.h"
#import "MHVConnectionFactory.h"
#import "MHVConnectionFactoryInternal.h"
#import "MHVConnectionFactoryProtocol.h"
#import "MHVConnectionProtocol.h"
#import "MHVConnections.h"
#import "MHVSessionCredential.h"
#import "MHVSessionCredentialClient.h"
#import "MHVSessionCredentialClientProtocol.h"
#import "MHVSodaConnection.h"
#import "MHVSodaConnectionProtocol.h"
#import "MHVErrorConstants.h"
#import "NSError+MHVError.h"
#import "MHVArrayExtensions.h"
#import "MHVDateExtensions.h"
#import "MHVDictionaryExtensions.h"
#import "MHVStringExtensions.h"
#import "MHVViewExtensions.h"
#import "MHVCommon.h"
#import "MHVRestApi.h"
#import "HealthVault.h"
#import "MHVHttpService.h"
#import "MHVHttpServiceProtocol.h"
#import "MHVHttpServiceResponse.h"
#import "MHVHttpTask.h"
#import "MHVHttpTaskProtocol.h"
#import "MHVNetworkReachability.h"
#import "MHVServiceResponse.h"
#import "MHVJsonCacheItem.h"
#import "MHVJsonCacheRetainObjectProtocol.h"
#import "MHVJsonCacheService.h"
#import "MHVJsonEnumProtocol.h"
#import "MHVJsonEnums.h"
#import "MHVJsonSerializer.h"
#import "MHVPropertyIntrospection.h"
#import "MHVBlobDownloadRequest.h"
#import "MHVBlobUploadRequest.h"
#import "MHVHttpServiceOperationProtocol.h"
#import "MHVHttpServiceRequest.h"
#import "MHVMethod.h"
#import "MHVRestRequest.h"
#import "MHVCacheQuery.h"
#import "NSArray+DataModel.h"
#import "NSArray+MHVEnum.h"
#import "NSArray+Utils.h"
#import "NSData+DataModel.h"
#import "NSData+Utils.h"
#import "NSDate+DataModel.h"
#import "NSDictionary+DataModel.h"
#import "NSNull+DataModel.h"
#import "NSNumber+DataModel.h"
#import "NSSet+DataModel.h"
#import "NSString+DataModel.h"
#import "NSUUID+DataModel.h"
#import "MHVActionPlansApi.h"
#import "MHVActionPlanTasksApi.h"
#import "MHVGoalsApi.h"
#import "MHVGoalsRecommendationsApi.h"
#import "MHVActionPlan.h"
#import "MHVActionPlanAdherenceSummary.h"
#import "MHVActionPlanFrequencyTaskCompletionMetrics.h"
#import "MHVActionPlanInstance.h"
#import "MHVActionPlanRangeMetric.h"
#import "MHVActionPlanScheduledTaskCompletionMetrics.h"
#import "MHVActionPlansResponseActionPlanInstance_.h"
#import "MHVActionPlanTask.h"
#import "MHVActionPlanTaskAdherenceSummary.h"
#import "MHVActionPlanTaskInstance.h"
#import "MHVActionPlanTaskOccurrenceMetrics.h"
#import "MHVActionPlanTasksResponseActionPlanTaskInstance_.h"
#import "MHVActionPlanTaskTargetEvent.h"
#import "MHVActionPlanTaskTracking.h"
#import "MHVActionPlanTaskTrackingEvidence.h"
#import "MHVActionPlanTaskTrackingResponseActionPlanTaskTracking_.h"
#import "MHVActionPlanTrackingPolicy.h"
#import "MHVErrorInformation.h"
#import "MHVErrorResponse.h"
#import "MHVGoal.h"
#import "MHVGoalRange.h"
#import "MHVGoalRecommendation.h"
#import "MHVGoalRecommendationInstance.h"
#import "MHVGoalRecommendationsResponse.h"
#import "MHVGoalRecurrenceMetrics.h"
#import "MHVGoalsResponse.h"
#import "MHVGoalsWrapper.h"
#import "MHVObjective.h"
#import "MHVObjectiveAdherenceSummary.h"
#import "MHVSchedule.h"
#import "MHVTrackingValidation.h"
#import "MHVWeeklyAdherenceSummary.h"
#import "MHVDataModelDynamicClass.h"
#import "MHVDataModelProtocol.h"
#import "MHVDynamicEnum.h"
#import "MHVEnum.h"
#import "MHVModelBase.h"
#import "MHVApplicationCreationInfo.h"
#import "MHVPlatformConstants.h"
#import "MHVServiceDefinitionRequestParameters.h"
#import "MHVThingConstants.h"
#import "MHVKeychainService.h"
#import "MHVKeychainServiceProtocol.h"
#import "MHVThingTypeDefinition.h"
#import "MHVThingTypeDefinitionRequestParameters.h"
#import "MHVThingTypeDefinitions.h"
#import "MHVThingTypeOrderByProperty.h"
#import "MHVThingTypeVersionInfo.h"
#import "MHVAdvanceDirective.h"
#import "MHVAerobicProfile.h"
#import "MHVAllergicEpisode.h"
#import "MHVAllergy.h"
#import "MHVAppointment.h"
#import "MHVAppSpecificInformation.h"
#import "MHVAssessment.h"
#import "MHVAsthmaInhaler.h"
#import "MHVAsthmaInhalerUsage.h"
#import "MHVBasicDemographics.h"
#import "MHVBloodGlucose.h"
#import "MHVBloodPressure.h"
#import "MHVBodyComposition.h"
#import "MHVBodyDimension.h"
#import "MHVCCD.h"
#import "MHVCCR.h"
#import "MHVCholesterol.h"
#import "MHVCollection.h"
#import "MHVConcern.h"
#import "MHVCondition.h"
#import "MHVDailyDietaryIntake.h"
#import "MHVDailyMedicationUsage.h"
#import "MHVDietaryIntake.h"
#import "MHVEmergencyOrProviderContact.h"
#import "MHVEmotionalState.h"
#import "MHVEncounter.h"
#import "MHVExercise.h"
#import "MHVExplanationOfBenefits.h"
#import "MHVFamilyHistory.h"
#import "MHVFile.h"
#import "MHVHealthGoal.h"
#import "MHVHealthJournalEntry.h"
#import "MHVHeartRate.h"
#import "MHVHeight.h"
#import "MHVImmunization.h"
#import "MHVInsight.h"
#import "MHVInsurance.h"
#import "MHVLabTestResults.h"
#import "MHVMedicalDevice.h"
#import "MHVMedication.h"
#import "MHVMenstruation.h"
#import "MHVMessage.h"
#import "MHVPeakFlow.h"
#import "MHVPersonalContactInfo.h"
#import "MHVPersonalDemographics.h"
#import "MHVPersonalImage.h"
#import "MHVPlan.h"
#import "MHVPregnancy.h"
#import "MHVProcedure.h"
#import "MHVQuestionAnswer.h"
#import "MHVSleepJournalAM.h"
#import "MHVSleepJournalPM.h"
#import "MHVTaskThing.h"
#import "MHVTaskTrackingEntry.h"
#import "MHVThingRaw.h"
#import "MHVThingTypes.h"
#import "MHVVitalSigns.h"
#import "MHVWeight.h"
#import "MHVAuthSession.h"
#import "MHVRequestMessageCreator.h"
#import "MHVRequestMessageCreatorProtocol.h"
#import "MHVBaseTypes.h"
#import "MHVBool.h"
#import "MHVConstrainedDouble.h"
#import "MHVConstrainedInt.h"
#import "MHVConstrainedString.h"
#import "MHVConstrainedXmlDate.h"
#import "MHVDay.h"
#import "MHVDouble.h"
#import "MHVEmailAddress.h"
#import "MHVHour.h"
#import "MHVInt.h"
#import "MHVMillisecond.h"
#import "MHVMinute.h"
#import "MHVMonth.h"
#import "MHVNonNegativeDouble.h"
#import "MHVNonNegativeInt.h"
#import "MHVOneToFive.h"
#import "MHVPercentage.h"
#import "MHVPositiveDouble.h"
#import "MHVPositiveInt.h"
#import "MHVSecond.h"
#import "MHVString1024.h"
#import "MHVString128.h"
#import "MHVString255.h"
#import "MHVStringNZ256.h"
#import "MHVStringNZNW.h"
#import "MHVStringZ512.h"
#import "MHVUUID.h"
#import "MHVVocabularySearchString.h"
#import "MHVYear.h"
#import "MHVBlob.h"
#import "MHVBlobHashInfo.h"
#import "MHVBlobInfo.h"
#import "MHVBlobPayload.h"
#import "MHVBlobPayloadThing.h"
#import "MHVBlobPutParameters.h"
#import "MHVBlobSource.h"
#import "MHVItemTypePropertyConverterProtocol.h"
#import "MHVLinearItemTypePropertyConverer.h"
#import "MHVAddress.h"
#import "MHVAlert.h"
#import "MHVApplicationSettings.h"
#import "MHVApproxDate.h"
#import "MHVApproxDateTime.h"
#import "MHVApproxMeasurement.h"
#import "MHVAssessmentField.h"
#import "MHVAudit.h"
#import "MHVBaby.h"
#import "MHVBloodGlucoseMeasurement.h"
#import "MHVBodyCompositionValue.h"
#import "MHVClaimAmounts.h"
#import "MHVCodableValue.h"
#import "MHVCodedValue.h"
#import "MHVConcentrationValue.h"
#import "MHVConditionEntry.h"
#import "MHVContact.h"
#import "MHVDate.h"
#import "MHVDateTime.h"
#import "MHVDelivery.h"
#import "MHVDisplayValue.h"
#import "MHVDow.h"
#import "MHVDuration.h"
#import "MHVEmail.h"
#import "MHVEOBService.h"
#import "MHVFlowValue.h"
#import "MHVFoodEnergyValue.h"
#import "MHVGeneralMeasurement.h"
#import "MHVGetAuthorizedPeopleResult.h"
#import "MHVGetAuthorizedPeopleSettings.h"
#import "MHVGetRecordOperationsResult.h"
#import "MHVGoalAssociatedTypeInfo.h"
#import "MHVGoalRangeType.h"
#import "MHVGoalRecurrence.h"
#import "MHVHeartrateZone.h"
#import "MHVHeartrateZoneGroup.h"
#import "MHVInsightAttribution.h"
#import "MHVInsightMessages.h"
#import "MHVLabTestResultsDetails.h"
#import "MHVLabTestResultsGroup.h"
#import "MHVLabTestResultValue.h"
#import "MHVLengthMeasurement.h"
#import "MHVLocation.h"
#import "MHVMaxVO2.h"
#import "MHVMeasurement.h"
#import "MHVMedicalImageStudy.h"
#import "MHVMedicalImageStudySeries.h"
#import "MHVMedicalImageStudySeriesImage.h"
#import "MHVMessageAttachment.h"
#import "MHVMessageHeaderThing.h"
#import "MHVName.h"
#import "MHVNameValue.h"
#import "MHVNutritionFact.h"
#import "MHVOccurence.h"
#import "MHVOrganization.h"
#import "MHVPendingThing.h"
#import "MHVPerson.h"
#import "MHVPersonInfo.h"
#import "MHVPhone.h"
#import "MHVPlanObjective.h"
#import "MHVPlanOutcome.h"
#import "MHVPrescription.h"
#import "MHVRecord.h"
#import "MHVRecordOperation.h"
#import "MHVRecordReference.h"
#import "MHVRelatedThing.h"
#import "MHVRelative.h"
#import "MHVResponse.h"
#import "MHVResponseStatus.h"
#import "MHVServerError.h"
#import "MHVStructuredInsightValue.h"
#import "MHVStructuredMeasurement.h"
#import "MHVTaskCompletionMetrics.h"
#import "MHVTaskOccurrenceMetrics.h"
#import "MHVTaskRangeMetrics.h"
#import "MHVTaskSchedule.h"
#import "MHVTaskTargetEvents.h"
#import "MHVTaskTrackingPolicy.h"
#import "MHVTestResultRange.h"
#import "MHVTestResultRangeValue.h"
#import "MHVThing.h"
#import "MHVThingData.h"
#import "MHVThingDataCommon.h"
#import "MHVThingDataTyped.h"
#import "MHVThingFilter.h"
#import "MHVThingKey.h"
#import "MHVThingQuery.h"
#import "MHVThingQueryResult.h"
#import "MHVThingQueryResults.h"
#import "MHVThingSection.h"
#import "MHVThingState.h"
#import "MHVThingType.h"
#import "MHVThingView.h"
#import "MHVTime.h"
#import "MHVTrackingSourceTypes.h"
#import "MHVTrackingTriggerTypes.h"
#import "MHVType.h"
#import "MHVTypes.h"
#import "MHVVitalSignResult.h"
#import "MHVVolumeValue.h"
#import "MHVWeightMeasurement.h"
#import "MHVZoneBoundary.h"
#import "MHVConfigurationEntry.h"
#import "MHVPlatformInfo.h"
#import "MHVServiceDef.h"
#import "MHVServiceDefinition.h"
#import "MHVServiceInstance.h"
#import "MHVShellInfo.h"
#import "MHVSystemInstances.h"
#import "MHVClientInfo.h"
#import "MHVClientResult.h"
#import "MHVCore.h"
#import "MHVCryptographer.h"
#import "MHVLogger.h"
#import "MHVQueuedDictionary.h"
#import "MHVRandom.h"
#import "MHVValidator.h"
#import "MHVVocabulary.h"
#import "MHVVocabularyCodeItem.h"
#import "MHVVocabularyCodeSet.h"
#import "MHVVocabularyIdentifier.h"
#import "MHVVocabularyKey.h"
#import "MHVVocabularyParams.h"
#import "MHVVocabularySearchParams.h"
#import "XConverter.h"
#import "XLib.h"
#import "XNodeType.h"
#import "XReader.h"
#import "XSerializableType.h"
#import "XSerializer.h"
#import "XString.h"
#import "XWriter.h"

FOUNDATION_EXPORT double HealthVaultVersionNumber;
FOUNDATION_EXPORT const unsigned char HealthVaultVersionString[];

