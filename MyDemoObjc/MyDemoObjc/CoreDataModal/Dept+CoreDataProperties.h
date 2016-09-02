//
//  Dept+CoreDataProperties.h
//  MyDemoObjc
//
//  Created by 杨剑 on 16/9/2.
//  Copyright © 2016年 zdksii. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Dept.h"

NS_ASSUME_NONNULL_BEGIN

@interface Dept (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *deptId;
@property (nullable, nonatomic, retain) NSString *deptName;
@property (nullable, nonatomic, retain) NSSet<NSManagedObject *> *personsRef;

@end

@interface Dept (CoreDataGeneratedAccessors)

- (void)addPersonsRefObject:(NSManagedObject *)value;
- (void)removePersonsRefObject:(NSManagedObject *)value;
- (void)addPersonsRef:(NSSet<NSManagedObject *> *)values;
- (void)removePersonsRef:(NSSet<NSManagedObject *> *)values;

@end

NS_ASSUME_NONNULL_END
