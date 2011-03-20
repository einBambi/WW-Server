//
//  WWServerAppDelegate.m
//  WWServer
//
//  Created by Max Dominik Weber on 3/5/11.
//  Copyright 2011 Max Dominik Weber. All rights reserved.
//

#import "WWServerAppDelegate.h"
#import "FHStringAdditions.h"

@implementation WWServerAppDelegate
@synthesize window;

- (IBAction)startServer:(id)sender {
	srv = [WWServer serverWithDelegate:self];
	[self readUsersPlist];
}

- (IBAction)stopServer:(id)sender {
	[srv dealloc];
	srv = nil;
	[inputTextView setString:@""];
}

- (BOOL)readUsersPlist {
	NSString* errorDesc = nil;
	NSPropertyListFormat format;
	NSString* plistPath = [@"~/Library/Application Support/Fenhl/WWServer/Users.plist" stringByExpandingTildeInPath];
	if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
		plistPath = [[NSBundle mainBundle] pathForResource:@"Users" ofType:@"plist"];
	}
	NSData* plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
	NSDictionary* temp = (NSDictionary*)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
	if (!temp) {
		[self receive:[NSString stringWithFormat:@"Error reading plist: %@, format: %d", errorDesc, format]];
		registeredPlayers = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"swordfish", @"Macca meja_13", @"EAOW4enye4C1is2", @"dn4j6r", @"JeNeRegretteRien", nil] forKeys:[NSArray arrayWithObjects:@"test", @"Fenhl", @"ericssson", @"Jan", @"Garou", nil]];
		mods = [NSMutableArray arrayWithObjects:@"Fenhl", @"ericssson", @"Jan", @"Garou", nil];
		return NO;
	}
	registeredPlayers = [NSMutableDictionary dictionaryWithDictionary:[temp objectForKey:@"PASS"]];
	mods = [NSMutableArray arrayWithArray:[temp objectForKey:@"MOD"]];
	return YES;
}

- (void)saveUsersPlist {
	[[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:mods, registeredPlayers, nil] forKeys:[NSArray arrayWithObjects:@"MOD", @"PASS", nil]] writeToFile:[@"~/Library/Application Support/Fenhl/WWServer/Users.plist" stringByExpandingTildeInPath] atomically:YES];
}

- (void)receive:(NSString*)msg {
	[inputTextView setString:[NSString stringWithFormat:@"%@\n%@", msg, [inputTextView string]]];
}

#pragma mark NSApplicationDelegate protocol

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	pathToMailSenderProgram = [[[NSBundle mainBundle] pathForResource:@"simple-mailer" ofType:@"py"] copy];
	[self startServer:self];
	[inputTextView setFont:[NSFont fontWithName:@"Menlo-Regular" size:12]];
	[inputTextView setTextColor:[NSColor colorWithDeviceRed:0.1568627451 green:0.9960784314 blue:0.07843137255 alpha:1]];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
	return YES;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	if ([srv isRunning]) {
		if ([[NSAlert alertWithMessageText:@"Do you really want to quit?" defaultButton:@"Quit" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"The server is still running. If you quit now, all games will be aborted and all players will be disconnected."] runModal] != NSAlertDefaultReturn) {
			[window makeKeyAndOrderFront:self];
			return NO;
		}
	}
	return YES;
}

#pragma mark WWServerDelegate protocol

- (NSString*)passwordForNick:(NSString*)nick {
	for (NSString* s in [registeredPlayers allKeys]) {
		if ([s isEqualToString:nick]) {
			return [registeredPlayers objectForKey:nick];
		}
	}
	return nil;
}

- (BOOL)playerWithNick:(NSString *)nick canLogInWithPassword:(NSString *)password {
	if (![nick isNotEmpty]) {
		return NO;
	}
	return (![[self passwordForNick:nick] isNotEmpty] || [[self passwordForNick:nick] isEqualToString:password]);
}

- (BOOL)registerNick:(NSString *)nick withMail:(NSString *)mail password:(NSString *)password {
	//generate confirmation code
	NSString* allowedChars = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
	int r = 30 + (rand() % 20);
	NSMutableString* confCode = [NSMutableString stringWithCapacity:r];
	for (int i = 0; i < r; i++) {
		[confCode appendFormat:@"%c", [allowedChars characterAtIndex:rand() % [allowedChars length]]];
	}
	//save data in Users.plist…
	//send mail…
	return NO;
}

- (BOOL)confirmRegistrationOfNick:(NSString *)nick withCode:(NSString *)confirmationCode {
	//check against Users.plist…
	//update database if code is correct…
	return NO;
}

- (void)serverDidStart {
	[inputTextView setString:[@"Server started. Current IPs: " stringByAppendingString:[[[NSHost currentHost] addresses] componentsJoinedByString:@" "]]];
}

- (void)newConnectionWithID:(long)i {
	[self receive:[NSString stringWithFormat:@"New connection: %d", i]];
}

- (void)playerWithNick:(NSString *)nick sent:(NSString *)msg {
	[self receive:[NSString stringWithFormat:@"%@: %@", nick, msg]];
}

- (void)playerWithID:(long)i sent:(NSString*)msg {
	[self receive:[NSString stringWithFormat:@"%d: %@", i, msg]];
}

- (void)disconnectedID:(long)i {
	[self receive:[NSString stringWithFormat:@"Disconnected: %d", i]];
}

- (void)disconnectedNick:(NSString *)nick {
	[self receive:[NSString stringWithFormat:@"Disconnected: %@", nick]];
}

- (void)listenerDidDisconnect {
	[self receive:@"Listener disconnected, reconnecting…"];
}

@end
