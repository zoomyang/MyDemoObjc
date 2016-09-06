//
//  ViewController.m
//  MyDemoObjc
//
//  Created by 杨剑 on 16/8/29.
//  Copyright © 2016年 zdksii. All rights reserved.
//

#import "ViewController.h"

#import "MyDemoObjc-swift.h"

#import "FMDatabase.h"
#import "DHManager.h"
#import "Dept.h"

#import "OpenUDID.h"

#import "CoreDataDBHelper.h"

#import "CocoaLumberjack.h"
#ifdef DEBUG
static DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
static DDLogLevel ddLogLevel = DDLogLevelInfo;
#endif

#import "MyPlane.h"
#import "PureLayout.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSDictionary *dic = [[DHManager shareDHManager] DH];
    
    DDLogInfo(@"%@",dic);
    
    
    [[CoreDataDBHelper sharedInstance] addEmpty:@"Dept" block:^(NSObject *obj) {
        Dept *dept = (Dept*)obj;
        dept.deptId=[[NSUUID UUID] UUIDString];
        dept.deptName=@"开发部";
    } isSave:YES];
    
    
    NSMutableArray *muDepts = [[CoreDataDBHelper sharedInstance] fetchBy:@"Dept"];
    
    for (Dept *dept in muDepts) {
        NSLog(@"id:%@ name:%@",dept.deptId,dept.deptName);
    }
     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *dbPath = [[paths firstObject] stringByAppendingPathComponent:@"im_demo.db"];
    DDLogWarn(@"%@",dbPath);
    FMDatabase *dataBase = [FMDatabase databaseWithPath:dbPath];
    
    [dataBase open];
    [dataBase setKey:@"111111"];
//    NSString *createSql=@"CREATE table nationsTable (code TEXT NOT NULL PRIMARY KEY UNIQUE ON CONFLICT REPLACE, name TEXT, abbr TEXT)";
//    [dataBase executeUpdate:createSql];
    
    
     BOOL ret = [dataBase executeUpdate:@"INSERT INTO nationsTable(code,name,abbr) VALUES (?,?,?)", @"1111",@"中国",@"222"];
    if (ret) {
        DDLogInfo(@"结果：%d",ret);
    }
    
    FMResultSet *rs=[dataBase executeQuery:@"SELECT name from nationsTable "];
    if ([rs next]) {
       NSString* name = [rs stringForColumn:@"name"];
        DDLogInfo(@"name：%@",name);
    }
    [rs close];
//    NSMutableArray *mu1=[[NSMutableArray alloc] init];
//    NSMutableArray *mu2=[[NSMutableArray alloc] init];
//    
//    [mu1 addObject:mu2];
//    [mu2 addObject:mu1];
    
    
    
    [self addPlane];
    
    MySwift *mySwift = [[MySwift alloc] init];
    
    [mySwift test];
    
    [mySwift myFunc:@"李斯" add:^NSInteger(NSInteger i, NSInteger j) {
        return i*j;
    }];
}


-(void)addPlane
{
    MyPlane *plane = [[MyPlane alloc] initForAutoLayout];
    
    [self.view addSubview:plane];
    
    UIEdgeInsets edge = {0,0,0,0};
    [plane autoPinEdgesToSuperviewEdgesWithInsets:edge];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
