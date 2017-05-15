//
// MHVTypeViewController.h
// SDKFeatures
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

#import <UIKit/UIKit.h>
#import "MHVLib.h"
#import "MHVItemDataTypedFactory.h"
#import "MHVStatusLabel.h"
#import "MHVItemDataTypedFeatures.h"
#import "MHVUIAlert.h"

@interface MHVTypeViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithTypeClass:(Class)typeClass useMetric:(BOOL)metric;

- (IBAction)addItem:(id)sender;
- (IBAction)removeItem:(id)sender;
- (IBAction)moreClicked:(id)sender;

//
// Returns the item in the table that is currently selected
//
- (MHVItem *)getSelectedItem;

//
// Add random data for ONE DAY for the type currently selected by the user
// For types like DietaryIntake, this may create more than one item
// The data has a date within m_maxDaysOffsetRandomData from the current date
//
- (void)addRandomData:(BOOL)isMetric;
- (void)removeCurrentItem;

- (void)refreshView;
- (void)getItemsFromHealthVault;
- (void)showActivityAndStatus:(NSString *)status;
- (void)clearStatus;

@end
