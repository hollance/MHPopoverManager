
#import "MenuViewController.h"

@implementation MenuViewController

- (void)dealloc
{
	NSLog(@"dealloc MenuViewController");
	[super dealloc];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.contentSizeForViewInPopover = CGSizeMake(320, 320);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
