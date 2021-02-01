#import <substrate.h>
#import "../Headers/dobby.h"

void loadFJMemoryHooks();
void loadFJMemoryRunTimeHooks();
void loadFJMemoryIntegrityRecover();
void loadFJMemorySymbolHooks();
void loadSVC80MemHooks();
void loadSVC80OpenMemHooks();
void loadSVC80AccessMemHooks();
void loadSVC80ExitMemHooks();
void loadOpendirMemHooks();
void startHookTarget_lxShield(uint8_t* match);
void startHookTarget_AhnLab(uint8_t* match);
void startHookTarget_AhnLab2(uint8_t* match);
void startHookTarget_AhnLab3(uint8_t* match);
void startHookTarget_AhnLab4(uint8_t* match);
void startHookTarget_AppSolid(uint8_t* match);
void startPatchTarget_SYSAccess(uint8_t* match);
void startPatchTarget_SYSAccessNOP(uint8_t* match);
void startPatchTarget_SYSOpen(uint8_t* match);
void startPatchTarget_KJBank(uint8_t* match);
void startPatchTarget_KJBank2(uint8_t* match);
void startPatchTarget_nProtect(uint8_t* match);
void startPatchTarget_nProtect2(uint8_t* match);
void startPatchTarget_MiniStock(uint8_t* match);

@interface MemHooks: NSObject
- (NSDictionary *)getFJMemory;
@end
