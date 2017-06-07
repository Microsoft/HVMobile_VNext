//
//  PickerContentCreator.swift
//  MedicationTracker
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

import Foundation

struct HVUnitTypes
{
    static let doseUnits = ["Applicatorfuls","Bags", "Bars","Capsules", "Doses", "Dropperfuls",
                     "Drops", "Grams (g)", "Inhalations", "Lozenges","Micrograms (mcg)",
                     "Milligrams (mg)","Milliliters (ml)","Packets", "Pads", "Patches",
                     "Percent (%)", "Puffs", "Scoops", "Shots", "Sprays","Suppositories",
                     "Syringe","Tablespoons (tbsp)", "Tablets", "Teaspoons (tsp)", "Units (U)"]
    static let strengthUnits = ["Colony forming units per milliliter (cfu/ml)", "International unit (iu)",
                         "Micrograms (mcg)", "Milliequivalent (meq)", "Milliequivalent per milliliter (meq/ml)",
                         "Milligram (mg)","Milligram per milliliter (mg/ml)", "Milliliter (ml)", "Percent (%)",
                         "Unit (unt)","Units per milliliter (unt/ml)"]
}

struct FormSubmission{
    static func canSubmit(subviews: [UIView]) -> Bool
    {
        var fieldsComplete = true
        for subview in subviews
        {
            if let textField = subview as? UIMedicationTextField
            {
                if !textField.isValid()
                {
                    fieldsComplete = false
                }
            }
        }
        return fieldsComplete
    }
 
}

class MedicationVocabSearcher
{
    let minSearchSize = 3

    func searchForMeds(searchValue: String, completion: @escaping(MHVVocabularyCodeItemCollection?) -> Void)
    {
        let connection = MHVConnectionFactory.current().getOrCreateSodaConnection(with: HVFeaturesConfiguration.configuration())
        let key = MHVVocabularyKey.init(name: "RxNorm Active Medicines", andFamily: "RxNorm",
                                        andVersion: "09AB_091102F", andCode: nil)
        connection.vocabularyClient()?.searchVocabulary(withSearchValue: searchValue,
                                                        searchMode: MHVSearchMode.contains, vocabularyKey: key!,
                                                        maxResults: 25, completion:
            {
                (matchedMeds: MHVVocabularyCodeSetCollection?, error: Error?) in
                let meds = matchedMeds!.firstObject().vocabularyCodeItems
                completion(meds)
            })
    }
    
    func showMedList(textField: UITextField, nameTableView: UITableView, range: NSRange, string: String,
                     completion: @escaping(MHVVocabularyCodeItemCollection?) -> Void)
    {
        // Get substring and check if we the min size for searching was reached
        let substring = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if substring.characters.count >= minSearchSize
        {
            // Show autocomplete contents in table view
            nameTableView.isHidden = false
            searchForMeds(searchValue: substring, completion:
                {
                    autocompleteContents in
                    DispatchQueue.main.async
                        {
                            completion(autocompleteContents)
                        }
            })
            nameTableView.reloadData()
        }
        else
        {
            nameTableView.isHidden = true
        }
    }
}
