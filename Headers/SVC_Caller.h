#include <stdio.h>
#include <stdint.h>

inline int SVC_Access(const char* detectionPath) {

#if defined __arm64__ || defined __arm64e__
	int64_t flag = 0;
	__asm __volatile("mov x0, %0" :: "r" (detectionPath));    //path
	__asm __volatile("mov x1, #0");   //mode
	__asm __volatile("mov x16, #0x21");       //access
	__asm __volatile("svc #0x80");    //supervisor call
	__asm __volatile("mov %0, x0" : "=r" (flag));
#else
	int flag = 0;
	__asm __volatile("mov r0, %0" :: "r" (detectionPath)); //path
	__asm __volatile("mov r1, #0"); //mode
	__asm __volatile("mov r12, #0x21"); //access
	__asm __volatile("svc #0x80"); //supervisor call
	__asm __volatile("mov %0, r0" : "=r" (flag));
#endif
	return flag;
}