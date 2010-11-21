// Created by Satoshi Nakagawa <psychs AT limechat DOT net> <http://github.com/psychs/limechat>
// Modifications by Michael Morris <mikey AT codeux DOT com> <http://github.com/mikemac11/Textual>
// You can redistribute it and/or modify it under the new BSD license.

#import "ListDialog.h"
#import "Preferences.h"
#import "NSDictionaryHelper.h"

@interface ListDialog (Private)
- (void)sortedInsert:(NSArray*)item inArray:(NSMutableArray*)ary;
- (void)reloadTable;
@end

@implementation ListDialog

@synthesize delegate;
@synthesize sortKey;
@synthesize sortOrder;

- (id)init
{
	if ((self = [super init])) {
		[NSBundle loadNibNamed:@"ListDialog" owner:self];
		
		list = [NSMutableArray new];
		sortKey = 1;
		sortOrder = NSOrderedDescending;
	}
	return self;
}

- (void)dealloc
{
	[list release];
	[filteredList release];
	[super dealloc];
}

- (void)start
{
	[table setDoubleAction:@selector(onJoin:)];
	
	[self show];
}

- (void)show
{
	if (![self.window isVisible]) {
		[self.window center];
	}
	
	[self.window makeKeyAndOrderFront:nil];
}

- (void)close
{
	[self.window close];
}

- (void)clear
{
	[list removeAllObjects];
	[filteredList release];
	filteredList = nil;
	
	[self reloadTable];
}

- (void)addChannel:(NSString*)channel count:(NSInteger)count topic:(NSString*)topic
{
	NSArray* item = [NSArray arrayWithObjects:channel, [NSNumber numberWithInteger:count], topic, [topic attributedStringWithIRCFormatting], nil];
	
	NSString* filter = [filterText stringValue];
	if (filter.length) {
		if (!filteredList) {
			filteredList = [NSMutableArray new];
		}
		
		if ([channel rangeOfString:filter options:NSCaseInsensitiveSearch].location != NSNotFound
			|| [topic rangeOfString:filter options:NSCaseInsensitiveSearch].location != NSNotFound) {
			[self sortedInsert:item inArray:filteredList];
		}
	}
	
	[self sortedInsert:item inArray:list];
	[self reloadTable];
}

- (void)reloadTable
{
	if ([[filterText stringValue] length] >= 1 && [list count] != [filteredList count]) {
		[channelCount setStringValue:[NSString stringWithFormat:TXTLS(@"LIST_DIALOG_HAS_SEARCH_RESULTS"), [list count], [filteredList count]]];
	} else {
		[channelCount setStringValue:[NSString stringWithFormat:TXTLS(@"LIST_DIALOG_HAS_CHANNELS"), [list count]]];
	}
	
	[table reloadData];
}

static NSInteger compareItems(NSArray* self, NSArray* other, void* context)
{
	ListDialog* dialog = (ListDialog*)context;
	NSInteger key = dialog.sortKey;
	NSComparisonResult order = dialog.sortOrder;
	
	NSString* mine = [self safeObjectAtIndex:key];
	NSString* others = [other safeObjectAtIndex:key];
	
	NSComparisonResult result;
	if (key == 1) {
		result = [mine compare:others];
	} else {
		result = [mine caseInsensitiveCompare:others];
	}
	
	if (order == NSOrderedDescending) {
		return - result;
	} else {
		return result;
	}
}

- (void)sort
{
	[list sortUsingFunction:compareItems context:self];
}

- (void)sortedInsert:(NSArray*)item inArray:(NSMutableArray*)ary
{
	const NSInteger THRESHOLD = 5;
	NSInteger left = 0;
	NSInteger right = ary.count;
	
	while (right - left > THRESHOLD) {
		NSInteger pivot = (left + right) / 2;
		if (compareItems([ary safeObjectAtIndex:pivot], item, self) == NSOrderedDescending) {
			right = pivot;
		} else {
			left = pivot;
		}
	}
	
	for (NSInteger i=left; i<right; ++i) {
		if (compareItems([ary safeObjectAtIndex:i], item, self) == NSOrderedDescending) {
			[ary insertObject:item atIndex:i];
			return;
		}
	}
	
	[ary insertObject:item atIndex:right];
}

#pragma mark -
#pragma mark Actions

- (void)onClose:(id)sender
{
	[self.window close];
}

- (void)onUpdate:(id)sender
{
	if ([delegate respondsToSelector:@selector(listDialogOnUpdate:)]) {
		[delegate listDialogOnUpdate:self];
	}
}

- (void)onJoin:(id)sender
{
	NSArray* ary = list;
	NSString* filter = [filterText stringValue];
	if (filter.length) {
		ary = filteredList;
	}
	
	NSIndexSet* indexes = [table selectedRowIndexes];
	for (NSUInteger i=[indexes firstIndex]; i!=NSNotFound; i=[indexes indexGreaterThanIndex:i]) {
		NSArray* item = [ary safeObjectAtIndex:i];
		if ([delegate respondsToSelector:@selector(listDialogOnJoin:channel:)]) {
			[delegate listDialogOnJoin:self channel:[item safeObjectAtIndex:0]];
		}
	}
}

- (void)onSearchFieldChange:(id)sender
{
	[filteredList release];
	filteredList = nil;

	NSString* filter = [filterText stringValue];
	if (filter.length) {
		NSMutableArray* ary = [NSMutableArray new];
		for (NSArray* item in list) {
			NSString* channel = [item safeObjectAtIndex:0];
			NSString* topic = [[item safeObjectAtIndex:2] string];
			if ([channel rangeOfString:filter options:NSCaseInsensitiveSearch].location != NSNotFound
				|| [topic rangeOfString:filter options:NSCaseInsensitiveSearch].location != NSNotFound) {
				[ary addObject:item];
			}
		}
		filteredList = ary;
	}
	
	[self reloadTable];
}

#pragma mark -
#pragma mark NSTableView Delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)sender
{
	if (filteredList) {
		return filteredList.count;
	}
	return list.count;
}

- (id)tableView:(NSTableView *)sender objectValueForTableColumn:(NSTableColumn *)column row:(NSInteger)row
{
	NSArray* ary = filteredList ?: list;
	NSArray* item = [ary safeObjectAtIndex:row];
	NSString* col = [column identifier];
	
	if ([col isEqualToString:@"chname"]) {
		return [item safeObjectAtIndex:0];
	} else if ([col isEqualToString:@"count"]) {
		return [item safeObjectAtIndex:1];
	} else if ([col isEqualToString:@"topic"]) {
		return [item safeObjectAtIndex:3];
	} else {
		return @"";
	}
}

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)column
{
	NSInteger i;
	NSString* col = [column identifier];
	if ([col isEqualToString:@"chname"]) {
		i = 0;
	} else if ([col isEqualToString:@"count"]) {
		i = 1;
	} else if ([col isEqualToString:@"topic"]) {
		i = 2;
	} else {
		return;
	}
	
	if (sortKey == i) {
		sortOrder = - sortOrder;
	} else {
		sortKey = i;
		sortOrder = (sortKey == 1) ? NSOrderedDescending : NSOrderedAscending;
	}
	
	[self sort];
	
	if (filteredList) {
		// this reloads the table
		[self onSearchFieldChange:nil];
	} else {
		[self reloadTable];
	}
	
	
}

#pragma mark -
#pragma mark NSWindow Delegate

- (void)windowWillClose:(NSNotification*)note
{
	if ([delegate respondsToSelector:@selector(listDialogWillClose:)]) {
		[delegate listDialogWillClose:self];
	}
}

@synthesize list;
@synthesize filteredList;
@synthesize table;
@synthesize filterText;
@synthesize updateButton;
@synthesize channelCount;
@end