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

@protocol MHPopoverManagerDelegate;

/*
 * Manages the lifecycle of one or more UIPopoverControllers and their content
 * view controllers.
 *
 * Advantages of using MHPopoverManager:
 * - You do not need to keep references to the UIPopoverControllers or their
 *   content view controllers.
 * - The popover controllers are lazily loaded. When memory warnings occur, the
 *   popovers that are not visible are deallocated.
 * - When the device rotates, the popover manager will hide the visible popover
 *   and makes it easy to restore that popover after the rotation.
 *
 * You typically use one MHPopoverManager instance per view controller, and 
 * create it in viewDidLoad.
 */
@interface MHPopoverManager : NSObject

/* The delegate, usually a view controller. */
@property (nonatomic, weak) id <MHPopoverManagerDelegate> delegate;

/*
 * For popovers that are presented from controls other than bar button items,
 * you will have to restore them manually after the user interface orientation
 * changes; this property contains the tag of the popover that was visible at
 * the time the rotation took place, or NSNotFound if no popover was visible.
 *
 * Note: The HIG allows only one popover at a time to be visible. Your app will
 * be rejected from the App Store if you display more than one popover.
 */
@property (nonatomic, assign, readonly) NSInteger tagOfVisiblePopoverBeforeRotation;

/*
 * Returns the UIPopoverController for the specified tag, or creates a new one
 * if no instance exists yet. To create the new instance, the delegate method
 * popoverManager:instantiatePopoverControllerWithTag: is invoked.
 */
- (UIPopoverController *)popoverControllerWithTag:(NSInteger)tag;

/*
 * Dismisses the specified popover if it is visible. You can safely call this
 * method even if no popover instance for the specified tag exists yet.
 */
- (void)dismissPopoverControllerWithTag:(NSInteger)tag animated:(BOOL)animated;

@end

/*
 * The delegate protocol for MHPopoverManager.
 */
@protocol MHPopoverManagerDelegate <NSObject>

/*
 * Invoked when a new popover controller and its contents view controller must
 * be created. You are responsible for creating and configuring both the content
 * view controller and the popover controller.
 */
- (UIPopoverController *)popoverManager:(MHPopoverManager *)popoverManager instantiatePopoverControllerWithTag:(NSInteger)tag;

@optional

/*
 * Invoked when the interface orientation changes. If you do not implement this
 * method, any visible popovers will be automatically hidden upon rotation (i.e.
 * the default is YES).
 *
 * Return NO if you don't want to auto-hide the popover. This is something you
 * usually only do for popovers presented from a bar button item, as UIKit will
 * properly show them again after the rotation finishes.
 *
 * Return YES for popovers that you want to restore yourself after the rotation
 * completes. Basically you return YES for any popover that is not presented 
 * from a bar button item. You should present the popover again in your view
 * controller's didRotateFromInterfaceOrientation: method.
 *
 * You typically only implement this method when you have popovers that are 
 * presented from bar button items, and return NO.
 */
- (BOOL)popoverManager:(MHPopoverManager *)popoverManager shouldDismissOnRotationPopoverControllerWithTag:(NSInteger)tag;

@end
