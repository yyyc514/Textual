// Created by Satoshi Nakagawa <psychs AT limechat DOT net> <http://github.com/psychs/limechat>
// Modifications by Michael Morris <mikey AT codeux DOT com> <http://github.com/mikemac11/Textual>
// You can redistribute it and/or modify it under the new BSD license.

#import <Foundation/Foundation.h>
#import "ListView.h"

@interface ListDialog : NSWindowController
{
	id delegate;
	NSMutableArray* list;
	NSMutableArray* filteredList;
	
	NSInteger sortKey;
	NSComparisonResult sortOrder;
	
	IBOutlet NSProgressIndicator* progress;
	IBOutlet ListView* table;
	IBOutlet NSSearchField* filterText;
	IBOutlet NSButton* updateButton;
	IBOutlet NSTextField* channelCount;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, readonly) NSInteger sortKey;
@property (nonatomic, readonly) NSComparisonResult sortOrder;
@property (nonatomic, retain) NSMutableArray* list;
@property (nonatomic, retain) NSMutableArray* filteredList;
@property (nonatomic, retain) NSProgressIndicator* progress;
@property (nonatomic, retain) ListView* table;
@property (nonatomic, retain) NSSearchField* filterText;
@property (nonatomic, retain) NSButton* updateButton;
@property (nonatomic, retain) NSTextField* channelCount;

- (void)start;
- (void)show;
- (void)close;
- (void)clear;

- (void)addChannel:(NSString*)channel count:(NSInteger)count topic:(NSString*)topic;
- (void)listEnded;

- (void)onClose:(id)sender;
- (void)onUpdate:(id)sender;
- (void)onJoin:(id)sender;
- (void)onSearchFieldChange:(id)sender;
@end

@interface NSObject (ListDialogDelegate)
- (void)listDialogOnUpdate:(ListDialog*)sender;
- (void)listDialogOnJoin:(ListDialog*)sender channel:(NSString*)channel;
- (void)listDialogWillClose:(ListDialog*)sender;
@end