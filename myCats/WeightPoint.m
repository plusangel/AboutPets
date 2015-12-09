//
//  WeightPoint.m
//  myCats
//
//  Created by Agathangelos Plastropoulos on 1/2/12.
//  Copyright (c) 2012 plusangel@gmail.com. All rights reserved.
//

#import "WeightPoint.h"

@implementation WeightPoint
@synthesize date;
@synthesize weight;

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:date forKey:@"date"];
    [aCoder encodeObject:weight forKey:@"weight"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setDate:[aDecoder decodeObjectForKey:@"date"]];
        [self setWeight:[aDecoder decodeObjectForKey:@"weight"]];
    }
    return self;
}

@end
