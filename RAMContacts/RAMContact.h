//
//  RAMContact.h
//  RAMContact
//
//  Created by Rodrigo A. Morbach on 17/03/16.
//  Copyright © 2016 Morbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RAMContact : NSObject

@property (nonatomic) UIImage * picture;
@property (nonatomic) NSString * firstName;
@property (nonatomic) NSString * lastName;
@property (nonatomic) NSArray * phoneNumbers;
@property (nonatomic) NSString * group;
@property (nonatomic) NSMutableDictionary * numbersAndGroups;

/*!
 @brief return the dictionary format for the object
 */
- (NSDictionary *)dictionaryRepresentation;

- (void)addPhoneNumber:(NSString *)number andGroup:(NSString *)group;

@end
