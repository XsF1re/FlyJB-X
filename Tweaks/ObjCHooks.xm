#import "../Headers/ObjCHooks.h"
#import "../Headers/FJPattern.h"

static NSError *_error_file_not_found = nil;

%group ObjCHooks
// %hook NSProcessInfo
// -(NSDictionary*)environment {
// 	NSDictionary *orig = %orig;
// 	NSMutableDictionary *dict = [orig mutableCopy];
// 	[dict removeObjectForKey:@"DYLD_INSERT_LIBRARIES"];
// 	return dict;
// }
// %end

// %hook UIViewController
// -(void)setRootViewController:(UIViewController *)arg1 {
// 	NSLog(@"[FlyJB] UIWindow setRootViewController");
// 	%orig;
// }
// %end
//
// %hook ViewHelper
// +(void)showAlertAndExit:(id)arg1 {
// 	NSLog(@"[FlyJB] ViewHelper: %@", arg1);
// 	%orig;
// }
// %end
//
// %hook UIStoryboard
// + (UIStoryboard *)storyboardWithName:(NSString *)name bundle:(NSBundle *)storyboardBundleOrNil {
// 	// if([name isEqualToString:@"LaunchScreen"] && !storyboardBundleOrNil)
// 	// 	return %orig(@"Main", [NSBundle mainBundle]);
// 	NSLog(@"[FlyJB] UIStoryboard: %@, storyboardBundleOrNil: %@", name, storyboardBundleOrNil);
// 	return %orig;
// }
//
// -(id)instantiateInitialViewController {
// 	id orig = %orig;
// 	NSLog(@"[FlyJB] UIStoryboard instantiateInitialViewController: %@", orig);
// 	return orig;
// }
// %end
//
// %hook UIView
// +(void)transitionWithView:(id)arg1 duration:(double)arg2 options:(unsigned long long)arg3 animations:(/*^block*/id)arg4 completion:(/*^block*/id)arg5 {
// 	NSLog(@"[FlyJB] UIView transitionWithView: %@, duration: %f, options: %llu, animations: %@, completion: %@", arg1, arg2, arg3, arg4, arg5);
// 	%orig;
// }
//
// -(id)window {
// 	id orig = %orig;
// 	// NSLog(@"[FlyJB] window: %@", orig);
// 	return orig;
// }
// %end

%hook UIApplication
-(BOOL)openURL:(NSURL *)url {
	if([[FJPattern sharedInstance] isURLRestricted:url]) {
		return NO;
	}
	return %orig;
}

- (BOOL)canOpenURL: (NSURL *)url {
	if([[FJPattern sharedInstance] isURLRestricted:url]) {
		return NO;
	}
	return %orig;
}
%end

%hook NSString
- (BOOL)writeToFile: (NSString *)path atomically: (BOOL)useAuxiliaryFile encoding: (NSStringEncoding)enc error: (NSError * _Nullable *)error {
	if([[FJPattern sharedInstance] isSandBoxPathRestricted:path]) {
		return %orig(nil, useAuxiliaryFile, enc, error);
	}
	else {
		return %orig;
	}
}

- (BOOL)writeToFile: (NSString *)path  {
	if([[FJPattern sharedInstance] isSandBoxPathRestricted:path]) {
		return NO;
	}
	else {
		return %orig;
	}
}

//NSHC BinaryChecker and etc... +mVaccine v2
- (NSString *)substringFromIndex: (NSUInteger)from {
	NSString *orig = %orig;
	if(from == 2 && [orig hasPrefix:@"/"] && [[FJPattern sharedInstance] isPathRestricted:orig])
	{
		return @"/substringFromIndexHooked";
	}
	return orig;
}
%end

%hook NSFileManager
- (BOOL)isReadableFileAtPath: (NSString *)path {
	if([[FJPattern sharedInstance] isPathRestricted:path]) {
		return NO;
	}
	return %orig;
}

- (NSString *)destinationOfSymbolicLinkAtPath: (NSString *)path error: (NSError * _Nullable *)error {
	if([[FJPattern sharedInstance] isPathRestricted:path]) {
		if(error) {
			*error = _error_file_not_found;
		}
		return nil;
	}
	return %orig;
}

- (BOOL)isWritableFileAtPath: (NSString *)path {
	if([[FJPattern sharedInstance] isSandBoxPathRestricted:path]) {
		return NO;
	}
	return %orig;
}

- (NSArray<NSString *> *)contentsOfDirectoryAtPath: (NSString *)path error: (NSError * _Nullable *)error {
	if([[FJPattern sharedInstance] isPathRestricted:path]
	   || [path isEqualToString:@"/bin"]) {
		if(error) {
			*error = _error_file_not_found;
		}
		return nil;
	}
	NSMutableArray *filtered_ret = nil;
	NSArray *ret = %orig;
	if(ret) {
		filtered_ret = [NSMutableArray new];
		for(NSString *ret_path in ret) {
			if(![[FJPattern sharedInstance] isPathRestricted:[path stringByAppendingPathComponent:ret_path]]) {
				[filtered_ret addObject:ret_path];
			}
		}
	}
	ret = [filtered_ret copy];
	return ret;
}

-(BOOL) changeCurrentDirectoryPath: (NSString *)path {
	if([[FJPattern sharedInstance] isPathRestricted:path])
	{
		return NO;
	}
	return %orig;
}

- (BOOL)removeItemAtPath: (NSString *)path {
	if([[FJPattern sharedInstance] isSandBoxPathRestricted:path]) {
		return NO;
	}
	else {
		return %orig;
	}
}

- (BOOL)fileExistsAtPath: (NSString *)path isDirectory: (BOOL *)isDirectory {
	if([[FJPattern sharedInstance] isPathRestricted:path])
	{
		return NO;
	}
	return %orig;
}

- (BOOL)fileExistsAtPath: (NSString *)path {
	if([[FJPattern sharedInstance] isPathRestricted:path])
	{
		return NO;
	}
	return %orig;
}

%end
%end

%group StealienObjCHooks
%hook NSString
- (NSString *)stringByAppendingString: (NSString *)aString {
	NSString *orig = %orig;
	if ([orig isEqualToString:@"%08X"]) {
		return @"00000000";
	}
	return orig;
}
%end
%end

%group YogiyoObjCHooks
%hook NSUserDefaults
-(BOOL)boolForKey: (NSString *)defaultName {
	if([defaultName isEqualToString:@"colorChecker"]) {
		return NO;
	}
	return %orig;
}
%end
%end

void loadObjCHooks() {
	%init(ObjCHooks);
}

void loadStealienObjCHooks() {
	%init(StealienObjCHooks);
}

void loadYogiyoObjcHooks() {
	%init(YogiyoObjCHooks);
}
