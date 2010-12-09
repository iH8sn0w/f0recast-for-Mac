//
//  f0recastAppDelegate.h
//  f0recast
//
//  Created by AriX on 3/13/10.
//  Copyright 2010 Ari Weinstein. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BWToolkitFramework/BWToolkitFramework.h>
#import "MobileDevice.h"

@interface f0recastAppDelegate : NSObject {
    NSWindow *window;
	
	IBOutlet NSTextField *serialNum;
	IBOutlet NSTextField *basebandVersion;
	IBOutlet NSTextField *basebandBootloaderVersion;
	IBOutlet NSTextField *modelNum;
	
	IBOutlet NSTextField *isUnlockable;
	IBOutlet NSTextField *isJailbreakable;
	IBOutlet NSTextField *isUntethered;
	IBOutlet NSTextField *deviceConnectionField;
	
	IBOutlet BWHyperlinkButton *ultrasn0wLink;
	IBOutlet BWHyperlinkButton *blacksn0wLink;
	IBOutlet BWHyperlinkButton *BootNeuterLink;
}

- (void)populateData;
- (void)dePopulateData;
- (NSString *)getDeviceValue:(NSString *)value;

@property (assign) IBOutlet NSWindow *window;

@end
