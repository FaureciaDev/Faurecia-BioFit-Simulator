
//  Faurecia BioFit Simulator
//  Copyright (c) 2014 Faurecia. All rights reserved.

#import "Kiwi.h"
#import "FSSeatData.h"

SPEC_BEGIN(FSSimulatedDataTest)

describe(@"Read Simulation Data from file", ^{
    let(sim, ^{ return [[FSSeatData alloc] init]; });
    describe(@"reads in the csv file", ^{
        it(@"has length 0 for empty subscription", ^{
            [sim loadSimData:1];
            [[theValue([sim.simulatorData count]) should] beGreaterThan:theValue(0)];
        });
        it(@"starts the state index at 0", ^{
            sim.simulatorStateIndex = 6;
            [sim loadSimData:1];
            [[theValue(sim.simulatorStateIndex) should] equal:theValue(0)];
        });
    });

});

SPEC_END
