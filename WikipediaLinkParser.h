/* *********************************************************************
 
 By Michael Morris (https://github.com/emsquared)
 Released into the Public Domain
 
 *********************************************************************** */

#import "TextualApplication.h"

@interface TPIWikipediaLinkParser : NSObject
- (void)messageReceivedByServer:(IRCClient *)client
						 sender:(NSDictionary *)senderDict
						message:(NSDictionary *)messageDict;

- (NSArray *)pluginSupportsServerInputCommands;
@end

@interface IRCWorld (WikipediaLinkParserExtension)
- (void)inputText:(id)str command:(NSString *)command;
@end