/*
 * Name: OgreTest.m
 * Project: OgreKit
 *
 * Creation Date: Sep 7 2003
 * Author: Isao Sonobe <sonobe@gauge.scphys.kyoto-u.ac.jp>
 * Copyright: Copyright (c) 2003 Isao Sonobe, All rights reserved.
 * License: OgreKit License
 *
 * Encoding: UTF8
 * Tabsize: 4
 */

#import <OgreKit/OgreKit.h>
#import "OgreTest.h"


@implementation OgreTest

- (IBAction)match:(id)sender
{
	OGRegularExpression			*rx;
	OGRegularExpressionMatch	*match, *lastMatch = nil;
	int	i;
	
	// キャレットを最後に。
	[resultTextView setSelectedRange: NSMakeRange([[resultTextView string] length], 0)];
	
	// テキストフィールドから読み込む
	NSString	*pattern = [patternTextField stringValue];
	NSString	*str = [targetTextField stringValue];

	// \の代替文字
	NSString	*escapeChar = [escapeCharacterTextField stringValue];
	[OGRegularExpression setDefaultEscapeCharacter:escapeChar];
	// 構文
	[OGRegularExpression setDefaultSyntax:OgreRubySyntax];
	
	/*double	sum = 0;
	NSDate	*processTime;
	for(i = 0; i < 1000; i++) {
		processTime = [NSDate date];*/

		// 正規表現オブジェクトの作成
		NS_DURING
			rx = [OGRegularExpression regularExpressionWithString: pattern options: OgreFindNotEmptyOption | OgreCaptureGroupOption];
		NS_HANDLER
			// 例外処理
			[resultTextView insertText: [NSString stringWithFormat: @"%@ caught in 'regularExpressionWithString:'\n", [localException name]]];
			[resultTextView insertText: [NSString stringWithFormat: @"reason = \"%@\"\n", [localException reason]]];
			return;
		NS_ENDHANDLER
		
		/*match = [rx matchInString:str];
		if (match == nil) {
			// マッチしなかった場合
			[resultTextView insertText:@"search fail\n"];
			return;
		}

	sum += -[processTime timeIntervalSinceNow];
	}
	NSLog(@"process time: %fsec/inst", sum/1000);*/
	
	/* 検索 */
	NSEnumerator	*enumerator = [rx matchEnumeratorInString:str];
	
	[resultTextView insertText: [NSString stringWithFormat:@"OgreKit version: %@, OniGuruma version: %@\n", [OGRegularExpression version], [OGRegularExpression onigurumaVersion]]];
	[resultTextView insertText: [NSString stringWithFormat:@"target string: \"%@\", escape character: \"%@\"\n", str, [OGRegularExpression defaultEscapeCharacter]]];
	
	int	matches = 0;
	while((match = [enumerator nextObject]) != nil) {
		if(matches == 0) {
			NSRange	range = [match rangeOfPrematchString];
			[resultTextView insertText: [NSString stringWithFormat:@"prematch string: (%d-%d) \"%@\"\n", range.location, range.location + range.length, [match prematchString]]];
		} else {
			NSRange	range = [match rangeOfStringBetweenMatchAndLastMatch];
			[resultTextView insertText: [NSString stringWithFormat:@"string between match #%d and match #%d: (%d-%d) \"%@\"\n", matches - 1, matches, range.location, range.location + range.length, [match stringBetweenMatchAndLastMatch]]];
		}

		for (i = 0; i < [match count]; i++) {
			NSRange	subexpRange = [match rangeOfSubstringAtIndex:i];
			[resultTextView insertText: [NSString stringWithFormat:@"#%d.%d", [match index], i]];
			if([match nameOfSubstringAtIndex:i] != nil) {
				[resultTextView insertText:[NSString stringWithFormat:@"(\"%@\")", [match nameOfSubstringAtIndex:i]]];
			}
			[resultTextView insertText:[NSString stringWithFormat:@": (%d-%d)", subexpRange.location, subexpRange.location + subexpRange.length]];
			if([match substringAtIndex:i] == nil) {
				[resultTextView insertText:@" no match!\n"];
			} else {
				[resultTextView insertText:@" \""];
				[resultTextView insertText:[match substringAtIndex:i]];
				[resultTextView insertText:@"\"\n"];
			}
			OGRegularExpressionMatch	*capturehistory = [match captureHistoryAtIndex:i];
			if (capturehistory != nil) {
				int index;
				for (index = 0; index < [capturehistory count]; index++) {
					[resultTextView insertText:[NSString stringWithFormat:@" capture history#%d.%d.%d: \"%@\"\n", [match index], i, index, [capturehistory substringAtIndex:index]]];
				}
			}
		}
		/*NSLog(@"match: %@", [match description]);
		[NSArchiver archiveRootObject:match toFile: [@"~/Desktop/mt.archive" stringByExpandingTildeInPath]];
		OGRegularExpressionMatch	*match2 = [NSUnarchiver unarchiveObjectWithFile: [@"~/Desktop/mt.archive" stringByExpandingTildeInPath]];
		NSLog(@"match2: %@", [match2 description]);
		match = match2;*/
		matches++;
		lastMatch = match;
	}
	if(lastMatch != nil) {
		NSRange	range = [lastMatch rangeOfPostmatchString];
		[resultTextView insertText: [NSString stringWithFormat:@"postmatch string: (%d-%d) \"%@\"\n", range.location, range.location + range.length, [lastMatch postmatchString]]];
	} else {
		[resultTextView insertText:@"search fail\n"];
	}
	[resultTextView insertText:@"\n"];
	[resultTextView setFont:[NSFont fontWithName:@"Monaco" size:10.0]];
	[resultTextView display];
}

- (IBAction)replace:(id)sender
{
	OGRegularExpression	*rx;
	
	// キャレットを最後に。
	[resultTextView setSelectedRange: NSMakeRange([[resultTextView string] length], 0)];
	
	// テキストフィールドから読み込む
	NSString	*pattern = [patternTextField stringValue];
	NSString	*str     = [targetTextField stringValue];
	NSString	*newStr  = [replaceTextField stringValue];
	
	// \の代替文字
	NSString	*escapeChar = [escapeCharacterTextField stringValue];
	[OGRegularExpression setDefaultEscapeCharacter:escapeChar];
	// 構文
	[OGRegularExpression setDefaultSyntax:OgreRubySyntax];
	
	/*NSDate	*processTime;
	int i;
	double	sum = 0;
	for(i = 0; i < 1000; i++) {
		processTime = [NSDate date];*/
		
		// 正規表現オブジェクトの作成
		rx = [OGRegularExpression regularExpressionWithString: pattern options: OgreFindNotEmptyOption | OgreCaptureGroupOption];
		
		/*[rx replaceAllMatchesInString:str withString:newStr options:OgreNoneOption];
		sum += -[processTime timeIntervalSinceNow];
	}
	NSLog(@"process time: %fsec/inst", sum/1000);*/
	
	// 置換
	[resultTextView insertText: [NSString stringWithFormat:@"replaced string: \"%@\"\n", [rx replaceAllMatchesInString:str withString:newStr options:OgreNoneOption]]];
	[resultTextView setFont:[NSFont fontWithName:@"Monaco" size:10.0]];
	[resultTextView display];
}

// 開始処理
- (void)awakeFromNib
{
	[resultTextView setRichText: NO];
	[resultTextView setFont:[NSFont fontWithName:@"Monaco" size:10.0]];
	[resultTextView setContinuousSpellCheckingEnabled:NO];

	[self replaceTest];
	[self categoryTest];
}

// デリゲートに処理を委ねた置換／マッチした部分での分割
- (void)replaceTest
{
	NSLog(@"Replacement Test");
	// デリゲートに処理を委ねた置換
	NSString	*targetString = @"36.5C, 3.8C, -195.8C";
	NSLog(@"%@", targetString);
	OGRegularExpression	*celciusRegex = [OGRegularExpression regularExpressionWithString:@"([+-]?\\d+(?:\\.\\d+)?)C\\b"];
	NSLog(@"%@", [celciusRegex replaceAllMatchesInString:targetString 
		delegate:self 
		replaceSelector:@selector(fahrenheitFromCelsius:contextInfo:) 
		contextInfo:nil]);
	
	// 文字列を分割する
	OGRegularExpression	*delimiterRegex = [OGRegularExpression regularExpressionWithString:@"\\s*,\\s*"];
	NSLog(@"%@", [[delimiterRegex splitString:targetString] description]);
}

- (void)categoryTest
{
	NSLog(@"NSString (OgreKitAdditions) Test");
	NSString	*string = @"36.5C, 3.8C, -195.8C";
	NSLog(@"%@", [[string componentsSeparatedByRegularExpressionString:@"\\s*,\\s*"] description]);
	NSMutableString *mstr = [NSMutableString stringWithString:string];
	unsigned	numberOfReplacement = [mstr replaceOccurrencesOfRegularExpressionString:@"C"
		withString:@"F" options:OgreNoneOption range:NSMakeRange(0, [string length])];
	NSLog(@"%d %@", numberOfReplacement, mstr);
	NSRange matchRange = [string rangeOfRegularExpressionString:@"\\s*,\\s*"];
	NSLog(@"(%d, %d)", matchRange.location, matchRange.length);
}

// 摂氏を華氏に変換する。
- (NSString*)fahrenheitFromCelsius:(OGRegularExpressionMatch*)aMatch contextInfo:(id)contextInfo
{
	//NSLog(@"matchedString:%@ index:%d", [aMatch matchedString], [aMatch index]);
	double	celcius = [[aMatch substringAtIndex:1] doubleValue];
	double	fahrenheit = celcius * 9.0 / 5.0 + 32.0;
	
	// 置換した文字列を返す。nilを返した場合は置換を終了する。
	return [NSString stringWithFormat:@"%.1fF", fahrenheit];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)aApp
{
	return YES;	// 全てのウィンドウを閉じたら終了する。
}


@end
