//
//  WeightPoint.h
//  myCats
//
//  Created by Agathangelos Plastropoulos on 1/2/12.
//  Copyright (c) 2012 plusangel@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeightPoint : NSObject <NSCoding>

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSNumber *weight;

@end