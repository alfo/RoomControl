//
//  FlipsideViewController.h
//  Room Control
//
//  Created by Alex Forey on 21/10/2013.
//  Copyright (c) 2013 Alex Forey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlipsideViewController;

@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

@interface FlipsideViewController : UIViewController

@property (weak, nonatomic) id <FlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;
@property (strong, nonatomic) IBOutlet UIWebView *settingsWebView;


@end
