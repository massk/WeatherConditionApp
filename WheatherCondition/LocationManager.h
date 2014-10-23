//
//  LocationManager.h
//  WheatherCondition
//
//  Created by Manoj Kamde on 10/22/14.
//  Copyright (c) 2014 Kamde Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@protocol LocationManagerDelegate <NSObject>

-(void)locationManageDidFailWithError:(NSError*)error;
-(void)locationManageDidUpdateLocations:(NSArray*)locations;
-(void)locationManageDidUpdateNewLocations:(CLLocation*)newLocations;

@end

@interface LocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic,weak) id<LocationManagerDelegate> delegate;

-(void)getUserLocationWithInterval:(int)interval;

@end
