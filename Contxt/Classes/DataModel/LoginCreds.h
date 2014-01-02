//
//  LoginCreds.h
//  Contxt
//
//  Created by Chad Morris on 8/10/13.
//  Copyright (c) 2013 Chad Morris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Object.h"


@interface LoginCreds : Object

@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * username;

@end
