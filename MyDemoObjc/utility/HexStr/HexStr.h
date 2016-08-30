//
//  HexStr.h
//  MyDemoObjc
//
//  Created by Yang Jian on 16/8/30.
//  Copyright © 2016年 zdksii. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HexStr : NSObject
/**
 *  十六进制的字符串转换成为NSData
 *
 *  @param strHex 十六进制的字符串
 *
 *  @return 十六进制的NSData
 */
-(NSData*)StrHexToByte:(NSString*)strHex;

/**
 *  将NSData转换成十六进制的字符串
 *
 *  @param data NSData
 *
 *  @return 十六进制的字符串
 */
- (NSString *)convertDataToHexStr:(NSData *)data;
/**
 *  普通字符串转换为十六进制的
 *
 *  @param byteData byteData
 *  @param Datalen  byteData的长度
 *
 *  @return 为十六进制的字符串
 */
-(NSString *)hexBytToString:(unsigned char *)byteData datalen:(int)Datalen;
/**
 *  十六进制转换为普通字符串的
 *
 *  @param hexString 十六进制
 *
 *  @return 普通字符串
 */
-(NSString *)stringFromHexString:(NSString *)hexString;
@end
