//
//  Appointment.h
//  myPets
//
//  Created by angelos plastropoulos on 10/18/12.
//  Copyright (c) 2012 plusangel@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Pet;

@interface Appointment : NSManagedObject

@property (nonatomic, retain) NSString * appointmentIdentifier;
@property (nonatomic, retain) NSDate * appointmentDate;
@property (nonatomic, retain) Pet *pet;

@end
