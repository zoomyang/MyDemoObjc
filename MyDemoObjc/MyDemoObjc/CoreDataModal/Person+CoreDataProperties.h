//
//  Person+CoreDataProperties.h
//  MyDemoObjc
//
//  Created by 杨剑 on 16/9/2.
//  Copyright © 2016年 zdksii. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Person.h"

NS_ASSUME_NONNULL_BEGIN

@interface Person (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *personId;
@property (nullable, nonatomic, retain) NSString *personName;
@property (nullable, nonatomic, retain) Dept *deptRef;

@end

NS_ASSUME_NONNULL_END
