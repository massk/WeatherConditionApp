//
//  WCViewController.m
//  WheatherCondition
//
//  Created by Manoj Kamde on 10/22/14.
//  Copyright (c) 2014 Kamde Inc. All rights reserved.
//

#import "WCViewController.h"
#import <CoreLocation/CLLocation.h>


@interface WCViewController ()
{
    NSString *latitudeValue;
    NSString *longitudeValue;
}

@end

@implementation WCViewController
@synthesize resultLabel, cityName;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.cityName.delegate = self;
    self.locationManager = [[LocationManager alloc]init];
    self.locationManager.delegate = self;
    [self.locationManager getUserLocationWithInterval:60]; // replace this value with what you want, but it can not be higher than kMaxBGTime
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)locationManageDidFailWithError:(NSError *)error
{
    NSLog(@"Error %@",error);
}

-(void)locationManageDidUpdateNewLocations:(CLLocation*)newLocations
{
    NSLog(@"New Locations %@",newLocations);
//    currentLocation = newLocations;
}

-(void)locationManageDidUpdateLocations:(NSArray *)locations
{
    // You will receive location updates every 60 seconds (value what you set with getUserLocationWithInterval)
    // and you will continue to receive location updates for 3 seconds (value of kTimeToGetLocations).
    // You can gather and pick most accurate location
    NSString *locationData = [[ NSString stringWithFormat:@"%@", locations]init];
//    NSLog(@"Locations %@",locations);
    NSCharacterSet *patternChars = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
    NSString *cleanedStr = [[locationData componentsSeparatedByCharactersInSet:patternChars] componentsJoinedByString:@","];
    NSArray *items = [cleanedStr componentsSeparatedByString:@"," ];
    if ([items count] >= 3) {
    latitudeValue = [NSString stringWithFormat:@"%@", [items objectAtIndex:1]];
    longitudeValue = [NSString stringWithFormat:@"%@", [items objectAtIndex:2]];
    }
    NSLog(@"Latitude Value = %@  and Longitude Value =%@", latitudeValue, longitudeValue);

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.cityName) {
        [cityName resignFirstResponder];
        NSLog(@"City Name = %@", cityName.text);
        [self getWeatherByCityName];
        return NO;
    }
    return YES;
}


-(void) getWeatherByCityName
{
    // api.openweathermap.org/data/2.5/weather?q=London,uk
    NSString *base_url = @"http://api.openweathermap.org/data/2.5/weather?q=";
    
    NSString* encodedCityName = [cityName.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
    NSString *weatherAPIUrl = [NSString stringWithFormat:@"%@%@", base_url, encodedCityName];

    [self getWeatherData:weatherAPIUrl];
//    [resultLabel setText:[self parseJsonForDisplay:returnedJson]];
}

-(void) getWeatherData: (NSString *) reqUrl
{
    __block NSDictionary *responseJson = nil;
    NSURL *weatherURL = [NSURL URLWithString:reqUrl];
    NSMutableURLRequest *weatherRequest = [NSMutableURLRequest requestWithURL:weatherURL];
    NSLog(@"URL = %@", reqUrl);

    [resultLabel setText:@"Please wait while we get \nweather details for you."];

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:weatherRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if(error != nil)
        {
            NSLog(@"%@", error.userInfo);
        }
        else
        {
            responseJson =
            [NSJSONSerialization JSONObjectWithData: data
                                            options: NSJSONReadingMutableContainers
                                              error: &error];
            NSLog(@"%@", responseJson);
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSLog(@"Coming Back from the thread");
                [resultLabel setText:[self parseJsonForDisplay:responseJson]];
            });

        }
    }];
}


-(NSString *) parseJsonForDisplay: (NSDictionary *) returnedJson
{
    NSString *labelValueDetails = nil;
    NSString *weatherCityName = nil;
    NSString *weather = nil;
    for (id key in [returnedJson allKeys]) {
        NSLog(@"key: %@, value: %@", key, [returnedJson objectForKey:key]);
        if ([key isEqualToString:@"main"]) {
            NSString *humidity = [[returnedJson objectForKey:key]valueForKey:@"humidity"];
            NSString *pressure = [[returnedJson objectForKey:key]valueForKey:@"pressure"];
            float tempValueinFahrenhite = [[[returnedJson objectForKey:key]valueForKey:@"temp"] longLongValue] - 237.15;
            NSString *temp = [NSString stringWithFormat:@"%5.2f", tempValueinFahrenhite];
            tempValueinFahrenhite = [[[returnedJson objectForKey:key]valueForKey:@"temp_max"] longLongValue] - 237.15;
            NSString *temp_max =  [NSString stringWithFormat:@"%5.2f", tempValueinFahrenhite];
            tempValueinFahrenhite = [[[returnedJson objectForKey:key]valueForKey:@"temp_min"] longLongValue] - 237.15;
            NSString *temp_min = [NSString stringWithFormat:@"%5.2f", tempValueinFahrenhite];
            labelValueDetails = [NSString stringWithFormat:@"Humidity = %@\nPressure = %@\nTemperature = %@\nMaximum Temprature = %@\nMinimum Temprature = %@\n",humidity, pressure, temp, temp_max, temp_min ];
        }
        if ([key isEqualToString:@"name"]) {
            weatherCityName = [NSString stringWithFormat:@"%@", [returnedJson objectForKey:key]];
        }
        if ([key isEqualToString:@"weather"]) {
            weather =  [NSString stringWithFormat:@"%@", [[returnedJson objectForKey:key]valueForKey:@"main"]];                NSLog(@"%@", weather);
        }
    }
    return [NSString stringWithFormat:@"City Name : %@\n%@", weatherCityName, labelValueDetails];
}

- (IBAction)getCurrentLocation:(id)sender {
    
//    api.openweathermap.org/data/2.5/weather?lat=35&lon=139
    NSString *const BASE_URL_STRING = @"http://api.openweathermap.org/data/2.5/weather?";
    
    NSString *weatherAPIUrl = [NSString stringWithFormat:@"%@lat=%@&lon=%@",
                                BASE_URL_STRING, latitudeValue,longitudeValue];
    [self getWeatherData:weatherAPIUrl];    
}

@end
