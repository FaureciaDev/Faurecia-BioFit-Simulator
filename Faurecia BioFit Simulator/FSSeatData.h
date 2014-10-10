
//  Faurecia BioFit Simulator
//  Copyright (c) 2014 Faurecia. All rights reserved.

#import <IOBluetooth/IOBluetooth.h>
#import "FSSeatDataValue.h"

extern CBUUID *kFS_UUID_OCCUPANT_PRESENCE;
extern CBUUID *kFS_UUID_SYSTEM_TIME_STAMP;
extern CBUUID *kFS_UUID_CONNECTION_REFERENCE_TIME;
extern CBUUID *kFS_UUID_CURRENT_ELAPSED_TIME;

extern CBUUID *kFS_UUID_NOTIFIABLE_GROUP;
extern CBUUID *kFS_UUID_NOTIFIABLE_GROUP_VALUES;
extern CBUUID *kFS_UUID_WRITE_EFFECT_COMPLETE;

extern CBUUID *kFS_UUID_HEART_RATE;
extern CBUUID *kFS_UUID_RESPIRATION_RATE;
extern CBUUID *kFS_UUID_INTEGRATED_PULMONARY_INDEX;
extern CBUUID *kFS_UUID_HEART_RATE_VARIABILITY;
extern CBUUID *kFS_UUID_BLOOD_PRESSURE_SYSTOLIC;
extern CBUUID *kFS_UUID_BLOOD_PRESSURE_DIASTOLIC;
extern CBUUID *kFS_UUID_BLOOD_FLOW_INDEX;

extern CBUUID *kFS_UUID_INTEGRATED_COMFORT_INDEX;
extern CBUUID *kFS_UUID_STRESS;
extern CBUUID *kFS_UUID_EMOTIONAL_VALENCE;
extern CBUUID *kFS_UUID_EMOTIONAL_AROUSAL;

extern CBUUID *kFS_UUID_OCCUPANT_MASS;
extern CBUUID *kFS_UUID_OCCUPANT_CENTER_OF_MASS;

extern CBUUID *kFS_UUID_AMBIENT_HUMIDITY;
extern CBUUID *kFS_UUID_CUSHION_SURFACE_HUMIDITY;
extern CBUUID *kFS_UUID_UPPER_BACK_SURFACE_HUMIDITY;
extern CBUUID *kFS_UUID_LOWER_BACK_SURFACE_HUMIDITY;

extern CBUUID *kFS_UUID_CUSHION_SURFACE_TEMPERATURE;
extern CBUUID *kFS_UUID_BACK_SURFACE_TEMPERATURE;
extern CBUUID *kFS_UUID_AMBIENT_TEMPERATURE;

extern CBUUID *kFS_UUID_LOWER_LUMBAR_PRESSURE;
extern CBUUID *kFS_UUID_MIDDLE_LUMBAR_PRESSURE;
extern CBUUID *kFS_UUID_UPPER_LUMBAR_PRESSURE;
extern CBUUID *kFS_UUID_CUSHION_SIDE_BOLSTER_PRESSURE;
extern CBUUID *kFS_UUID_BACK_SIDE_BOLSTER_PRESSURE;
extern CBUUID *kFS_UUID_CUSHION_LENGTH;
extern CBUUID *kFS_UUID_CUSHION_EDGE_PRESSURE;
extern CBUUID *kFS_UUID_UPPER_BACKREST_POSITION;

extern CBUUID *kFS_UUID_MASSAGE_PROGRAM_SELECTION;
extern CBUUID *kFS_UUID_MASSAGE_INTENSITY;
extern CBUUID *kFS_UUID_MASSAGE_SPEED;

extern CBUUID *kFS_UUID_VENTILATION_LEVEL;
extern CBUUID *kFS_UUID_BACK_HEATING_AND_COOLING;
extern CBUUID *kFS_UUID_CUSHION_HEATING_AND_COOLING;

extern NSArray *kFS_SEAT_DATA_UUID;
extern NSArray *kFS_SEAT_DATA_DESCRIPTION;

@interface CBUUID (StringExtraction)

// See http://stackoverflow.com/questions/13275859/how-to-turn-cbuuid-into-string
- (NSString *)FS_representativeString;

@end

struct RawData {
    BOOL occupantPresence;
    //heart and blood
    uint8_t heartRate;
    uint8_t respirationRate;
    int8_t integratedPulmonaryIndex;
    int8_t heartRateVariablility;
    uint8_t systolicBloodPressure;
    uint8_t diastolicBloodPressure;
    int8_t bloodFlowIndex;
    
    //emotion and comfort
    int8_t integratedComfortIndex;
    int8_t stress;
    int8_t emotionalVariance;
    int8_t emotionalArousal;
    
    //mass
    int16_t occupantMass;
    uint8_t occupantCenterOfMassX;
    uint8_t occupantCenterOfMassY;
    uint8_t occupantCenterOfMassZ;
    
    //humidity
    int8_t ambientHumidity;
    int8_t cushionSurfaceHumidity;
    int8_t upperBackSurfaceHumidity;
    int8_t lowerBackSurfaceHumidity;
    
    //temperatures
    int8_t cushionSurfaceTemperature;
    int8_t backSurfaceTemperature;
    int8_t ambientTemperature;
    
    //seat pressures
    int8_t lowerLumbarPressure;
    int8_t middleLumbarPressure;
    int8_t upperLumbarPressure;
    int8_t cushionSideBolsterPressure;
    int8_t backSideBolsterPressure;
    int8_t cushionLength;
    int8_t cushionEdgePressure;
    int8_t upperBackrestPosition;
    
    //massage
    uint8_t massageProgramSelection;
    int8_t massageIntensity;
    int8_t massageSpeed;
    
    //ventilation
    uint8_t ventilationLevel;
    int8_t backHeatingAndCooling;
    int8_t cushionHeatingAndCooling;
};

@interface FSSeatData : NSObject {
    @public struct RawData values;
}

@property ULONG ticks; //this will increment by one every second, when the simulation state changes regardless of whether a data input stream is running. It exists to help with modifying the data stream. Adjusting this value in any way will not affect anything except data modification stream.

@property BOOL modificationA;
@property BOOL modificationB;
@property BOOL modificationC;
@property BOOL modificationD;
@property BOOL modificationE;
@property BOOL modificationF;

@property (nonatomic, assign) NSTimeInterval timeOffsetFromClient;
@property (nonatomic, strong) NSDate *connectionReferenceTime;

@property (nonatomic, strong) NSData *notifiableGroup;
@property (nonatomic, strong) NSArray *pendingWrites; // TODO: gcd queue might suffice

@property (nonatomic, strong) NSMutableDictionary *data;
@property (nonatomic, strong) NSArray *simulatorData;
@property (nonatomic, strong) NSString *simulationDescription;
@property int simulatorStateIndex;
@property BOOL sampleDataIsStreaming;

- (uint32_t)currentElapsedTime;

- (void)format_NOTIFIABLE_GROUP;
- (void)format_NOTIFIABLE_GROUP_VALUES;
- (void)formatForBluetooth;

- (void)set:(CBUUID *)c value:(NSData *)v;
- (NSData *)get:(CBUUID *)c;

- (void)configure:(CBUUID *)c withTestValue:(int)v;
- (void)configure:(CBUUID *)c withUserValue:(NSData *)v;
- (void)subscribe:(NSData *)cs;

- (void)loadSimData:(int)number;
- (void)startDataSimulator:(int)number;
- (void)adjustData;

+ (FSSeatData *)nextState:(FSSeatData *)current;


@end
