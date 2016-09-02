//
//  CoreDataDBHelper.h
//  MyDemoObjc
//
//  Created by 杨剑 on 16/9/2.
//  Copyright © 2016年 zdksii. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObject;
@class NSFetchedResultsController;

@interface CoreDataDBHelper : NSObject
+(CoreDataDBHelper*)sharedInstance;
/**
 *   数据库保存
 */
-(Boolean)save;

/**
 *  添加数据
 *
 *  @param emptyName 模型名称 类名
 */
-(void)addEmpty:(NSString*)emptyName block:(void(^)(NSObject *obj))block isSave:(BOOL)isSave;

/**
 *  更新或添加数据，如果object为nil那么就是添加数据，否者就是更新数据
 *
 *  @param emptyName 模型名称
 *  @param object    要更新的对象
 */
-(void)addOrUpdateEmpty:(NSString*)emptyName obj:(NSManagedObject *)object block:(void(^)(NSObject *obj))block isSave:(BOOL)isSave;

/**
 *  删除数据
 *
 *  @param obj   要删除的数据对象
 *  @param block 删除成功后回调
 */
-(void)deleteObj:(id)obj block:(void(^)(bool status))block;

/**
 *  更具模型名称查处所有数据
 *
 *  @param emptyName 模型名称
 *
 *  @return 模型对象数组
 */
-(NSMutableArray*)fetchBy:(NSString*)emptyName;

/**
 *  更具模型名称查处所有数据
 *
 *  @param emptyName      模型名称
 *  @param predicate      谓词数组，谓词对象[NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
 *  @param sortDescriptor 排序数组，[NSSortDescriptor sortDescriptorWithKey:@“关键字” ascending:YES];
 *
 *  @return 模型对象数组
 */
-(NSMutableArray *)fetch:(NSString *)emptyName predicateArr:(NSArray*(^)())predicate  sortDescriptor:(NSArray*(^)())sortDescriptor;


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
-(NSFetchedResultsController *)fetchedResultsController:(NSString *)emptyName sectionNameKey:(NSString*)sectionNameKey predicateArr:(NSArray *(^)())predicate sortDescriptor:(NSArray *(^)())sortDescriptor;

@end
