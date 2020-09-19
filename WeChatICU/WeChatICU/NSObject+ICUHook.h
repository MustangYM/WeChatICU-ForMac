//
//  NSObject+ICUHook.h
//  WeChatICU
//
//  Created by MustangYM on 2019/12/5.
//  Copyright © 2019 MustangYM. All rights reserved.
//

#import <AppKit/AppKit.h>


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Hook) <NSUserNotificationCenterDelegate>
+ (void)hook;
@end

NS_ASSUME_NONNULL_END
