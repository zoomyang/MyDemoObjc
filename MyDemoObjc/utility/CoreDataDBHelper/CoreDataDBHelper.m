//
//  CoreDataDBHelper.m
//  MyDemoObjc
//
//  Created by 杨剑 on 16/9/2.
//  Copyright © 2016年 zdksii. All rights reserved.
//

#import "CoreDataDBHelper.h"

#import "AppDelegate.h"

@implementation CoreDataDBHelper

static  CoreDataDBHelper* _sharedInstance = nil;

+(CoreDataDBHelper*)sharedInstance
{
    if (_sharedInstance==nil) {
       _sharedInstance=[[self alloc] init];
    }
    return _sharedInstance;
}

-(Boolean)save
{
    AppDelegate* appDelegate = [self getApplegate];
    NSManagedObjectContext* context = [appDelegate managedObjectContext];
    
    NSError* error = nil;
    
    if (![context save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return NO;
    }
    return YES;
}


/**
 *  添加数据
 *
 *  @param emptyName 模型名称 类名
 */
-(void)addEmpty:(NSString*)emptyName block:(void(^)(NSObject *obj))block isSave:(BOOL)isSave
{
    AppDelegate* appDelegate = [self getApplegate];
    NSManagedObjectContext* context = [appDelegate managedObjectContext];
    
    
    NSManagedObject *obj = [NSEntityDescription insertNewObjectForEntityForName:emptyName inManagedObjectContext:context];
   
    block(obj);
    
    if (isSave) {
        [self save];
    }

}

/**
 *  更新或添加数据，如果object为nil那么就是添加数据，否者就是更新数据
 *
 *  @param emptyName 模型名称
 *  @param object    要更新的对象
 */
-(void)addOrUpdateEmpty:(NSString*)emptyName obj:(NSManagedObject*)object block:(void(^)(NSObject *obj))block isSave:(BOOL)isSave;
{
    AppDelegate* appDelegate = [self getApplegate];
    NSManagedObjectContext* context = [appDelegate managedObjectContext];
    
    if (object) {
        object= [NSEntityDescription insertNewObjectForEntityForName:emptyName inManagedObjectContext:context];
    }
    
    block(object);
    
    if (isSave) {
        [self save];
    }


}


/**
 *  删除数据
 *
 *  @param obj   要删除的数据对象
 *  @param block 删除成功后回调
 */
-(void)deleteObj:(id)obj block:(void(^)(bool status))block
{
    AppDelegate* appDelegate = [self getApplegate];
    NSManagedObjectContext* context = [appDelegate managedObjectContext];
    
    [context deleteObject:obj];
    
    NSError* error = nil;
    if (![context save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        block(NO);
    }else{
        block(YES);
    }
}


/**
 *  更具模型名称查处所有数据
 *
 *  @param emptyName 模型名称
 *
 *  @return 模型对象数组
 */
-(NSMutableArray *)fetchBy:(NSString *)emptyName
{
    AppDelegate* appDelegate = [self getApplegate];
    NSManagedObjectContext* context = [appDelegate managedObjectContext];
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* entityDesc = [NSEntityDescription entityForName:emptyName inManagedObjectContext:context]; // generate a description that describe which entity in data model you want to handle.
    [request setEntity:entityDesc]; // assign the description to the request


    NSError* error;
    NSArray* objects = [context executeFetchRequest:request error:&error]; // all needed are prepared, then execute it.
    NSMutableArray* mutableObjects = [NSMutableArray arrayWithArray:objects];
    return mutableObjects;
}

/**
 *  根据模型名称查处所有数据
 *
 *  @param emptyName      模型名称
 *  @param predicate      谓词数组，谓词对象[NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
 *  @param sortDescriptor 排序数组，[NSSortDescriptor sortDescriptorWithKey:@“关键字” ascending:YES];
 *
 *  @return 模型对象数组
 */
-(NSMutableArray *)fetch:(NSString *)emptyName predicateArr:(NSArray*(^)())predicate  sortDescriptor:(NSArray*(^)())sortDescriptor
{
    AppDelegate* appDelegate = [self getApplegate];
    NSManagedObjectContext* context = [appDelegate managedObjectContext];
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* entityDesc = [NSEntityDescription entityForName:emptyName inManagedObjectContext:context]; // generate a description that describe which entity in data model you want to handle.
    [request setEntity:entityDesc]; // assign the description to the request
    NSArray *predicates = predicate();
    if (predicates!=nil&&[predicates count]>0) {
        NSPredicate *predicate =[NSCompoundPredicate andPredicateWithSubpredicates:predicates];
        [request setPredicate:predicate];
    }

    
    if (sortDescriptor!=nil&&[sortDescriptor count]>0) {
        [request setSortDescriptors:sortDescriptor()];
    }
    
    
    NSError* error;
    NSArray* objects = [context executeFetchRequest:request error:&error]; // all needed are prepared, then execute it.
    NSMutableArray* mutableObjects = [NSMutableArray arrayWithArray:objects];
    return mutableObjects;
    
}

/**
 *  根据模型名称返回检索结果控制器
 *
 *  @param emptyName      模型名称
 *  @param sectionNameKey 分组关键字
 *  @param predicate      谓词数组，谓词对象[NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
 *  @param sortDescriptor 排序数组，[NSSortDescriptor sortDescriptorWithKey:@“关键字” ascending:YES];
 *
 *  @return 检索结果控制器
 */
-(NSFetchedResultsController *)fetchedResultsController:(NSString *)emptyName sectionNameKey:(NSString*)sectionNameKey predicateArr:(NSArray *(^)())predicate sortDescriptor:(NSArray *(^)())sortDescriptor
{
    AppDelegate* appDelegate = [self getApplegate];
    NSManagedObjectContext* context = [appDelegate managedObjectContext];
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* entityDesc = [NSEntityDescription entityForName:emptyName inManagedObjectContext:context]; // generate a description that describe which entity in data model you want to handle.
    [request setEntity:entityDesc]; // assign the description to the request
    NSArray *predicates = predicate();
    if (predicates!=nil&&[predicates count]>0) {
        NSPredicate *predicate =[NSCompoundPredicate andPredicateWithSubpredicates:predicates];
        [request setPredicate:predicate];
    }
    
    
    if (sortDescriptor!=nil&&[sortDescriptor count]>0) {
        [request setSortDescriptors:sortDescriptor()];
    }
    
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:sectionNameKey cacheName:nil];
    NSError* error;
    if ([fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@ %@",error,[error userInfo]);
        return nil;
    }
    return fetchedResultsController;
}

-(AppDelegate*)getApplegate
{
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return appDelegate;
}

@end
