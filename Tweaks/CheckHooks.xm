#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <string.h>
#import "../Headers/CheckHooks.h"

@interface StockNewsdmManager : NSObject
+ (const char *)defRandomString;
@end

@interface NSDistributedNotificationCenter : NSNotificationCenter
@end

%group CheckHooks
%hookf (int, UIApplicationMain, int argc, char * _Nullable *argv, NSString *principalClassName, NSString *delegateClassName) {
	Class oldClass = objc_getClass("StockNewsdmManager");
	if(!oldClass)
		return %orig;

	const char* bypasscode = [%c(StockNewsdmManager) defRandomString];
	// NSLog(@"[FlyJB] defRandomString = %s", bypasscode);
	if(!bypasscode || strcmp("00000000", bypasscode) != 0) {
		showAlertBypassFailedToss();
	}
	return %orig;
}
%end

void showAlertBypassFailedToss() {
	NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
	[userInfo setObject:@"bypassFailedToss" forKey:@"terminateReason"];
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"kr.xsf1re.flyjbcenter" object:nil userInfo:userInfo];
	exit(0);
}

void loadCheckHooks() {
	%init(CheckHooks);
}
