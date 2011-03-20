//
//	FHStringAdditions.m
//	Version 0.0.1
//
//	Created by Max Dominik Weber on 2011-3-11.
//	This class is in the public domain.
//	If used, I'd appreciate it if you credit me.
//
//	E-Mail: m@masuco.de
//

#import "FHStringAdditions.h"

@implementation NSString (FHStringAdditions)

- (BOOL)isNotEmpty {
	return (![[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]);
}

- (NSCharacterSet*)characterSet {
	return [NSCharacterSet characterSetWithCharactersInString:self];
}

- (BOOL)containsOnlyCharactersInSet:(NSCharacterSet *)charSet {
	return [charSet isSupersetOfSet:[self characterSet]];
}

@end

@implementation NSMutableString (FHStringAdditions)

- (void)prependString:(NSString *)aString {
	[self insertString:aString atIndex:0];
}

@end
