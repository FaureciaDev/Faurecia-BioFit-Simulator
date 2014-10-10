
//  Faurecia BioFit Simulator
//  Copyright (c) 2014 Faurecia. All rights reserved.

#import <Cocoa/Cocoa.h>
#import <IOBluetooth/IOBluetooth.h>
#import "FSSeatDataDelegate.h"

@interface FSAppDelegate : NSObject <NSApplicationDelegate, CBPeripheralManagerDelegate>

@property (atomic, strong) FSSeatData *seatData;
@property (atomic, assign) BOOL readyToAdvertise;
@property (atomic, assign) BOOL readyToUpdate;

@property (nonatomic, assign) BOOL sittingInSeat;

@property (nonatomic, weak) IBOutlet NSWindow *window;
@property (nonatomic, weak) IBOutlet NSButton *sitDownButton;
@property (nonatomic, weak) IBOutlet NSTextField *command;
@property (nonatomic, weak) IBOutlet NSButton *scenario1Button;
@property (nonatomic, weak) IBOutlet NSButton *scenario2Button;
@property (nonatomic, weak) IBOutlet NSButton *scenario3Button;
@property (nonatomic, weak) IBOutlet NSTextField *infoLabel;
@property (nonatomic, weak) IBOutlet NSTableView *table;
@property (nonatomic, weak) IBOutlet NSButton *modificationAButton;
@property (nonatomic, weak) IBOutlet NSButton *modificationBButton;
@property (nonatomic, weak) IBOutlet NSButton *modificationCButton;
@property (nonatomic, weak) IBOutlet NSButton *modificationDButton;
@property (nonatomic, weak) IBOutlet NSButton *modificationEButton;
@property (nonatomic, weak) IBOutlet NSButton *modificationFButton;
@property (weak) IBOutlet NSTextField *seatBackLabel;
@property (weak) IBOutlet NSTextField *seatCushionLabel;
@property (weak) IBOutlet NSTextField *ambientLabel;

@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CBMutableService *service;
@property (nonatomic, strong) NSDictionary *characteristics;

@property (nonatomic, strong) NSString *currentScenario;
@property (nonatomic, strong) FSSeatDataDelegate *seatDataDelegate;

@end
