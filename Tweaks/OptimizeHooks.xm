#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "../Headers/OptimizeHooks.h"
#include <dlfcn.h>

#ifndef kCFCoreFoundationVersionNumber_iOS_14_1
#define kCFCoreFoundationVersionNumber_iOS_14_1 1751.108
#endif

%group OptimizeHooks
void* (*dlopen_internal)(const char*, int, void*);
void* $dlopen_internal(const char *path, int mode, void* lr)
{
	@autoreleasepool
	{
		if(path != NULL)
		{
			NSString* nspath = @(path);

			if((([nspath hasPrefix:@"/Library/MobileSubstrate/DynamicLibraries/"] || [nspath hasPrefix:@"/Library/TweakInject"])
		   && [nspath hasSuffix:@".dylib"])
			 && [nspath rangeOfString:@"AppList"].location == NSNotFound
		 	 && [nspath rangeOfString:@"PreferenceLoader"].location == NSNotFound
		   && [nspath rangeOfString:@"RocketBootstrap"].location == NSNotFound) {
				 // NSLog(@"[FlyJB] blocked dylib: %s", path);
				 return NULL;
			 }
		}
	}
	// NSLog(@"[FlyJB] dylib: %s", path);
	return dlopen_internal(path, mode, lr);
}

void* (*dlopen_regular)(const char*, int);
void* $dlopen_regular(const char *path, int mode)
{
	@autoreleasepool
	{
		if(path != NULL)
		{
			NSString* nspath = @(path);

			if((([nspath hasPrefix:@"/Library/MobileSubstrate/DynamicLibraries/"] || [nspath hasPrefix:@"/Library/TweakInject"])
		   && [nspath hasSuffix:@".dylib"])
			 && [nspath rangeOfString:@"AppList"].location == NSNotFound
		 	 && [nspath rangeOfString:@"PreferenceLoader"].location == NSNotFound
		   && [nspath rangeOfString:@"RocketBootstrap"].location == NSNotFound) {
				 // NSLog(@"[FlyJB] blocked dylib: %s", path);
				 return NULL;
			 }
		}
	}
	// NSLog(@"[FlyJB] dylib: %s", path);
	return dlopen_regular(path, mode);
}%end

void loadOptimizeHooks() {
//Thanks to opa334 (Choicy Project)
	%init(OptimizeHooks);
	MSImageRef libdyldImage = MSGetImageByName("/usr/lib/system/libdyld.dylib");

	if(kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_14_1)
	{
		MSHookFunction(MSFindSymbol(libdyldImage, "__ZL15dlopen_internalPKciPv"), (void*)$dlopen_internal, (void**)&dlopen_internal);
	}
	else
	{
		MSHookFunction(MSFindSymbol(libdyldImage, "_dlopen"), (void*)$dlopen_regular, (void**)&dlopen_regular);
	}
}
