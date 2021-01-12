#include "ImportHooker.h"

//void *handlerCS = NULL;
static void *handlerD = NULL;
static void *handlerD_DobbyHook = NULL;
static void *handlerD_DobbyInstrument = NULL;
static void *handlerD_DENBT = NULL;
static void *handlerD_DDNTBT = NULL;

//void openCydiaSubstrate() {
//    handlerCS = dlopen("/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate", RTLD_NOW);
//}
//
//void closeCydiaSubstrate() {
//    dlclose(handlerCS);
//}


void getAddrFuncDobby() {
    handlerD_DobbyHook = dlsym(handlerD, "DobbyHook");
    handlerD_DobbyInstrument = dlsym(handlerD, "DobbyInstrument");
    handlerD_DENBT = dlsym(handlerD, "dobby_enable_near_branch_trampoline");
    handlerD_DDNTBT = dlsym(handlerD, "dobby_disable_near_branch_trampoline");
}

void openDobby() {
    handlerD = dlopen("/usr/lib/FJDobby", RTLD_NOW);
    getAddrFuncDobby();
}

void closeDobby() {
    dlclose(handlerD);
}

//void MSHookFunction(void *symbol, void *hook, void **old) {
//    void (*MSHookFunction)(void *symbol, void *hook, void **old) = NULL;
//    MSHookFunction = (void (*)(void *, void *, void **))dlsym(handlerCS, "MSHookFunction");
//    MSHookFunction(symbol, hook, old);
//}

int DobbyHook(void *symbol, void *hook, void **old) {
    int (*DobbyHook)(void *symbol, void *hook, void **old) = NULL;
    DobbyHook = (int (*)(void *, void *, void **))handlerD_DobbyHook;
    return DobbyHook(symbol, hook, old);
}

//void *MSFindSymbol(MSImageRef image, const char *name) {
//    void* (*MSFindSymbol)(MSImageRef image, const char *name) = NULL;
//    MSFindSymbol = (void* (*)(MSImageRef image, const char *name))dlsym(handlerCS, "MSFindSymbol");
//    return MSFindSymbol(image, name);
//}

int DobbyInstrument(void *instr_address, DBICallTy dbi_call) {
    int (*DobbyInstrument)(void *instr_address, DBICallTy dbi_call) = NULL;
    DobbyInstrument = (int (*)(void *instr_address, DBICallTy dbi_call))handlerD_DobbyInstrument;
    return DobbyInstrument(instr_address, dbi_call);
}

//void MSHookMessageEx(Class _class, SEL sel, IMP imp, IMP *result) {
//    void (*MSHookMessageEx)(Class _class, SEL sel, IMP imp, IMP *result) = NULL;
//    MSHookMessageEx = (void (*)(Class _class, SEL sel, IMP imp, IMP *result))dlsym(handlerCS, "MSHookMessageEx");
//    MSHookMessageEx(_class, sel, imp, result);
//}

void dobby_enable_near_branch_trampoline() {
    void (*dobby_enable_near_branch_trampoline)() = NULL;
    dobby_enable_near_branch_trampoline = (void (*)())handlerD_DENBT;
    dobby_enable_near_branch_trampoline();
}

void dobby_disable_near_branch_trampoline() {
    void (*dobby_disable_near_branch_trampoline)() = NULL;
    dobby_disable_near_branch_trampoline = (void (*)())handlerD_DDNTBT;
    dobby_disable_near_branch_trampoline();
}
