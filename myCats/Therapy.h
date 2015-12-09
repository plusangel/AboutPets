//
//  Therapy.h
//  myCats
//
//  Created by Agathangelos Plastropoulos on 26/3/12.
//  Copyright (c) 2012 plusangel@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Pet;
@class TherapyType;

@interface Therapy : NSManagedObject

@property (nonatomic, retain) NSDate *dateOfTherapy;
@property (nonatomic, retain) NSDecimalNumber *price;
@property (nonatomic, retain) Pet *pet;
@property (nonatomic, retain) NSString *therapyType;
@property (nonatomic, retain) NSString *notes;
@property (nonatomic, retain) NSString *product;

@end
