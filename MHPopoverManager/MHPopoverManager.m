/*
 * Copyright (c) 2011-2012 Matthijs Hollemans
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
@property (nonatomic, assign, readwrite) NSInteger tagOfVisiblePopoverBeforeRotation;
@end

@implementation MHPopoverManager
{
	NSMutableDictionary *_dictionary;
}

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
	[[NSNotificationCenter defaultCenter] removeObserver:self
		name:UIApplicationDidReceiveMemoryWarningNotification
		object:nil];

	[[NSNotificationCenter defaultCenter] removeObserver:self
		name:UIApplicationWillChangeStatusBarOrientationNotification
		object:nil];

	[_dictionary enumerateKeysAndObjectsUsingBlock:^(id key, UIPopoverController *popoverController, BOOL *stop)
	{
		if (popoverController.isPopoverVisible)
		{
			[popoverController dismissPopoverAnimated:NO];
		}
	}];
}

- (UIPopoverController *)popoverControllerWithTag:(NSInteger)tag
{
	NSNumber *key = @(tag);
	UIPopoverController *popoverController = _dictionary[key];
	if (popoverController == nil && self.delegate != nil)
	{
		popoverController = [self.delegate popoverManager:self instantiatePopoverControllerWithTag:tag];
		if (popoverController != nil)
		{
			_dictionary[key] = popoverController;
		}
	}
	return popoverController;
}

- (void)dismissPopoverControllerWithTag:(NSInteger)tag animated:(BOOL)animated
{
	NSNumber *key = @(tag);
	UIPopoverController *popoverController = _dictionary[key];
	if (popoverController != nil && popoverController.popoverVisible)
	{
		[popoverController dismissPopoverAnimated:animated];
	}
}

- (void)didReceiveMemoryWarningNotification:(NSNotification *)notification
{
	// Release all the popovers that are not currently visible.
	NSArray *keys = [_dictionary allKeys];
	for (NSNumber *key in keys)
	{
		UIPopoverController *popoverController = _dictionary[key];
		if (!popoverController.popoverVisible)
		{
			[_dictionary removeObjectForKey:key];
		}
	}
}

- (void)orientationWillChangeNotification:(NSNotification *)notification
{
	BOOL haveMethod = [self.delegate respondsToSelector:@selector(popoverManager:shouldDismissOnRotationPopoverControllerWithTag:)];

	self.tagOfVisiblePopoverBeforeRotation = NSNotFound;

	for (NSNumber *key in _dictionary)
	{
		UIPopoverController *popoverController = _dictionary[key];
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
