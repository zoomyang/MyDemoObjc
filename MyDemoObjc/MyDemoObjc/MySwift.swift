//
//  MySwift.swift
//  MyDemoObjc
//
//  Created by 杨剑 on 16/9/6.
//  Copyright © 2016年 zdksii. All rights reserved.
//

import UIKit

class MySwift: NSObject {
    
    
    
    func myFunc(str:String , add: (i:Int ,j:Int)->Int ) -> Int {
        print(str);
        return add(i: 1,j: 2);
    }
    
    func myFunc2(str:String ,b:(i:Int,s:String)) ->(Int,Int){
        print("myFUnc2");
        return (10,20)
    }
    
    func test() {
        let result:Int = myFunc("张三") {
            return $0+$1;
        }
        //等价于上面的方法
        myFunc("王武") { (i, j) -> Int in
            return i+j;
        }
        
        print(result);
        
    }
}
