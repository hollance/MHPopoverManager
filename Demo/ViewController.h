
#import "MHPopoverManager.h"

@interface ViewController : UIViewController <MHPopoverManagerDelegate>

@property (nonatomic, retain) IBOutlet UIButton *button;

- (IBAction)menu1Action:(id)sender;
- (IBAction)menu2Action:(id)sender;

@end
