
//  Faurecia BioFit Simulator
//  Copyright (c) 2014 Faurecia. All rights reserved.

#import "Kiwi.h"
#import "FSSeatData.h"
#import "FSSeatDataValue.h"

SPEC_BEGIN(FSSimulatorDataFileTest)

describe(@"Read simulator data file", ^{
    __block FSSeatData * sim;
    beforeEach(^{
        sim = [[FSSeatData alloc] init];
    });
    
    describe(@"reads sim data", ^{
        it(@"reads the file", ^{
            [sim loadSimData:1];
            [[theValue([sim.simulatorData count]) should] beGreaterThan:theValue(0)];
        });
    });
    
    describe(@"start simulated data", ^{
        //[HR, BP(S), Stress, RR]
        let(fakeData, ^{ return @[@[@1,@2,@3,@4,@11], @[@5,@6,@7,@8,@12]];});
        it(@"updates the data for heart rate based on the sim data file", ^{
            [sim startDataSimulator:1];
            sim.simulatorData = fakeData;
            sim = [FSSeatData nextState:sim];
            
            int heartRate = [FSSeatDataValue unpack_uint8:[sim get:kFS_UUID_HEART_RATE]];
            [[theValue(heartRate) should] equal:theValue(1)];
            
            sim = [FSSeatData nextState:sim];
            
            heartRate = [FSSeatDataValue unpack_uint8:[sim get:kFS_UUID_HEART_RATE]];
            [[theValue(heartRate) should] equal:theValue(5)];
        });
        it(@"updates the data for blood pressure (systolic) based on the sim data file", ^{
            [sim startDataSimulator:1];
            sim.simulatorData = fakeData;
            sim = [FSSeatData nextState:sim];
            
            int bloodPressure = [FSSeatDataValue unpack_uint8:[sim get:kFS_UUID_BLOOD_PRESSURE_SYSTOLIC]];
            [[theValue(bloodPressure) should] equal:theValue(4)];
            
            sim = [FSSeatData nextState:sim];
            
            bloodPressure = [FSSeatDataValue unpack_uint8:[sim get:kFS_UUID_BLOOD_PRESSURE_SYSTOLIC]];
            [[theValue(bloodPressure) should] equal:theValue(8)];
        });
        it(@"updates the data for blood pressure (diastolic) based on the sim data file", ^{
            [sim startDataSimulator:1];
            sim.simulatorData = fakeData;
            sim = [FSSeatData nextState:sim];
            
            int bloodPressure = [FSSeatDataValue unpack_uint8:[sim get:kFS_UUID_BLOOD_PRESSURE_DIASTOLIC]];
            [[theValue(bloodPressure) should] equal:theValue(11)];
            
            sim = [FSSeatData nextState:sim];
            
            bloodPressure = [FSSeatDataValue unpack_uint8:[sim get:kFS_UUID_BLOOD_PRESSURE_DIASTOLIC]];
            [[theValue(bloodPressure) should] equal:theValue(12)];
        });
        it(@"updates the data for stress based on the sim data file", ^{
            [sim startDataSimulator:1];
            sim.simulatorData = fakeData;
            sim = [FSSeatData nextState:sim];
            
            int stress = [FSSeatDataValue unpack_uint8:[sim get:kFS_UUID_STRESS]];
            [[theValue(stress) should] equal:theValue(2)];
            
            sim = [FSSeatData nextState:sim];
            
            stress = [FSSeatDataValue unpack_uint8:[sim get:kFS_UUID_STRESS]];
            [[theValue(stress) should] equal:theValue(6)];
        });
        it(@"updates the data for respiration rate  based on the sim data file", ^{
            [sim startDataSimulator:1];
            sim.simulatorData = fakeData;
            sim = [FSSeatData nextState:sim];
            
            int respirationRate = [FSSeatDataValue unpack_uint8:[sim get:kFS_UUID_RESPIRATION_RATE]];
            [[theValue(respirationRate) should] equal:theValue(3)];
            
            sim = [FSSeatData nextState:sim];
            
            respirationRate = [FSSeatDataValue unpack_uint8:[sim get:kFS_UUID_RESPIRATION_RATE]];
            [[theValue(respirationRate) should] equal:theValue(7)];
        });
        it(@"doesn't update data when the data simulator is not running", ^{
            sim.simulatorData = fakeData;
            int initialHeartRate = [FSSeatDataValue unpack_uint8:[sim get:kFS_UUID_HEART_RATE]];
            
            sim = [FSSeatData nextState:sim];
            
            int heartRate = [FSSeatDataValue unpack_uint8:[sim get:kFS_UUID_HEART_RATE]];
            [[theValue(heartRate) should] equal:theValue(initialHeartRate)];
        });
        it(@"freezes the simulation state when the end of the file is reached", ^{
            [sim startDataSimulator:1];
            sim.simulatorData = fakeData;
            
            for (int i = 0; i < [fakeData count]; ++i) {
                sim = [FSSeatData nextState:sim];
            }
            sim = [FSSeatData nextState:sim];
            
            int heartRate = [FSSeatDataValue unpack_uint8:[sim get:kFS_UUID_HEART_RATE]];
            [[theValue(heartRate) should] equal:theValue(5)];
        });
    });
    
});

SPEC_END
