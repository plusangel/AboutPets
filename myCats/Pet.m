//
//  Pet.m
//  myCats
//
//  Created by Agathangelos Plastropoulos on 6/1/12.
//  Copyright (c) 2012 plusangel@gmail.com. All rights reserved.
//

#import "Pet.h"
#import "Photo.h"
#import "UIImageToDataTransformer.h"

@implementation Pet

@dynamic breed;
@dynamic dob;
@dynamic name;
@dynamic weight;
@dynamic thumbnail;
@dynamic sex;
@dynamic kind;
@dynamic lastAppointment;
@dynamic registration;
@dynamic microchip;
@dynamic photo;
@dynamic therapy;
@dynamic appointment;

+ (void)initialize {
	if (self == [Pet class]) {
		UIImageToDataTransformer *transformer = [[UIImageToDataTransformer alloc] init];
		[NSValueTransformer setValueTransformer:transformer forName:@"UIImageToDataTransformer"];
	}
}

@end
