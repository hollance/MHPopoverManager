
#import "MenuViewController.h"

@implementation MenuViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.contentSizeForViewInPopover = CGSizeMake(320.0f, 320.0f);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)dealloc
{
	NSLog(@"dealloc %@", self);
}

@end
