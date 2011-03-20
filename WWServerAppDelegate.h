//
//  WWServerAppDelegate.h
//  WWServer
//
//  Created by Max Dominik Weber on 3/5/11.
//  Copyright 2011 Max Dominik Weber. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WWServer.h"

@interface WWServerAppDelegate : NSObject <NSApplicationDelegate, WWServerDelegate> {
    NSWindow *window;
	WWServer* srv;
	IBOutlet NSTextView* inputTextView;
	NSMutableDictionary* registeredPlayers;
	NSMutableArray* mods;
	NSString* pathToMailSenderProgram;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)startServer:(id)sender;
- (IBAction)stopServer:(id)sender;

- (BOOL)readUsersPlist;
- (void)saveUsersPlist;

- (void)receive:(NSString*)msg;

@end
