//
//  WWRoom.h
//  WWServer
//
//  Created by Max Dominik Weber on 3/11/11.
//  Copyright 2011 Max Dominik Weber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FHObject.h"
#import "WWPlayer.h"

@interface WWRoom : FHObject <NSFastEnumeration> {
	NSMutableSet* players;
}

+ (NSSet*)allRooms;
+ (NSSet*)allGames;

+ (WWRoom*)lobbyRoom;

+ (WWRoom*)roomWithPlayer:(WWPlayer*)player;
+ (WWPlayer*)playerWithNick:(NSString*)nick;
- (WWPlayer*)playerWithNick:(NSString*)nick;

- (NSSet*)allPlayers;
- (BOOL)containsPlayer:(WWPlayer*)player;
- (void)addPlayer:(WWPlayer*)player;
- (BOOL)removePlayer:(WWPlayer*)player;

- (void)player:(WWPlayer*)player willChangeNickFrom:(NSString*)oldNick to:(NSString*)newNick;

- (BOOL)chatMessage:(NSString*)msg fromPlayer:(WWPlayer*)player;

@end
