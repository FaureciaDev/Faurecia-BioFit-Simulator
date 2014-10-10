
//  Faurecia BioFit Simulator
//  Copyright (c) 2014 Faurecia. All rights reserved.

#import "Kiwi.h"
#import "FSSeatDataValue.h"

static NSString *as_hex(NSData *v) {
    uint8_t *v_bytes = (uint8_t *)v.bytes;
    NSMutableString *hex = [NSMutableString stringWithCapacity:2 * v.length];
    for (int i = 0; i < v.length; ++i) {
        [hex appendFormat:@"%02x", v_bytes[i]];
    }
    return hex;
}

SPEC_BEGIN(FSCharacteristicBundlingTest)

describe(@"Characteristics", ^{
    describe(@"packed individually to NSData", ^{
        describe(@"an int8 '-9' value", ^{
            let(v, ^{ return [FSSeatDataValue pack_int8:-9]; });
            it(@"uses 1 byte", ^{
                [[theValue(v.length) should] equal:theValue(1)];
            });
            it(@"has hex representation of 'f7'", ^{
                [[as_hex(v) should] equal:@"f7"];
            });
            it(@"unpacks", ^{
                int n = [FSSeatDataValue unpack_int8:v];
                [[theValue(n) should] equal:theValue(-9)];
            });
        });
        describe(@"a uint8 '100' value", ^{
            let(v, ^{ return [FSSeatDataValue pack_uint8:100]; });
            it(@"uses 1 byte", ^{
                [[theValue(v.length) should] equal:theValue(1)];
            });
            it(@"has hex representation of '64'", ^{
                [[as_hex(v) should] equal:@"64"];
            });
            it(@"unpacks", ^{
                int n = [FSSeatDataValue unpack_uint8:v];
                [[theValue(n) should] equal:theValue(100)];
            });
        });
        describe(@"an int16 '500' value", ^{
            let(v, ^{ return [FSSeatDataValue pack_int16:500]; });
            it(@"uses 2 bytes", ^{
                [[theValue(v.length) should] equal:theValue(2)];
            });
            it(@"has hex representation of 'f401'", ^{
                [[as_hex(v) should] equal:@"f401"];
            });
            it(@"unpacks", ^{
                int n = [FSSeatDataValue unpack_int16:v];
                [[theValue(n) should] equal:theValue(500)];
            });
        });
        describe(@"a uint32 '100000' value", ^{
            let(v, ^{ return [FSSeatDataValue pack_uint32:100000]; });
            it(@"uses 4 bytes", ^{
                [[theValue(v.length) should] equal:theValue(4)];
            });
            it(@"has hex representation of '000186a0'", ^{
                [[as_hex(v) should] equal:@"a0860100"];
            });
            it(@"unpacks", ^{
                int n = [FSSeatDataValue unpack_uint32:v];
                [[theValue(n) should] equal:theValue(100000)];
            });
        });
    });

    describe(@"packed in groups to NSData", ^{
        it(@"has a time stamp", ^{
            [[as_hex([FSSeatDataValue pack_group:@[] time:0]) should] equal:@"00000000"];
            [[as_hex([FSSeatDataValue pack_group:@[] time:0x87654321]) should] equal:@"21436587"];
        });
        describe(@"as the concatenation of the individuals", ^{
            let(v, ^{ return [FSSeatDataValue pack_group:@[[FSSeatDataValue pack_int8:1],
                                                           [FSSeatDataValue pack_int8:2]] time:0x0f]; });
            it(@"use 2 bytes for int8,int8", ^{
                NSData *empty = [FSSeatDataValue pack_group:@[] time:0];
                [[theValue(v.length - empty.length) should] equal:theValue(2)];
            });
            it(@"has hex representation of '0f0000000102'", ^{
                [[as_hex(v) should] equal:@"0f0000000102"];
            });
            it(@"unpacks", ^{
                uint32_t t;
                NSArray *ds = [FSSeatDataValue unpack_group:v size:@[@1, @1] time:&t];
                [[theValue(t) should] equal:theValue(0x0f)];
                [[theValue(ds.count) should] equal:theValue(2)];
                [[as_hex(ds[0]) should] equal:@"01"];
                [[as_hex(ds[1]) should] equal:@"02"];
            });
        });
    });
});

SPEC_END
