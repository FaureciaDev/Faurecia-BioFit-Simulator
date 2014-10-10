
//  Faurecia BioFit Simulator
//  Copyright (c) 2014 Faurecia. All rights reserved.

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "FSSeatData.h"

@interface FSSeatDataDelegate : NSObject<NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, strong) FSSeatData *seatData;
@property (nonatomic, weak) NSTextField *command;

@end
