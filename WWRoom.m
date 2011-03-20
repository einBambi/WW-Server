//
//  WWRoom.m
//  WWServer
//
//  Created by Max Dominik Weber on 3/11/11.
//  Copyright 2011 Max Dominik Weber. All rights reserved.
//

#import "WWRoom.h"

@implementation WWRoom

+ (NSSet*)allRooms {
	NSSet* games = [self allGames];
	if (games) {
		return [games setByAddingObject:[self lobbyRoom]];
	}
	return [NSSet setWithObject:[self lobbyRoom]];
}

+ (NSSet*)allGames {
	static NSMutableSet* FHAllGames = nil;
	@synchronized(self) {
		if (FHAllGames == nil) {
			FHAllGames = [NSMutableSet set];
		}
	}
	return FHAllGames;
}

+ (WWRoom*)lobbyRoom {
	static WWRoom* WWLobbyRoom = nil;
	@synchronized(self) {
		if (WWLobbyRoom == nil) {
			WWLobbyRoom = [[self alloc] init];
		}
	}
	return WWLobbyRoom;
}

+ (WWRoom*)roomWithPlayer:(WWPlayer *)player {
	for (WWRoom* room in [self allRooms]) {
		if ([room playerWithNick:[player nick]]) {
			return room;
		}
	}
	return nil;
}

+ (WWPlayer*)playerWithNick:(NSString *)nick {
	for (WWRoom* room in [self allRooms]) {
		if ([room playerWithNick:nick]) {
			return [room playerWithNick:nick];
		}
	}
	return nil;
}

- (WWPlayer*)playerWithNick:(NSString *)nick {
	for (WWPlayer* pl in players) {
		if ([[pl nick] isEqualToString:nick]) {
			return pl;
		}
	}
	return nil;
}

- (NSSet*)allPlayers {
	return [NSSet setWithSet:players];
}

- (BOOL)containsPlayer:(WWPlayer *)player {
	return [players containsObject:player];
}

- (void)addPlayer:(WWPlayer *)player {
	[players addObject:player];
	for (WWPlayer* pl in self) {
		[pl playerDidJoinRoom:player];
	}
	//maybe start countdown…
}

- (BOOL)removePlayer:(WWPlayer*)player {
	if (![self containsPlayer:player]) {
		return NO;
	}
	[players removeObject:player];
	for (WWPlayer* pl in self) {
		[pl playerDidPartFromRoom:player];
	}
	//maybe stop countdown…
	return YES;
}

- (void)player:(WWPlayer *)player willChangeNickFrom:(NSString *)oldNick to:(NSString *)newNick {
	for (WWPlayer* pl in self) {
		[pl player:player willChangeNickFrom:oldNick to:newNick];
	}
}

- (BOOL)chatMessage:(NSString *)msg fromPlayer:(WWPlayer *)player {
	if (self == [WWRoom lobbyRoom]) {
		for (WWPlayer* pl in self) {
			[pl receiveLobbyChatMessage:msg fromPlayer:player];
		}
		return YES;
	}
	return NO;
}

#pragma mark FHObject superclass

+ (id)singleton {
	return [self lobbyRoom];
}

#pragma mark NSObject superclass

- (id)init {
	if (!(self = [super init])) {
		return nil;
	}
	players = [NSMutableSet set];
	return self;
}

#pragma mark NSFastEnumeration protocol

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len {
	return [[self allPlayers] countByEnumeratingWithState:state objects:stackbuf count:len];
}

@end
