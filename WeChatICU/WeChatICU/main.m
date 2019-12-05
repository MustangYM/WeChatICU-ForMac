//
//  main.c
//  WeChatICU
//
//  Created by MustangYM on 2019/12/5.
//  Copyright © 2019 MustangYM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+ICUHook.h"

static void __attribute__((constructor)) initialize(void) {
    [NSObject hook];
}
