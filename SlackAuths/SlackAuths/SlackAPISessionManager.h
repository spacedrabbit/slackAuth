//
//  SlackAPISessionManager.h
//  SlackAuths
//
//  Created by Louis Tur on 11/9/14.
//  Copyright (c) 2014 Louis Tur. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SlackAPISessionManager : NSObject

+(void) createRequestForService:(NSString *)service withCompletion:(void(^)(BOOL))success;


@end
