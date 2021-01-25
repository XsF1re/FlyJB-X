#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "../Headers/OptimizeDisableInjector.h"
#include <sys/syscall.h>
#include <spawn.h>
#import "../Headers/FJPattern.h"

@interface RBSProcessIdentity : NSObject
@property(readonly, copy, nonatomic) NSString *embeddedApplicationIdentifier;
@end

@interface FBProcessExecutionContext : NSObject
@property (nonatomic,copy) NSDictionary* environment;
@property (nonatomic,copy) RBSProcessIdentity* identity;
@end

%group OptimizeDisableInjector
%hook FBProcessManager
//iOS 13 Higher
- (id)_createProcessWithExecutionContext: (FBProcessExecutionContext*)executionContext {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/kr.xsf1re.flyjb.plist"];
  NSMutableDictionary *prefs_optimize = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/kr.xsf1re.flyjb_optimize.plist"];
	NSMutableDictionary *prefs_disabler = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/kr.xsf1re.flyjb_disabler.plist"];
	NSString *bundleID = executionContext.identity.embeddedApplicationIdentifier;
	BOOL optimizeEnabled = [prefs[bundleID] boolValue] && [prefs_optimize [bundleID] boolValue] && ![prefs_disabler [bundleID] boolValue];

	if([bundleID isEqualToString:@"com.vivarepublica.cash"]) {
		return %orig;
	}

	if([prefs[@"enabled"] boolValue]) {
		//NSLog(@"[test] FBProcessManager createApplicationProcessForBundleID, bundleIDx = %@", bundleIDx);
		if ([prefs_disabler[bundleID] boolValue] || optimizeEnabled) {
					NSMutableDictionary* environmentM = [executionContext.environment mutableCopy];
					if(optimizeEnabled)
						[environmentM setObject:@"/usr/lib/FJHooker.dylib" forKey:@"DYLD_INSERT_LIBRARIES"];
					[environmentM setObject:@(1) forKey:@"_MSSafeMode"];
					[environmentM setObject:@(1) forKey:@"_SafeMode"];
					executionContext.environment = [environmentM copy];
		}
	}
	return %orig;
}

//iOS 12 Lower
-(id)createApplicationProcessForBundleID: (NSString *)bundleID withExecutionContext: (FBProcessExecutionContext*)executionContext {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/kr.xsf1re.flyjb.plist"];
  NSMutableDictionary *prefs_optimize = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/kr.xsf1re.flyjb_optimize.plist"];
	NSMutableDictionary *prefs_disabler = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/kr.xsf1re.flyjb_disabler.plist"];
	BOOL optimizeEnabled = [prefs[bundleID] boolValue] && [prefs_optimize [bundleID] boolValue] && ![prefs_disabler [bundleID] boolValue];

	if([bundleID isEqualToString:@"com.vivarepublica.cash"]) {
		return %orig;
	}

	if([prefs[@"enabled"] boolValue]) {
		//NSLog(@"[test] FBProcessManager createApplicationProcessForBundleID, bundleIDx = %@", bundleIDx);
		if ([prefs_disabler[bundleID] boolValue] || optimizeEnabled) {
					NSMutableDictionary* environmentM = [executionContext.environment mutableCopy];
					if(optimizeEnabled)
						[environmentM setObject:@"/usr/lib/FJHooker.dylib" forKey:@"DYLD_INSERT_LIBRARIES"];
					[environmentM setObject:@(1) forKey:@"_MSSafeMode"];
					[environmentM setObject:@(1) forKey:@"_SafeMode"];
					executionContext.environment = [environmentM copy];
		}
	}
	return %orig;
}
%end
%end

void loadOptimizeDisableInjector() {
	%init(OptimizeDisableInjector);
}
