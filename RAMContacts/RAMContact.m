//
//  RAMContacts.m
//  RAMContacts
//
//  Created by Rodrigo A. Morbach on 17/03/16.
//  Copyright © 2016 Morbach. All rights reserved.
//

#import "RAMContact.h"

NSString * const KCMFContactFn = @"fn";
NSString * const KCMFContactLn = @"ln";
NSString * const KCMFContactP = @"p";
NSString * const KCMFContactPh = @"ph";

@implementation RAMContact

- (instancetype)init
{
    if (self = [super init]) {
        self.numbersAndGroups = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary * contactDict = [NSMutableDictionary dictionary];
    
    //For now we set the value for the p key as Null
    [contactDict setObject:@"" forKey:KCMFContactP];
    [contactDict setObject:(self.firstName != nil)?self.firstName:@"" forKey:KCMFContactFn];
    [contactDict setObject:(self.lastName != nil)?self.lastName:@"" forKey:KCMFContactLn];
    [contactDict setObject:(self.phoneNumbers != nil)?self.phoneNumbers:@"" forKey:KCMFContactPh];
    
    return [NSDictionary dictionaryWithDictionary:contactDict];
}

- (void)addPhoneNumber:(NSString *)number andGroup:(NSString *)group
{
    [self.numbersAndGroups setObject:[group capitalizedString] forKey:number];
}

@end
