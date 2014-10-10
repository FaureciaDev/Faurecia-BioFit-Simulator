
//  Faurecia BioFit Simulator
//  Copyright (c) 2014 Faurecia. All rights reserved.

#import "FSAppDelegate.h"

@implementation FSAppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {
    [FSSeatData initialize];

    self.seatData = [[FSSeatData alloc] init];
    self.seatDataDelegate = [[FSSeatDataDelegate alloc] init];

    NSLog(@"simulator ready");
}

static volatile dispatch_queue_t bluetooth_queue;
static volatile dispatch_queue_t simulator_queue;
static dispatch_source_t timer;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
#if defined(FAURECIA_TEST)
    NSLog(@"disabled simulator event queues during testing");
#else
    self.table.delegate = self.seatDataDelegate;
    self.table.dataSource = self.seatDataDelegate;
    self.seatDataDelegate.command = self.command;

    dispatch_queue_t high_priority_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);

    bluetooth_queue = dispatch_queue_create("bluetooth", DISPATCH_QUEUE_SERIAL);
    dispatch_set_target_queue(bluetooth_queue, high_priority_queue);

    // all core bluetooth delegate callbacks will run on the bluetooth_queue
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:bluetooth_queue];

    simulator_queue = dispatch_queue_create("simulator", DISPATCH_QUEUE_SERIAL);
    dispatch_set_target_queue(simulator_queue, high_priority_queue);

    // timer ticks update the simulation at 1 Hz
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, simulator_queue);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        self.seatData = [FSSeatData nextState:self.seatData];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self refreshDisplay];
        });

        if (self.readyToUpdate) {
            dispatch_async(bluetooth_queue, ^{
                [self notifyUpdates:@[kFS_UUID_NOTIFIABLE_GROUP_VALUES]];
            });
        }
    });
    dispatch_resume(timer);

    NSLog(@"simulator event queues ready");
#endif
}

- (NSArray *)peripheralCharacteristics {

#define CR__(UUID) [[CBMutableCharacteristic alloc] initWithType:UUID properties:(CBCharacteristicPropertyRead) value:nil permissions:CBAttributePermissionsReadable]

#define CR_N(UUID) [[CBMutableCharacteristic alloc] initWithType:UUID properties:(CBCharacteristicPropertyRead|CBCharacteristicPropertyNotify) value:nil permissions:CBAttributePermissionsReadable]

#define CRW_(UUID) [[CBMutableCharacteristic alloc] initWithType:UUID properties:(CBCharacteristicPropertyRead|CBCharacteristicPropertyWrite) value:nil permissions:CBAttributePermissionsReadable|CBAttributePermissionsWriteable]

    return @[CR__(kFS_UUID_OCCUPANT_PRESENCE),
             CR__(kFS_UUID_SYSTEM_TIME_STAMP),
             CR__(kFS_UUID_CONNECTION_REFERENCE_TIME),
             CR__(kFS_UUID_CURRENT_ELAPSED_TIME),

             CRW_(kFS_UUID_NOTIFIABLE_GROUP),
             CR_N(kFS_UUID_NOTIFIABLE_GROUP_VALUES),
             CR__(kFS_UUID_WRITE_EFFECT_COMPLETE),

             CR__(kFS_UUID_HEART_RATE),
             CR__(kFS_UUID_RESPIRATION_RATE),
             CR__(kFS_UUID_INTEGRATED_PULMONARY_INDEX),
             CR__(kFS_UUID_HEART_RATE_VARIABILITY),
             CR__(kFS_UUID_BLOOD_PRESSURE_SYSTOLIC),
             CR__(kFS_UUID_BLOOD_PRESSURE_DIASTOLIC),
             CR__(kFS_UUID_BLOOD_FLOW_INDEX),

             CR__(kFS_UUID_INTEGRATED_COMFORT_INDEX),
             CR__(kFS_UUID_STRESS),
             CR__(kFS_UUID_EMOTIONAL_VALENCE),
             CR__(kFS_UUID_EMOTIONAL_AROUSAL),

             CR__(kFS_UUID_OCCUPANT_MASS),
             CR__(kFS_UUID_OCCUPANT_CENTER_OF_MASS),

             CR__(kFS_UUID_AMBIENT_HUMIDITY),
             CR__(kFS_UUID_CUSHION_SURFACE_HUMIDITY),
             CR__(kFS_UUID_UPPER_BACK_SURFACE_HUMIDITY),
             CR__(kFS_UUID_LOWER_BACK_SURFACE_HUMIDITY),

             CR__(kFS_UUID_CUSHION_SURFACE_TEMPERATURE),
             CR__(kFS_UUID_BACK_SURFACE_TEMPERATURE),
             CR__(kFS_UUID_AMBIENT_TEMPERATURE),

             CRW_(kFS_UUID_LOWER_LUMBAR_PRESSURE),
             CRW_(kFS_UUID_MIDDLE_LUMBAR_PRESSURE),
             CRW_(kFS_UUID_UPPER_LUMBAR_PRESSURE),
             CRW_(kFS_UUID_CUSHION_SIDE_BOLSTER_PRESSURE),
             CRW_(kFS_UUID_BACK_SIDE_BOLSTER_PRESSURE),
             CRW_(kFS_UUID_CUSHION_LENGTH),
             CRW_(kFS_UUID_CUSHION_EDGE_PRESSURE),
             CRW_(kFS_UUID_UPPER_BACKREST_POSITION),

             CRW_(kFS_UUID_MASSAGE_PROGRAM_SELECTION),
             CRW_(kFS_UUID_MASSAGE_INTENSITY),
             CRW_(kFS_UUID_MASSAGE_SPEED),

             CRW_(kFS_UUID_VENTILATION_LEVEL),
             CRW_(kFS_UUID_BACK_HEATING_AND_COOLING),
             CRW_(kFS_UUID_CUSHION_HEATING_AND_COOLING)];
}

- (void)sitInSeat {
    if (self.readyToAdvertise) {
        [self.sitDownButton setTitle:@"Get Up"];
        self.sittingInSeat = TRUE;
        dispatch_async(simulator_queue, ^{
            self.seatData->values.occupantPresence = TRUE;
        });

        [self.peripheralManager startAdvertising: @{ CBAdvertisementDataLocalNameKey: @"BioFit-01" }];
        self.readyToUpdate = TRUE;
    }
}

- (void)getOutOfSeat {
    [self.sitDownButton setTitle:@"Sit Down"];
    self.sittingInSeat = FALSE;
    dispatch_async(simulator_queue, ^{
            self.seatData->values.occupantPresence = FALSE;
    });

    [self.peripheralManager stopAdvertising];
}

- (IBAction)sitDownInSeat:(NSButtonCell *)sender {
    if (self.sittingInSeat) {
        [self getOutOfSeat];
    }
    else {
        [self sitInSeat];
    }
}

- (void) refreshDisplay {
    NSString *message = @"";
    if(self.seatData.sampleDataIsStreaming) {
        message = [NSString stringWithFormat:@"%@ \n%d/%d sec", self.currentScenario, self.seatData.simulatorStateIndex, (ULONG)[self.seatData.simulatorData count]];
    }
    else {
        message = @"No scenario selected";
    }

    int heartRate = self.seatData->values.heartRate;
    int ambientTemp = self.seatData->values.ambientTemperature;
    int ambientHumidity = self.seatData->values.ambientHumidity;
    int backTemp = self.seatData->values.backSurfaceTemperature;
    int upperBackHumidity = self.seatData->values.upperBackSurfaceHumidity;
    int lowerBackHumidity = self.seatData->values.lowerBackSurfaceHumidity;
    int cushionTemp = self.seatData->values.cushionSurfaceTemperature;
    int cushionHumidity = self.seatData->values.cushionSurfaceHumidity;

    message = [NSString stringWithFormat:@"%@\n\u2665 %d BPM", message, heartRate];
    
    [self.infoLabel setStringValue:message];
    [self.ambientLabel setStringValue:[NSString stringWithFormat: @"Ambient\n%d \u00B0C\n%d%% Humidity", ambientTemp, ambientHumidity]];
    [self.seatCushionLabel setStringValue:[NSString stringWithFormat: @"Seat Cushion\n%d \u00B0C\n%d%% Humidity", cushionTemp, cushionHumidity]];
    [self.seatBackLabel setStringValue:[NSString stringWithFormat: @"Seat Back\n%d \u00B0C\nUpper\n%d%% Humidity\nLower\n%d%% Humidity", backTemp, upperBackHumidity, lowerBackHumidity]];

    self.seatDataDelegate.seatData = self.seatData;

    NSRange rowRange = { 0, self.table.numberOfRows };
    NSIndexSet *rowIndexes = [NSIndexSet indexSetWithIndexesInRange:rowRange];
    NSIndexSet *columnIndexes = [NSIndexSet indexSetWithIndex:1];
    [self.table reloadDataForRowIndexes:rowIndexes columnIndexes:columnIndexes];
}

- (IBAction)startScenario:(id)sender {
    if (sender == self.scenario1Button) {
        [self.seatData startDataSimulator:1];
        self.currentScenario = @"Scenario 1";
    }
    else if (sender == self.scenario2Button) {
        [self.seatData startDataSimulator:2];
        self.currentScenario = @"Scenario 2";
    }
    else if (sender == self.scenario3Button) {
        [self.seatData startDataSimulator:3];
        self.currentScenario = @"Scenario 3";
        
    }
    
    self.currentScenario = [NSString stringWithFormat:@"%@: %@", self.currentScenario, self.seatData.simulationDescription];
}

- (IBAction)updateSimulatorWithCommand:(id)sender {
    NSString *command = [self.command.stringValue stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (command.length > 0) {
        // TODO if '=' in command, use left side to determine CBUUID
        NSInteger row = self.table.selectedRow;
        CBUUID *c = kFS_SEAT_DATA_UUID[row];
        if ([command characterAtIndex:0] <= '9') {
            int value = [command intValue];
            dispatch_async(simulator_queue, ^{
                [self.seatData configure:c withTestValue:value];
            });
            self.command.stringValue = @"";
        }
    }
}

- (void)notifyUpdates:(NSArray *)cs {
    for (CBUUID *uuid in cs) {
        CBMutableCharacteristic *c = [self.characteristics objectForKey:uuid];
        NSData *value = [self.seatData get:uuid];
        if (value) {
            BOOL ok = [self.peripheralManager updateValue:value forCharacteristic:c onSubscribedCentrals:nil];
            if (!ok) {
                // FIXME handle core bluetooth not ready and retry: use gcd queue?
                NSLog(@"updateValue:%@ forCharacteristic:%@ FAILED", value, [c.UUID FS_representativeString]);
            }
        }
    }
}

- (IBAction)enableCustomModification:(id)sender {
    dispatch_async(simulator_queue, ^{
        if (sender == self.modificationAButton) {
            self.seatData.modificationA = !self.seatData.modificationA;
        }
        if (sender == self.modificationBButton) {
            self.seatData.modificationB = !self.seatData.modificationB;
        }
        if (sender == self.modificationCButton) {
            self.seatData.modificationC = !self.seatData.modificationC;
        }
        if (sender == self.modificationDButton) {
            self.seatData.modificationD = !self.seatData.modificationD;
        }
        if (sender == self.modificationEButton) {
            self.seatData.modificationE = !self.seatData.modificationE;
        }
        if (sender == self.modificationFButton) {
            self.seatData.modificationF = !self.seatData.modificationF;
        }
    });
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSLog(@"didUpdateState: %d", (int)peripheral.state);

    if (CBPeripheralManagerStatePoweredOn == peripheral.state) {
        self.service =
            [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:@"E5E8451C-A235-4A96-9E81-EAE3DF296564"]
                                           primary:YES];

        NSArray *characteristics = [self peripheralCharacteristics];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:characteristics.count];

        for (CBMutableCharacteristic *c in characteristics) {
            [dict setObject:c forKey:c.UUID];
        }
        self.characteristics = dict;

        self.service.characteristics = characteristics;

        [self.peripheralManager addService:self.service];
    }
    else {
        [peripheral stopAdvertising];
        [peripheral removeAllServices];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
         willRestoreState:(NSDictionary *)dict
{
    NSLog(@"willRestoreState");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
            didAddService:(CBService *)service
                    error:(NSError *)error
{
    NSLog(@"didAddService: uuid=%@ count=%lu error=%@",
          [service.UUID FS_representativeString], service.characteristics.count, error);

    self.readyToAdvertise = TRUE;
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral
                                       error:(NSError *)error
{
    NSLog(@"didStartAdvertising: error=%@", error);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
                  central:(CBCentral *)central
didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"didSubscribe: %@ %@", central, characteristic);

    [self.peripheralManager setDesiredConnectionLatency:CBPeripheralManagerConnectionLatencyLow
                                             forCentral:central];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
                  central:(CBCentral *)central
didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"didUnsubscribe: %@ %@", central, characteristic);
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    NSLog(@"isReadyToUpdate");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
    didReceiveReadRequest:(CBATTRequest *)request
{
    NSData *value = [self.seatData get:request.characteristic.UUID];
    if (value) {
        NSLog(@"didReceiveReadRequest: %@ %@",
              [request.characteristic.UUID FS_representativeString], value);
        request.value = value;
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
    }
    else {
        NSLog(@"didReceiveReadRequest: %@ NOT FOUND",
              [request.characteristic.UUID FS_representativeString]);
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorAttributeNotFound];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
  didReceiveWriteRequests:(NSArray *)requests
{
    NSLog(@"didReceiveWriteRequests: %@", requests);

    for (CBATTRequest *request in requests) {
        CBUUID *uuid = request.characteristic.UUID;
        NSData *value = request.value;
        if ([kFS_UUID_NOTIFIABLE_GROUP isEqual:uuid]) {
            dispatch_async(simulator_queue, ^{
                NSLog(@"subscribing to notifiable values");
                [self.seatData subscribe:value];
            });
        }
        else {
            dispatch_time_t timer_delay = dispatch_time(DISPATCH_TIME_NOW, 5.2 * NSEC_PER_SEC);
            dispatch_after(timer_delay, simulator_queue, ^{
                NSLog(@"setting value %@ to %@", uuid, value);
                [self.seatData configure:uuid withUserValue:value];
            });
        }
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
    }
}

@end
