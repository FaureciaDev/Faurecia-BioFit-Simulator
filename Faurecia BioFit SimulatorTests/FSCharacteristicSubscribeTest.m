
//  Faurecia BioFit Simulator
//  Copyright (c) 2014 Faurecia. All rights reserved.

#import "Kiwi.h"
#import "FSSeatData.h"
#import "FSSeatDataValue.h"

NSData * createData(uint8_t cid) {
    return [NSData dataWithBytes:&cid length:sizeof(cid)];
}

NSData * createDataArray(uint8_t c1id, uint8_t c2id) {
    uint8_t array[2] = {c1id, c2id};
    return [NSData dataWithBytes:&array length:sizeof(array)];
}

SPEC_BEGIN(FSCharacteristicSubscribeTest)

describe(@"Characteristic subscription", ^{
    let(sim, ^{ return [[FSSeatData alloc] init]; });
    describe(@"recorded in the Notifiable Group", ^{
        it(@"has length 0 for empty subscription", ^{
            [sim subscribe:[[NSData alloc] init]];
            [[theValue([sim get:kFS_UUID_NOTIFIABLE_GROUP].length) should] equal:theValue(0)];
        });
        it(@"has 1 ID for a length 1 subscription", ^{
            [sim subscribe:createData(0)];
            [[theValue([sim get:kFS_UUID_NOTIFIABLE_GROUP].length) should] equal:theValue(1)];
        });
        it(@"has 2 IDs for a length 2 subscription", ^{
            [sim subscribe:createDataArray(0, 18)];
            [[theValue([sim get:kFS_UUID_NOTIFIABLE_GROUP].length) should] equal:theValue(2)];
        });
    });

    describe(@"allows easy retrieval of changing values", ^{
        it(@"has a timestamp and no values for empty subscription", ^{
            [sim subscribe:[[NSData alloc] init]];
            [sim formatForBluetooth];
            [[theValue([sim get:kFS_UUID_NOTIFIABLE_GROUP_VALUES].length) should] equal:theValue(sizeof(uint32_t))];
        });
        it(@"has a timestamp and 1 value for a length 1 subscription", ^{
            [sim set:kFS_UUID_OCCUPANT_PRESENCE value:[FSSeatDataValue pack_uint8:1]];
            [sim subscribe:createData(0)];
            [sim formatForBluetooth];
            [[theValue([sim get:kFS_UUID_NOTIFIABLE_GROUP_VALUES].length) should] equal:theValue(sizeof(uint32_t) + sizeof(uint8_t))];
        });
        it(@"has a timestamp and 2 values for a length 2 subscription", ^{
            [sim set:kFS_UUID_OCCUPANT_PRESENCE value:[FSSeatDataValue pack_uint8:1]];
            [sim set:kFS_UUID_OCCUPANT_MASS value:[FSSeatDataValue pack_int16:87]];
            [sim subscribe:createDataArray(0, 18)];
            [sim formatForBluetooth];
            [[theValue([sim get:kFS_UUID_NOTIFIABLE_GROUP_VALUES].length) should] equal:theValue(sizeof(uint32_t) + sizeof(uint8_t) + sizeof(int16_t))];
        });
    });
});

SPEC_END
