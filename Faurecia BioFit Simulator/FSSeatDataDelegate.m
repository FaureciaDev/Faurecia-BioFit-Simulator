
//  Faurecia BioFit Simulator
//  Copyright (c) 2014 Faurecia. All rights reserved.

#import "FSSeatDataDelegate.h"

@implementation FSSeatDataDelegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return kFS_SEAT_DATA_UUID.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = [tableColumn identifier];
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];

    if ([identifier isEqualToString:@"Name"]) {
        cellView.textField.stringValue = kFS_SEAT_DATA_DESCRIPTION[row];
    }
    else if ([identifier isEqualToString:@"ID"]) {
        cellView.textField.stringValue = [NSString stringWithFormat:@"%02ld %@", (long)row,[kFS_SEAT_DATA_UUID[row] FS_representativeString]];
    }
    else if ([identifier isEqualToString:@"Value"]) {
        // TODO: show semantic decimal format of data with proper precision
        CBUUID *uuid = kFS_SEAT_DATA_UUID[row];
        NSData *data = [self.seatData get:uuid];
        BOOL dataIsSigned = ([uuid isEqual:kFS_UUID_UPPER_BACKREST_POSITION] ||
                             [uuid isEqual:kFS_UUID_BACK_HEATING_AND_COOLING] ||
                             [uuid isEqual:kFS_UUID_CUSHION_HEATING_AND_COOLING]);
        NSString *value;
        switch (data.length) {
            case 0:
                value = @"<empty>";
                break;
            case 1:
                if (dataIsSigned) {
                    value = [NSString stringWithFormat:@"%d %@",
                             [FSSeatDataValue unpack_int8:data],
                             [data description]];
                }
                else {
                    value = [NSString stringWithFormat:@"%u %@",
                             [FSSeatDataValue unpack_uint8:data],
                             [data description]];
                }
                break;
            case 2:
                value = [NSString stringWithFormat:@"%d %@",
                         [FSSeatDataValue unpack_int16:data],
                         [data description]];
                break;
            case 4:
                value = [NSString stringWithFormat:@"%u %@",
                         [FSSeatDataValue unpack_uint32:data],
                         [data description]];
                break;
            default:
                if ([uuid isEqual:kFS_UUID_SYSTEM_TIME_STAMP] || [uuid isEqual:kFS_UUID_CONNECTION_REFERENCE_TIME]) {
                    value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                }
                else {
                    value = [data description];
                }
                break;
        }
        cellView.textField.stringValue = value;
    }

    return cellView;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    if ([aNotification.object isKindOfClass:[NSTableView class]]) {
        NSTableView *table = (NSTableView *)aNotification.object;
        NSString *characteristic = kFS_SEAT_DATA_DESCRIPTION[table.selectedRow];
        if (characteristic) {
            [self.command setStringValue:[NSString stringWithFormat:@"%@", characteristic]];
            [self.command.window makeFirstResponder:self.command];
        }
    }
}

@end
