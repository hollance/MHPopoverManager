
#import "ViewController.h"
#import "MenuViewController.h"

#define MENU1_TAG 100
#define MENU2_TAG 101

@interface ViewController ()
@property (nonatomic, retain) MHPopoverManager *popoverManager;
@end

@implementation ViewController

@synthesize popoverManager = _popoverManager;
@synthesize button = _button;

- (void)viewDidLoad
{
	[super viewDidLoad];

	// You typically create the MHPopoverManager instance in viewDidLoad.
	// It is best to make it a private property (or ivar when you use ARC).

	self.popoverManager = [[[MHPopoverManager alloc] init] autorelease];
	self.popoverManager.delegate = self;
}

- (void)viewDidUnload
{
	[super viewDidUnload];

	// If you created the MHPopoverManager in viewDidLoad, then you have to
	// release it in viewDidUnload. This will dismiss any visible popovers.

	self.popoverManager = nil;
	self.button = nil;
}

- (void)dealloc
{
	[_popoverManager release];
	[_button release];
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

	// If the "Menu 2" popover was visible when the user rotated the device,
	// then we have to manually present it again from the new position of
	// the UIButton.

	if (self.popoverManager.tagOfVisiblePopoverBeforeRotation == MENU2_TAG)
	{
		UIPopoverController *popoverController = [self.popoverManager popoverControllerWithTag:MENU2_TAG];

		[popoverController presentPopoverFromRect:[self.button.superview convertRect:self.button.frame toView:self.view] 
			inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
}

- (IBAction)menu1Action:(id)sender
{
	// This will either create the UIPopoverController (through a trip to the
	// MHPopoverManagerDelegate method) or reuse the existing instance if one
	// was already created earlier.

	UIPopoverController *popoverController = [self.popoverManager popoverControllerWithTag:MENU1_TAG];

	// Popovers that are presented from a bar button item do not block that bar
	// button. The code below hides the popover when you press the button again.

	if (!popoverController.isPopoverVisible)
		[popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	else
		[popoverController dismissPopoverAnimated:YES];
}

- (IBAction)menu2Action:(UIView *)sender
{
	UIPopoverController *popoverController = [self.popoverManager popoverControllerWithTag:MENU2_TAG];

	// You can do additional customizations here. These are performed every 
	// time the user opens the popover. (This is just a silly example.)

	UINavigationController *navController = (UINavigationController *)popoverController.contentViewController;
	MenuViewController *contentViewController = [[navController viewControllers] objectAtIndex:0];
	contentViewController.view.backgroundColor = [UIColor clearColor];

	// Popovers that are presented from controls other than bar button items 
	// will always block the entire screen, so you do not have to check for
	// isPopoverVisible or dismiss the popover here.

	[popoverController presentPopoverFromRect:[sender.superview convertRect:sender.frame toView:self.view] 
		inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

	// Just to demonstrate dismissPopoverControllerWithTag:animated:, we'll
	// hide this popover after 3 seconds.

	[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(timerFired:) userInfo:nil repeats:NO];
}

- (void)timerFired:(NSTimer *)timer
{
	// If you already have a reference to the UIPopoverController, then you can
	// call dismissPopoverAnimated: to hide it. But when you have no reference,
	// you can call MHPopoverManager's dismissPopoverControllerWithTag:animated:.

	[self.popoverManager dismissPopoverControllerWithTag:MENU2_TAG animated:YES];
}

#pragma mark - MHPopoverManagerDelegate

- (UIPopoverController *)popoverManager:(MHPopoverManager *)popoverManager instantiatePopoverControllerWithTag:(NSInteger)tag
{
	// Here you create the new content view controller and set its properties.
	// This is only called when there is no instance yet.

	MenuViewController *controller = [[[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil] autorelease];

	if (tag == MENU1_TAG)
		controller.title = @"Menu 1";
	else
		controller.title = @"Menu 2";

	UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];

	// This is also where you would set passthroughViews and any other 
	// properties on the popover controller itself.

	return [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
}

- (BOOL)popoverManager:(MHPopoverManager *)popoverManager shouldDismissOnRotationPopoverControllerWithTag:(NSInteger)tag
{
	// We don't want dismiss Menu 1 on rotation. This popover is presented from
	// a bar button item and UIKit will handle rotation automatically. However,
	// we do want to hide the Menu 2 popover, which is presented from a regular
	// UIButton. If we don't hide it, UIKit will put it back in the wrong place
	// after the rotation completes.

	return (tag == MENU2_TAG);
}

@end
