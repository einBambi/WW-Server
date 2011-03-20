//
//	AsyncServer.h
//	Version 0.0.1
//
//	Created by Max Dominik Weber on 2011-3-4.
//	This class is in the public domain.
//  If used, I'd appreciate it if you credit me.
//
//	E-Mail: m@masuco.de
//

/*
 *	Make sure to include AsyncSocket.h and AsyncSocket.m by Dustin Voss <d-j-v@earthlink.net> in the project.
 */

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

@class AsyncServer;
@protocol AsyncServerDelegate <NSObject>
@required
- (BOOL)reconnectDisconnectedListenerOfServer:(AsyncServer*)server;

@optional
- (void)serverDidStart:(AsyncServer*)server;
- (void)server:(AsyncServer*)server didAcceptNewSocketWithID:(long)i;
- (void)socketAtID:(long)i ofServer:(AsyncServer*)server didReadData:(NSData*)data;
- (void)socketAtID:(long)i ofServer:(AsyncServer*)server didReadString:(NSString*)string;
- (void)socketDidDisconnectAtID:(long)i ofServer:(AsyncServer*)server;

@end

@interface AsyncServer : NSObject {
	UInt16 port;
	id <AsyncServerDelegate> delegate;
	AsyncSocket* listener;
	NSMutableSet* clients;
	NSStringEncoding defaultEncoding;
	NSString* messageSeparator;
	long nextID;
}

@property (assign) id <AsyncServerDelegate> delegate;
@property (readwrite) NSStringEncoding defaultEncoding;
@property (copy) NSString* messageSeparator;

+ (id)serverThatListensOnPort:(UInt16)p withDelegate:(id <AsyncServerDelegate>)del;
- (void)listenOnPort:(UInt16)p;
- (BOOL)isListening;
- (void)stopListening;

- (void)sendData:(NSData*)data toSocketWithID:(long)i;
- (void)sendString:(NSString*)string toSocketWithID:(long)i;
- (void)sendString:(NSString*)string toSocketWithID:(long)i usingEncoding:(NSStringEncoding)encoding;
- (void)disconnectSocketWithID:(long)i;

- (void)disconnectAllSocketsIncludingListener:(BOOL)includingListener;

@end
