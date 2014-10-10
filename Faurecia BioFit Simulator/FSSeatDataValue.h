
//  Faurecia BioFit Simulator
//  Copyright (c) 2014 Faurecia. All rights reserved.

#import <Foundation/Foundation.h>

@interface FSSeatDataValue : NSObject

+ (NSData *)pack_int8:(int8_t)v;
+ (NSData *)pack_uint8:(uint8_t)v;
+ (NSData *)pack_int16:(int16_t)v;
+ (NSData *)pack_uint32:(uint32_t)v;

+ (NSData *)pack_group:(NSArray *)ds time:(uint32_t)t;

+ (int8_t)unpack_int8:(NSData *)d;
+ (uint8_t)unpack_uint8:(NSData *)d;
+ (int16_t)unpack_int16:(NSData *)d;
+ (uint32_t)unpack_uint32:(NSData *)d;

+ (NSArray *)unpack_group:(NSData *)g size:(NSArray *)s time:(uint32_t *)t;

@end
