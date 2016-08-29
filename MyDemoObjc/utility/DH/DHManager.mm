//
//  DHManager.m
//  DHT1
//
//  Created by 杨剑 on 15-8-7.
//  Copyright (c) 2015年 zdksii. All rights reserved.
//

#import "DHManager.h"

#include <openssl/evp.h>
#include <openssl/hmac.h>
#include <openssl/dh.h>
#include <openssl/bn.h>
#include <openssl/err.h>
#include <openssl/rsa.h>
#include <openssl/sha.h>
#include <openssl/pem.h>

#include <string>
#include "string.h"
#include "dh.h"

#import "GTMBase64.h"

//using namespace std;

static DHManager *dhmanager_;

@implementation DHManager


+(DHManager *)shareDHManager
{
    if (dhmanager_==nil) {
        dhmanager_=[[DHManager alloc] init];
    }
    return dhmanager_;
}

/**
 *  DH 加密算法
 *
 *  @return 加密集合
 */
-(NSDictionary*)DH
{
    int keylen = 512;
     std::string p,g,pubkey,prikey;
    
    p="F1FE5FC1044041C561AC5754D0A3BEB86469A338732AB68F93BFA22CDE4BB289CC1116731108BC31F15F9AEAE4F73A052952C94A38B091CFC1CA58A799657F7B";
    g="05";
    genDHWithPG(p,g,pubkey,prikey,keylen);
    
    NSString *strpubkey = [NSString stringWithUTF8String:pubkey.c_str()];
    NSString *strP = [NSString stringWithUTF8String:p.c_str()];
    NSString *strG = [NSString stringWithUTF8String:g.c_str()];
    NSString *strprikey = [NSString stringWithUTF8String:prikey.c_str()];
    NSNumber *nkeylen=[NSNumber numberWithInt:keylen];
    
    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:
                       strpubkey,@"pubkey",
                       strP,@"p",
                       strG,@"g",
                       strprikey,@"prikey",
                       nkeylen,@"keylen",nil];
   return dic;
    
}

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
-(NSData*)pwdKeyP:(NSString*)strp g:(NSString*)strg pubkey:(NSString*)strpubkey prikey:(NSString*)strprikey
{
//    unsigned char out1[1024]={0};
    unsigned char skey[512]={0};
    
    int outl = 512;
    
     std::string p=[strp UTF8String];
     std::string g=[strg UTF8String];
     std::string pubkey=[strpubkey UTF8String];
     std::string prikey=[strprikey UTF8String];
    
    computeKey(skey,&outl,p,g,pubkey,prikey);
//    printf("outl:%d\n",outl);
//    EVP_EncodeBlock(out1,skey,outl);
//    NSString *key = [[NSString alloc] initWithCString:(const char*)out1 encoding:NSUTF8StringEncoding];
    _keyData = [NSData dataWithBytes:skey length:outl];
    return _keyData;
}

/**
 *  对称加密
 *
 *  @param str 文本
 *  @param key 加密密匙
 *
 *  @return 加密后文本 base64加密
 */
-(NSString*)blockEncrypt:(NSString*)str withKey:(NSData*)key
{
    if (key==nil) {
        key=_keyData;
    }
    
    if (str==nil) {
        NSLog(@"----对称加密内容为空");
        return nil;
    }
    
    //将字符串明码转换成为char
    const char *mw=[str cStringUsingEncoding:NSUTF8StringEncoding];
    int mwl=(int)strlen(mw);
    //初始化密码buf
    unsigned char *outMi=new unsigned char[mwl+500];
    unsigned int outl = sizeof(outMi);
    
    //将字符串转换成为char
//    const char *k=[key cStringUsingEncoding:NSUTF8StringEncoding];
    
    const char *iv="abcdefghijklmnop";
    
    
//    NSLog(@"%@",str);
//    NSLog(@"%@",key);
    
    
    blockEncrypt(outMi, &outl,(unsigned char*)mw, mwl+1, (unsigned char*)[key bytes],(int)[key length] ,(unsigned char*)iv , 16);
//    printf("%s",outMi);
    NSData *data = [NSData dataWithBytes:outMi length:outl];
//    NSString *base= [data base64EncodedString];
    
     NSString *base= [data dh_base64Encode_DataTobase64Code];
    
    delete [] outMi;
    base=[base stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    base=[base stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    return base;
    
}

/**
 *  对称解密
 *
 *  @param str 文本
 *  @param key 加密密匙
 *
 *  @return 解密后的文本
 */
-(NSString*)blockDecrypt:(NSString*)str withKey:(NSData*)key
{
    if (key==nil) {
        key=_keyData;
    }
    //将bese64密码转换为Data
//    NSData *miwenData=[NSData dataFromBase64String:str];
//    str=[str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//    NSData *data=[str utf8];
//    NSData *miwenData=[GTMBase64 decodeData:data ];
    NSData *miwenData= [GTMBase64 decodeString:str  ];
    //密码长度
    int miwenl =(int) [miwenData length];
    //将密码转换为char
    unsigned char *miwen=(unsigned char*)[miwenData bytes];

    
    //初始化明码buf
    unsigned char *outMing=new unsigned char[miwenl];
    unsigned int outl = miwenl;
    
    
    const char *iv="abcdefghijklmnop";
    blockDecrypt(outMing, &outl,miwen, miwenl,(unsigned char*)[key bytes],(int)[key length] , (unsigned char*)iv , 16);
    outMing[outl]='\0';
//    printf("%s",outMing);
    NSString *strMingMa = [[NSString alloc] initWithCString:(const char*)outMing encoding:NSUTF8StringEncoding];
    if (strMingMa==nil) {
        NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        strMingMa = [[NSString alloc] initWithData:[NSData dataWithBytes:outMing length:outl] encoding:gbkEncoding];
    }
    
//    NSLog(@"%@",strMingMa);
    delete [] outMing;
    
    return strMingMa;
}
/**
 *  hmac
 *
 *  @param str 要加密的值
 *  @param key base64之后的key
 *
 *  @return 加密后的数据
 */
-(NSString*)hmac:(NSString*)str key:(NSString*)key
{
    NSLog(@"key ====|%@",key);
    NSData  *nskey =  [key dh_base64Decode_base64CodeToData];
    const unsigned char *keyl=(const unsigned char*)[nskey bytes];
    const unsigned char *d=(const unsigned char*)[str UTF8String];
    
    unsigned char outmi[128]={0};
    unsigned int outmil=128;
    hmacl(keyl, (int)[nskey length], d, (int)[str length], outmi, &outmil);
    
    
    
//    printf("\n\n%s",outmi);
    
    NSData *data = [NSData dataWithBytes:outmi length:outmil];
    NSString *base= [data dh_base64Encode_DataTobase64Code];
    
//    NSLog(@"base64 =====|%@",base);
    //delete [] outmi;
//    base=[base stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
//        base=[base stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    return base;
}




-(NSString*)rsaEncrypt:(NSString*)str
{
    NSString *pubkey = [[NSBundle mainBundle] pathForResource:@"pubkey" ofType:@"pem"];
    const char *a=[str cStringUsingEncoding:NSUTF8StringEncoding];
    const char *b=[pubkey cStringUsingEncoding:NSUTF8StringEncoding];
    char *o = rsa_encrypt((char*)a, (char*)b);

    
    
    NSString *strOut =  [GTMBase64 stringByEncodingBytes:o length:128];
    NSLog(@"=============%@",strOut);
//    strOut= @"J02dYCabEmi7fu3ZbgubYen7xf0enQ3yHDFC1cK/VQU6LxJ6AnAtqwIT5GNjDgNz3BZdjRlw7/fI+m2g0rllrDyPyOVguoQRKvmrXyMnlZw3x5lAYhRE6WhM3YH6NgvIcyliO+POJUuxEsiEI0wL78QHoEjB4wpPCCgUYM6/IHs=";
    
//    NSString *ppp = [[NSBundle mainBundle] pathForResource:@"private_key" ofType:@"pem"];
//    const void *aa=[[GTMBase64 decodeString:strOut] bytes];
//    const char *bb=[ppp cStringUsingEncoding:NSUTF8StringEncoding];
//    char *oo = rsa_decrypt((char*)aa, (char*)bb);
//    NSString *aaaaaa =[[NSString alloc] initWithBytes:oo length:strlen(oo) encoding:NSUTF8StringEncoding];
//    NSLog(@"===========%@",aaaaaa);
    return strOut;
}



-(SecKeyRef)getPublicKey{
    NSString *certPath = [[NSBundle mainBundle] pathForResource:@"keystore" ofType:@"p7b"];
    SecCertificateRef myCertificate = nil;
    NSData *certificateData = [[NSData alloc] initWithContentsOfFile:certPath];
    myCertificate = SecCertificateCreateWithData(kCFAllocatorDefault, (CFDataRef)certificateData);
    SecPolicyRef myPolicy = SecPolicyCreateBasicX509();
    SecTrustRef myTrust;
    OSStatus status = SecTrustCreateWithCertificates(myCertificate,myPolicy,&myTrust);
    SecTrustResultType trustResult;
    if (status == noErr) {
        status = SecTrustEvaluate(myTrust, &trustResult);
    }
    return SecTrustCopyPublicKey(myTrust);
}


-(NSString *)RSAEncrypotoTheData:(NSString *)plainText
{
    
    SecKeyRef publicKey=nil;
    publicKey=[self getPublicKey];
    size_t cipherBufferSize = SecKeyGetBlockSize(publicKey);
    uint8_t *cipherBuffer = NULL;
    
    cipherBuffer = (uint8_t *)malloc(cipherBufferSize * sizeof(uint8_t));
    memset((void *)cipherBuffer, 0*0, cipherBufferSize);
    
    NSData *plainTextBytes = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    int blockSize = (int)cipherBufferSize-11;  // 这个地方比较重要是加密问组长度
    int numBlock = (int)ceil([plainTextBytes length] / (double)blockSize);
    NSMutableData *encryptedData = [[NSMutableData alloc] init];
    for (int i=0; i<numBlock; i++) {
        int bufferSize =(int) MIN(blockSize,[plainTextBytes length]-i*blockSize);
        NSData *buffer = [plainTextBytes subdataWithRange:NSMakeRange(i * blockSize, bufferSize)];
        OSStatus status = SecKeyEncrypt(publicKey,
                                        kSecPaddingPKCS1,
                                        (const uint8_t *)[buffer bytes],
                                        [buffer length],
                                        cipherBuffer,
                                        &cipherBufferSize);
        if (status == noErr)
        {
            NSData *encryptedBytes = [[NSData alloc]
                                       initWithBytes:(const void *)cipherBuffer
                                       length:cipherBufferSize];
            [encryptedData appendData:encryptedBytes];
        }
        else
        {
            return nil;
        }
    }
    if (cipherBuffer)
    {
        free(cipherBuffer);
    }
    NSString *encrypotoResult=[NSString stringWithFormat:@"%@",[GTMBase64 stringByEncodingData:encryptedData]];
    return encrypotoResult;
}


//base64编码

@end
@implementation NSString (base64_DH)

-(NSData*)dh_base64Encode_StringToData
{
    NSData *data=[self dataUsingEncoding:NSUTF8StringEncoding];
    data=[GTMBase64 encodeData:data];
    
    return data;
}

-(NSString*)dh_base64Encode_StringTobase64Code
{
    NSData *data=[self dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data1=[GTMBase64 encodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
    return base64String;
}

//base64解码

-(NSData*)dh_base64Decode_base64CodeToData
{
    NSData *data=[self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    return [GTMBase64 decodeData:data];
}

-(NSString*)dh_base64Decode_base64codeToString
{
    NSData *base64Data=[self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSData *data=[GTMBase64 decodeData:base64Data];
    
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return base64String;
}

@end

@implementation NSData (base64_DH)

-(NSData*)dh_base64Encode_DataToData
{
    return [GTMBase64 encodeData:self];
}

-(NSString*)dh_base64Encode_DataTobase64Code
{
    NSData *data1=[GTMBase64 encodeData:self];
    NSString *base64String = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
    return base64String;
}


-(NSData*)dh_base64Decode_base64DataToData
{
    NSData *data=[GTMBase64 decodeData:self];
    
    return data;
}

-(NSString*)dh_base64Decode_base64DataToString
{
    NSData *data=[GTMBase64 decodeData:self];
    
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return base64String;
}



@end
