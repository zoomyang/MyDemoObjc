//
//  ViewController.m
//  MyDemoObjc
//
//  Created by 杨剑 on 16/8/29.
//  Copyright © 2016年 zdksii. All rights reserved.
//

#import "ViewController.h"

#import "DHManager.h"

#import "CocoaLumberjack.h"
#ifdef DEBUG
static DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
static DDLogLevel ddLogLevel = DDLogLevelInfo;
#endif

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSDictionary *dic = [[DHManager shareDHManager] DH];
    
    DDLogInfo(@"%@",dic);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
