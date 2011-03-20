//
//	AsyncServer.m
//	Version 0.0.1
//
//	Created by Max Dominik Weber on 2011-3-4.
//	This class is in the public domain.
//  If used, I'd appreciate it if you credit me.
//
//	E-Mail: m@masuco.de
//

#import "AsyncServer.h"

@interface AsyncServer (private)

- (id)initWithDelegate:(id <AsyncServerDelegate>)del andListenOnPort:(UInt16)p;

- (AsyncSocket*)socketWithID:(long)i;

@end

@implementation AsyncServer
@synthesize delegate, defaultEncoding, messageSeparator;

- (id)init {
	return [self initWithDelegate:nil andListenOnPort:-1];
}

+ (id)serverThatListensOnPort:(UInt16)p withDelegate:(id <AsyncServerDelegate>)del {
	return [[self alloc] initWithDelegate:del andListenOnPort:p];
}

- (void)listenOnPort:(UInt16)p {
	if (listener) {
		[listener disconnectAfterWriting];
	}
	port = p;
	listener = [[AsyncSocket alloc] initWithDelegate:self userData:-1];
	[listener acceptOnPort:port error:nil];
	if ([delegate respondsToSelector:@selector(serverDidStart:)]) {
		[delegate serverDidStart:self];
	}
}

- (BOOL)isListening {
	if (listener) {
		return YES;
	}
	return NO;
}

- (void)stopListening {
	if (listener) {
		[listener disconnectAfterWriting];
	}
}

- (void)sendData:(NSData*)data toSocketWithID:(long)i {
	[[self socketWithID:i] writeData:data withTimeout:-1 tag:i];
}

- (void)sendString:(NSString*)string toSocketWithID:(long)i {
	[self sendString:string toSocketWithID:i usingEncoding:defaultEncoding];
}

- (void)sendString:(NSString*)string toSocketWithID:(long)i usingEncoding:(NSStringEncoding)encoding {
	[self sendData:[string dataUsingEncoding:encoding] toSocketWithID:i];
}

- (void)disconnectSocketWithID:(long)i {
	[[self socketWithID:i] disconnectAfterWriting];
}

- (void)disconnectAllSocketsIncludingListener:(BOOL)includingListener {
	for (AsyncSocket* sock in clients) {
		[sock disconnectAfterWriting];
	}
	if (includingListener) {
		[listener disconnectAfterWriting];
	}
}

- (void)dealloc {
	[self disconnectAllSocketsIncludingListener:YES];
	[super dealloc];
}

#pragma mark private category

- (id)initWithDelegate:(id <AsyncServerDelegate>)del andListenOnPort:(UInt16)p {
	if (!(self = [super init])) {
		return nil;
	}
	clients = [NSMutableSet set];
	[self setDefaultEncoding:NSUTF8StringEncoding];
	[self setMessageSeparator:@"\n"];
	nextID = 0;
	[self setDelegate:del];
	[self listenOnPort:p];
	return self;
}

- (AsyncSocket*)socketWithID:(long)i {
	if (i < 0) {
		return listener;
	}
	for (AsyncSocket* sock in clients) {
		if ([sock userData] == i) {
			return sock;
		}
	}
	return nil;
}

#pragma mark AsyncSocketDelegate category

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket {
	[newSocket setDelegate:self];
	[newSocket setUserData:nextID];
	nextID++;
	[clients addObject:newSocket];
	if ([delegate respondsToSelector:@selector(server:didAcceptNewSocketWithID:)]) {
		[delegate server:self didAcceptNewSocketWithID:[newSocket userData]];
	}
	[newSocket readDataToData:[messageSeparator dataUsingEncoding:defaultEncoding] withTimeout:-1 tag:[newSocket userData]];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData*)data withTag:(long)tag {
	[sock readDataToData:[messageSeparator dataUsingEncoding:defaultEncoding] withTimeout:-1 tag:tag];
	if ([delegate respondsToSelector:@selector(socketAtID:ofServer:didReadData:)]) {
		[delegate socketAtID:[sock userData] ofServer:self didReadData:data];
	}
	if ([delegate respondsToSelector:@selector(socketAtID:ofServer:didReadString:)]) {
		[delegate socketAtID:[sock userData] ofServer:self didReadString:[[NSString alloc] initWithData:data encoding:defaultEncoding]];
	}
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
	if ([delegate respondsToSelector:@selector(socketDidDisconnectAtID:ofServer:)]) {
		[delegate socketDidDisconnectAtID:[sock userData] ofServer:self];
	}
	[clients removeObject:sock];
	[sock dealloc];
}

@end
