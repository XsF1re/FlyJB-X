#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "../../Headers/AeonLucid.h"
#include <mach-o/dyld.h>

static uint8_t RET[] = {
	0xC0, 0x03, 0x5F, 0xD6  //RET
};
