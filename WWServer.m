//
//  WWServer.m
//  WWServer
//
//  Created by Max Dominik Weber on 3/5/11.
//  Copyright 2011 Max Dominik Weber. All rights reserved.
//

#import "WWServer.h"
#import "FHStringAdditions.h"

@interface NSArray (WWServerAdditions)

- (NSString*)textFromIndex:(NSUInteger)index;

@end

@implementation NSArray (WWServerAdditions)

- (NSString*)textFromIndex:(NSUInteger)index {
	if (index >= [self count]) {
		return @"";
	}
	return [[self subarrayWithRange:NSMakeRange(index, [self count] - index)] componentsJoinedByString:@" "];
}

@end

@interface WWServer (private)

- (id)initWithDelegate:(id <WWServerDelegate>)del;

- (void)send:(NSString*)msg toPlayer:(WWPlayer*)pl;
- (void)sendToAll:(NSString*)msg;
- (void)sendToAllLoggedIn:(NSString*)msg;
- (void)sendToAllInLobby:(NSString*)msg;

- (BOOL)sendConfCode:(NSString*)confCode to:(NSString*)mailAddress;

@end

@implementation WWServer
@synthesize delegate;

+ (id)serverWithDelegate:(id <WWServerDelegate>)del {
	return [[self alloc] initWithDelegate:del];
}

- (BOOL)isRunning {
	return [srv isListening];
}

#pragma mark FHObject superclass

- (id)singleton {
	if (!(self = [super singleton])) {
		return nil;
	}
	return self;
}

#pragma mark NSObject superclass

- (void)dealloc {
	[srv dealloc];
	[super dealloc];
}

#pragma mark private category

- (id)initWithDelegate:(id <WWServerDelegate>)del {
	if (!(self = [self singleton])) {
		return nil;
	}
	[self setDelegate:del];
	players = [NSMutableArray array];
	srv = [AsyncServer serverThatListensOnPort:4814 withDelegate:self];
	return self;
}

- (void)send:(NSString *)msg toPlayer:(WWPlayer *)pl {
	for (long i = 0; i < [players count]; i++) {
		if ([players objectAtIndex:i] == pl) {
			[srv sendString:[[msg stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]] stringByAppendingString:@"\n"] toSocketWithID:i];
		}
	}
}

- (void)sendToAll:(NSString *)msg {
	for (long i = 0; i < [players count]; i++) {
		[srv sendString:[[msg stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]] stringByAppendingString:@"\n"] toSocketWithID:i];
	}
}

- (void)sendToAllLoggedIn:(NSString *)msg {
	for (long i = 0; i < [players count]; i++) {
		if ([[players objectAtIndex:i] isLoggedIn]) {
			[srv sendString:[[msg stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]] stringByAppendingString:@"\n"] toSocketWithID:i];
		}
	}
}

- (void)sendToAllInLobby:(NSString *)msg {
	for (long i = 0; i < [players count]; i++) {
		if ([[WWRoom lobbyRoom] containsPlayer:[players objectAtIndex:i]]) {
			[srv sendString:[[msg stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]] stringByAppendingString:@"\n"] toSocketWithID:i];
		}
	}
}

- (BOOL)sendConfCode:(NSString *)confCode to:(NSString *)mailAddress {
	return NO;
}

#pragma mark AsyncServerDelegate protocol

- (BOOL)reconnectDisconnectedListenerOfServer:(AsyncServer*)server {
	return YES;
}

- (void)serverDidStart:(AsyncServer*)server {
	if ([delegate respondsToSelector:@selector(serverDidStart)]) {
		[delegate serverDidStart];
	}
}

- (void)server:(AsyncServer*)server didAcceptNewSocketWithID:(long)i {
	if ([delegate respondsToSelector:@selector(newConnectionWithID:)]) {
		[delegate newConnectionWithID:i];
	}
	[WWPlayer playerWithDelegate:self];
}

- (void)socketAtID:(long)i ofServer:(AsyncServer*)server didReadString:(NSString*)string {
	NSMutableString* m = [NSMutableString stringWithString:[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	WWPlayer* pl = [players objectAtIndex:i];
	if ([[players objectAtIndex:i] isLoggedIn] && [delegate respondsToSelector:@selector(playerWithNick:sent:)]) {
		[delegate playerWithNick:[pl nick] sent:m];
	} else if ([delegate respondsToSelector:@selector(playerWithID:sent:)]) {
		[delegate playerWithID:i sent:m];
	}
	//analyze:
	NSMutableArray* args = [NSMutableArray arrayWithArray:[m componentsSeparatedByString:@" "]];
	NSString* cmd = [[args objectAtIndex:0] uppercaseString];
	[args removeObjectAtIndex:0];
	if ([cmd isEqualToString:@"PING"]) {
		[srv sendString:[NSString stringWithFormat:@"PONG SRV %@\n", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]] toSocketWithID:i];
		return;
	}
	if ([cmd isEqualToString:@"PONG"]) {
		return;
	}
	if ([cmd isEqualToString:@"NICK"]) {
		if ([args count] < 1 || ![[args objectAtIndex:0] isNotEmpty] || [[args objectAtIndex:0] length] > 16) {
			//nickname too long or missing
			[srv sendString:@"NICKERR LONG\n" toSocketWithID:i];
			return;
		}
		NSString* nick = [args objectAtIndex:0];
		NSString* pass = [args textFromIndex:1];
		if (![nick containsOnlyCharactersInSet:[@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz" characterSet]]) {
			[srv sendString:@"NICKERR CHAR\n" toSocketWithID:i];
			return;
		}
		if ([pl isLoggedIn]) {
			if ([delegate playerWithNick:nick canLogInWithPassword:pass]) {
				if ([WWRoom playerWithNick:nick]) {
					[srv sendString:@"NICKERR TAKEN\n" toSocketWithID:i];
					return;
				}
				[pl setNick:nick];
				return;
			}
			[srv sendString:@"NICKERR PASS\n" toSocketWithID:i];
			return;
		}
		//login
		if ([delegate playerWithNick:nick canLogInWithPassword:pass]) {
			if ([WWRoom playerWithNick:nick]) {
				if ([[WWRoom playerWithNick:nick] delegate] != self) {
					//incompatible delegates
					[srv sendString:@"NICKERR INCOMP\n" toSocketWithID:i];
					return;
				}
				[players replaceObjectAtIndex:i withObject:[WWRoom playerWithNick:nick]];
				//initialize player state for the new socket…
				return;
			}
			[pl setNick:nick];
			[pl join:[WWRoom lobbyRoom]];
			return;
		}
		[srv sendString:@"NICKERR PASS\n" toSocketWithID:i];
		return;
	}
	if ([cmd isEqualToString:@"NOCMD"]) {
		//kick if understanding the cmd is critical…
		return;
	}
	//login required for CMDs below
	if ([cmd isEqualToString:@"CHAT"]) {
		if (![pl isLoggedIn]) {
			[srv sendString:[NSString stringWithFormat:@"LOGIN %@\n", cmd] toSocketWithID:i];
			return;
		}
		[[pl room] chatMessage:[args textFromIndex:0] fromPlayer:pl];
		return;
	}
	if ([cmd isEqualToString:@"REG"]) {
		if (![pl isLoggedIn]) {
			[srv sendString:[NSString stringWithFormat:@"LOGIN %@\n", cmd] toSocketWithID:i];
			return;
		}
		if ([args count] < 1) {
			[srv sendString:@"REG MAIL\n" toSocketWithID:i];
			return;
		}
		if ([args count] < 2) {
			//confirmation code
			if (![delegate confirmRegistrationOfNick:[pl nick] withCode:[args objectAtIndex:0]]) {
				[srv sendString:@"REG CODE\n" toSocketWithID:i];
				return;
			}
			[srv sendString:@"REG CONF\n" toSocketWithID:i];
			return;
		}
		//mail/pass
		NSString* mailAddress = [args objectAtIndex:0];
		if ([mailAddress hasPrefix:@"mailto:"]) {
			mailAddress = [mailAddress substringFromIndex:[@"mailto:" length]];
		}
		if (![delegate registerNick:[pl nick] withMail:mailAddress password:[args textFromIndex:1]]) {
			[srv sendString:@"REG ERR\n" toSocketWithID:i];
			return;
		}
		[srv sendString:@"REG SENT\n" toSocketWithID:i];
		return;
	}
	//more CMDs…
	[srv sendString:[NSString stringWithFormat:@"NOCMD %@\n", cmd] toSocketWithID:i];
}

- (void)socketDidDisconnectAtID:(long)i ofServer:(AsyncServer*)server {
	if ([[players objectAtIndex:i] isLoggedIn]) {
		if ([delegate respondsToSelector:@selector(disconnectedNick:)]) {
			[delegate disconnectedNick:[[players objectAtIndex:i] nick]];
		}
	} else {
		if ([delegate respondsToSelector:@selector(disconnectedID:)]) {
			[delegate disconnectedID:i];
		}
	}
	WWPlayer* pl = [players objectAtIndex:i];
	[players replaceObjectAtIndex:i withObject:[NSNull null]];
	if (![players containsObject:pl]) {
		[pl destroy];
	}
}

#pragma mark WWPlayerDelegate protocol

- (void)addPlayer:(WWPlayer *)pl {
	[players addObject:pl];
}

- (void)removePlayer:(WWPlayer *)pl {
	while ([players containsObject:pl]) {
		[players replaceObjectAtIndex:[players indexOfObject:pl] withObject:[NSNull null]];
	}
}

- (void)player:(WWPlayer *)receiver didReceiveLobbyChatMessage:(NSString *)msg fromPlayer:(WWPlayer *)sender {
	[self send:[NSString stringWithFormat:@"CHAT %@ %@", sender, msg] toPlayer:receiver];
}

- (void)player:(WWPlayer *)pl didJoinRoomWithPlayer:(WWPlayer *)playerInRoom {
	if ([playerInRoom room] == [WWRoom lobbyRoom]) {
		[self send:[NSString stringWithFormat:@"STATE %@ NONE", pl] toPlayer:playerInRoom];
		if (pl == playerInRoom) {
			for (WWPlayer* p in [playerInRoom room]) {
				if (p == pl) {
					continue;
				}
				NSString* state = @"NONE";
				if ([p state] == WWPlayerStateReadyToPlay) {
					state = @"PLAYER";
				}
				if ([p state] == WWPlayerStateMod) {
					state = @"MOD";
				}
				[self send:[NSString stringWithFormat:@"STATE %@ %@", p, state] toPlayer:pl];
			}
		}
	}
}

- (void)player:(WWPlayer *)pl didPartFromRoomWithPlayer:(WWPlayer *)playerInRoom {
	if ([playerInRoom room] == [WWRoom lobbyRoom]) {
		NSString* state = @"OFF";
		if ([WWRoom playerWithNick:[pl nick]]) {
			state = @"GAME";
		}
		[self send:[NSString stringWithFormat:@"STATE %@ %@", pl, state] toPlayer:playerInRoom];
	}
}

- (void)player:(WWPlayer *)observer didSeePlayer:(WWPlayer *)playerWhoChangedNicks changingNicksFrom:(NSString *)oldNick to:(NSString *)newNick {
	[self send:[NSString stringWithFormat:@"NICK %@ %@", oldNick, newNick] toPlayer:observer];
}

@end
