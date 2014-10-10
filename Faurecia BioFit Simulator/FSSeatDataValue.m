
//  Faurecia BioFit Simulator
//  Copyright (c) 2014 Faurecia. All rights reserved.

#import "FSSeatDataValue.h"

@implementation FSSeatDataValue

+ (NSData *)pack_int8:(int8_t)v {
    return [[NSData alloc] initWithBytes:&v length:sizeof(v)];
}

+ (NSData *)pack_uint8:(uint8_t)v {
    return [[NSData alloc] initWithBytes:&v length:sizeof(v)];
}

+ (NSData *)pack_int16:(int16_t)v {
    v = CFSwapInt16HostToLittle(v);
    return [[NSData alloc] initWithBytes:&v length:sizeof(v)];
}

+ (NSData *)pack_uint32:(uint32_t)v {
    v = CFSwapInt32HostToLittle(v);
    return [[NSData alloc] initWithBytes:&v length:sizeof(v)];
}

+ (NSData *)pack_group:(NSArray *)ds time:(uint32_t)t {
    NSMutableData *g = nil;
    if (ds) {
        size_t size = sizeof(t);
        for (NSData *d in ds) {
            size += d.length;
        }

        g = [NSMutableData dataWithCapacity:size];

        t = CFSwapInt32HostToLittle(t);
        [g appendBytes:&t length:sizeof(t)];

        for (NSData *d in ds) {
            [g appendData:d];
        }
    }
    return g;
}

+ (int8_t)unpack_int8:(NSData *)d {
    int8_t n = 0;
    if (d.length >= sizeof(n)) {
        memcpy(&n, d.bytes, sizeof(n));
    }
    return n;
}

+ (uint8_t)unpack_uint8:(NSData *)d {
    uint8_t n = 0;
    if (d.length >= sizeof(n)) {
        memcpy(&n, d.bytes, sizeof(n));
    }
    return n;
}

+ (int16_t)unpack_int16:(NSData *)d {
    int16_t n = 0;
    if (d.length >= sizeof(n)) {
        memcpy(&n, d.bytes, sizeof(n));
    }
    return CFSwapInt16LittleToHost(n);
}

+ (uint32_t)unpack_uint32:(NSData *)d {
    uint32_t n = 0;
    if (d.length >= sizeof(n)) {
        memcpy(&n, d.bytes, sizeof(n));
    }
    return CFSwapInt32LittleToHost(n);
}

+ (NSArray *)unpack_group:(NSData *)g size:(NSArray *)s time:(uint32_t *)t {
    NSMutableArray *ds = [NSMutableArray arrayWithCapacity:s.count];
    *t = 0;
    if (g.length >= sizeof(*t)) {
        uint8_t *g_bytes = (uint8_t *)g.bytes;

        memcpy(t, g_bytes, sizeof(*t));
        *t = CFSwapInt32LittleToHost(*t);

        size_t offset = sizeof(*t);
        size_t i = 0;

        while (offset < g.length && i < s.count) {
            size_t size = [s[i] integerValue];
            [ds addObject:[NSData dataWithBytes:(g_bytes + offset) length:size]];
            offset += size;
            ++i;
        }
    }
    return ds;
}

@end
