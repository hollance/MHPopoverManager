/*!
 * \file MHPopoverManager.m
 *
 * Copyright (c) 2011 Matthijs Hollemans
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "MHPopoverManager.h"

@interface MHPopoverManager ()
@property (nonatomic, retain) NSMutableDictionary *dictionary;
@property (nonatomic, assign, readwrite) NSInteger tagOfVisiblePopoverBeforeRotation;
@end

@implementation MHPopoverManager

@synthesize delegate = _delegate;
@synthesize dictionary = _dictionary;
@synthesize tagOfVisiblePopoverBeforeRotation = _tagOfVisiblePopoverBeforeRotation;

- (id)init
{
	if ((self = [super init]))
	{
		_dictionary = [[NSMutableDictionary alloc] initWithCapacity:3];
		_tagOfVisiblePopoverBeforeRotation = NSNotFound;

		[[NSNotificationCenter defaultCenter] addObserver:self
			selector:@selector(didReceiveMemoryWarningNotification:)
			name:UIApplicationDidReceiveMemoryWarningNotification
			object:nil];
			
		[[NSNotificationCenter defaultCenter] addObserver:self
			selector:@selector(orientationWillChangeNotification:)
			name:UIApplicationWillChangeStatusBarOrientationNotification
			object:nil];
	}
	return self;
}

- (void)dealloc
{
	NSLog(@"dealloc MHPopoverManager");

	[[NSNotificationCenter defaultCenter] removeObserver:self
		name:UIApplicationDidReceiveMemoryWarningNotification
		object:nil];

	[[NSNotificationCenter defaultCenter] removeObserver:self
		name:UIApplicationWillChangeStatusBarOrientationNotification
		object:nil];

	// First make sure all popovers are dismissed before we release them.
	for (NSNumber *key in self.dictionary)
	{
		UIPopoverController *popoverController = [self.dictionary objectForKey:key];
		if (popoverController.isPopoverVisible)
		{
			[popoverController dismissPopoverAnimated:NO];
		}
	}

	[_dictionary release];
	[super dealloc];
}

- (UIPopoverController *)popoverControllerWithTag:(NSInteger)tag
{
	NSNumber *number = [NSNumber numberWithInteger:tag];
	UIPopoverController *popoverController = [self.dictionary objectForKey:number];
	if (popoverController == nil && self.delegate != nil)
	{
		popoverController = [self.delegate popoverManager:self instantiatePopoverControllerWithTag:tag];
		if (popoverController != nil)
		{
			[self.dictionary setObject:popoverController forKey:number];
		}
	}
	return popoverController;
}

- (void)dismissPopoverControllerWithTag:(NSInteger)tag animated:(BOOL)animated
{
	NSNumber *number = [NSNumber numberWithInteger:tag];
	UIPopoverController *popoverController = [self.dictionary objectForKey:number];
	if (popoverController != nil && popoverController.popoverVisible)
	{
		[popoverController dismissPopoverAnimated:animated];
	}
}

- (void)didReceiveMemoryWarningNotification:(NSNotification *)notification
{
	// Release all the popovers that are not currently visible.
	NSArray *keys = [self.dictionary allKeys];
	for (NSNumber *key in keys)
	{
		UIPopoverController *popoverController = [self.dictionary objectForKey:key];
		if (!popoverController.popoverVisible)
		{
			[self.dictionary removeObjectForKey:key];
		}
	}
}

- (void)orientationWillChangeNotification:(NSNotification *)notification
{
	BOOL haveMethod = [self.delegate respondsToSelector:@selector(popoverManager:shouldDismissOnRotationPopoverControllerWithTag:)];

	self.tagOfVisiblePopoverBeforeRotation = NSNotFound;

	for (NSNumber *key in self.dictionary)
	{
		UIPopoverController *popoverController = [self.dictionary objectForKey:key];
		if (popoverController.isPopoverVisible)
		{
			self.tagOfVisiblePopoverBeforeRotation = [key integerValue];

			if (!haveMethod || [self.delegate popoverManager:self shouldDismissOnRotationPopoverControllerWithTag:[key integerValue]])
			{
				[popoverController dismissPopoverAnimated:NO];
			}
		}
	}
}

@end
