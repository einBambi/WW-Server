//
//  WWPlayer.h
//  WWServer
//
//  Created by Max Dominik Weber on 3/5/11.
//  Copyright 2011 Max Dominik Weber. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	WWPlayerStateNone = 0,
	WWPlayerStateReadyToPlay,
	WWPlayerStateMod,
	WWPlayerStateAlive,
	WWPlayerStateDead
} WWPlayerState;

@class WWPlayer;
@protocol WWPlayerDelegate <NSObject>
@required
- (void)addPlayer:(WWPlayer*)pl;
- (void)removePlayer:(WWPlayer*)pl;

@optional
- (void)player:(WWPlayer*)receiver didReceiveLobbyChatMessage:(NSString*)msg fromPlayer:(WWPlayer*)sender;
- (void)player:(WWPlayer*)playerWhoJoined didJoinRoomWithPlayer:(WWPlayer*)playerInRoom;
- (void)player:(WWPlayer*)playerWhoParted didPartFromRoomWithPlayer:(WWPlayer*)playerInRoom;
- (void)player:(WWPlayer*)observer didSeePlayer:(WWPlayer*)playerWhoChangedNicks changingNicksFrom:(NSString*)oldNick to:(NSString*)newNick;

@end

@class WWRoom;
@interface WWPlayer : NSObject {
	id <WWPlayerDelegate> delegate;
	NSString* nick;
	WWPlayerState playerState;
}

+ (id)playerWithDelegate:(id <WWPlayerDelegate>)del;

- (id <WWPlayerDelegate>)delegate;
- (void)setDelegate:(id <WWPlayerDelegate>)del;

- (void)setNick:(NSString*)n;
- (NSString*)nick;
- (NSString*)description;

- (BOOL)isLoggedIn;
- (WWPlayerState)state;

- (WWRoom*)room;
- (void)join:(WWRoom*)r;
- (BOOL)part;

- (void)playerDidJoinRoom:(WWPlayer*)pl;
- (void)playerDidPartFromRoom:(WWPlayer*)pl;
- (void)player:(WWPlayer*)pl willChangeNickFrom:(NSString*)oldNick to:(NSString*)newNick;

- (void)receiveLobbyChatMessage:(NSString*)msg fromPlayer:(WWPlayer*)pl;

- (void)destroy;

@end
