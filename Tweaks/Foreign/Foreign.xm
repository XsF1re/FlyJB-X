#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <mach-o/dyld.h>
#import "../../Headers/Foreign/Foreign.h"
#import "../../Headers/Foreign/PatchFinder.h"
#import "../../Headers/MemHooks.h"
#import "../../Headers/AeonLucid.h"


int (*orig_func)(void);
int hook_func(void) {
    NSLog(@"[FlyJB] hook_func call stack:\n%@", [NSThread callStackSymbols]);
    return 0;
}



void loadForeignBypass() {

    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];

    //iXGuard - Bank Muscat
	if([bundleID isEqualToString:@"com.bankmuscat.bm"]) {
		loadSVC80MemHooks();
	}

    //Arxan - Commerzbank photoTAN
    if([bundleID isEqualToString:@"de.comdirect.phototan"]) {
		loadSVC80AccessMemHooks();
	}
}