#import "../Headers/LibraryHooks.h"
#import "../Headers/FJPattern.h"

@interface JobBase : NSObject
+(id)sharedInstance;
+(void)notifyJobFinished:(int)arg1;
@end

%group LibraryHooks
// %hook TAUtil
// +(id)getCarrierCode {
// 	return @"1";
// }
// %end

//불명 - KB손해보험
%hook JBHelper
-(BOOL)getJBCResult {
	return false;
}
%end

//Arxan - THE POP
%hook thepop_Utils
+(void)showConfirmWithTitle:(id)arg1 message:(id)arg2 willDissmiss:(bool)arg3 rightButtnTitle:(id)arg4 onRightButtonClick:(id)arg5 {
	if([arg2 isEqualToString:@"위험요소(비정상 단말)가 감지되었습니다. 앱을 종료합니다."])
		return;
	return %orig;
}
%end

//Arxan - GS수퍼마켓
%hook gsthefresh_Utils
+(void)showConfirmWithTitle:(id)arg1 message:(id)arg2 willDissmiss:(bool)arg3 rightButtnTitle:(id)arg4 onRightButtonClick:(id)arg5 {
	if([arg2 isEqualToString:@"위험요소(비정상 단말)가 감지되었습니다. 앱을 종료합니다."])
		return;
	return %orig;
}
%end

//Arxan - 나만의냉장고
%hook gs25_Utils
+(void)showConfirmWithTitle:(id)arg1 message:(id)arg2 willDissmiss:(bool)arg3 rightButtnTitle:(id)arg4 onRightButtonClick:(id)arg5 {
	if([arg2 isEqualToString:@"위험요소(비정상 단말)가 감지되었습니다. 앱을 종료합니다."])
		return;
	return %orig;
}
%end

//NHN Payco (페이코)
%hook Diresu
+(int)s: (id)arg1: (id)arg2: (id)arg3: (id)arg4 {
	return 0;
}
%end

//nProtect AppGuard - 뱅뱅뱅 상상인디지털뱅크, 애큐온저축은행 모바일뱅킹
%hook AGFramework
-(void)CGColorSpaceCopyName: (BOOL)arg1 B: (void *)arg2 {
	;
}

-(void)CGColorGetPattern: (int)arg1 {
	;
}
%end

//KSFileUtil - opendir 후킹하면 substitute와 충돌 :(
%hook KSFileUtil
+(int)checkJailBreak {
	return 1;
}
%end

//Arxan 카카오뱅크 v2.2.0+
%hook AIPExecutor
-(void)detectedWith:(id)arg1 type:(int)arg2 {
	;
}
%end

//Arxan 삼성카드 마이홈
%hook samsungCardMyHome
-(void)crash {
	;
}

-(void)timeout {
	;
}

-(void)showPopup:(id)arg1 {
	;
}
%end

//Arxan BC카드
%hook BCAppDelegate
- (void)arxanHackingDetected: (id)arg1 {
	;
}
%end

//Arxan SSGPAY
%hook SSGPAY_DetectionController
-(void) sendLogWithFrgflsType: (id)arg1 {
	;
}
%end

//Arxan 우리카드, 우리페이, 위비멤버스
%hook ArxanTamper
-(void)didSendFinishedEx: (id)arg1 {
	;
}
%end

//Arxan 삼성앱카드
%hook EN_AIP
-(void)deleteMemo {
	;
}

//Arxan 우리카드 Lite
-(void)getIpInsideDataWithCode:(int)arg1 {
	;
}
%end

//Arxan? 하나은행
%hook DataManager
//(구)하나은행
-(void)setP_gCheckGuard: (id)arg1 {
	;
}
//NEW하나은행
-(void)setGCheckGuard: (id)arg1 {
	;
}
%end

//XecureAppShield? SVC
%hook XASBase64
+(id)decode: (char *)arg1 {
	NSString *path = %orig;
	if([[FJPattern sharedInstance] isPathRestricted:path])
		return nil;
	return %orig(arg1);
}
%end

//현대해상 - XAS, XFJailbreakDetection
%hook XASJailbreakDetection
+(BOOL)isJailbroken {
	return false;
}
%end

//RaonSecure
%hook mVaccine
-(BOOL)isJailBreak {
	return false;
}

-(BOOL)mvc {
	return false;
}
%end

//NSHC - 한국투자증권(계좌개설포힘)
// Get the instance of a class
// https://www.reddit.com/r/jailbreakdevelopers/comments/2rgjce/get_the_instance_of_a_class/
static JobBase* sharedInstanceJB = nil;
%hook JobBase
-(id)init {
	id orig = %orig;
  sharedInstanceJB = orig;
	return orig;
}

%new
+(id)sharedInstance{
  return sharedInstanceJB;
}
%end

%hook JobCodeGuard
-(void)onBegin {
	[[%c(JobBase) sharedInstance] notifyJobFinished:0];
}
%end

//NSHC
%hook SN_SelfChecker
-(BOOL)startToCheckError:(id*)arg1 {
	return NO;
}
%end

%hook iX_SelfChecker
-(BOOL)startToCheckError:(id*)arg1 {
	return NO;
}
%end

%hook __ns_a
-(id)__ns_a1 {
	return @"0";
}
%end

%hook Sanne
-(id)sanneResult {
	NSArray *keys = [NSArray arrayWithObjects:@"ResultCode", nil];
	NSArray *objects = [NSArray arrayWithObjects:@"0000", nil];
	NSDictionary *output = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	return output;
}
%end

%hook __ns_d
-(NSString*)detectionObject {
	NSString* orig = %orig;
	if([orig hasSuffix:@"san.dat"] || [orig hasSuffix:@"updateinfo.dat"])
		return orig;
	return @"/NSHC.bypass";
}
%end

%hook IxShieldController
+(BOOL)systemCheck {
	return true;
}

+(BOOL)integrityCheck {
	return true;
}
%end

//AhnLab
//SBI저축은행
%hook LayoutManag
-(int)a3142:(id)arg1 {
	return 200;
}

-(int)timestamp {
	return 0;
}
%end

%hook AMSLFairPlayInspector
-(id)init {
	return self;
}

+(id)fairPlayInspector {
	return [[self alloc] init];
}

-(id)responseForChallenge {
	return nil;
}

+(id)unarchive: (id)arg1 {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	NSData *object_nsdata = [@"AhnLab.bypass" dataUsingEncoding:NSUTF8StringEncoding];
	[dict setObject:object_nsdata forKey:@"kConfirm"];
	[dict setObject:object_nsdata forKey:@"kConfirmValidation"];
	[dict setObject:object_nsdata forKey:@"8D9188AA-36C3-428E-BE4C-134EF1EBF648"];
	[dict setObject:object_nsdata forKey:@"95BA52F0-0A20-4728-89C1-18B5E69ECE04"];
	return dict;
}

+(id)hmacWithSierraEchoCharlieRomeoEchoTango: (id)arg1 andData: (id)arg2 {
	NSData *object_nsdata = [@"AhnLab.bypass" dataUsingEncoding:NSUTF8StringEncoding];
	return object_nsdata;
}

-(id)fairPlayWithResponseAck: (id)arg1 {
	NSData *object_nsdata = [@"AhnLab.bypass" dataUsingEncoding:NSUTF8StringEncoding];
	return object_nsdata;
}
%end

%hook StringEncryption
- (id)decrypt: (id)arg1 key: (id)arg2 padding: (int)arg3 {
	NSData *orig = %orig;
	NSString* decode = [[NSString alloc] initWithData:orig encoding:NSUTF8StringEncoding];
	if([[FJPattern sharedInstance] isPathRestricted:decode] || [[FJPattern sharedInstance] isAhnLabPathRestricted:decode])
		return [@"/AhnLab.bypass" dataUsingEncoding:NSUTF8StringEncoding];
	return %orig;
}
%end

%hook amsLibrary
- (id)decrypt: (id)arg1 key: (id)arg2 padding: (int)arg3 {
	NSData *orig = %orig;
	NSString* decode = [[NSString alloc] initWithData:orig encoding:NSUTF8StringEncoding];
	if([[FJPattern sharedInstance] isPathRestricted:decode] || [[FJPattern sharedInstance] isAhnLabPathRestricted:decode])
		return [@"/AhnLab.bypass" dataUsingEncoding:NSUTF8StringEncoding];
	return %orig;
}
%end

%hook ams2Library
- (id)decrypt: (id)arg1 key: (id)arg2 padding: (int)arg3 {
	NSData *orig = %orig;
	NSString* decode = [[NSString alloc] initWithData:orig encoding:NSUTF8StringEncoding];
	if([[FJPattern sharedInstance] isPathRestricted:decode] || [[FJPattern sharedInstance] isAhnLabPathRestricted:decode])
		return [@"/AhnLab.bypass" dataUsingEncoding:NSUTF8StringEncoding];
	return %orig;
}
%end

%hook AMSLBouncer
- (id)decrypt: (id)arg1 key: (id)arg2 padding: (int)arg3 {
	NSData *orig = %orig;
	NSString* decode = [[NSString alloc] initWithData:orig encoding:NSUTF8StringEncoding];
	if([[FJPattern sharedInstance] isPathRestricted:decode] || [[FJPattern sharedInstance] isAhnLabPathRestricted:decode])
		return [@"/AhnLab.bypass" dataUsingEncoding:NSUTF8StringEncoding];
	return %orig;
}
%end

//xigncode - 좀비고
int (*orig_xigncode)();
int hook_xigncode() {
	return 0;
}

%end

void loadLibraryHooks() {
	%init(LibraryHooks,
	      SSGPAY_DetectionController = NSClassFromString(@"SSGPAY.DetectionController"),
	      samsungCardMyHome = NSClassFromString(@" "),
				gs25_Utils = NSClassFromString(@"gs25.Utils"),
				gsthefresh_Utils = NSClassFromString(@"gsthefresh.Utils"),
				thepop_Utils = NSClassFromString(@"thepop.Utils"));
}

void loadXignCodeHooks() {
	MSHookFunction(MSFindSymbol(NULL, "__ZN16JailBreakChecker2DoEP12ISDispatcher"), (void*)hook_xigncode, (void**)&orig_xigncode);
}
