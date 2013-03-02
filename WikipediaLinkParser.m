/* ********************************************************************* 

 By Michael Morris (https://github.com/emsquared)
 Released into the Public Domain
 
 *********************************************************************** */

#import "WikipediaLinkParser.h"

@implementation IRCWorld (WikipediaLinkParserExtension)

- (void)inputText:(id)str command:(NSString *)command
{
    if (PointerIsEmpty(str)) {
        return;
    }

    NSMutableAttributedString *muteString = [str mutableCopy];

    while (1 == 1) {
        NSRange linkRange = [TLORegularExpression string:[muteString string] rangeOfRegex:@"\\[\\[([^\\]]+)\\]\\]"];

        if (linkRange.location == NSNotFound) {
            break;
        }

        if (linkRange.length < 5) {
            break;
        }
        
        NSRange cutRange = NSMakeRange((linkRange.location + 2),
                                       (linkRange.length - 4));

        NSString *linkInside;

        linkInside = [muteString.string safeSubstringWithRange:cutRange];
        if ([linkInside contains:@"|"]) {
            linkInside = [linkInside safeSubstringToIndex:[linkInside stringPosition:@"|"]];
            linkInside = [linkInside trim];
        }
        linkInside = [linkInside encodeURIComponent];
        linkInside = [@"https://en.wikipedia.org/wiki/" stringByAppendingString:linkInside];

        [muteString replaceCharactersInRange:linkRange withString:linkInside];
    }

    [self.selected.client inputText:muteString command:command];
}

@end

@implementation TPIWikipediaLinkParser

#pragma mark -
#pragma mark Server Input

- (void)messageReceivedByServer:(IRCClient *)client
						 sender:(NSDictionary *)senderDict
						message:(NSDictionary *)messageDict
{
	NSArray *params = messageDict[@"messageParamaters"];

	NSString *message = messageDict[@"messageSequence"];

	IRCChannel *channel = [client findChannel:params[0]];

    if (PointerIsEmpty(channel)) {
        return;
    }

    message = [message stripEffects];

    NSArray *linkMatches = [TLORegularExpression matchesInString:message withRegex:@"\\[\\[([^\\]]+)\\]\\]"];

    if (linkMatches.count > 0) {
        //NSString *message = [NSString stringWithFormat:@"Found %i possible Wikipedia links: ", linkMatches.count];

        //[client printDebugInformation:message channel:channel];

        NSInteger loopIndex = 0;

        for (__strong NSString *linkRaw in linkMatches) {

            if (linkRaw.length < 5) {
                break;
            }

            loopIndex += 1;

            NSRange cutRange = NSMakeRange(2, (linkRaw.length - 4));

            linkRaw = [linkRaw safeSubstringWithRange:cutRange];
            if ([linkRaw contains:@"|"]) {
                linkRaw = [linkRaw safeSubstringToIndex:[linkRaw stringPosition:@"|"]];
                linkRaw = [linkRaw trim];
            }
            message = [NSString stringWithFormat:@" %i: %@ —> https://en.wikipedia.org/wiki/%@", loopIndex, linkRaw, [linkRaw encodeURIComponent]];

            [client printDebugInformation:message channel:channel];
        }
        
    }

}

- (NSArray *)pluginSupportsServerInputCommands
{
	return @[@"privmsg"];
}

@end
