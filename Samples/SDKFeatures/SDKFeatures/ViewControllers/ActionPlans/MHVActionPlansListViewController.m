//
// MHVActionPlansListViewController.m
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

#import <Foundation/Foundation.h>
#import "MHVActionPlansListViewController.h"
#import "MHVActionPlanDetailViewController.h"
#import "MHVConnection.h"
#import "MHVActionPlansApi.h"

@interface MHVActionPlansListViewController ()

@property (nonatomic, strong) NSArray<MHVActionPlanInstance *> *actionPlans;
@property (nonatomic, strong) MHVConnection *connection;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (strong, nonatomic) IBOutlet MHVStatusLabel *statusLabel;

- (IBAction)addActionPlan:(id)sender;

@end

@implementation MHVActionPlansListViewController

- (instancetype)initWithTypeClass:(Class)typeClass useMetric:(BOOL)metric
{
    self = [super init];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _actionPlans = [[NSArray alloc] init];
    
    [self.navigationController.navigationBar setTranslucent:FALSE];
    self.navigationItem.title = @"Action Plans List";
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self loadActionPlans];
}

- (void)loadActionPlans
{
    [self.statusLabel showBusy];
    
    MHVConfiguration *config = MHVFeaturesConfiguration.configuration;
    _connection = [[MHVConnectionFactory current] getOrCreateSodaConnectionWithConfiguration:config];
    
    [self.connection.remoteMonitoringClient getActionPlansWithMaxPageSize:@(10) completion:^(MHVActionPlansResponseActionPlanInstance_ * _Nullable output, NSError * _Nullable error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
            if (!error)
            {
                self.actionPlans = output.plans;
                
                [self.tableView reloadData];
                [self.statusLabel clearStatus];
            }
            else
            {
                [MHVUIAlert showInformationalMessage:error.description];
                [self.statusLabel showStatus:@"Failed"];
            }
         }];
    }];
}

- (IBAction)addActionPlan:(id)sender
{
    // Create a new action plan, we don't allow input here because plans are fairly complicated. Just create one.
    
    NSNumber *rand = @(arc4random_uniform(100));
    
    MHVObjective *objective = [[MHVObjective alloc] init];
    objective._description = @"A sample objective which encourages you to get more activity.";
    objective.name = @"Start doing some fun activities.";
    objective.outcomeName = @"Exercise hours / week";
    objective.outcomeType = @"ExerciseHoursPerWeek";
    objective.state = @"Active";
    objective._id = [[NSUUID UUID] UUIDString];
    
    MHVActionPlanTrackingPolicy *policy = [[MHVActionPlanTrackingPolicy alloc] init];
    policy.isAutoTrackable = @(NO);
    
    MHVActionPlanFrequencyTaskCompletionMetrics *metrics = [[MHVActionPlanFrequencyTaskCompletionMetrics alloc] init];
    metrics.reminderState = @"Off";
    metrics.scheduledDays = @[@"Monday", @"Wednesday", @"Friday"];
    metrics.occurrenceCount = @(1);
    metrics.windowType = @"Daily";
    
    MHVActionPlanTask *frequencyTask = [[MHVActionPlanTask alloc] init];
    NSString *taskName =[NSString stringWithFormat:@"Do a fun activity (plan %@)", rand];
    frequencyTask.name = taskName;
    frequencyTask.shortDescription = @"Do an activity to get some exercise.";
    frequencyTask.longDescription = @"Go for a run, hike a mountain, ride your bike around town, or something else to get moving.";
    frequencyTask.imageUrl = @"https://img-prod-cms-rt-microsoft-com.akamaized.net/cms/api/am/imageFileData/RE1rXx2?ver=d68e";
    frequencyTask.thumbnailImageUrl = @"https://img-prod-cms-rt-microsoft-com.akamaized.net/cms/api/am/imageFileData/RE1s2KS?ver=0ad8";
    frequencyTask.taskType = @"Other";
    frequencyTask.signupName = taskName;
    frequencyTask.associatedObjectiveIds = [[NSArray alloc] initWithObjects:objective._id, nil];
    frequencyTask.trackingPolicy = policy;
    frequencyTask.completionType = @"Frequency";
    frequencyTask.frequencyTaskCompletionMetrics = metrics;
    
    MHVActionPlan *newPlan = [[MHVActionPlan alloc] init];
    newPlan.name = [NSString stringWithFormat:@"My new plan (%@)", rand];
    newPlan._description = @"A sample activity plan";
    newPlan.imageUrl = @"https://img-prod-cms-rt-microsoft-com.akamaized.net/cms/api/am/imageFileData/RE10omP?ver=59cf";
    newPlan.thumbnailImageUrl = @"https://img-prod-cms-rt-microsoft-com.akamaized.net/cms/api/am/imageFileData/RE10omP?ver=59cf";
    newPlan.category = @"Activity";
    newPlan.objectives = [[NSArray<MHVObjective> alloc] initWithObjects:objective, nil];
    newPlan.associatedTasks = [[NSArray<MHVActionPlanTask> alloc] initWithObjects:frequencyTask, nil];
    
    [self.connection.remoteMonitoringClient createActionPlanWithActionPlan:newPlan completion:^(MHVSystemObject * _Nullable output, NSError * _Nullable error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             if (!error)
             {
                 [self loadActionPlans];
             }
             else
             {
                 [MHVUIAlert showInformationalMessage:error.description];
                 [self.statusLabel showStatus:@"Failed"];
             }
         }];
    }];
}

// -------------------------------------
//
// UITableViewDataSource & Delegate
//
// -------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.actionPlans count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MHVCell"];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MHVCell"];
    }
    
    cell.textLabel.text = self.actionPlans[indexPath.row].name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *planId = self.actionPlans[indexPath.row]._id;
    
    MHVActionPlanDetailViewController *typeView = [[MHVActionPlanDetailViewController alloc] initWithPlanId:planId];
    
    if (!typeView || !planId)
    {
        [MHVUIAlert showInformationalMessage:@"Could not create MHVActionPlanDetailViewController view for plan."];
        return;
    }
    
    [self.navigationController pushViewController:typeView animated:YES];
}

@end
