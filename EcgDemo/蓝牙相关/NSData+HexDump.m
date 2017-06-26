//
//  NSData+hex.m
//  DarkBlue
//
//  Created by chenee on 14-3-27.
//  Copyright (c) 2014年 chenee. All rights reserved.
//

#import "NSData+HexDump.h"

@implementation NSData (HexDump)

- (NSString *)hexval
{
    NSMutableString *hex = [NSMutableString string];
    unsigned char *bytes = (unsigned char *)[self bytes];
    char temp[3];
    int i = 0;
    
    for (i = 0; i < [self length]; i++) {
        temp[0] = temp[1] = temp[2] = 0;
        (void)sprintf(temp, "%02x", bytes[i]);
        [hex appendString:[NSString stringWithUTF8String:temp]];
    }
    
    
    
    return hex;
}


-(NSString *)backString
{
    Byte *bytes = (Byte *)[self bytes];
    NSString *hexStr = @"";
    for (int i = 0; i < [self length]; i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if ([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    
    return hexStr;
    
}

-(NSMutableArray *)byteToShort
{
    Byte *bytes = (Byte *)[self bytes];
    
    
    NSMutableArray *shortArray = [[NSMutableArray alloc]initWithCapacity:self.length];
    
    for (int i = 0; i<self.length/2; i++) {
        
        NSString *shortString  = [NSString stringWithFormat:@"%d",(short)(((bytes [i*2+1] & 0xff) << 8) | (bytes [1*2] & 0xff))];
//        NSLog(@"shortString :  %@",shortString);
        [shortArray addObject:shortString];
        
    }
    
    
    
    return shortArray;
}

-(NSMutableString *)transform:(NSString *)string{
    NSMutableString *newStr = [NSMutableString string];
    NSInteger length = string.length;
    for (int i = 0; i < length / 2; i++) {
        NSString *str1 = [string substringWithRange:NSMakeRange(length - (i+1) * 2 , 2)];
        
        [newStr insertString:str1 atIndex:i * 2];
    }
    return newStr;
}

- (NSString *)hexdump
{
    NSMutableString *ret=[NSMutableString stringWithCapacity:[self length]*2];
    /* dumps size bytes of *data to string. Looks like:
     * [0000] 75 6E 6B 6E 6F 77 6E 20
     *                  30 FF 00 00 00 00 39 00 unknown 0.....9.
     * (in a single line of course)
     */
    unsigned int size= (int)[self length];
    const unsigned char *p = [self bytes];
    unsigned char c;
    int n;
    char bytestr[4] = {0};
    char addrstr[10] = {0};
    char hexstr[ 16*3 + 5] = {0};
    char charstr[16*1 + 5] = {0};
    for(n=1;n<=size;n++) {
        if (n%16 == 1) {
            /* store address for this line */
            snprintf(addrstr, sizeof(addrstr), "%.4x",
                     (unsigned int)((long)p-(long)self) );
        }
        
        c = *p;
        if (isalnum(c) == 0) {
            c = '.';
        }
        
        /* store hex str (for left side) */
        snprintf(bytestr, sizeof(bytestr), "%02X ", *p);
        strncat(hexstr, bytestr, sizeof(hexstr)-strlen(hexstr)-1);
        
        /* store char str (for right side) */
        snprintf(bytestr, sizeof(bytestr), "%c", c);
        strncat(charstr, bytestr, sizeof(charstr)-strlen(charstr)-1);
        
        if(n%16 == 0) {
            /* line completed */
            //printf("[%4.4s]   %-50.50s  %s\n", addrstr, hexstr, charstr);
            [ret appendString:[NSString stringWithFormat:@"[%4.4s]   %-50.50s  %s\n",
                               addrstr, hexstr, charstr]];
            hexstr[0] = 0;
            charstr[0] = 0;
        } else if(n%8 == 0) {
            /* half line: add whitespaces */
            strncat(hexstr, "  ", sizeof(hexstr)-strlen(hexstr)-1);
            strncat(charstr, " ", sizeof(charstr)-strlen(charstr)-1);
        }
        p++; /* next byte */
    }
    
    if (strlen(hexstr) > 0) {
        /* print rest of buffer if not empty */
        //printf("[%4.4s]   %-50.50s  %s\n", addrstr, hexstr, charstr);
        [ret appendString:[NSString stringWithFormat:@"[%4.4s]   %-50.50s  %s\n",
                           addrstr, hexstr, charstr]];
    }
    return ret;
}





@end
