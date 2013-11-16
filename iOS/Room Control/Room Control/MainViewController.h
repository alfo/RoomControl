//
//  MainViewController.h
//  Room Control
//
//  Created by Alex Forey on 21/10/2013.
//  Copyright (c) 2013 Alex Forey. All rights reserved.
//

#import "FlipsideViewController.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;
- (IBAction)preset1Button:(id)sender;
- (IBAction)preset2Button:(id)sender;
- (IBAction)preset3Button:(id)sender;
- (IBAction)preset4Button:(id)sender;

@end
