//
//  NSObject+ICUHook.m
//  WeChatICU
//
//  Created by MustangYM on 2019/12/5.
//  Copyright © 2019 MustangYM. All rights reserved.
//

#import "NSObject+ICUHook.h"
#import "fishhook.h"
#import <AppKit/AppKit.h>
#import <objc/runtime.h>
#import "ANYMethodLog.h"

void hookMethod(Class originalClass, SEL originalSelector, Class swizzledClass, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(originalClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(swizzledClass, swizzledSelector);
    if (originalMethod && swizzledMethod) {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

void hookClassMethod(Class originalClass, SEL originalSelector, Class swizzledClass, SEL swizzledSelector) {
    Method originalMethod = class_getClassMethod(originalClass, originalSelector);
    Method swizzledMethod = class_getClassMethod(swizzledClass, swizzledSelector);
    if (originalMethod && swizzledMethod) {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

static NSArray<NSString *> *(*original_NSSearchPathForDirectoriesInDomains)(NSSearchPathDirectory directory, NSSearchPathDomainMask domainMask, BOOL expandTilde);

static NSString *(*original_NSHomeDirectory)(void);

NSArray<NSString *> *swizzled_NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory directory, NSSearchPathDomainMask domainMask, BOOL expandTilde) {
    NSMutableArray<NSString *> *paths = [original_NSSearchPathForDirectoriesInDomains(directory, domainMask, expandTilde) mutableCopy];
    NSString *sandBoxPath = [NSString stringWithFormat:@"%@/Library/Containers/com.tencent.WeWorkMac/Data", original_NSHomeDirectory()];
    
    [paths enumerateObjectsUsingBlock:^(NSString *filePath, NSUInteger idx, BOOL *_Nonnull stop) {
        NSRange range = [filePath rangeOfString:original_NSHomeDirectory()];
        if (range.length > 0) {
            NSMutableString *newFilePath = [filePath mutableCopy];
            [newFilePath replaceCharactersInRange:range withString:sandBoxPath];
            paths[idx] = newFilePath;
        }
    }];
    
    return paths;
}

NSString *swizzled_NSHomeDirectory(void) {
    return [NSString stringWithFormat:@"%@/Library/Containers/com.tencent.WeWorkMac/Data", original_NSHomeDirectory()];
}


static NSString *const REVOKE = @"REVOKE_MSG";
static NSString *const WATERMARK = @"REMOVE_WATERMARK";

@implementation NSObject (Hook)

+ (void)hook {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       [self inflateMenu];
    });
    
    
    hookMethod(objc_getClass("WEWConversation"), @selector(isConversationSupportWaterMark), [self class], @selector(hook_isConversationSupportWaterMark));
    hookMethod(objc_getClass("WEWMessage"), @selector(isRevoke), [self class], @selector(hook_isRevoke));
    hookMethod(objc_getClass("NSBundle"), @selector(executablePath), [self class], @selector(hook_executablePath));
    
    rebind_symbols((struct rebinding[2]) {
        {"NSSearchPathForDirectoriesInDomains", swizzled_NSSearchPathForDirectoriesInDomains, (void *) &original_NSSearchPathForDirectoriesInDomains},
        {"NSHomeDirectory", swizzled_NSHomeDirectory, (void *) &original_NSHomeDirectory}
    }, 2);
    
//    [ANYMethodLog logMethodWithClass:[objc_getClass("WEWMessageService") class] condition:^BOOL(SEL sel) {
//          return YES;
//      } before:^(id target, SEL sel, NSArray *args, int deep) {
//          NSLog(@"\n🐸类名:%@ 👍方法:%@\n%@", target, NSStringFromSelector(sel),args);
//      } after:^(id target, SEL sel, NSArray *args, NSTimeInterval interval, int deep, id retValue) {
//          NSLog(@"\n🚘类名:%@ 👍方法:%@\n%@\n↪️%@", target, NSStringFromSelector(sel),args,retValue);
//      }];
//    hookMethod(objc_getClass("NSAlert"), @selector(buildAlertStyle:title:formattedMessage:first:second:third:oldStyle:), [self class], @selector(hook_buildAlertStyle:title:formattedMessage:first:second:third:oldStyle:));
}

//- (id)hook_buildAlertStyle:(id)arg1 title:(id)arg2 formattedMessage:(id)arg3 first:(id)arg4 second:(id)arg5 third:(id)arg6 oldStyle:(id)arg6
//{
//    return nil;
//}

- (NSString *)hook_executablePath {
    NSString *executablePath = [self hook_executablePath];
    if ([executablePath hasSuffix:@"企业微信"]) {
        executablePath = [executablePath stringByAppendingString:@"_backup"];
    }
    return executablePath;
}

- (BOOL)hook_isRevoke; {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:REVOKE]) {
        return [self hook_isRevoke];
    }
    
    return NO;
}

- (BOOL)hook_isConversationSupportWaterMark; {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:WATERMARK]) {
        return [self hook_isConversationSupportWaterMark];
    }
    return NO;
}

- (void)inflateMenu {
    NSMenuItem *revoteItm = [[NSMenuItem alloc] initWithTitle:@"消息防撤回" action:@selector(onPreventRevoke:) keyEquivalent:@""];
    
    NSMenuItem *waterMartItm = [[NSMenuItem alloc] initWithTitle:@"去掉会话水印" action:@selector(onConversationWaterMark:) keyEquivalent:@""];
    
    revoteItm.state = [[NSUserDefaults standardUserDefaults] boolForKey:REVOKE];
    waterMartItm.state = [[NSUserDefaults standardUserDefaults] boolForKey:WATERMARK];
    
    NSMenu *subMenu = [[NSMenu alloc] initWithTitle:@"小助手"];
    [subMenu addItem:revoteItm];
    [subMenu addItem:waterMartItm];
    
    NSMenuItem *menuItem = [[NSMenuItem alloc] init];
    [menuItem setTitle:@"小助手"];
    [menuItem setSubmenu:subMenu];
    [menuItem setSubmenu:subMenu];
    
    [[[NSApplication sharedApplication] mainMenu] addItem:menuItem];
}

- (void)onPreventRevoke:(NSMenuItem *)item {
    item.state = !item.state;
    [[NSUserDefaults standardUserDefaults] setBool:(BOOL)item.state forKey:REVOKE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)onConversationWaterMark:(NSMenuItem *)item {
    item.state = !item.state;
    [[NSUserDefaults standardUserDefaults] setBool:(BOOL)item.state forKey:WATERMARK];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
