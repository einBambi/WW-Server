//
//	WWServer.h
//	WWServer
//
//	Created by Max Dominik Weber on 3/5/11.
//	Copyright 2011 Max Dominik Weber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncServer.h"
#import "FHObject.h"
#import "WWPlayer.h"
#import "WWRoom.h"

@protocol WWServerDelegate <NSObject>
@required
- (NSString*)passwordForNick:(NSString*)nick;
- (BOOL)playerWithNick:(NSString*)nick canLogInWithPassword:(NSString*)password;
- (BOOL)registerNick:(NSString*)nick withMail:(NSString*)mail password:(NSString*)password;
- (BOOL)confirmRegistrationOfNick:(NSString*)nick withCode:(NSString*)confirmationCode;

@optional
- (void)serverDidStart;
- (void)newConnectionWithID:(long)i;
- (void)playerWithID:(long)i sent:(NSString*)msg;
- (void)playerWithNick:(NSString*)nick sent:(NSString *)msg;
- (void)disconnectedID:(long)i;
- (void)disconnectedNick:(NSString*)nick;
- (void)listenerDidDisconnect;

@end

@interface WWServer : FHObject <AsyncServerDelegate, WWPlayerDelegate> {
	id <WWServerDelegate> delegate;
	AsyncServer* srv;
	NSMutableArray* players;
}

@property (assign) id <WWServerDelegate> delegate;

+ (id)serverWithDelegate:(id <WWServerDelegate>)del;

- (BOOL)isRunning;

@end
