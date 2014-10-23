//
//  WCViewController.h
//  WheatherCondition
//
//  Created by Manoj Kamde on 10/22/14.
//  Copyright (c) 2014 Kamde Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationManager.h"

@interface WCViewController : UIViewController <LocationManagerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *cityName;
@property (strong, nonatomic) LocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

- (IBAction)getCurrentLocation:(id)sender;

@end
