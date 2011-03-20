//
//  WWPlayer.m
//  WWServer
//
//  Created by Max Dominik Weber on 3/5/11.
//  Copyright 2011 Max Dominik Weber. All rights reserved.
//

#import "WWPlayer.h"
#import "FHStringAdditions.h"
#import "WWRoom.h"

@interface WWPlayer (private)

- (id)initWithDelegate:(id <WWPlayerDelegate>) del;

@end

@implementation WWPlayer

+ (id)playerWithDelegate:(id<WWPlayerDelegate>)del {
	return [[self alloc] initWithDelegate:del];
}

- (id <WWPlayerDelegate>)delegate {
	return delegate;
}

- (void)setDelegate:(id<WWPlayerDelegate>)del {
	[delegate removePlayer:self];
	delegate = del;
	[delegate addPlayer:self];
}

- (void)setNick:(NSString *)n {
	[[self room] player:self willChangeNickFrom:[self nick] to:n];
	nick = [n copy];
}

- (NSString*)nick {
	return [nick copy];
}

- (NSString*)description {
	return [self nick];
}

- (BOOL)isLoggedIn {
	return [nick isNotEmpty];
}

- (WWPlayerState)state {
	return playerState;
}

- (WWRoom*)room {
	return [WWRoom roomWithPlayer:self];
}

- (void)join:(WWRoom *)r {
	[self part];
	[r addPlayer:self];
}

- (BOOL)part {
	return [[self room] removePlayer:self];
}

- (void)playerDidJoinRoom:(WWPlayer *)pl {
	if ([delegate respondsToSelector:@selector(player:didJoinRoomWithPlayer:)]) {
		[delegate player:pl didJoinRoomWithPlayer:self];
	}
}

- (void)playerDidPartFromRoom:(WWPlayer *)pl {
	if ([delegate respondsToSelector:@selector(player:didPartFromRoomWithPlayer:)]) {
		[delegate player:pl didPartFromRoomWithPlayer:self];
	}
}

- (void)player:(WWPlayer *)pl willChangeNickFrom:(NSString *)oldNick to:(NSString *)newNick {
	if ([delegate respondsToSelector:@selector(player:didSeePlayer:changingNicksFrom:to:)]) {
		[delegate player:self didSeePlayer:pl changingNicksFrom:oldNick to:newNick];
	}
}

- (void)receiveLobbyChatMessage:(NSString *)msg fromPlayer:(WWPlayer *)pl {
	if ([delegate respondsToSelector:@selector(player:didReceiveLobbyChatMessage:fromPlayer:)]) {
		[delegate player:self didReceiveLobbyChatMessage:msg fromPlayer:pl];
	}
}

- (void)destroy {
	[[self room] removePlayer:self];
	[delegate removePlayer:self];
}

#pragma mark private category

- (id)initWithDelegate:(id<WWPlayerDelegate>)del {
	if (!(self = [super init])) {
		return nil;
	}
	[self setNick:@""];
	playerState = WWPlayerStateNone;
	[self setDelegate:del];
	return self;
}

@end
