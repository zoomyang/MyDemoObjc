//
//  DHManager.h
//  DHT1
//
//  Created by 杨剑 on 15-8-7.
//  Copyright (c) 2015年 zdksii. All rights reserved.
//

#import <Foundation/Foundation.h>

#define wb_blockEncrypt(a) [[DHManager shareDHManager] blockEncrypt:a withKey:nil]
#define wb_blockDecrypt(a) [[DHManager shareDHManager] blockDecrypt:a withKey:nil]

@interface DHManager : NSObject

@property(nonatomic,strong)NSData *keyData;

/**
 *  返回一个DHManager单例
 *
 *  @return DHManager单例对象
 */
+(DHManager*)shareDHManager;

/**
 *  DH 加密算法
 *
 *  @return 加密集合
 */
-(NSDictionary*)DH;

/**
 *  生成密钥
 *
 *  @param strp      p
 *  @param strg      g
 *  @param strpubkey 对方公钥
 *  @param strprikey 自己私钥
 *
 *  @return 加密用的密钥
 */
-(NSData*)pwdKeyP:(NSString*)strp g:(NSString*)strg pubkey:(NSString*)strpubkey prikey:(NSString*)strprikey;

/**
 *  对称加密
 *
 *  @param str 文本
 *  @param key 加密密匙
 *
 *  @return 加密后文本 base64加密
 */
-(NSString*)blockEncrypt:(NSString*)str withKey:(NSData*)key;

/**
 *  对称解密
 *
 *  @param str 文本
 *  @param key 加密密匙
 *
 *  @return 解密后的文本
 */
-(NSString*)blockDecrypt:(NSString*)str withKey:(NSData*)key;

/**
 *  hmac
 *
 *  @param str 要加密的值
 *  @param key base64之后的key
 *
 *  @return 加密后的数据
 */
-(NSString*)hmac:(NSString*)str key:(NSString*)key;


///Rsa 解码
-(NSString*)rsaEncrypt:(NSString*)str;

@end
@interface NSString (base64_DH)
/**
 *  Base64加密
 *
 *  @param str 要编码的字符串
 *
 *  @return base64字符的data数据
 */
-(NSData*)dh_base64Encode_StringToData;
/**
 *  Base64加密
 *
 *  @param str 要编码的字符串
 *
 *  @return base64字符串
 */
-(NSString*)dh_base64Encode_StringTobase64Code;

/**
 *  base64解码
 *
 *  @param base64Code 要解码的字符串
 *
 *  @return 解码后的data数据
 */
-(NSData*)dh_base64Decode_base64CodeToData;

/**
 *  base64解码
 *
 *  @param base64code 要解码的字符串
 *
 *  @return 解码后的字符串
 */
-(NSString*)dh_base64Decode_base64codeToString;
@end
@interface NSData (base64_DH)

/**
 *  Base64加密
 *
 *  @param data 要编码的data数据
 *
 *  @return base64字符的data数据
 */
-(NSData*)dh_base64Encode_DataToData;

/**
 *  Base64加密
 *
 *  @param data 要编码的data数据
 *
 *  @return base64字符串
 */
-(NSString*)dh_base64Encode_DataTobase64Code;




/**
 *  base64解码
 *
 *  @return 解码后的data数据
 */
-(NSData*)dh_base64Decode_base64DataToData;
/**
 *  base64解码
 *
 *  @param base64Data 要解码的data数据
 *
 *  @return 解码后的字符串
 */
-(NSString*)dh_base64Decode_base64DataToString;

@end
