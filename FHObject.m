//
//	FHObject.m
//	Version 0.0.1
//
//	Created by Max Dominik Weber on 2011-3-5.
//	This class is in the public domain.
//  If used, I'd appreciate it if you credit me.
//
//	E-Mail: m@masuco.de
//

#import "FHObject.h"

@implementation FHObject

+ (id)singleton {
	static FHObject* FHSingleton = nil;
	@synchronized(self) {
		if (FHSingleton == nil) {
			FHSingleton = [[self alloc] init];
		}
	}
	return FHSingleton;
}

- (id)singleton {
	return [[self class] singleton];
}

@end
