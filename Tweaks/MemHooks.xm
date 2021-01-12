#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "../Headers/MemHooks.h"
#import "../Headers/AeonLucid.h"
#import "../Headers/dobby.h"
#import "../Headers/FJPattern.h"
#include <sys/syscall.h>
#include <dlfcn.h>

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
	if(syscall_num == SYS_open || syscall_num == SYS_access || syscall_num == SYS_lstat64) {
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

	//int num_syscall = (int)(uint64_t)reg_ctx->general.regs.x16;
	//NSLog(@"[FlyJB] Detected SVC #0x80 number = %d", num_syscall);

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



// ====== PATCH FROM FJMemory ====== //
void loadFJMemoryHooks() {

	NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
	NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	NSDictionary *dict = [[[MemHooks alloc] init] getFJMemory];
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
