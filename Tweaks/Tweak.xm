#import <substrate.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "../Headers/FJPattern.h"
#import "../Headers/LibraryHooks.h"
#import "../Headers/ObjCHooks.h"
#import "../Headers/OptimizeDisableInjector.h"
#import "../Headers/SysHooks.h"
#import "../Headers/NoSafeMode.h"
#import "../Headers/MemHooks.h"
#import "../Headers/CheckHooks.h"
#import "../Headers/PatchFinder.h"
#import "../ImportHooker/ImportHooker.h"
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <spawn.h>
#include <dlfcn.h>

@interface SBHomeScreenViewController : UIViewController
@end

@interface NSDistributedNotificationCenter : NSNotificationCenter
@end


%group NoFile
%hook SpringBoard
-(void)applicationDidFinishLaunching: (id)arg1 {
	%orig;
	UIAlertController *alertController = [UIAlertController
	                                      alertControllerWithTitle:@"FlyJB X"
	                                      message:@"Couldn't find FJMemory. Please reinstall FlyJB X."
	                                      preferredStyle:UIAlertControllerStyleAlert
	                                     ];

	[alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
	                                    [((UIApplication*)self).keyWindow.rootViewController dismissViewControllerAnimated:YES completion:NULL];
				    }]];

	[((UIApplication*)self).keyWindow.rootViewController presentViewController:alertController animated:YES completion:NULL];
}
%end
%end

%group TossAppProtection
%hook SBHomeScreenViewController
-(void)loadView {
	%orig;
	[[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"kr.xsf1re.flyjbcenter" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
		// [self performSelector:selector];
		if([[notification.userInfo objectForKey:@"terminateReason"] isEqualToString:@"bypassFailedToss"]) {
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"FlyJB X" message:@"토스 계정이 정지될 위험한 상황으로부터 보호되었습니다.\n\n토스 탈옥감지를 우회하는데 실패한 것으로 판단되어 앱을 강제 종료하였습니다." preferredStyle: UIAlertControllerStyleAlert];
		[alert addAction:[UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		                          [alert dismissViewControllerAnimated:YES completion:nil];
				  }]];
		[self presentViewController:alert animated:true completion:nil];
	}
}];
}
%end
%end

%ctor{

	NSLog(@"[FlyJB] Loaded!!!");

	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/kr.xsf1re.flyjb.plist"];
	NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
	BOOL isSubstitute = ([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/lib/libsubstitute.dylib"] && ![[NSFileManager defaultManager] fileExistsAtPath:@"/usr/lib/substrate"] && ![[NSFileManager defaultManager] fileExistsAtPath:@"/usr/lib/libhooker.dylib"]);
	BOOL isLibHooker = [[NSFileManager defaultManager] fileExistsAtPath:@"/usr/lib/libhooker.dylib"];
	BOOL DobbyHook = [prefs[@"enableDobby"] boolValue];

	if([bundleID isEqualToString:@"com.vivarepublica.cash"]) {
		loadNoSafeMode();
	}

	if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/Preferences/FJMemory"]) {
		%init(NoFile);
		return;
	}

	%init(TossAppProtection);
	loadOptimizeDisableInjector();

	if(![bundleID hasPrefix:@"com.apple"] && prefs && [prefs[@"enabled"] boolValue]) {
		if(([prefs[bundleID] boolValue])
		   || ([bundleID hasPrefix:@"com.ibk.ios.ionebank"] && [prefs[@"com.ibk.ios.ionebank"] boolValue])
		   || ([bundleID hasPrefix:@"com.lguplus.mobile.cs"] && [prefs[@"com.lguplus.mobile.cs"] boolValue]))
		{
			openDobby();

			if([bundleID isEqualToString:@"com.kbstar.kbbank"])
				loadNoSafeMode();

			loadFJMemoryHooks();

//Arxan 메모리 패치
			if([bundleID isEqualToString:@"com.hana.hanamembers"] || [bundleID isEqualToString:@"com.lottecard.mobilepay"])
				loadFJMemoryIntegrityRecover();

//Arxan 심볼 패치
			if([bundleID isEqualToString:@"com.kakaobank.channel"]) {
				NSLog(@"[FlyJB] kakaoBankPatch: %d", kakaoBankPatch());
			}
//AhnLab Mobile Security - NH올원페이, 하나카드, NH스마트뱅킹, NH농협카드, 하나카드 원큐페이(앱카드), NH스마트알림, NH올원뱅크, NH콕뱅크...
			Class AhnLabExist = objc_getClass("AMSLContaminationInspector");
			if(AhnLabExist)
				loadAhnLabMemHooks();

//락인컴퍼니 솔루션 LiApp - 차이, 랜덤다이스, 아시아나항공, 코인원, blind...
			Class LiappExist = objc_getClass("Liapp");
			if(LiappExist)
				loadSysHooksForLiApp();

//스틸리언...
			Class stealienExist = objc_getClass("Diresu");
			Class stealienExist2 = objc_getClass("Kartzela");

			if(stealienExist && stealienExist2) {
				loadSysHooks4();
			}

//배달요기요앱은 한번 탈옥감지하면 설정파일에 colorChecker key에 TRUE 값이 기록됨.
			if([bundleID isEqualToString:@"com.yogiyo.yogiyoapp"])
				loadYogiyoObjcHooks();

//AppSolid - 코레일톡, NICE지키미, 나이스아이핀
			NSArray *AppSolidApps = [NSArray arrayWithObjects:
																@"com.korail.KorailTalk",
																@"com.nice.MyCreditManager",
																@"com.niceid.niceipin",
																nil
																];
			for(NSString* app in AppSolidApps) {
				if([bundleID isEqualToString:app]) {
					loadAppSolidMemHooks();
					break;
				}
			}

//광주은행
			if([bundleID isEqualToString:@"com.kjbank.smart.public.pbanking"])
				loadKJBankMemHooks();

//따로 제작? 불명 - AppDefense? - 우체국예금 스마트 뱅킹, 바이오인증공동앱, 모바일증권 나무, 디지털OTP(스마트보안카드)
			NSArray *UnkApps = [NSArray arrayWithObjects:
																@"com.epost.psf.sd",
																@"org.kftc.fido.lnk.lnkApp",
																@"com.wooriwm.txsmart",
																@"kr.or.kftc.fsc.dist",
																nil
																];

			for(NSString* app in UnkApps) {
				if([bundleID isEqualToString:app]) {
					if(DobbyHook) {
						loadSVC80MemHooks();
					}
					else {
						//Disabled DobbyHook...
						loadSVC80MemPatch();
					}
					break;
				}
			}

//NSHCApps: 엘포인트, 엘페이, 알밤 매니저
			NSArray *NSHCApps = [NSArray arrayWithObjects:
																@"com.lottecard.LotteMembers",
																@"kr.co.nmcs.lpay",
																@"com.albamapp.OwnerR2",
																nil
																];
			Class NSHCExist = objc_getClass("__ns_d");

//NSHC 블랙리스트: 빗썸, NSHC와 스틸리언 솔루션 둘다 적용된 앱
			for(NSString* app in NSHCApps) {
				if([bundleID isEqualToString:app] || (NSHCExist && ![bundleID isEqualToString:@"com.btckorea.bithumb"] && !(stealienExist && stealienExist2 && NSHCExist))) {
					loadSVC80MemPatch();
					break;
				}
			}

//SVC탐지 + 스틸리언: 티머니 관련 4종, 유안타증권, 키위뱅크(KB저축은행)
			NSArray *SVCWithStealienApps = [NSArray arrayWithObjects:
																@"com.tmoney.tmpay",
																@"com.kscc.t-gift",
																@"kr.co.ondataxi.passenger",
																@"kr.co.tmoney.tia",
																@"com.yuanta.tradarm",
																@"com.kbsavings.app.KBsavingsMobile",
																nil
																];

			for(NSString* app in SVCWithStealienApps) {
				if([bundleID isEqualToString:app]) {
					if(isSubstitute || isLibHooker)
						loadSVC80MemHooks();
					else {
						loadSVC80AccessMemHooks();
						loadSVC80OpenMemHooks();
					}
					break;
				}
			}

//NSHC - 미니스탁
			if([bundleID isEqualToString:@"com.truefriend.ministock"])
				loadMiniStockMemHooks();

//NSHC lxShield - 가디언테일즈
			if([bundleID isEqualToString:@"com.kakaogames.gdtskr"])
				loadlxShieldMemHooks();

//NSHC lxShield v2 - SKT PASS, 현대카드, 달빛조각사
			if([bundleID isEqualToString:@"com.sktelecom.tauth"] || [bundleID isEqualToString:@"com.hyundaicard.hcappcard"] || [bundleID isEqualToString:@"com.kakaogames.moonlight"])
				loadlxShieldMemHooks2();

//NSHC lxShield v3 - LPay
			if([bundleID isEqualToString:@"com.lotte.mybee.lpay"])
				loadlxShieldMemHooks3();

//RaonSecure TouchEn mVaccine - 비플제로페이, 하나은행(+Arxan?), 하나알리미(+Arxan?, 메모리 패치 있음), 미래에셋생명 모바일창구
			NSArray *mVaccineApps = [NSArray arrayWithObjects:
																@"com.bizplay.zeropay",
																@"com.hanabank.smart.HanaNBank",
																@"com.kebhana.hanapush",
																@"com.miraeasset.mobilewindow",
																nil
																];

			for(NSString* app in mVaccineApps) {
				if([bundleID isEqualToString:app]) {
						//Disabled DobbyHook...
						loadSVC80MemPatch();
					}
					break;
				}

//Arxan - 스마일페이, 페이코
			NSArray *ArxanApps = [NSArray arrayWithObjects:
																@"com.mysmilepay.app",
																@"com.nhnent.TOASTPAY",
																nil
																];

			for(NSString* app in ArxanApps) {
				if([bundleID isEqualToString:app]) {
					if(DobbyHook) {
						if(isSubstitute || isLibHooker)
							loadSVC80MemHooks();
						else
							loadSVC80AccessMemHooks();
					}
					else {
						//Disabled DobbyHook...
						NSLog(@"[FlyJB] Disabled DobbyHook for Arxan Apps... You must manually patch with FJMemory!!!");
					}
					break;
				}
			}

//XignCode - 좀비고
		if([bundleID isEqualToString:@"net.kernys.aooni"])
			loadXignCodeHooks();

//nProtect AppGuard - 뱅뱅뱅 상상인디지털뱅크, 애큐온저축은행 모바일뱅킹
		Class nProtectExist = objc_getClass("AGFramework");
		if(nProtectExist)
			loadnProtectMemHooks();

//하나카드, NEW하나은행, THE POP, 나만의 냉장고(GS25), GS수퍼마켓, BC카드, 페이코, 삼성카드(마이홈) 등 Arxan, 신한카드, 롯데카드 일부 앱은 우회가 좀 까다로운 듯? 하면 안되는 시스템 후킹이 있음
		 NSMutableArray *blacklistApps = [NSMutableArray arrayWithObjects:
															 @"com.hanaskcard.mobileportal",
															 @"com.kebhana.hanapush",
															 @"com.gsretail.ios.thepop",
															 @"com.gsretail.gscvs",
															 @"com.gsretail.supermarket",
															 @"com.bccard.iphoneapp",
															 @"com.nhnent.TOASTPAY",
															 @"com.samsungCard.samsungCard",
															 @"com.shinhancard.SmartShinhan2",
															 @"com.lottecard.appcard",
															 nil
															 ];

		 [blacklistApps addObjectsFromArray: ArxanApps];

		 BOOL enableSysHook = true;
		 for(NSString* app in blacklistApps) {
			 if([bundleID isEqualToString:app]) {
				 enableSysHook = false;
				 break;
			 }
		 }


			if(enableSysHook) {
				loadSysHooks2();
				loadSysHooks3();
			}

			loadDlsymSysHooks();
			loadOpendirSysHooks();

			loadObjCHooks();
			loadSysHooks();
			loadLibraryHooks();
		}
	}

	//토스 탈옥감지 확인
	if([bundleID isEqualToString:@"com.vivarepublica.cash"])
		loadCheckHooks();
}
