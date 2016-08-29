// dllmain.cpp : Defines the entry point for the DLL application.
#include <openssl/evp.h>
#include <openssl/hmac.h>
#include <openssl/dh.h>
#include <openssl/bn.h>
#include <openssl/err.h>
#include <openssl/rsa.h>
#include <openssl/sha.h>
#include <openssl/pem.h>
#include <openssl/hmac.h>
#include <string>
#include <iostream>
#include "dh.h"
using namespace std;


extern"C"{
    
    size_t fwrite$UNIX2003( const void *a, size_t b, size_t c, FILE *d )
    
    {
        
        return fwrite(a, b, c, d);
        
    }
    
    char* strerror$UNIX2003( int errnum )
    
    {
        
        return strerror(errnum);
        
    }
    
}

#if defined (_WIN32_WINNT) || defined(_WINDOWS)|| defined(WIN32)
#include <Windows.h>
BOOL APIENTRY DllMain( HMODULE hModule,
	DWORD  ul_reason_for_call,
	LPVOID lpReserved
	)
{
	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
	case DLL_THREAD_ATTACH:
	case DLL_THREAD_DETACH:
	case DLL_PROCESS_DETACH:
		break;
	}
	return TRUE;
}
#else
void __attribute__ ((constructor)) my_init(void)
{

}
void __attribute__ ((destructor)) my_fini(void)
{

}
#endif


#ifdef __cplusplus
extern "C" {
#endif

int bn2string(string &str,BIGNUM *bn)
{
	int ret = 0;
	char* out = BN_bn2hex(bn);
	if(NULL!=out)
	{
		str.assign(out);
	}else{
		ret = (int)ERR_get_error();
	}

	return ret;
}
int string2bn(string &str,BIGNUM **bn)
{
	int ret = 0;
	ret=BN_hex2bn(bn,str.c_str());
	return ret==0?(int)ERR_get_error():0;
}


int bn2bin(unsigned char* bin,int *binlen,BIGNUM *bn)
{
	int ret = 0;

	int len=BN_num_bytes(bn);
	if(bin==NULL)
	{
		*binlen = len;
		return 0;
	}
	if(*binlen<len)
	{
		cout<<"binlen error!"<<endl;
		return -2;
	}

	*binlen=BN_bn2bin(bn,bin);

	return ret;
}

int genDH(string&p,string &g,string &pubkey,string &prikey,int keylen)
{
	DH   *d1;
	/* 构造DH数据结构 */
	d1=DH_new();
	int  ret,i;
	/* 生成d1的密钥参数，该密钥参数是可以公开的 */
	ret=DH_generate_parameters_ex(d1,keylen,DH_GENERATOR_5,NULL);
	if(ret!=1)
	{
		cout<<"DH_generate_parameters_ex err!\n";
		return (int)ERR_get_error();
	}

	/* 检查密钥参数 */
	ret=DH_check(d1,&i);
	if(ret!=1)
	{
		if(i&DH_CHECK_P_NOT_PRIME)
			cout<<"p value is not prime\n";
		if(i&DH_CHECK_P_NOT_SAFE_PRIME)
			cout<<"p value is not a safe prime\n";
		if (i&DH_UNABLE_TO_CHECK_GENERATOR)
			cout<<"unable to check the generator value\n";
		if (i&DH_NOT_SUITABLE_GENERATOR)
			cout<<"the g value is not a generator\n";
		DH_free(d1);
		return (int)ERR_get_error();
	}

	/* 生成公私钥 */
	ret=DH_generate_key(d1);
	if(ret!=1)
	{
		cout<<"DH_generate_key err!\n";
		DH_free(d1);
		return (int)ERR_get_error();
	}
	/*获取生成结果*/
	bn2string(p,d1->p);
	bn2string(g,d1->g);
	bn2string(pubkey,d1->pub_key);
	bn2string(prikey,d1->priv_key);

	DH_free(d1);
	return 0;
}

int genDHWithPG(string&p,string &g,string &pubkey,string &prikey,int keylen)
{
	DH   *d1;
	/* 构造DH数据结构 */
	d1=DH_new();
	int  ret,i;
	/* 生成d1的密钥参数，该密钥参数是可以公开的 */
	string2bn(p,&d1->p);
	string2bn(g,&d1->g);

	/* 检查密钥参数 */
	ret=DH_check(d1,&i);
	if(ret!=1)
	{
		if(i&DH_CHECK_P_NOT_PRIME)
			cout<<"p value is not prime\n";
		if(i&DH_CHECK_P_NOT_SAFE_PRIME)
			cout<<"p value is not a safe prime\n";
		if (i&DH_UNABLE_TO_CHECK_GENERATOR)
			cout<<"unable to check the generator value\n";
		if (i&DH_NOT_SUITABLE_GENERATOR)
			cout<<"the g value is not a generator\n";
		DH_free(d1);
		return (int)ERR_get_error();
	}

	/* 生成公私钥 */
	ret=DH_generate_key(d1);
	if(ret!=1)
	{
		cout<<"DH_generate_key err!\n";
		DH_free(d1);
		return (int)ERR_get_error();
	}
	/*获取生成结果*/
	bn2string(pubkey,d1->pub_key);
	bn2string(prikey,d1->priv_key);

	DH_free(d1);
	return 0;
}

int computeKey(unsigned char*sharekey,int* sharekeysize, string&p,string &g,string &pubkey,string &prikey)
{
    
    int ret =0,len;
    DH* d2=DH_new();
    /* p和g为公开的密钥参数，因此可以拷贝 */
    string2bn(p,&d2->p);
    string2bn(g,&d2->g);
    string2bn(prikey,&d2->priv_key);
    if(sharekey==NULL)
    {
        * sharekeysize = DH_size(d2);
        DH_free(d2);
        return 0;
    }
    BIGNUM *pub_bn = BN_new();
    string2bn(pubkey,&pub_bn);
    
    /* 计算共享密钥 */
    len=DH_compute_key(sharekey,pub_bn,d2);
    if(* sharekeysize < len)
    {
        cout<<"genarate key error!"<<*sharekeysize<<"!="<<len<<endl;
        ret = -1;
    }
    * sharekeysize = len;
    
    BN_free(pub_bn);
    DH_free(d2);
    
    return ret;
}
int genRSA(unsigned char* rsa,int *rsalen, int bits,char* pwd)
{
    RSA     *r;
    int ret = 0,len;
    unsigned int  e=RSA_F4;
    BIGNUM   *bne;
    BIO      *b;
    EVP_PKEY *pkey;
    
    //公钥指数e
    bne=BN_new();
    ret=BN_set_word(bne,e);
    
    r=RSA_new();
    ret=RSA_generate_key_ex(r,bits,bne,NULL);
    
    if(ret!=1)
    {
        cout<<"RSA_generate_key_ex err!\n";
        RSA_free(r);
        return (int)ERR_get_error();
    }
    
    
    pkey=EVP_PKEY_new();
    EVP_PKEY_assign_RSA(pkey,r);
    
    b=BIO_new(BIO_s_mem());
    if (!PEM_write_bio_PrivateKey(b, pkey, EVP_aes_256_cbc(), NULL, 0, 0, pwd))
    {
        RSA_free(r);
        EVP_PKEY_free(pkey);
        
        return (int)ERR_get_error();
    }
    len=(int)BIO_ctrl_pending(b);
    if(*rsalen>=len)
    {
        len=BIO_read(b,rsa,len);
    }
    *rsalen = len;
    BIO_free(b);
    
    return 0;
}
    
    //对称加密
DH_API int blockEncrypt(
                        unsigned char* out,
                        unsigned int* outlen,
                        unsigned char* in,
                        unsigned int inlen,
                        unsigned char* key,
                        unsigned int keylen,
                        unsigned char* iv,
                        unsigned int ivlen
                        )
{
    int    ret,total=0,outl=0;
    EVP_CIPHER_CTX     ctx;
    const EVP_CIPHER   *cipher;
    cipher=EVP_aes_128_cbc();
    
    if(EVP_CIPHER_key_length(cipher)>keylen||EVP_CIPHER_iv_length(cipher)>ivlen)
    {
        return -1;
    }
    
    EVP_CIPHER_CTX_init(&ctx);
    ret=EVP_EncryptInit_ex(&ctx,cipher,NULL,key,iv);
    
    if(ret!=1)
    {
        return -1;
    }
    outl = *outlen;
    EVP_EncryptUpdate(&ctx,out,&outl,in,inlen);
    total = outl;
    outl = *outlen - total;
    EVP_EncryptFinal_ex(&ctx,out+total,&outl);
    total += outl;
    *outlen = total;
    
    EVP_CIPHER_CTX_cleanup(&ctx);
    
    return 0;
}
//对称解密
DH_API int blockDecrypt(
                        unsigned char* out,
                        unsigned int* outlen,
                        unsigned char* in,
                        unsigned int inlen,
                        unsigned char* key,
                        unsigned int keylen,
                        unsigned char* iv,
                        unsigned int ivlen
                        )
{
    int    ret,total=0,outl=0;
    EVP_CIPHER_CTX     ctx;
    const EVP_CIPHER   *cipher;
    cipher=EVP_aes_128_cbc();
    if(EVP_CIPHER_key_length(cipher)>keylen||EVP_CIPHER_iv_length(cipher)>ivlen)
    {
        return -1;
    }
    
    EVP_CIPHER_CTX_init(&ctx);
    ret=EVP_DecryptInit_ex(&ctx,cipher,NULL,key,iv);
    
    if(ret!=1)
    {
        return -1;
    }
    outl = *outlen;
    EVP_DecryptUpdate(&ctx,out,&outl,in,inlen);
    total = outl;
    outl = *outlen - total;
    EVP_DecryptFinal_ex(&ctx,out+total,&outl);
    total += outl;
    *outlen = total;
    
    EVP_CIPHER_CTX_cleanup(&ctx);
    
    return 0;
}
//HMAC
unsigned char * hmacl( const void *key, int key_len, const unsigned char *d, int n, unsigned char *md,unsigned int *md_len)
{
//        const EVP_MD *evp_md = EVP_md5();
//        
//        return HMAC(evp_md,key, key_len,d, n,md,md_len);
    
    const EVP_MD* evp_md = EVP_md5();
    HMAC_CTX c;
    memset(&c,0x00,sizeof(HMAC_CTX));
    HMAC_CTX_init(&c);
    if (!HMAC_Init(&c, key, key_len, evp_md))
        return NULL;
    if (!HMAC_Update(&c, d, n))
        return NULL;
    if (!HMAC_Final(&c, md, md_len))
        return NULL;
    HMAC_CTX_cleanup(&c);
    return md;
}


int base64Decode(unsigned char* d,//输入
                 unsigned char* out,//输出
                 int len //输入长度
                 )
{
    int routlen=EVP_DecodeBlock(d,out,len);
    unsigned char *p = d+len;
    int i=0;
    for (i=0; i<4; i++) {
        if (*(p-i)!='=') {
            break;
        }
    }
    routlen-=i;
    return routlen;
}

int base64Encode(unsigned char*out,//输出
                 unsigned char* in,//输入
                 int inl//输入长度
                 )
{
    return EVP_EncodeBlock(out,in,inl);
}
    
    
    
    //RSA 加密
    char *rsa_encrypt(char *str,char *path_key){
        char *p_en;
        RSA *p_rsa;
        FILE *file;
        int flen,rsa_len;
        if((file=fopen(path_key,"r"))==NULL){
            perror("open key file error");
            return NULL;
        }
        
        if((p_rsa=PEM_read_RSA_PUBKEY(file,NULL,NULL,NULL))==NULL){
            //            if((p_rsa=PEM_read_RSAPublicKey(file,NULL,NULL,NULL))==NULL){   换成这句死活通不过，无论是否将公钥分离源文件
            ERR_print_errors_fp(stdout);
            return NULL;
        }
        flen=(int)strlen(str);
        rsa_len=RSA_size(p_rsa);
        p_en=(char *)malloc(rsa_len);
        memset(p_en,0,rsa_len+1);
        int strLen=(int)strlen(str);
        if(RSA_public_encrypt(strLen,(unsigned char *)str,(unsigned char*)p_en,p_rsa,RSA_PKCS1_PADDING)<0){
            return NULL;
        }
        RSA_free(p_rsa);
        fclose(file);
        return p_en;
    }
    //RSA 解密
    char *rsa_decrypt(char *str,char *path_key){
        char *p_de;
        RSA *p_rsa;
        FILE *file;
        int rsa_len;
        if((file=fopen(path_key,"r"))==NULL){
            perror("open key file error");
            return NULL;
        }
        if((p_rsa=PEM_read_RSAPrivateKey(file,NULL,NULL,NULL))==NULL){
            ERR_print_errors_fp(stdout);
            return NULL;
        }
        rsa_len=RSA_size(p_rsa);
        p_de=(char *)malloc(rsa_len+1);
        memset(p_de,0,rsa_len+1);
        if(RSA_private_decrypt(rsa_len,(unsigned char *)str,(unsigned char*)p_de,p_rsa,RSA_PKCS1_PADDING)<0){
            return NULL;
        }
        RSA_free(p_rsa);
        fclose(file);
        return p_de;
    }

    
#ifdef __cplusplus
}
#endif
