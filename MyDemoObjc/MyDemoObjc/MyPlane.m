//
//  MyPlane.m
//  MyDemoObjc
//
//  Created by 杨剑 on 16/9/6.
//  Copyright © 2016年 zdksii. All rights reserved.
//

#import "MyPlane.h"

@implementation MyPlane

-(instancetype)init
{
    if (self) {
        self=[super init];
    }
    self.allLineMutableArray = [[NSMutableArray alloc] init];
    [self setBackgroundColor:[UIColor whiteColor]];
    
    
    return self;
}


//开始触摸
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 获得触摸对象
    UITouch *touch = touches.anyObject ;
    // 获得触摸的点
    CGPoint startPoint = [touch locationInView:self] ;
    // 初始化一个UIBezierPath对象,用来存储所有的轨迹点
    UIBezierPath *bezierPath = [UIBezierPath bezierPath] ;
    // 把起始点存储到UIBezierPath对象中
    [bezierPath moveToPoint:startPoint] ;
    // 把当前UIBezierPath对象存储到数组中
    [self.allLineMutableArray addObject:bezierPath] ;
    
}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 获取触摸对象
    UITouch *touch = touches.anyObject ;
    // 获得当前的点
    CGPoint currentPoint = [touch locationInView:self] ;
    // 获得数组中的最后一个UIBezierPath对象(因为我们每次都把UIBezierPath存入到数组最后一个,因此获取时也取最后一个)
    UIBezierPath *bezierPath = self.allLineMutableArray.lastObject ;
    // 把当前点加入到bezierPath中
    [bezierPath addLineToPoint:currentPoint] ;
    // 每移动一次就重新绘制当前视图
    [self setNeedsDisplay] ;// 调用此方法,就会触发drawrect来重新绘制当前视图. }
    
}
// 重新绘制当前视图
- (void)drawRect:(CGRect)rect
{
    [[UIColor redColor] setStroke] ; // 设置画笔颜色
    for (UIBezierPath *bezierPath in self.allLineMutableArray)
    {
        bezierPath.lineCapStyle=kCGLineCapRound;
        bezierPath.lineJoinStyle=kCGLineJoinRound;
        bezierPath.lineWidth = 3 ;// 设置画笔线条粗细
        [bezierPath stroke] ; // 划线
    }
}
    

@end
