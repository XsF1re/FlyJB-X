#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "../Headers/MemHooks.h"
#import "../Headers/AeonLucid.h"
#import "../Headers/dobby.h"
#import "../Headers/FJPattern.h"
#include <sys/syscall.h>
#include <dlfcn.h>
#include <mach-o/dyld.h>

@implementation MemHooks
- (NSDictionary *)getFJMemory {
	NSData *FJMemory = [NSData dataWithContentsOfFile:@"/var/mobile/Library/Preferences/FJMemory" options:0 error:nil];
	NSDictionary *DecryptedFJMemory = [NSJSONSerialization JSONObjectWithData:FJMemory options:0 error:nil];
	return DecryptedFJMemory;
}
@end

uint8_t RET[] = {
	0xC0, 0x03, 0x5F, 0xD6  //RET
};

uint8_t RET1[] = {
	0x20, 0x00, 0x80, 0xD2,	//MOV X0, #1
	0xC0, 0x03, 0x5F, 0xD6  //RET
};

uint8_t KJP[] = {
	0x1F, 0x20, 0x03, 0xD5,	//NOP
	0x09, 0x00, 0x00, 0x14	//B #0x24
};

uint8_t SYSOpenBlock[] = {
	0xB0, 0x00, 0x80, 0xD2, //MOV X16, #5
	0x00, 0x00, 0x80, 0x52  //MOV X0, #0
};

uint8_t SYSAccessBlock[] = {
	0xB0, 0x00, 0x80, 0xD2,	//MOV X16, #21
	0x40, 0x00, 0x80, 0x52	//MOV X0, #2
};

uint8_t SYSAccessNOPBlock[] = {
	0xB0, 0x00, 0x80, 0xD2, //MOV X16, #21
	0x1F, 0x20, 0x03, 0xD5,  //NOP
	0x1F, 0x20, 0x03, 0xD5,  //NOP
	0x1F, 0x20, 0x03, 0xD5,  //NOP
	0x40, 0x00, 0x80, 0x52  //MOV X0, #2
};

void (*orig_subroutine)(void);
void nothing(void)
{
	;
}

int (*orig_int)(void);

int ret_0(void)
{
	return 0;
}

int ret_1(void)
{
	return 1;
}

void startHookTarget_lxShield(uint8_t* match) {

	hook_memory(match - 0x1C, RET, sizeof(RET));

}

void startHookTarget_AhnLab(uint8_t* match) {

	hook_memory(match, RET, sizeof(RET));

}

void startHookTarget_AhnLab2(uint8_t* match) {

	hook_memory(match - 0x10, RET, sizeof(RET));

}

void startHookTarget_AhnLab3(uint8_t* match) {

	hook_memory(match - 0x8, RET, sizeof(RET));

}

void startHookTarget_AhnLab4(uint8_t* match) {

	hook_memory(match - 0x10, RET, sizeof(RET));

}

void startHookTarget_AppSolid(uint8_t* match) {

	hook_memory(match, RET, sizeof(RET));

}

void startPatchTarget_KJBank(uint8_t* match) {
	hook_memory(match - 0x4, KJP, sizeof(KJP));
}

void startPatchTarget_KJBank2(uint8_t* match) {
	uint8_t B10[] = {
		0x04, 0x00, 0x00, 0x14  //B #0x10
	};

	hook_memory(match + 0x14, B10, sizeof(B10));
}

void startPatchTarget_nProtect(uint8_t* match) {
	hook_memory(match, RET, sizeof(RET));
}

void startPatchTarget_nProtect2(uint8_t* match) {
	hook_memory(match - 0x10, RET, sizeof(RET));
}

void startPatchTarget_MiniStock(uint8_t* match) {
	hook_memory(match - 0x1C, RET1, sizeof(RET1));
}

void startPatchTarget_SYSAccess(uint8_t* match) {

	hook_memory(match, SYSAccessBlock, sizeof(SYSAccessBlock));

}

void startPatchTarget_SYSAccessNOP(uint8_t* match) {

	hook_memory(match, SYSAccessNOPBlock, sizeof(SYSAccessNOPBlock));

}

void startPatchTarget_SYSOpen(uint8_t* match) {

	hook_memory(match, SYSOpenBlock, sizeof(SYSOpenBlock));

}

// ====== PATCH CODE ====== //
void SVC80_handler(RegisterContext *reg_ctx, const HookEntryInfo *info) {

	int syscall_num = (int)(uint64_t)reg_ctx->general.regs.x16;
	if(syscall_num == SYS_open || syscall_num == SYS_access || syscall_num == SYS_lstat64 || syscall_num == SYS_setxattr || syscall_num == SYS_stat64 || syscall_num == SYS_rename) {
		const char* path = (const char*)(uint64_t)(reg_ctx->general.regs.x0);
		NSString* path2 = [NSString stringWithUTF8String:path];
		if(![path2 hasSuffix:@"/sbin/mount"] && [[FJPattern sharedInstance] isPathRestrictedForSymlink:path2]) {
			*(unsigned long *)(&reg_ctx->general.regs.x0) = (unsigned long long)"/XsF1re";
			NSLog(@"[FlyJB] Bypassed SVC #0x80 - num: %d, path: %s", syscall_num, path);
		}
		else {
			NSLog(@"[FlyJB] Detected SVC #0x80 - num: %d, path: %s", syscall_num, path);
		}
	}

	else if(syscall_num == SYS_syscall) {
		int x0 = (int)(uint64_t)reg_ctx->general.regs.x0;
		NSLog(@"[FlyJB] Detected syscall of SVC #0x80 number: %d", x0);
	}

	else if(syscall_num == SYS_exit) {
		NSLog(@"[FlyJB] Detected SVC #0x80 Exit call stack: \n%@", [NSThread callStackSymbols]);
	}

	else {
		NSLog(@"[FlyJB] Detected Unknown SVC #0x80 number: %d", syscall_num);
	}

}

void startHookTarget_SVC80(uint8_t* match) {

	dobby_enable_near_branch_trampoline();
	DobbyInstrument((void *)(match), (DBICallTy)SVC80_handler);
	dobby_disable_near_branch_trampoline();

}

void loadSVC80MemHooks() {
	const uint8_t target[] = {
		0x01, 0x10, 0x00, 0xD4  //SVC #0x80
	};

	scan_executable_memory(target, sizeof(target), &startHookTarget_SVC80);
}

void SVC80Access_handler(RegisterContext *reg_ctx, const HookEntryInfo *info) {

	const char* path = (const char*)(uint64_t)(reg_ctx->general.regs.x0);
	NSString* path2 = [NSString stringWithUTF8String:path];

//Arxan 솔루션에서는 /sbin/mount 파일이 존재해야 우회됨.
	if(![path2 hasSuffix:@"/sbin/mount"] && [[FJPattern sharedInstance] isPathRestrictedForSymlink:path2]) {
		//Start Bypass
		NSLog(@"[FlyJB] Bypassed SVC #0x80 - SYS_Access path = %s", path);
		*(unsigned long *)(&reg_ctx->general.regs.x0) = (unsigned long long)"/XsF1re";
	}
	else {
		NSLog(@"[FlyJB] Detected SVC #0x80 - SYS_Access path = %s", path);
	}
}

void startHookTarget_SVC80Access(uint8_t* match) {

	dobby_enable_near_branch_trampoline();
	DobbyInstrument((void *)(match), (DBICallTy)SVC80Access_handler);
	dobby_disable_near_branch_trampoline();

}

void loadSVC80AccessMemHooks() {

	const uint8_t target[] = {
		0x30, 0x04, 0x80, 0xD2, //MOV X16, #21
		0x01, 0x10, 0x00, 0xD4  //SVC #0x80
	};
	scan_executable_memory(target, sizeof(target), &startHookTarget_SVC80Access);

	const uint8_t target2[] = {
		0x30, 0x04, 0x80, 0xD2, //MOV X16, #21
		0x1F, 0x20, 0x03, 0xD5,  //NOP
		0x1F, 0x20, 0x03, 0xD5,  //NOP
		0x1F, 0x20, 0x03, 0xD5,  //NOP
		0x01, 0x10, 0x00, 0xD4  //SVC #0x80
	};
	scan_executable_memory(target2, sizeof(target2), &startHookTarget_SVC80Access);

}

void SVC80Open_handler(RegisterContext *reg_ctx, const HookEntryInfo *info) {

	const char* path = (const char*)(uint64_t)(reg_ctx->general.regs.x0);
	NSString* path2 = [NSString stringWithUTF8String:path];

	if(![path2 hasSuffix:@"/sbin/mount"] && [[FJPattern sharedInstance] isPathRestrictedForSymlink:path2]) {
		//Start Bypass
		NSLog(@"[FlyJB] Bypassed SVC #0x80 - SYS_Open path = %s", path);
		*(unsigned long *)(&reg_ctx->general.regs.x0) = (unsigned long long)"/XsF1re";
	}
	else {
		NSLog(@"[FlyJB] Detected SVC #0x80 - SYS_Open path = %s", path);
	}
}

void startHookTarget_SVC80Open(uint8_t* match) {
	dobby_enable_near_branch_trampoline();
	DobbyInstrument((void *)(match), (DBICallTy)SVC80Open_handler);
	dobby_disable_near_branch_trampoline();
}

void loadSVC80OpenMemHooks() {

	const uint8_t target[] = {
		0xB0, 0x00, 0x80, 0xD2, //MOV X16, #5
		0x01, 0x10, 0x00, 0xD4  //SVC #0x80
	};
	scan_executable_memory(target, sizeof(target), &startHookTarget_SVC80Open);
}

void SVC80Exit_handler(RegisterContext *reg_ctx, const HookEntryInfo *info) {
	NSLog(@"[FlyJB] Detected SVC #0x80 Exit call stack: \n%@", [NSThread callStackSymbols]);
}

void startHookTarget_SVC80Exit(uint8_t* match) {
	// dobby_enable_near_branch_trampoline();
	DobbyInstrument((void *)(match + 0x4), (DBICallTy)SVC80Exit_handler);
	// dobby_disable_near_branch_trampoline();
}

void loadSVC80ExitMemHooks() {

	const uint8_t target[] = {
		0x30, 0x00, 0x80, 0xD2, //MOV X16, #1
		0x01, 0x10, 0x00, 0xD4  //SVC #0x80
	};
	scan_executable_memory(target, sizeof(target), &startHookTarget_SVC80Exit);
}
//
// void blrx8_handler(RegisterContext *reg_ctx, const HookEntryInfo *info) {
// 	uint64_t x8 = (uint64_t)(reg_ctx->general.regs.x8);
// 	NSLog(@"[FlyJB] BLR X8: %llX", x8 - _dyld_get_image_vmaddr_slide(3));
// 	NSLog(@"[FlyJB] BLR X8 callstack: %@", [NSThread callStackSymbols]);
// }
//
// void blrx9_handler(RegisterContext *reg_ctx, const HookEntryInfo *info) {
// 	uint64_t x9 = (uint64_t)(reg_ctx->general.regs.x9);
// 	NSLog(@"[FlyJB] BLR X9: %llX", x9 - _dyld_get_image_vmaddr_slide(3));
// }
//
// void blrx10_handler(RegisterContext *reg_ctx, const HookEntryInfo *info) {
// 	uint64_t x10 = (uint64_t)(reg_ctx->general.regs.x10);
// 	NSLog(@"[FlyJB] BLR X10: %llX", x10 - _dyld_get_image_vmaddr_slide(3));
// }

// ====== PATCH FROM FJMemory ====== //
void loadFJMemoryHooks() {

	NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
	// loadSVC80MemHooks();
	// NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
	bundlePath = [bundlePath stringByAppendingString:@"/Info.plist"];
	NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] initWithContentsOfFile:bundlePath];
	NSString *appVersion = infoDict[@"CFBundleShortVersionString"];
	NSDictionary *dict = [[[MemHooks alloc] init] getFJMemory];

	//Framework
	NSInteger fwAddrCount = [[[[dict valueForKeyPath:bundleID] objectForKey:appVersion] objectForKeyedSubscript:@"fwAddr"] count];
	NSString* fwName = [[[[dict valueForKeyPath:bundleID] objectForKey:appVersion] objectForKeyedSubscript:@"fwName"] objectAtIndex:0];

	if(fwAddrCount) {
		int imageIndex = 0;
		uint32_t count = _dyld_image_count();
		for(uint32_t i = 0; i < count; i++)
		{
			const char *dyld = _dyld_get_image_name(i);
			NSString *nsdyld = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:dyld length:strlen(dyld)];
			if([nsdyld hasSuffix:fwName]) {
				NSLog(@"[FlyJB] Found fwName: %@, imageIndex: %d", nsdyld, i);
				imageIndex = i;
				break;
			}
		}

		for(int j=0; j < fwAddrCount; j++)
		{
			NSString* nsfwaddr = [[[[dict valueForKeyPath:bundleID] objectForKey:appVersion] objectForKeyedSubscript:@"fwAddr"] objectAtIndex:j];
			NSLog(@"[FlyJB] nsfwaddr: %@", nsfwaddr);
			unsigned long fwAddr = _dyld_get_image_vmaddr_slide(imageIndex) + strtoull(nsfwaddr.UTF8String, NULL, 0);
			MSHookFunction((void *)fwAddr, (void *)ret_0, (void **)&orig_int);
		}
	}



	//App
	NSInteger dictAddrCount = [[[[dict valueForKeyPath:bundleID] objectForKey:appVersion] objectForKeyedSubscript:@"addr"] count];
	if(dictAddrCount) {
		for(int i=0; i < dictAddrCount; i++)
		{
			NSString* dict_addr = [[[[dict valueForKeyPath:bundleID] objectForKey:appVersion] objectForKeyedSubscript:@"addr"] objectAtIndex:i];
			NSString* dict_instr = [[[[dict valueForKeyPath:bundleID] objectForKey:appVersion] objectForKeyedSubscript:@"instr"] objectAtIndex:i];
			NSLog(@"[FlyJB] bundleID = %@, dict_addr = %@, dict_instr = %@", bundleID, dict_addr, dict_instr);
			writeData(strtoull(dict_addr.UTF8String, NULL, 0), strtoull(dict_instr.UTF8String, NULL, 0));
		}
	}

}

// ====== 하나멤버스 무결성 복구 ====== //
%group FJMemoryIntegrityRecoverHMS
%hook NSFileManager
- (BOOL)fileExistsAtPath: (NSString *)path {

	if([path hasSuffix:@"/com.vungle/userInfo"]) {
		NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
		NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
		NSDictionary *dict = [[[MemHooks alloc] init] getFJMemory];
		NSInteger dictInstrOrigCount = [[[[dict valueForKeyPath:bundleID] objectForKey:appVersion] objectForKeyedSubscript:@"instr_orig"] count];
		if(dictInstrOrigCount) {
			for(int i=0; i < dictInstrOrigCount; i++)
			{
				NSString* dict_addr = [[[[dict valueForKeyPath:bundleID] objectForKey:appVersion] objectForKeyedSubscript:@"addr"] objectAtIndex:i];
				NSString* dict_instrOrig = [[[[dict valueForKeyPath:bundleID] objectForKey:appVersion] objectForKeyedSubscript:@"instr_orig"] objectAtIndex:i];
				writeData(strtoull(dict_addr.UTF8String, NULL, 0), strtoull(dict_instrOrig.UTF8String, NULL, 0));
			}
		}
	}

	return %orig;
}
%end
%end

// ====== 롯데안심인증 무결성 복구 ====== //
%group FJMemoryIntegrityRecoverLMP
%hook XASAskJobs
+(int)updateCheck {

	NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
	NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	NSDictionary *dict = [[[MemHooks alloc] init] getFJMemory];
	NSInteger dictInstrOrigCount = [[[[dict valueForKeyPath:bundleID] objectForKey:appVersion] objectForKeyedSubscript:@"instr_orig"] count];
	if(dictInstrOrigCount) {
		for(int i=0; i < dictInstrOrigCount; i++)
		{
			NSString* dict_addr = [[[[dict valueForKeyPath:bundleID] objectForKey:appVersion] objectForKeyedSubscript:@"addr"] objectAtIndex:i];
			NSString* dict_instrOrig = [[[[dict valueForKeyPath:bundleID] objectForKey:appVersion] objectForKeyedSubscript:@"instr_orig"] objectAtIndex:i];
			writeData(strtoull(dict_addr.UTF8String, NULL, 0), strtoull(dict_instrOrig.UTF8String, NULL, 0));
		}
	}

	return 121;
}
%end
%end

void loadFJMemoryIntegrityRecover() {
	NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
	if([bundleID isEqualToString:@"com.hana.hanamembers"]) {
		%init(FJMemoryIntegrityRecoverHMS);
	}
	if([bundleID isEqualToString:@"com.lottecard.mobilepay"]) {
		%init(FJMemoryIntegrityRecoverLMP);
	}
}

// ====== PATCH SYMBOL FROM FJMemory ====== //
void loadFJMemorySymbolHooks() {
	NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
	NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	NSDictionary *dict = [[[MemHooks alloc] init] getFJMemory];
	NSInteger SymbolCount = [[[[dict valueForKeyPath:bundleID] objectForKey:appVersion] objectForKeyedSubscript:@"symbol"] count];
	for(int i=0; i < SymbolCount; i++)
	{
		NSString* dict_Symbol = [[[[dict valueForKeyPath:bundleID] objectForKey:appVersion] objectForKeyedSubscript:@"symbol"] objectAtIndex:i];
		const char *dict_Symbol_cs = [dict_Symbol cStringUsingEncoding:NSUTF8StringEncoding];
		MSHookFunction(MSFindSymbol(NULL, dict_Symbol_cs), (void *)nothing, (void **)&orig_subroutine);
	}
}
