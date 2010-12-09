//
//  f0recastAppDelegate.m
//  f0recast
//
//  Created by AriX on 3/13/10.
//  Copyright 2010 Ari Weinstein. All rights reserved.
//

#import "f0recastAppDelegate.h"

static f0recastAppDelegate *classPointer;
struct am_device* device;
struct am_device_notification *notification;

void notification_callback(struct am_device_notification_callback_info *info, int cookie) {	
	if (info->msg == ADNCI_MSG_CONNECTED) {
		NSLog(@"Device connected.");
		device = info->dev;
		AMDeviceConnect(device);
		AMDevicePair(device);
		AMDeviceValidatePairing(device);
		AMDeviceStartSession(device);
		[classPointer populateData];
	} else if (info->msg == ADNCI_MSG_DISCONNECTED) {
		NSLog(@"Device disconnected.");
		[classPointer dePopulateData];
	} else {
		NSLog(@"Received device notification: %d", info->msg);
	}
}

@implementation f0recastAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	classPointer = self;
	AMDeviceNotificationSubscribe(notification_callback, 0, 0, 0, &notification);
}

- (void)populateData {
	NSString *serialNumber = [self getDeviceValue:@"SerialNumber"];
	NSString *bootloaderVersionText = [self getDeviceValue:@"BasebandBootloaderVersion"];
	NSString *basebandVersionText = [self getDeviceValue:@"BasebandVersion"];
	NSString *modelNumber = [self getDeviceValue:@"ModelNumber"];
	NSString *deviceString = [self getDeviceValue:@"ProductType"];
	NSString *firmwareVersion = [self getDeviceValue:@"ProductVersion"];
	
	[serialNum setStringValue:serialNumber];
	if (![deviceString hasPrefix:@"iPod"]) {
		[basebandBootloaderVersion setStringValue:[bootloaderVersionText substringToIndex:[bootloaderVersionText length]-5]];
		[basebandVersion setStringValue:basebandVersionText];
	} else {
		[basebandBootloaderVersion setStringValue:@"N/A"];
		[basebandVersion setStringValue:@"N/A"];
	}
	[modelNum setStringValue:modelNumber];
	[deviceConnectionField setStringValue:[NSString stringWithFormat:@"Device (Firmware %@) Connected", firmwareVersion]];
	
	if ([deviceString hasPrefix:@"iPod"]) {
		[isUnlockable setStringValue:@"N/A"];
		if ([modelNumber hasPrefix:@"MC"] || [modelNumber hasPrefix:@"PC"]) {
			[isUntethered setStringValue:@"No"];
		} else {
			[isUntethered setStringValue:@"Yes"];
		}
		if ([deviceString isEqualToString:@"iPod1,1"]) {
			deviceString = @"iPod Touch 1G";
			[isJailbreakable setStringValue:@"Yes (always)"];
		} else if ([deviceString isEqualToString:@"iPod2,1"]) {
			deviceString = [@"iPod Touch 2G [" stringByAppendingString:[[modelNumber substringToIndex:2] stringByAppendingString:@"]"]];
			[isJailbreakable setStringValue:@"Yes (always)"];
			if ([deviceString hasPrefix:@"MC"]) {
				if ([firmwareVersion isEqualToString:@"3.1.3"]) [isJailbreakable setStringValue:@"Only if SHSH is on file."];
				else [isJailbreakable setStringValue:@"Yes (don't upgrade!)"];
			}
		} else if ([deviceString isEqualToString:@"iPod3,1"]) {
			if ([firmwareVersion isEqualToString:@"3.1.3"]) [isJailbreakable setStringValue:@"Only if SHSH is on file."];
			else [isJailbreakable setStringValue:@"Yes (don't upgrade!)"];
			deviceString = @"iPod Touch 3G";
		}
	} else if ([deviceString hasPrefix:@"iPhone"]) {
		if ([deviceString isEqualToString:@"iPhone1,1"]) {
			deviceString = @"iPhone 2G";
			[isUntethered setStringValue:@"Yes"];
			[isJailbreakable setStringValue:@"Yes"];
		} else if ([deviceString isEqualToString:@"iPhone1,2"]) {
			deviceString = @"iPhone 3G";
			[isUntethered setStringValue:@"Yes"];
			[isJailbreakable setStringValue:@"Yes"];
		} else if ([deviceString isEqualToString:@"iPhone2,1"]) {
			if ([[[serialNumber substringToIndex:5] substringFromIndex:3] intValue] < 40) [isUntethered setStringValue:@"Yes"];
			else [isUntethered setStringValue:@"Depends if it's refurbished"];
			if ([[[serialNumber substringToIndex:3] substringFromIndex:2] isEqualToString:@"0"]) [isUntethered setStringValue:@"Depends if it's refurbished"];
			if ([firmwareVersion isEqualToString:@"3.1.3"]) [isJailbreakable setStringValue:@"Only if SHSH is on file."];
			else [isJailbreakable setStringValue:@"Yes (don't upgrade!)"];
			deviceString = @"iPhone 3G  S⃣ ";
		}
		if ([[bootloaderVersionText substringToIndex:[bootloaderVersionText length]-5] isEqualToString:@"5.8"]) {
			NSError *errorMessage = [NSError errorWithDomain:@"f0recast5.8message" code:58 userInfo:[NSDictionary dictionaryWithObject:@"Hello fellow 3G user! If you are looking to unlock your phone and have accidentally updated your baseband, you are in luck! Your iPhone's bootloader is version 5.8 which downgradable to a unlockable baseband. Once jailbroken, you may launch Cydia, and search for FuzzyBand, Then, use FuzzyBand to downgrade your baseband and install ultrasn0w to unlock your iPhone!" forKey:NSLocalizedDescriptionKey]];
			[[NSApplication sharedApplication] presentError:errorMessage];
		}
		if ([basebandVersionText isEqualToString:@"04.26.08"]) {
			[isUnlockable setStringValue:@"Yes"];
			[ultrasn0wLink setHidden:NO];
		} else if ([basebandVersionText isEqualToString:@"05.11.07"]) {
			[isUnlockable setStringValue:@"Yes"];
			[blacksn0wLink setHidden:NO];
		} else if ([basebandVersionText isEqualToString:@"04.05.04_G"]) {
			[isUnlockable setStringValue:@"Yes"];
			[BootNeuterLink setHidden:NO];
		} else {
			[isUnlockable setStringValue:@"No"];
		}
	} else {
		deviceString = @"Unknown Device";
	}
	
	[deviceConnectionField setStringValue:[NSString stringWithFormat:@"%@ (Firmware %@) Connected", deviceString, firmwareVersion]];
}

- (void)dePopulateData {
	[serialNum setStringValue:@""];
	[basebandVersion setStringValue:@""];
	[basebandBootloaderVersion setStringValue:@""];
	[modelNum setStringValue:@""];
	
	[isUnlockable setStringValue:@""];
	[isJailbreakable setStringValue:@""];
	[isUntethered setStringValue:@""];
	[ultrasn0wLink setHidden:YES];
	[blacksn0wLink setHidden:YES];
	[BootNeuterLink setHidden:YES];
	[deviceConnectionField setStringValue:@"No Device Connected"];
}

- (NSString *)getDeviceValue:(NSString *)value {
	return AMDeviceCopyValue(device, 0, value);
}

@end
