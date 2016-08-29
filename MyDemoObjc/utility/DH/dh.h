#pragma once

// Including SDKDDKVer.h defines the highest available Windows platform.

// If you wish to build your application for a previous Windows platform, include WinSDKVer.h and
// set the _WIN32_WINNT macro to the platform you wish to support before including SDKDDKVer.h.
#include <string>
//using namespace std;


#if defined (_WIN32_WINNT) || defined(_WINDOWS)|| defined(WIN32)
#ifdef DH_EXPORTS
#define DH_API __declspec (dllexport)
#else
#define DH_API __declspec (dllimport)
#endif
#else
#define DH_API
#endif
#ifdef __cplusplus
extern "C" {
#endif
    //首次生成DH
    DH_API int genDH(
                     std::string &p,//输出参数 p
                     std::string &g,//输出参数 g
                     std::string &pubkey,//输出参数 公钥
                     std::string &prikey,//输出参数 私钥
                     int keylen //输入参数 密钥长度
    );
    //根据p，g生成DH
    DH_API int genDHWithPG(
                           std::string &p,//输入参数 p
                           std::string &g,//输入参数 g
                           std::string &pubkey,//输出参数 公钥
                           std::string &prikey,//输出参数 私钥
                           int keylen//输入参数 密钥长度
    );
    //计算密钥
    DH_API int computeKey(
                          unsigned char*sharekey,//输出参数 密钥
                          int* sharekeysize, //输入输出参数 密钥长度
                           std::string&p,//输入参数 p
                           std::string &g,//输入参数 g
                           std::string &pubkey,//输入参数 对方公钥
                           std::string &prikey//输入参数 自己私钥
    );
    //生成RSA
    DH_API int genRSA(
                      unsigned char* rsa, //输出参数 加密后的RSA数据
                      int *rsalen,  //输入输出参数 RSA数据长度
                      int bits,//输入参数 RSA长度
                      char* pwd//输入参数 保护密码
    );
    //对称加密
    DH_API int blockEncrypt(
                            unsigned char* out,//输出参数 加密后的密文数据
                            unsigned int* outlen,//输入输出参数 密文长度
                            unsigned char* in,//输入参数 明文
                            unsigned int inlen,//输入参数 明文长度
                            unsigned char* key,//输入参数 密钥
                            unsigned int keylen,//输入参数 密钥长度
                            unsigned char* iv,//输入参数 初始值
                            unsigned int ivlen//输入参数 初始值长度
    );
    //对称解密
    DH_API int blockDecrypt(
                            unsigned char* out,//输出参数 加密后的密文数据
                            unsigned int* outlen,//输入输出参数 密文长度
                            unsigned char* in,//输入参数 明文
                            unsigned int inlen,//输入参数 明文长度
                            unsigned char* key,//输入参数 密钥
                            unsigned int keylen,//输入参数 密钥长度
                            unsigned char* iv,//输入参数 初始值
                            unsigned int ivlen//输入参数 初始值长度
    );
    
    //HMAC
    unsigned char * hmacl( const void *key,//密钥
                           int key_len,//密钥长度
                           const unsigned char *d,//输入要加密的数据
                           int n,//上面的长度
                           unsigned char *md,//输出结果
                           unsigned int *md_len//上面的长度
                          );
    
    int base64Decode(unsigned char* d,//输入
                     unsigned char* out,//输出
                     int len //输入长度
    );
    
    int base64Encode(unsigned char*out,//输出
                     unsigned char* in,//输入
                     int inl//输入长度
    );
    
    
    
    
    //RSA 加密
    char *rsa_encrypt(char *str,char *path_key);
    //RSA 解密
    char *rsa_decrypt(char *str,char *path_key);
    
    
    
#ifdef __cplusplus
}
#endif