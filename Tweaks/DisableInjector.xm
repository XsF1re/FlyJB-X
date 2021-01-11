#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "../Headers/DisableInjector.h"
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

BOOL isSubstitute = ([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/lib/libsubstitute.dylib"] && ![[NSFileManager defaultManager] fileExistsAtPath:@"/usr/lib/substrate"] && ![[NSFileManager defaultManager] fileExistsAtPath:@"/usr/lib/libhooker.dylib"]);
const char *DisableLocation = "/var/tmp/.substitute_disable_loader";

%group DisableInjector
//iOS 11 ~ 13
%hook _SBApplicationLaunchAlertInfo
 -(NSString *)bundleID {
 	if (isSubstitute && syscall(SYS_access, DisableLocation, F_OK) == 0) {
 		//NSLog(@"[test] _SBApplicationLaunchAlertInfo bundleID = %@", orig);
 		//NSLog(@"[test] Found DisableLocation.");
 		int rmResult = remove(DisableLocation);
 		if(rmResult == -1) {
 			//NSLog(@"[test] Failed to remove file.");
 		}
 	}
 	return %orig;
 }
 %end

%hook FBProcessManager
//iOS 13 Higher
- (id)_createProcessWithExecutionContext: (FBProcessExecutionContext*)executionContext {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/kr.xsf1re.flyjb.plist"];
	NSMutableDictionary *prefs_disabler = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/kr.xsf1re.flyjb_disabler.plist"];
	NSString *bundleID = executionContext.identity.embeddedApplicationIdentifier;
	BOOL forcenabled = [prefs[@"forcenabled"] boolValue] && [prefs[bundleID] boolValue];

	if([bundleID isEqualToString:@"com.vivarepublica.cash"]) {
		return %orig;
	}

	if([prefs[@"enabled"] boolValue]) {
		//NSLog(@"[test] FBProcessManager createApplicationProcessForBundleID, bundleIDx = %@", bundleIDx);
		if ([prefs_disabler[bundleID] boolValue] || forcenabled) {
					if(isSubstitute && forcenabled) {
						FILE* fp = fopen(DisableLocation, "w");
						if (fp == NULL) {
							//NSLog(@"[test] Failed to write DisableLocation.");
						}
					}

					NSMutableDictionary* environmentM = [executionContext.environment mutableCopy];
					if(forcenabled)
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
	NSMutableDictionary *prefs_disabler = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/kr.xsf1re.flyjb_disabler.plist"];
	BOOL forcenabled = [prefs[@"forcenabled"] boolValue] && [prefs[bundleID] boolValue];

	if([bundleID isEqualToString:@"com.vivarepublica.cash"]) {
		return %orig;
	}

	if([prefs[@"enabled"] boolValue]) {
		//NSLog(@"[test] FBProcessManager createApplicationProcessForBundleID, bundleIDx = %@", bundleIDx);
		if ([prefs_disabler[bundleID] boolValue] || forcenabled) {
					if(isSubstitute && forcenabled) {
						FILE* fp = fopen(DisableLocation, "w");
						if (fp == NULL) {
							//NSLog(@"[test] Failed to write DisableLocation.");
						}
					}

					NSMutableDictionary* environmentM = [executionContext.environment mutableCopy];
					if(forcenabled)
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

void loadDisableInjector() {
	%init(DisableInjector);
}
