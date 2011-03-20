//
//	FHStringAdditions.h
//	Version 0.0.1
//
//	Created by Max Dominik Weber on 2011-3-11.
//	This class is in the public domain.
//	If used, I'd appreciate it if you credit me.
//
//	E-Mail: m@masuco.de
//

#import <Foundation/Foundation.h>

@interface NSString (FHStringAdditions)

- (BOOL)isNotEmpty;
- (NSCharacterSet*)characterSet;
- (BOOL)containsOnlyCharactersInSet:(NSCharacterSet*)charSet;

@end

@interface NSMutableString (FHStringAdditions)

- (void)prependString:(NSString*)aString;

@end
