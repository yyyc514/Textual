#import "MemberListViewCell.h"

#define MARK_LEFT_MARGIN			2
#define MARK_RIGHT_MARGIN	2

static NSInteger markWidth;
static NSMutableParagraphStyle* markStyle;
static NSMutableParagraphStyle* nickStyle;

@implementation MemberListViewCell

@synthesize member;
@synthesize theme;

- (id)init
{
	if ((self = [super init])) {
	}
	
	markStyle = [NSMutableParagraphStyle new];
	[markStyle setAlignment:NSCenterTextAlignment];

	nickStyle = [NSMutableParagraphStyle new];
	[nickStyle setAlignment:NSLeftTextAlignment];
	[nickStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	return self;
}

- (void)dealloc
{
	[member release];
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
	MemberListViewCell* c = [[MemberListViewCell allocWithZone:zone] init];
	c.font = self.font;
	c.member = member;
	return c;
}

- (void)calculateMarkWidth
{
	markWidth = 0;
	
	NSDictionary* style = [NSDictionary dictionaryWithObject:self.font forKey:NSFontAttributeName];
	NSArray* marks = [NSArray arrayWithObjects:@"~", @"&", @"@", @"%", @"+", @"!", nil];
	
	for (NSString* s in marks) {
		NSSize size = [s sizeWithAttributes:style];
		NSInteger width = ceil(size.width);
		if (markWidth < width) {
			markWidth = width;
		}
	}
}

+ (MemberListViewCell*)initWithTheme:(id)aTheme
{
	MemberListViewCell* cell=[[MemberListViewCell alloc]init];
	cell.theme=aTheme;
	return [cell autorelease];
}

- (void)themeChanged
{
	[self calculateMarkWidth];
}

- (void)drawInteriorWithFrame:(NSRect)frame inView:(NSView*)view
{
	NSWindow* window = view.window;
	NSColor* color = nil;
	
	if ([self isHighlighted]) {
		if (window && [window isMainWindow] && [window firstResponder] == view) {
			color = [theme memberListSelColor] ?: [NSColor alternateSelectedControlTextColor];
		} else {
			color = [theme memberListSelColor] ?: [NSColor selectedControlTextColor];
		}
	} else if ([member isOp]) {
		color = [theme memberListOpColor];
	} else {
		color = [theme memberListColor];
	}
	
	NSMutableDictionary* style = [NSMutableDictionary dictionary];
	[style setObject:markStyle forKey:NSParagraphStyleAttributeName];
	[style setObject:self.font forKey:NSFontAttributeName];
	[style setObject:color forKey:NSForegroundColorAttributeName];
	
	NSRect rect = frame;
	rect.origin.x += MARK_LEFT_MARGIN;
	rect.size.width = markWidth;
	
	char mark = [member mark];
	if (mark != ' ') {
		NSString* markStr = [NSString stringWithFormat:@"%C", mark];
		[markStr drawInRect:rect withAttributes:style];
	}
	
	[style setObject:nickStyle forKey:NSParagraphStyleAttributeName];
	
	NSInteger offset = MARK_LEFT_MARGIN + markWidth + MARK_RIGHT_MARGIN;
	
	rect = frame;
	rect.origin.x += offset;
	rect.size.width -= offset;
	
	NSString* nick = [member nick];
	[nick drawInRect:rect withAttributes:style];
}

@end