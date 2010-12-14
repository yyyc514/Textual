// Created by Satoshi Nakagawa <psychs AT limechat DOT net> <http://github.com/psychs/limechat>
// Modifications by Codeux Software <support AT codeux DOT com> <https://github.com/codeux/Textual>
// You can redistribute it and/or modify it under the new BSD license.

@class IRCWorld;
@class IRCClient;
@class IRCChannel;

@interface LogController : NSObject
{
	LogView* view;
	LogPolicy* policy;
	LogScriptEventSink* sink;
	MarkedScroller* scroller;
	WebScriptObject* js;
	WebViewAutoScroll* autoScroller;

	IRCWorld* world;
	IRCClient* client;
	IRCChannel* channel;
	NSMenu* menu;
	NSMenu* urlMenu;
	NSMenu* addrMenu;
	NSMenu* chanMenu;
	NSMenu* memberMenu;
	ViewTheme* theme;
	NSInteger maxLines;
	NSColor* initialBackgroundColor;
	NSMutableArray* highlightedLineNumbers;
	
	BOOL becameVisible;
	BOOL bottom;
	BOOL movingToBottom;
	NSMutableArray* lines;
	NSInteger lineNumber;
	NSInteger count;
	BOOL needsLimitNumberOfLines;
	BOOL loaded;
	NSInteger loadingImages;
	NSString* html;
	BOOL scrollBottom;
	NSInteger scrollTop;
}

@property (nonatomic, retain) NSMutableArray* highlightedLineNumbers;
@property (nonatomic, readonly) LogView* view;
@property (nonatomic, assign) IRCWorld* world;
@property (nonatomic, assign) IRCClient* client;
@property (nonatomic, assign) IRCChannel* channel;
@property (nonatomic, retain) NSMenu* menu;
@property (nonatomic, retain) NSMenu* urlMenu;
@property (nonatomic, retain) NSMenu* addrMenu;
@property (nonatomic, retain) NSMenu* chanMenu;
@property (nonatomic, retain) NSMenu* memberMenu;
@property (nonatomic, retain) ViewTheme* theme;
@property (nonatomic, retain) NSColor* initialBackgroundColor;
@property (nonatomic, assign, setter=setMaxLines:, getter=maxLines) NSInteger maxLines;
@property (nonatomic, readonly) BOOL viewingBottom;
@property (nonatomic, retain) LogPolicy* policy;
@property (nonatomic, retain) LogScriptEventSink* sink;
@property (nonatomic, retain) MarkedScroller* scroller;
@property (nonatomic, retain) WebScriptObject* js;
@property (nonatomic, retain) WebViewAutoScroll* autoScroller;
@property (nonatomic, assign) BOOL becameVisible;
@property (nonatomic, assign) BOOL bottom;
@property (nonatomic, assign) BOOL movingToBottom;
@property (nonatomic, retain) NSMutableArray* lines;
@property (nonatomic) NSInteger lineNumber;
@property (nonatomic) NSInteger count;
@property (nonatomic, assign) BOOL needsLimitNumberOfLines;
@property (nonatomic, assign) BOOL loaded;
@property (nonatomic) NSInteger loadingImages;
@property (nonatomic, retain) NSString* html;
@property (nonatomic, assign) BOOL scrollBottom;
@property (nonatomic) NSInteger scrollTop;

- (void)setUp;
- (void)notifyDidBecomeVisible;
- (void)notifyDidBecomeHidden;

- (void)moveToTop;
- (void)moveToBottom;

- (void)setTopic:(NSString *)topic;

- (void)mark;
- (void)unmark;
- (void)goToMark;
- (void)reloadTheme;
- (void) applyOverrideStyle;
- (void)clear;
- (void)changeTextSize:(BOOL)bigger;

- (BOOL)print:(LogLine*)line;
- (BOOL)print:(LogLine*)line withHTML:(BOOL)stripHTML;

- (void)logViewOnDoubleClick:(NSString*)e;

- (void)restorePosition;
@end