//
//  MedicationBuilder.swift
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

class MedicationBuilder
{
    
    // MARK: Properties
    private(set) var thing: MHVThing?
    private(set) var med: MHVMedication?
    
    // MARK: Builder functions
    func buildMedication(mhvThing: MHVThing) -> Bool
    {
        thing = mhvThing
        med = mhvThing.medication()
        return true
    }
    
    func updateNameIfNotNil(name: String?) -> Bool
    {
        guard let medName = name, !(medName.isEmpty), med != nil else
        {
            return false
        }
        
        med!.name = MHVCodableValue.fromText(medName)
        return true
    }
    
    func updateStrengthIfNotNil(amount: String, unit: String?) -> Bool
    {
        guard let strengthAmount = Double(amount), let strengthUnit = unit, !(strengthUnit.isEmpty), med != nil else
        {
            return false
        }
        med!.strength = MHVApproxMeasurement.fromValue(strengthAmount, unitsText: strengthUnit,
                                                       unitsCode: strengthUnit, unitsVocab: "medication-strength-unit")
        return true
    }
    
    func updateDoseIfNotNil(amount: String, unit: String?) -> Bool
    {
        guard let doseAmount = Double(amount), let doseUnit = unit, !(doseUnit.isEmpty), med != nil else
        {
            return false
        }
        med!.dose = MHVApproxMeasurement.fromValue(doseAmount, unitsText: doseUnit,
                                                   unitsCode: doseUnit, unitsVocab: "medication-dose-units")
        return true
    }
    
    func updateFrequencyIfNotNil(amount: String, unit: String?) -> Bool
    {
        guard let freqAmount = Double(amount), let freqUnit = unit, !(freqUnit.isEmpty), med != nil else
        {
            return false
        }
        med!.frequency = MHVApproxMeasurement.fromValue(freqAmount, unitsText: freqUnit, unitsCode: freqUnit,
                                                        unitsVocab: "frequency-units")
        return true
    }
    
    func updateTaskConnection(taskThingId: String, relationshipType: TaskRelationship) -> Bool
    {
        let relatedThing = MHVRelatedThing.init()
        relatedThing.thingID = taskThingId
        relatedThing.relationship = relationshipType.rawValue
        
        thing?.data.common.relatedThings.add(relatedThing)
        
        return true
    }
    
    func constructMedication() -> (MHVThing, contructedProperly: Bool)
    {
        guard med != nil, let medName = med?.name.text, !medName.isEmpty else
        {
            return (thing!, false)
        }
        return (thing!, true)
    }
}