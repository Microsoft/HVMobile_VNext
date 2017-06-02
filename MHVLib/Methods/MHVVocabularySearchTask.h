//
//  MHVSearchVocabTask.h
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

#import "MHVMethodCallTask.h"
#import "MHVVocabularyIdentifier.h"
#import "MHVVocabularySearchParams.h"
#import "MHVVocabularyCodeSet.h"

//-------------------------
//
// Search a given vocabulary
// Supports various options such as free text search
// Ideal for auto-complete scenarios
//
//-------------------------
@interface MHVVocabularySearchTask : MHVMethodCallTask
{
@private
    MHVVocabularyIdentifier* m_vocabID;
    MHVVocabularySearchParams* m_params;
}

//-------------------------
//
// Data
//
//-------------------------
//
// (Required) - vocabulary being searched
//
@property (readwrite, nonatomic, strong) MHVVocabularyIdentifier* vocabID;
//
// (Required) - search parameters
//
@property (readwrite, nonatomic, strong) MHVVocabularySearchParams* params;
//
// RESULT - use this property to retrieve results when the task completes
//
@property (readonly, nonatomic, strong) MHVVocabularyCodeSet* searchResult;

//-------------------------
//
// Initializers
//
//-------------------------
-(id) initWithVocab:(MHVVocabularyIdentifier *) vocab searchText:(NSString*) text andCallback:(MHVTaskCompletion) callback;

+(MHVVocabularySearchTask *) searchForText:(NSString *) text inVocabFamily:(NSString *) family vocabName:(NSString *) name callback:(MHVTaskCompletion) callback;

+(MHVVocabularySearchTask *) searchForText:(NSString *) text inVocab:(MHVVocabularyIdentifier *) vocab callback:(MHVTaskCompletion) callback;

+(MHVVocabularySearchTask *) searchMedications:(NSString *) text callback:(MHVTaskCompletion) callback;

@end
