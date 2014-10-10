
//  Faurecia BioFit Simulator
//  Copyright (c) 2014 Faurecia. All rights reserved.

#import <Foundation/Foundation.h>
#import "FSSeatData.h"
#import "FSSeatDataValue.h"

CBUUID *kFS_UUID_OCCUPANT_PRESENCE;
CBUUID *kFS_UUID_SYSTEM_TIME_STAMP;
CBUUID *kFS_UUID_CONNECTION_REFERENCE_TIME;
CBUUID *kFS_UUID_CURRENT_ELAPSED_TIME;

CBUUID *kFS_UUID_NOTIFIABLE_GROUP;
CBUUID *kFS_UUID_NOTIFIABLE_GROUP_VALUES;
CBUUID *kFS_UUID_WRITE_EFFECT_COMPLETE;

CBUUID *kFS_UUID_HEART_RATE;
CBUUID *kFS_UUID_RESPIRATION_RATE;
CBUUID *kFS_UUID_INTEGRATED_PULMONARY_INDEX;
CBUUID *kFS_UUID_HEART_RATE_VARIABILITY;
CBUUID *kFS_UUID_BLOOD_PRESSURE_SYSTOLIC;
CBUUID *kFS_UUID_BLOOD_PRESSURE_DIASTOLIC;
CBUUID *kFS_UUID_BLOOD_FLOW_INDEX;

CBUUID *kFS_UUID_INTEGRATED_COMFORT_INDEX;
CBUUID *kFS_UUID_STRESS;
CBUUID *kFS_UUID_EMOTIONAL_VALENCE;
CBUUID *kFS_UUID_EMOTIONAL_AROUSAL;

CBUUID *kFS_UUID_OCCUPANT_MASS;
CBUUID *kFS_UUID_OCCUPANT_CENTER_OF_MASS;

CBUUID *kFS_UUID_AMBIENT_HUMIDITY;
CBUUID *kFS_UUID_CUSHION_SURFACE_HUMIDITY;
CBUUID *kFS_UUID_UPPER_BACK_SURFACE_HUMIDITY;
CBUUID *kFS_UUID_LOWER_BACK_SURFACE_HUMIDITY;

CBUUID *kFS_UUID_CUSHION_SURFACE_TEMPERATURE;
CBUUID *kFS_UUID_BACK_SURFACE_TEMPERATURE;
CBUUID *kFS_UUID_AMBIENT_TEMPERATURE;

CBUUID *kFS_UUID_LOWER_LUMBAR_PRESSURE;
CBUUID *kFS_UUID_MIDDLE_LUMBAR_PRESSURE;
CBUUID *kFS_UUID_UPPER_LUMBAR_PRESSURE;
CBUUID *kFS_UUID_CUSHION_SIDE_BOLSTER_PRESSURE;
CBUUID *kFS_UUID_BACK_SIDE_BOLSTER_PRESSURE;
CBUUID *kFS_UUID_CUSHION_LENGTH;
CBUUID *kFS_UUID_CUSHION_EDGE_PRESSURE;
CBUUID *kFS_UUID_UPPER_BACKREST_POSITION;

CBUUID *kFS_UUID_MASSAGE_PROGRAM_SELECTION;
CBUUID *kFS_UUID_MASSAGE_INTENSITY;
CBUUID *kFS_UUID_MASSAGE_SPEED;

CBUUID *kFS_UUID_VENTILATION_LEVEL;
CBUUID *kFS_UUID_BACK_HEATING_AND_COOLING;
CBUUID *kFS_UUID_CUSHION_HEATING_AND_COOLING;

NSArray *kFS_SEAT_DATA_UUID;
NSArray *kFS_SEAT_DATA_DESCRIPTION;

@implementation CBUUID (StringExtraction)

- (NSString *)FS_representativeString;

{
    NSData *data = [self data];

    NSUInteger bytesToConvert = [data length];
    const unsigned char *uuidBytes = [data bytes];
    NSMutableString *outputString = [NSMutableString stringWithCapacity:16];

    for (NSUInteger currentByteIndex = 0; currentByteIndex < bytesToConvert; currentByteIndex++)
    {
        switch (currentByteIndex)
        {
            case 3:
            case 5:
            case 7:
            case 9:[outputString appendFormat:@"%02X-", uuidBytes[currentByteIndex]]; break;
            default:[outputString appendFormat:@"%02X", uuidBytes[currentByteIndex]];
        }
    }

    return outputString;
}

@end

@implementation FSSeatData

// Custom Data Modifications
/*------------------------------------------------------------*/
- (void) doModificationA {
    //increasing stress to high levels
    if (self.ticks < 15) {
        //increment stress quickly in the first 15 seconds
        self->values.stress = self.ticks * 4;
    } else if (self.sampleDataIsStreaming) {
        //if a data stream is running, add 3 to the current stress level
        self->values.stress += 3;
    }
    else if(self.ticks % 2 == 0) {
        //a data stream is not running, so increment stress slowly now;
        self->values.stress = self.ticks;
    }
    //max valid stress level is 100
    self->values.stress = MIN(self->values.stress, 100);
}

- (void) doModificationB {
   //gain weight while driving - because why not
    if (self.ticks % 2 == 0) {
        self->values.occupantMass++;
    }
    //max valid stress level is 100
    self->values.occupantMass = MIN(self->values.occupantMass, 255);
}

- (void) doModificationC {
    //shift in seat
    
    //random number {-5. 0, 5}
    int xAdjustment = arc4random_uniform(11) - 5;
    int yAdjustment = arc4random_uniform(11) - 5;
    int zAdjustment = arc4random_uniform(11) - 5;
    
    int x = self->values.occupantCenterOfMassX + xAdjustment;
    int y = self->values.occupantCenterOfMassY + yAdjustment;
    int z = self->values.occupantCenterOfMassZ + zAdjustment;
    
    self->values.occupantCenterOfMassX = MIN(x, 500);
    self->values.occupantCenterOfMassX = MAX(x, -500);
    self->values.occupantCenterOfMassY = MIN(y, 500);
    self->values.occupantCenterOfMassY = MAX(y, -500);
    self->values.occupantCenterOfMassZ = MIN(z, 500);
    self->values.occupantCenterOfMassZ = MAX(z, -500);
}

-(void) doModificationD {
    //increase heart rate of existing data stream
    if (self.sampleDataIsStreaming) {
        int heartRate = self->values.heartRate + 40;
        int sBloodPressure = self->values.systolicBloodPressure + 20;
        int dBloodPressure = self->values.diastolicBloodPressure + 20;
        int bloodFlow = self->values.bloodFlowIndex - 10;
        int respirationRate = self->values.respirationRate + 1;
        
        self->values.heartRate = MIN(heartRate, 255);
        self->values.systolicBloodPressure = MIN(sBloodPressure, 255);
        self->values.diastolicBloodPressure = MIN(dBloodPressure, 255);
        self->values.bloodFlowIndex =MAX(bloodFlow, 100);
        self->values.respirationRate = MIN(respirationRate, 10);
    }
}

-(void) doModificationE {
    //get in and out of seat
    self->values.occupantPresence = !self->values.occupantPresence;
}

-(void) doModificationF {
    //massage program 20: apply massage in a clockwise rotation starting with the recipient's left shoulder.
    self->values.massageProgramSelection = 20;
}


/*------------------------------------------------------------*/

- (void) adjustData {
    if (self.modificationA) {
        [self doModificationA];
    }
    if (self.modificationB) {
        [self doModificationB];
    }
    if (self.modificationC) {
        [self doModificationC];
    }
    if (self.modificationD) {
        [self doModificationD];
    }
    if (self.modificationE) {
        [self doModificationE];
    }
    if (self.modificationF) {
        [self doModificationF];
    }
}



+ (void)initialize {
    // The order in which the characterstics fill these arrays deterimines what
    // numeric index the characteristic has. This probably isn't a good approach
    // for preserving stable indexes for future characteristic updates.
    // TODO design a better way to assign indexes and display a table of values.

    NSMutableArray *uuid = [NSMutableArray arrayWithCapacity:100];
    NSMutableArray *desc = [NSMutableArray arrayWithCapacity:100];

#define M(U,D) [uuid addObject:(kFS_UUID_##D = [CBUUID UUIDWithString:@U])]; [desc addObject:(@#D)]

    M("B43EED9C-E88E-42FF-AB8C-4399977C3D9D", OCCUPANT_PRESENCE);
    M("71BFAE4D-51CD-422D-AE87-B4921AC75C1A", SYSTEM_TIME_STAMP);
    M("21752B03-3735-473E-903F-485CF77DA0AE", CONNECTION_REFERENCE_TIME);
    M("0A347E6C-02E4-4749-A8A4-6BD6202E8FEA", CURRENT_ELAPSED_TIME);

    M("B4A265CD-2786-432D-8E92-819B9113AA10", NOTIFIABLE_GROUP);
    M("5957BE8F-C01F-4531-A529-0924398E4FE9", NOTIFIABLE_GROUP_VALUES);
    M("F56A209B-2285-44E5-862F-1AB206DFFBE6", WRITE_EFFECT_COMPLETE);

    M("39D1E3AE-EA25-43BD-BB62-ADD8ECD897D5", HEART_RATE);
    M("D5F34109-9F28-4213-85A4-808357CEF8F3", RESPIRATION_RATE);
    M("8217E89D-C226-45F6-A36E-DA23DDE4A83A", INTEGRATED_PULMONARY_INDEX);
    M("00CFF3E3-A2FF-4E05-8EFA-C22D799EB136", HEART_RATE_VARIABILITY);
    M("D9A9F3E2-E884-40F4-91D6-41892C2D2E73", BLOOD_PRESSURE_SYSTOLIC);
    M("0038087B-31E2-4D67-8106-A4996E329EE2", BLOOD_PRESSURE_DIASTOLIC);
    M("65CF8D40-8943-473A-8DC9-400F5A17A6C7", BLOOD_FLOW_INDEX);

    M("48560C7A-F383-4C27-BE20-E92C416C8F80", INTEGRATED_COMFORT_INDEX);
    M("96A70770-C16F-40CC-BB4D-768E0F02494E", STRESS);
    M("C2D2F281-7756-47A7-9B14-C9BAC900354F", EMOTIONAL_VALENCE);
    M("3B7E5227-2926-4E15-9FE6-E4CD273371B2", EMOTIONAL_AROUSAL);

    M("E76B29AC-FD59-4530-898B-35AB751A43C8", OCCUPANT_MASS);
    M("B11102CC-5235-44BE-B8E8-825DFF3B90FD", OCCUPANT_CENTER_OF_MASS);

    M("2B46CF2F-C102-4683-8F05-9E6AD5A84843", AMBIENT_HUMIDITY);
    M("4612CD0D-64F0-4140-9EB5-198B770FC0D0", CUSHION_SURFACE_HUMIDITY);
    M("53603F65-6B4B-4D46-B373-B486B78590D2", UPPER_BACK_SURFACE_HUMIDITY);
    M("7E3DF6AE-41C7-493E-8D4D-556A62321A9B", LOWER_BACK_SURFACE_HUMIDITY);

    M("75A8A1EF-B8E0-4FB4-A867-B68E653DF932", CUSHION_SURFACE_TEMPERATURE);
    M("2CD29B7B-22D5-4371-89FF-E849E2120929", BACK_SURFACE_TEMPERATURE);
    M("45DEFC80-B2FC-49A4-A97D-A68FFDEFF8C2", AMBIENT_TEMPERATURE);

    M("1BA22BC7-28AB-4B25-A0EE-4553C4C28DC2", LOWER_LUMBAR_PRESSURE);
    M("636235DE-D04C-42DD-8673-F11918D7C5BD", MIDDLE_LUMBAR_PRESSURE);
    M("E430BAFB-B101-4896-9957-6E3938F575D8", UPPER_LUMBAR_PRESSURE);
    M("434A3872-2DE3-4E76-A120-30A179286D28", CUSHION_SIDE_BOLSTER_PRESSURE);
    M("984CB911-02F5-4941-9A1D-AD09A5764F15", BACK_SIDE_BOLSTER_PRESSURE);
    M("65A45C5D-9B54-4488-ABD2-1853D11E7F54", CUSHION_LENGTH);
    M("7949ABDC-965E-4175-ACF1-B842848C6AD5", CUSHION_EDGE_PRESSURE);
    M("EC7D0CB9-34D4-423C-AAAC-CFF722E3A6C5", UPPER_BACKREST_POSITION);

    M("E66E4070-831B-4E23-B05E-D7BE5F06AF4B", MASSAGE_PROGRAM_SELECTION);
    M("165F7489-A805-4D70-8900-135A4E174404", MASSAGE_INTENSITY);
    M("C4248837-F351-4538-9A73-8480637F3841", MASSAGE_SPEED);

    M("25BFE8A4-786D-458D-A4AD-F710D4E7EFC6", VENTILATION_LEVEL);
    M("C391FFC3-BD58-4BB4-AC90-08A96BF04E39", BACK_HEATING_AND_COOLING);
    M("B3AB6D33-3E6A-42B3-B1BD-D821FFBE3090", CUSHION_HEATING_AND_COOLING);

    kFS_SEAT_DATA_UUID = uuid;
    kFS_SEAT_DATA_DESCRIPTION = desc;
}

- (id) init {
    self = [super init];
    if (self) {
        _sampleDataIsStreaming = FALSE;
        _simulatorStateIndex = 0;
        _ticks = 0;
        _modificationA = false;
        _modificationB = false;
        _modificationC = false;
        _modificationD = false;
        _modificationE = false;
        _modificationF = false;

        _timeOffsetFromClient = 0.0;
        _connectionReferenceTime = nil;

        values.occupantPresence = FALSE;
        values.heartRate = 0;
        values.heartRateVariablility = 40;
        values.systolicBloodPressure = 120;
        values.diastolicBloodPressure = 80;
        values.bloodFlowIndex = 80;

        values.integratedComfortIndex = 90;
        values.stress = 50;
        values.emotionalVariance = 50;
        values.emotionalArousal = 50;

        values.occupantMass = 75;
        values.occupantCenterOfMassX = 0;
        values.occupantCenterOfMassY = 0;
        values.occupantCenterOfMassZ = 0;

        values.ambientHumidity = 40;
        values.cushionSurfaceHumidity = 50;
        values.upperBackSurfaceHumidity = 50;
        values.lowerBackSurfaceHumidity = 50;

        values.cushionSurfaceTemperature = 330;
        values.backSurfaceTemperature = 323;
        values.ambientTemperature = 215;

        values.lowerLumbarPressure = 50;
        values.middleLumbarPressure = 50;
        values.upperLumbarPressure = 50;
        values.cushionSideBolsterPressure = 50;
        values.backSideBolsterPressure = 50;
        values.cushionEdgePressure = 50;
        
        values.cushionLength = 50;
        values.upperBackrestPosition = 0;
        
        values.massageProgramSelection = 0;
        values.massageIntensity = 5;
        values.massageSpeed = 5;
        values.ventilationLevel = 0;
        values.backHeatingAndCooling = 0;
        values.cushionHeatingAndCooling = 0;
        
        //heart rate, stress
        _notifiableGroup = [[NSData alloc] init];

        [self initialFormatForBluetooth];
    }
    return self;
}

- (void)set:(CBUUID *)c value:(NSData *)v {
    if (!self.data) {
        self.data = [[NSMutableDictionary alloc] init];
    }
    if (v == nil) {
        v = [[NSData alloc] init];
    }
    [self.data setObject:v forKey:c];
}

- (NSData *)get:(CBUUID *)c {
    return [self.data objectForKey:c];
}

- (void)format:(CBUUID *)c data:(NSData *)value {
    [self set:c value:value];
}

- (void)format:(CBUUID *)c int8:(int8_t)value {
    [self set:c value:[FSSeatDataValue pack_int8:value]];
}

- (void)format:(CBUUID *)c uint8:(uint8_t)value {
    [self set:c value:[FSSeatDataValue pack_uint8:value]];
}

- (void)format:(CBUUID *)c int16:(int16_t)value {
    [self set:c value:[FSSeatDataValue pack_int16:value]];
}

- (void)format:(CBUUID *)c uint32:(uint32_t)value {
    [self set:c value:[FSSeatDataValue pack_uint32:value]];
}

- (void)format:(CBUUID *)c string:(NSString *)value {
    [self set:c value:[value dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)format:(CBUUID *)c date:(NSDate *)value {
    static NSLocale *usLocale = nil;
    static NSDateFormatter *dateFormatter = nil;

    if (usLocale == nil) {
        usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd-HH:mm:ss.SSSS"];
        [dateFormatter setLocale:usLocale];
    }

    [self format:c string:[dateFormatter stringFromDate:value]];
}

- (uint32_t)currentElapsedTime {
    NSDate *now = [NSDate date];
    return 1000.0 * [now timeIntervalSinceDate:self.connectionReferenceTime];
}

- (void)format_SYSTEM_TIME_STAMP {
    NSDate *date = [[NSDate date] dateByAddingTimeInterval:self.timeOffsetFromClient];
    [self format:kFS_UUID_SYSTEM_TIME_STAMP date:date];
}

- (void)format_CONNECTION_REFERENCE_TIME {
    NSDate *date = [self.connectionReferenceTime dateByAddingTimeInterval:self.timeOffsetFromClient];
    [self format:kFS_UUID_CONNECTION_REFERENCE_TIME date:date];
}

- (void)format_OCCUPANT_CENTER_OF_MASS {
    NSMutableData *point = [NSMutableData dataWithCapacity:(3 * sizeof(uint16_t))];
    [point appendData:[FSSeatDataValue pack_int16:self->values.occupantCenterOfMassX]];
    [point appendData:[FSSeatDataValue pack_int16:self->values.occupantCenterOfMassY]];
    [point appendData:[FSSeatDataValue pack_int16:self->values.occupantCenterOfMassZ]];
    [self set:kFS_UUID_OCCUPANT_CENTER_OF_MASS value:point];
}

- (void)format_NOTIFIABLE_GROUP {
    [self format:kFS_UUID_NOTIFIABLE_GROUP data:self.notifiableGroup];
}

- (void)format_NOTIFIABLE_GROUP_VALUES {
    NSMutableArray *ds = [[NSMutableArray alloc] initWithCapacity:self.notifiableGroup.length];
    
    for (int i = 0; i < self.notifiableGroup.length; ++i) {
        uint8_t *p = (uint8_t *) self.notifiableGroup.bytes;
        CBUUID *c = kFS_SEAT_DATA_UUID[p[i]];
        [ds addObject:[self get:c]];
    }
    
    [self set:kFS_UUID_NOTIFIABLE_GROUP_VALUES value:[FSSeatDataValue pack_group:ds time:[self currentElapsedTime]]];
}

- (void)formatForBluetooth {
    [self format:kFS_UUID_OCCUPANT_PRESENCE uint8:values.occupantPresence];
    [self format_SYSTEM_TIME_STAMP];
    [self format_CONNECTION_REFERENCE_TIME];
    [self format:kFS_UUID_CURRENT_ELAPSED_TIME uint32:[self currentElapsedTime]];

    [self format:kFS_UUID_HEART_RATE uint8:self->values.heartRate];
    [self format:kFS_UUID_RESPIRATION_RATE uint8:self->values.respirationRate];
    [self format:kFS_UUID_INTEGRATED_PULMONARY_INDEX uint8:self->values.integratedPulmonaryIndex];
    [self format:kFS_UUID_HEART_RATE_VARIABILITY uint8:(100 * self->values.heartRateVariablility)];
    [self format:kFS_UUID_BLOOD_PRESSURE_SYSTOLIC uint8:self->values.systolicBloodPressure];
    [self format:kFS_UUID_BLOOD_PRESSURE_DIASTOLIC uint8:self->values.diastolicBloodPressure];
    [self format:kFS_UUID_BLOOD_FLOW_INDEX uint8:self->values.bloodFlowIndex];

    [self format:kFS_UUID_INTEGRATED_COMFORT_INDEX uint8:self->values.integratedComfortIndex];
    [self format:kFS_UUID_STRESS uint8:self->values.stress];
    [self format:kFS_UUID_EMOTIONAL_VALENCE uint8:self->values.emotionalVariance];
    [self format:kFS_UUID_EMOTIONAL_AROUSAL uint8:self->values.emotionalArousal];

    [self format:kFS_UUID_OCCUPANT_MASS int16:self->values.occupantMass];
    [self format_OCCUPANT_CENTER_OF_MASS];

    [self format:kFS_UUID_AMBIENT_HUMIDITY uint8:self->values.ambientHumidity];
    [self format:kFS_UUID_CUSHION_SURFACE_HUMIDITY uint8:self->values.cushionSurfaceHumidity];
    [self format:kFS_UUID_UPPER_BACK_SURFACE_HUMIDITY uint8:self->values.upperBackSurfaceHumidity];
    [self format:kFS_UUID_LOWER_BACK_SURFACE_HUMIDITY uint8:self->values.lowerBackSurfaceHumidity];

    [self format:kFS_UUID_CUSHION_SURFACE_TEMPERATURE int16:self->values.cushionSurfaceTemperature];
    [self format:kFS_UUID_BACK_SURFACE_TEMPERATURE int16:self->values.backSurfaceTemperature];
    [self format:kFS_UUID_AMBIENT_TEMPERATURE int16:self->values.ambientTemperature];

    [self format:kFS_UUID_LOWER_LUMBAR_PRESSURE uint8:self->values.lowerLumbarPressure];
    [self format:kFS_UUID_MIDDLE_LUMBAR_PRESSURE uint8:self->values.middleLumbarPressure];
    [self format:kFS_UUID_UPPER_LUMBAR_PRESSURE uint8:self->values.upperLumbarPressure];
    [self format:kFS_UUID_CUSHION_SIDE_BOLSTER_PRESSURE uint8:self->values.cushionSideBolsterPressure];
    [self format:kFS_UUID_BACK_SIDE_BOLSTER_PRESSURE uint8:self->values.backSideBolsterPressure];
    [self format:kFS_UUID_CUSHION_LENGTH uint8:self->values.cushionLength];
    [self format:kFS_UUID_CUSHION_EDGE_PRESSURE uint8:self->values.cushionEdgePressure];
    [self format:kFS_UUID_UPPER_BACKREST_POSITION int8:self->values.upperBackrestPosition];

    [self format:kFS_UUID_MASSAGE_PROGRAM_SELECTION uint8:self->values.massageProgramSelection];
    [self format:kFS_UUID_MASSAGE_INTENSITY uint8:self->values.massageIntensity];
    [self format:kFS_UUID_MASSAGE_SPEED uint8:self->values.massageSpeed];

    [self format:kFS_UUID_VENTILATION_LEVEL uint8:self->values.ventilationLevel];
    [self format:kFS_UUID_BACK_HEATING_AND_COOLING int8:self->values.backHeatingAndCooling];
    [self format:kFS_UUID_CUSHION_HEATING_AND_COOLING int8:self->values.cushionHeatingAndCooling];

    [self format_NOTIFIABLE_GROUP_VALUES];
}

- (void)initialFormatForBluetooth {
    self.connectionReferenceTime = [NSDate date];

    [self formatForBluetooth];
    [self format_NOTIFIABLE_GROUP];
    [self format:kFS_UUID_WRITE_EFFECT_COMPLETE string:@""];
}

- (void)configure:(CBUUID *)c withUserValue:(NSData *)v {
    if ([kFS_UUID_MIDDLE_LUMBAR_PRESSURE isEqual:c]) {
        self->values.middleLumbarPressure = [FSSeatDataValue unpack_uint8:v];
    }
    else if ([kFS_UUID_UPPER_LUMBAR_PRESSURE isEqual:c]) {
        self->values.upperLumbarPressure = [FSSeatDataValue unpack_uint8:v];
    }
    else if ([kFS_UUID_CUSHION_SIDE_BOLSTER_PRESSURE isEqual:c]) {
        self->values.cushionSideBolsterPressure = [FSSeatDataValue unpack_uint8:v];
    }
    else if ([kFS_UUID_BACK_SIDE_BOLSTER_PRESSURE isEqual:c]) {
        self->values.backSideBolsterPressure = [FSSeatDataValue unpack_uint8:v];
    }
    else if ([kFS_UUID_CUSHION_LENGTH isEqual:c]) {
        self->values.cushionLength = [FSSeatDataValue unpack_uint8:v];
    }
    else if ([kFS_UUID_CUSHION_EDGE_PRESSURE isEqual:c]) {
        self->values.cushionEdgePressure = [FSSeatDataValue unpack_uint8:v];
    }
    else if ([kFS_UUID_UPPER_BACKREST_POSITION isEqual:c]) {
        self->values.upperBackrestPosition = [FSSeatDataValue unpack_int8:v];
    }
    else if ([kFS_UUID_MASSAGE_PROGRAM_SELECTION isEqual:c]) {
        self->values.massageProgramSelection = [FSSeatDataValue unpack_uint8:v];
    }
    else if ([kFS_UUID_MASSAGE_INTENSITY isEqual:c]) {
        self->values.massageIntensity = [FSSeatDataValue unpack_uint8:v];
    }
    else if ([kFS_UUID_MASSAGE_SPEED isEqual:c]) {
        self->values.massageSpeed = [FSSeatDataValue unpack_uint8:v];
    }
    else if ([kFS_UUID_VENTILATION_LEVEL isEqual:c]) {
        self->values.ventilationLevel = [FSSeatDataValue unpack_uint8:v];
    }
    else if ([kFS_UUID_BACK_HEATING_AND_COOLING isEqual:c]) {
        self->values.backHeatingAndCooling = [FSSeatDataValue unpack_int8:v];
    }
    else if ([kFS_UUID_CUSHION_HEATING_AND_COOLING isEqual:c]) {
        self->values.cushionHeatingAndCooling = [FSSeatDataValue unpack_int8:v];
    }
}

- (void)configure:(CBUUID *)c withTestValue:(int)v {
    if (0) { }

#define S(C, A, T) else if ([kFS_UUID_##C isEqual:c]) { self->values.A = (T)v; }

    S(OCCUPANT_PRESENCE, occupantPresence, uint8_t)

    S(HEART_RATE, heartRate, uint8_t)
    S(RESPIRATION_RATE, respirationRate, uint8_t)
    S(INTEGRATED_PULMONARY_INDEX, integratedPulmonaryIndex, uint8_t)
    S(HEART_RATE_VARIABILITY, heartRateVariablility, uint8_t)
    S(BLOOD_PRESSURE_SYSTOLIC, systolicBloodPressure, uint8_t)
    S(BLOOD_PRESSURE_DIASTOLIC, diastolicBloodPressure, uint8_t)
    S(BLOOD_FLOW_INDEX, bloodFlowIndex, uint8_t)

    S(INTEGRATED_COMFORT_INDEX, integratedComfortIndex, uint8_t)
    S(STRESS, stress, uint8_t)
    S(EMOTIONAL_VALENCE, emotionalVariance, uint8_t)
    S(EMOTIONAL_AROUSAL, emotionalArousal, uint8_t)

    S(OCCUPANT_MASS, occupantMass, uint8_t)

    S(AMBIENT_HUMIDITY, ambientHumidity, uint8_t)
    S(CUSHION_SURFACE_HUMIDITY, cushionSurfaceHumidity, uint8_t)
    S(UPPER_BACK_SURFACE_HUMIDITY, upperBackSurfaceHumidity, uint8_t)
    S(LOWER_BACK_SURFACE_HUMIDITY, lowerBackSurfaceHumidity, uint8_t)

    S(CUSHION_SURFACE_TEMPERATURE, cushionSurfaceTemperature, int16_t)
    S(BACK_SURFACE_TEMPERATURE, backSurfaceTemperature, int16_t)
    S(AMBIENT_TEMPERATURE, ambientTemperature, int16_t)

    S(LOWER_LUMBAR_PRESSURE, lowerLumbarPressure, uint8_t)
    S(MIDDLE_LUMBAR_PRESSURE, middleLumbarPressure, uint8_t)
    S(UPPER_LUMBAR_PRESSURE, upperLumbarPressure, uint8_t)
    S(CUSHION_SIDE_BOLSTER_PRESSURE, cushionSideBolsterPressure, uint8_t)
    S(BACK_SIDE_BOLSTER_PRESSURE, backSideBolsterPressure, uint8_t)
    S(CUSHION_LENGTH, cushionLength, uint8_t)
    S(CUSHION_EDGE_PRESSURE, cushionEdgePressure, uint8_t)
    S(UPPER_BACKREST_POSITION, upperBackrestPosition, uint8_t)

    S(MASSAGE_PROGRAM_SELECTION, massageProgramSelection, uint8_t)
    S(MASSAGE_INTENSITY, massageIntensity, uint8_t)
    S(MASSAGE_SPEED, massageSpeed, uint8_t)

    S(VENTILATION_LEVEL, ventilationLevel, uint8_t)
    S(BACK_HEATING_AND_COOLING, backHeatingAndCooling, int8_t)
    S(CUSHION_HEATING_AND_COOLING, cushionHeatingAndCooling, int8_t)

#undef S
}

- (void)subscribe:(NSData *)cs {
    uint8_t *p = (uint8_t *)cs.bytes;
    NSMutableData *group = [NSMutableData dataWithCapacity:cs.length];
    
    for (int i=0; i < cs.length; ++i) {
        if (p[i] < kFS_SEAT_DATA_UUID.count) {
            [group appendBytes:p + i length:sizeof(p[i])];
        }
    }

    self.notifiableGroup = group;
    self.connectionReferenceTime = [NSDate date];

    [self format_NOTIFIABLE_GROUP];
    [self format_NOTIFIABLE_GROUP_VALUES];
}

+ (FSSeatData *)nextState:(FSSeatData *)current {
    FSSeatData *next = [[FSSeatData alloc] init];
    next.data = [NSMutableDictionary dictionaryWithDictionary:current.data];
    next->values = current->values;

    if (current.sampleDataIsStreaming) {
        NSArray *state = current.simulatorData[current.simulatorStateIndex];
        
        next->values.heartRate = [state[0] intValue];
        next->values.stress = [state[1] intValue];
        next->values.respirationRate = [state[2] intValue];
        next->values.systolicBloodPressure = [state[3] intValue];
        next->values.diastolicBloodPressure = [state[4] intValue];
    }
    
    next.simulatorData = current.simulatorData;
    
    if (current.sampleDataIsStreaming && current.simulatorStateIndex < [current.simulatorData count] - 1) {
        next.simulatorStateIndex = current.simulatorStateIndex + 1;
        next.sampleDataIsStreaming = TRUE;
    }
    else {
        next.sampleDataIsStreaming = FALSE;
    }
    
    next.ticks = current.ticks+ 1;
    next.modificationA = current.modificationA;
    next.modificationB = current.modificationB;
    next.modificationC = current.modificationC;
    next.modificationD = current.modificationD;
    next.modificationE = current.modificationE;
    next.modificationF = current.modificationF;
    next.connectionReferenceTime = current.connectionReferenceTime;
    next.timeOffsetFromClient = current.timeOffsetFromClient;
    next.notifiableGroup = current.notifiableGroup;

    [next adjustData];
    [next formatForBluetooth];
    return next;
}

- (void)loadSimData:(int) number {
    NSString *path;
    if (number == 1) {
        path = [[NSBundle mainBundle] pathForResource:@"participant-1" ofType:@"csv" inDirectory:@"simulated-data"];
    }
    else if (number == 2) {
        path = [[NSBundle mainBundle] pathForResource:@"participant-11" ofType:@"csv" inDirectory:@"simulated-data"];
    }
    else {
        path = [[NSBundle mainBundle] pathForResource:@"participant-12" ofType:@"csv" inDirectory:@"simulated-data"];
    }
    
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray *stringData = [NSMutableArray arrayWithArray:[content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
    self.simulationDescription = [stringData[0] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@","]];
    int size = (int)[stringData count] - 2;
    
    NSMutableArray *data = [[NSMutableArray alloc] initWithCapacity:size];
    for (int i = 2; i < [stringData count]; i++) {
        NSArray *stringValues = [stringData[i] componentsSeparatedByString:@","];
        
        NSMutableArray *dataState = [[NSMutableArray alloc] initWithCapacity:5];
        //values = [heart rate, stress, respiration rate, blood pressure (systolic), blood pressure (diastolic]
        NSNumber *heartRate = [NSNumber numberWithInt:MIN([(NSString *)stringValues[0] intValue], 255)];
        NSNumber *stress = [NSNumber numberWithInt:MIN([(NSString *)stringValues[1] intValue], 100)];
        NSNumber *respirationRate= [NSNumber numberWithInt:MIN([(NSString *)stringValues[2] intValue], 255)];
        NSNumber *systolicBloodPressure = [NSNumber numberWithInt:MIN([(NSString *)stringValues[3] intValue], 255)];
        NSNumber *diastolicBloodPressure = [NSNumber numberWithInt:MIN([(NSString *)stringValues[4] intValue], 255)];
        
        [dataState addObject:heartRate];
        [dataState addObject:stress];
        [dataState addObject:respirationRate];
        [dataState addObject:systolicBloodPressure];
        [dataState addObject:diastolicBloodPressure];
        
        [data addObject:dataState];
    }
    
    self.simulatorData = [NSArray arrayWithArray:data];
    self.simulatorStateIndex = 0;
}

- (void)startDataSimulator:(int) number {
    [self loadSimData:number];
    self.sampleDataIsStreaming = TRUE;
    self.ticks = 0;
}

@end
