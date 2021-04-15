//
//  ICUWXHelper.m
//  WeChatICU
//
//  Created by acumen on 2021/4/14.
//  Copyright © 2021 MustangYM. All rights reserved.
//

#import "ICUWXHelper.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation ICUWXHelper

+ (id)serviceCenter {
    id serviceManager = ((id (*)(Class, SEL))objc_msgSend)(objc_getClass("WEWServiceManager"), NSSelectorFromString(@"defaultServiceManager"));
    return serviceManager;
}

+ (id)configService {
    id serviceManager = [self serviceCenter];
    id conversationService = ((id (*)(id, SEL))objc_msgSend)(serviceManager, NSSelectorFromString(@"configService"));
    return conversationService;
}

@end
