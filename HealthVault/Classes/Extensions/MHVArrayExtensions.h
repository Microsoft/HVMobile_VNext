//
// MHVArrayExtensions.h
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

#import <Foundation/Foundation.h>

@interface NSArray (MHVArrayExtensions)

+ (BOOL)isNilOrEmpty:(NSArray *)array;

- (NSArray *)arrayByAddingObjectsFromArray:(NSArray *)array atStartingIndex:(NSUInteger)startingIndex;

- (NSArray *)arrayByRemovingObject:(id)anObject;

- (BOOL)hasElementsOfType:(Class)type;

@end

@interface NSMutableArray (MHVArrayExtensions)


- (void)addFromEnumerator:(NSEnumerator *) enumerator;

@end
