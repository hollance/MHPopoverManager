# MHPopoverManager

This is a simple class for managing the lifecycle of your UIPopoverControllers.

Advantages of using MHPopoverManager:

* You do not need to keep references to the UIPopoverControllers or their content view controllers.
* The popover controllers are lazily loaded. When memory warnings occur, the popovers that are not visible are deallocated.
* When the device rotates, the popover manager will hide the visible popover and makes it easy to restore that popover after the rotation.

A basic demo project is included.

The MHPopoverManager source code is copyright 2011 Matthijs Hollemans and is licensed under the terms of the MIT license.
