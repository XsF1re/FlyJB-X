#import <spawn.h>
#include "FJRootListController.h"
#include "FJAppListController.h"
#include "FJCr4shF1xListController.h"
#include "FJDisablerListController.h"

#define RESET_PREFS 100
#define INSTALL_TWITTER 101
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define PREFERENCE_FlyJB @"/var/mobile/Library/Preferences/kr.xsf1re.flyjb.plist"
#define PREFERENCE_Cr4shF1x @"/var/mobile/Library/Preferences/kr.xsf1re.flyjb_crashfix.plist"
#define PREFERENCE_Disabler @"/var/mobile/Library/Preferences/kr.xsf1re.flyjb_disabler.plist"

NSMutableDictionary *prefs_FlyJB;
NSMutableDictionary *prefs_Cr4shF1x;
NSMutableDictionary *prefs_Disabler;
static NSString *vers = @"1.0.7";

static const NSBundle *tweakBundle;
#define LOCALIZED(str) [tweakBundle localizedStringForKey:str value:@"" table:nil]

@implementation FJRootListController
- (instancetype)init {

	self = [super init];

	if (self) {
		tweakBundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/FlyJBXPrefs.bundle"];

		self.title = LOCALIZED(@"FlyJB_TITLE");
	}

	return self;

}



- (void)viewDidLoad {
	if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
		[super viewDidLoad];
		return;
	}


	[super viewDidLoad];


	self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,200,150)];
	self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,200,150)];
	self.headerImageView.contentMode = UIViewContentModeScaleAspectFill;
	self.headerImageView.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/FlyJBXPrefs.bundle/Banner.png"];
	self.headerImageView.translatesAutoresizingMaskIntoConstraints = NO;

	[self.headerView addSubview:self.headerImageView];
	[NSLayoutConstraint activateConstraints:@[
		 [self.headerImageView.topAnchor constraintEqualToAnchor:self.headerView.topAnchor],
		 [self.headerImageView.leadingAnchor constraintEqualToAnchor:self.headerView.leadingAnchor],
		 [self.headerImageView.trailingAnchor constraintEqualToAnchor:self.headerView.trailingAnchor],
		 [self.headerImageView.bottomAnchor constraintEqualToAnchor:self.headerView.bottomAnchor],
	]];

	_table.tableHeaderView = self.headerView;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	tableView.tableHeaderView = self.headerView;
	return [super tableView:tableView cellForRowAtIndexPath:indexPath];

}

- (NSArray *)specifiers {
	if (!_specifiers) {
		[self getPreference];
		NSMutableArray *specifiers = [[NSMutableArray alloc] init];

		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_ACTIVATION") target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
			[specifier.properties setValue:@"0" forKey:@"footerAlignment"];
			[specifier.properties setValue:@"DobbyHook을 사용하지 않으면 일부 앱에서 우회 기능이 작동되지 않을 수 있으나 보통 메모리 패치로 해결될 수 있습니다.\n\n강제 로드 기능은 우회 리스트가 적용된 앱을 실행 시 환경 변수를 수정하여 모든 트윅 로드를 차단하고, FlyJB X 트윅만 로드되도록 만듭니다. 이 옵션을 적용하려면 리스프링이 필요합니다." forKey:@"footerText"];
			specifier;
		})];

		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_ENABLE") target:self set:@selector(setSwitch:forSpecifier:) get:@selector(getSwitch:) detail:nil cell:PSSwitchCell edit:nil];
			[specifier.properties setValue:@"enabled" forKey:@"displayIdentifier"];
			specifier;
		})];

		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_ENABLE_DOBBY") target:self set:@selector(setSwitch:forSpecifier:) get:@selector(getSwitch:) detail:nil cell:PSSwitchCell edit:nil];
			[specifier.properties setValue:@"enableDobby" forKey:@"displayIdentifier"];
			specifier;
		})];

		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"강제 로드" target:self set:@selector(setSwitch:forSpecifier:) get:@selector(getSwitch:) detail:nil cell:PSSwitchCell edit:nil];
			[specifier.properties setValue:@"forcenabled" forKey:@"displayIdentifier"];
			specifier;
		})];

		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"리스프링" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			specifier->action = @selector(respring:);
			specifier;
		})];

		if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
			[specifiers addObject:({
				PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"업데이트" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
				if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0") && [[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/Preferences/FJMemory"]) {
				        NSString *FJDataPath = @"/var/mobile/Library/Preferences/FJMemory";
				        NSData *FJMemory = [NSData dataWithContentsOfFile:FJDataPath options:0 error:nil];
				        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:FJMemory options:0 error:nil];
				        NSString *version = [dict objectForKeyedSubscript:@"version"];
				        [specifier.properties setValue:@"0" forKey:@"footerAlignment"];
				        [specifier.properties setValue:[NSString stringWithFormat:LOCALIZED(@"FlyJB_UPDATE_LASTDATE"), version] forKey:@"footerText"];
				}
				specifier;
			})];
		}

		if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0") && [[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/Preferences/FJMemory"]) {
			[specifiers addObject:({
				PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_UPDATE_MEMORY") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
				specifier->action = @selector(UpdatePatchData);
				specifier;
			})];
		}

		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_APPSETTINGS") target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
			[specifier.properties setValue:@"0" forKey:@"footerAlignment"];
			[specifier.properties setValue:LOCALIZED(@"FlyJB_BYPASS_DESC") forKey:@"footerText"];
			specifier;
		})];
		[specifiers addObject:[PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_BYPASSLIST") target:nil set:nil get:nil detail:[FJAppListController class] cell:PSLinkListCell edit:nil]];

		[specifiers addObject:({
			PSSpecifier *specifier = [[PSSpecifier alloc] init];
			[specifier.properties setValue:@"0" forKey:@"footerAlignment"];
			[specifier.properties setValue:LOCALIZED(@"FlyJB_OPTIMIZE_DESC") forKey:@"footerText"];
			specifier;
		})];
		// [specifiers addObject:({
		// 		PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"FlyJB X 인젝트하기" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
		// 		[specifier setIdentifier:@"ShowSourceCode"];
		// 		specifier->action = @selector(injectFlyJBX);
		// 		specifier;
		// })];
		[specifiers addObject:[PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_OPTIMIZELIST") target:nil set:nil get:nil detail:[FJCr4shF1xListController class] cell:PSLinkListCell edit:nil]];
		if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
			[specifiers addObject:({
				PSSpecifier *specifier = [[PSSpecifier alloc] init];
				[specifier.properties setValue:@"0" forKey:@"footerAlignment"];
				[specifier.properties setValue:LOCALIZED(@"FlyJB_DISABLER_DESC") forKey:@"footerText"];
				specifier;
			})];
			[specifiers addObject:[PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_DISABLERLIST") target:nil set:nil get:nil detail:[FJDisablerListController class] cell:PSLinkListCell edit:nil]];
		}
#if defined __arm64__ || defined __arm64e__
		if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0") && [[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/Preferences/FJMemory"]) {
			[specifiers addObject:({
				PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_UPDATEINFO") target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
				[specifier.properties setValue:@"0" forKey:@"footerAlignment"];
				[specifier.properties setValue:LOCALIZED(@"FlyJB_PATCHDATA_DESC") forKey:@"footerText"];
				specifier;
			})];

			[specifiers addObject:({
				PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_SHOWPATCHDATA") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
				[specifier setIdentifier:@"ShowPatchData"];
				specifier->action = @selector(openWebsite:);
				specifier;
			})];

            [specifiers addObject:({
                PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_SHOWSOURCECODE") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
                [specifier setIdentifier:@"ShowSourceCode"];
                specifier->action = @selector(openWebsite:);
                specifier;
            })];
		}
#endif





		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_ETCOPTIONS") target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
			specifier;
		})];

		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_RESETPREFS") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			specifier->action = @selector(resetPrefs:);
			[specifier setProperty:[NSNumber numberWithBool:TRUE] forKey:@"hasIcon"];
			[specifier setProperty:[UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"Init" ofType:@"png"]] forKey:@"iconImage"];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_SENDFEEDBACK") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			specifier->action = @selector(sendFeedback);
			[specifier setProperty:[NSNumber numberWithBool:TRUE] forKey:@"hasIcon"];
			[specifier setProperty:[UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"Mail" ofType:@"png"]] forKey:@"iconImage"];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_LIKE") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			specifier->action = @selector(Like);
			[specifier setProperty:[NSNumber numberWithBool:TRUE] forKey:@"hasIcon"];
			[specifier setProperty:[UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"Heart" ofType:@"png"]] forKey:@"iconImage"];
			specifier;
		})];

		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_CREDIT") target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
			specifier;
		})];

		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_DEVELOPER") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			[specifier setIdentifier:@"XsF1re"];
			specifier->action = @selector(openWebsite:);
			[specifier setProperty:[NSNumber numberWithBool:TRUE] forKey:@"hasIcon"];
			[specifier setProperty:[UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"Twitter" ofType:@"png"]] forKey:@"iconImage"];
			specifier;
		})];

		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"DobbyHook_DEVELOPER") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			[specifier setIdentifier:@"jmpews"];
			specifier->action = @selector(openWebsite:);
			[specifier setProperty:[NSNumber numberWithBool:TRUE] forKey:@"hasIcon"];
			[specifier setProperty:[UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"Twitter" ofType:@"png"]] forKey:@"iconImage"];
			specifier;
		})];

		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_DESIGNER") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_TRANSLATOR_AR") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			[specifier setIdentifier:@"Sultan"];
			specifier->action = @selector(openWebsite:);
			[specifier setProperty:[NSNumber numberWithBool:TRUE] forKey:@"hasIcon"];
			[specifier setProperty:[UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"Twitter" ofType:@"png"]] forKey:@"iconImage"];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_TRANSLATOR_CN") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			[specifier setIdentifier:@"yunzhimin"];
			specifier->action = @selector(openWebsite:);
			[specifier setProperty:[NSNumber numberWithBool:TRUE] forKey:@"hasIcon"];
			[specifier setProperty:[UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"Twitter" ofType:@"png"]] forKey:@"iconImage"];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_TRANSLATOR_HE") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			[specifier setIdentifier:@"guezomri"];
			specifier->action = @selector(openWebsite:);
			[specifier setProperty:[NSNumber numberWithBool:TRUE] forKey:@"hasIcon"];
			[specifier setProperty:[UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"Twitter" ofType:@"png"]] forKey:@"iconImage"];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_TRANSLATOR_DE") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			[specifier setIdentifier:@"t0mi"];
			specifier->action = @selector(openWebsite:);
			[specifier setProperty:[NSNumber numberWithBool:TRUE] forKey:@"hasIcon"];
			[specifier setProperty:[UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"Twitter" ofType:@"png"]] forKey:@"iconImage"];
			specifier;
		})];


		[specifiers addObject:({
			NSString *year = @"2021";
			PSSpecifier *specifier = [[PSSpecifier alloc] init];
			[specifier.properties setValue:@"2" forKey:@"footerAlignment"];
			[specifier.properties setValue:[NSString stringWithFormat:LOCALIZED(@"FlyJB_LASTMSG"), vers, year] forKey:@"footerText"];
			specifier;
		})];

		_specifiers = [specifiers copy];
	}
	return _specifiers;
}

-(void)UpdatePatchData {
	UIAlertController *alert = [UIAlertController
	                            alertControllerWithTitle:LOCALIZED(@"FlyJB_UPDATE_CHECK")
	                            message:LOCALIZED(@"FlyJB_GET_SERVER")
	                            preferredStyle:UIAlertControllerStyleAlert];
	UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[activity startAnimating];
	[activity setFrame:CGRectMake(0, 0, 70, 60)];
	[alert.view addSubview:activity];
	[self presentViewController:alert animated:YES completion:nil];

	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://xsf1re.dothome.co.kr/flyjb/last_roleset.php"]];
	NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
	                                      NSString *returnData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	                                      NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
	                                      [alert dismissViewControllerAnimated:YES completion:^{
	                                               if (error || statusCode != 200) {
	                                                       UIAlertController *alert = [UIAlertController alertControllerWithTitle:LOCALIZED(@"FlyJB_UPDATE_FAILED")
	                                                                                   message:LOCALIZED(@"FlyJB_UPDATE_FAILED_DATA")
	                                                                                   preferredStyle:UIAlertControllerStyleAlert];
	                                                       UIAlertAction *ok = [UIAlertAction actionWithTitle:LOCALIZED(@"FlyJB_OK")
	                                                                            style:UIAlertActionStyleDefault
	                                                                            handler:^(UIAlertAction *action){
	                                                                                    [alert dismissViewControllerAnimated:YES completion:nil];
										    }];

	                                                       [alert addAction: ok];
	                                                       [self presentViewController:alert animated:YES completion:nil];
						       }

	                                               if (error == nil && statusCode == 200) {
	                                                       NSString *FJDataPath = @"/var/mobile/Library/Preferences/FJMemory";
	                                                       NSData *FJMemory = [NSData dataWithContentsOfFile:FJDataPath options:0 error:nil];
	                                                       NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:FJMemory options:0 error:nil];
	                                                       NSString *version = [dict objectForKeyedSubscript:@"version"];

	                                                       NSData *returnData_nsd = [returnData dataUsingEncoding:NSUTF8StringEncoding];
	                                                       NSDictionary* dict_web = [NSJSONSerialization JSONObjectWithData:returnData_nsd options:0 error:nil];
	                                                       NSString *version_web = [dict_web objectForKey:@"version"];
	                                                       NSString *supportedVersion_web = [dict_web objectForKey:@"supportedVersion"];

	                                                       NSString *supportedVersion = @"20201223";
	                                                       if(![supportedVersion_web isEqualToString:supportedVersion])  {
	                                                               UIAlertController *alert = [UIAlertController alertControllerWithTitle:LOCALIZED(@"FlyJB_UPDATE_FAILED")
	                                                                                           message:@"현재 버전은 메모리 패치 업데이트 기능을 지원하지 않습니다.\n공중제비 트윅을 최신 버전으로 업데이트해주세요."
	                                                                                           preferredStyle:UIAlertControllerStyleAlert];
	                                                               UIAlertAction *ok = [UIAlertAction actionWithTitle:LOCALIZED(@"FlyJB_OK")
	                                                                                    style:UIAlertActionStyleDefault
	                                                                                    handler:^(UIAlertAction *action){
	                                                                                            [alert dismissViewControllerAnimated:YES completion:nil];
											    }];

	                                                               [alert addAction: ok];
	                                                               [self presentViewController:alert animated:YES completion:nil];
							       }
	                                                       else if([version_web isEqualToString:version]) {
	                                                               UIAlertController *alert = [UIAlertController alertControllerWithTitle:LOCALIZED(@"FlyJB_UPDATE")
	                                                                                           message:LOCALIZED(@"FlyJB_UPDATE_UPTODATE")
	                                                                                           preferredStyle:UIAlertControllerStyleAlert];
	                                                               UIAlertAction *ok = [UIAlertAction actionWithTitle:LOCALIZED(@"FlyJB_OK")
	                                                                                    style:UIAlertActionStyleDefault
	                                                                                    handler:^(UIAlertAction *action){
	                                                                                            [alert dismissViewControllerAnimated:YES completion:nil];
											    }];

	                                                               [alert addAction: ok];
	                                                               [self presentViewController:alert animated:YES completion:nil];
							       }

	                                                       else if(![returnData isEqualToString:version]) {
	                                                               NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://xsf1re.dothome.co.kr/flyjb/%@.php", version_web]]];
	                                                               NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
	                                                                                                     NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
	                                                                                                     if (error || statusCode != 200) {
	                                                                                                             UIAlertController *alert = [UIAlertController alertControllerWithTitle:LOCALIZED(@"FlyJB_UPDATE_FAILED")
	                                                                                                                                         message:LOCALIZED(@"FlyJB_UPDATE_FAILED_DATA")
	                                                                                                                                         preferredStyle:UIAlertControllerStyleAlert];
	                                                                                                             UIAlertAction *ok = [UIAlertAction actionWithTitle:LOCALIZED(@"FlyJB_OK")
	                                                                                                                                  style:UIAlertActionStyleDefault
	                                                                                                                                  handler:^(UIAlertAction *action){
	                                                                                                                                          [alert dismissViewControllerAnimated:YES completion:nil];
																	  }];

	                                                                                                             [alert addAction: ok];
	                                                                                                             [self presentViewController:alert animated:YES completion:nil];
													     }

	                                                                                                     if (error == nil && statusCode == 200) {
	                                                                                                             [data writeToFile:FJDataPath atomically:YES];
	                                                                                                             UIAlertController *alert = [UIAlertController alertControllerWithTitle:LOCALIZED(@"FlyJB_UPDATE_SUCCESS")
	                                                                                                                                         message:LOCALIZED(@"FlyJB_UPDATE_SUCCESS_DATA")
	                                                                                                                                         preferredStyle:UIAlertControllerStyleAlert];
	                                                                                                             UIAlertAction *ok = [UIAlertAction actionWithTitle:LOCALIZED(@"FlyJB_OK")
	                                                                                                                                  style:UIAlertActionStyleDefault
	                                                                                                                                  handler:^(UIAlertAction *action){
	                                                                                                                                          [alert dismissViewControllerAnimated:YES completion:nil];
																	  }];

	                                                                                                             [alert addAction: ok];
	                                                                                                             [self reloadSpecifiers];
	                                                                                                             [self presentViewController:alert animated:YES completion:nil];
													     }
												     }];
	                                                               [task resume];
							       }

						       }
					       }];



				      }];
	[task resume];
	//[self performSelector:@selector(respring:) withObject:nil afterDelay:3.0];
}

- (void)sendFeedback
{
	MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];

	NSString *deviceType = nil, *iOSVersion = nil, *buildNumber = nil, *udid = nil, *JBSubstitutor = nil;

	BOOL isLibHooker = [[NSFileManager defaultManager] fileExistsAtPath:@"/usr/lib/libhooker.dylib"];
	BOOL isSubstitute = ([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/lib/libsubstitute.dylib"] && ![[NSFileManager defaultManager] fileExistsAtPath:@"/usr/lib/substrate"]);


	deviceType = (NSString *)MGCopyAnswer(kMGProductType, nil);
	iOSVersion = (NSString *)MGCopyAnswer(kMGProductVersion, nil);
	buildNumber = (NSString *)MGCopyAnswer(kMGBuildVersion, nil);
	udid = (NSString*)MGCopyAnswer(kMGUniqueDeviceID, nil);

	if(isLibHooker)
		JBSubstitutor = @"libhooker";
	else if(isSubstitute)
		JBSubstitutor = @"Substitute";
	else
		JBSubstitutor = @"Substrate";

	NSString *subject = LOCALIZED(@"FlyJB_FEEDBACK");
	NSString *subjectVers = [NSString stringWithFormat:@"%@%@%@%@",subject,@" (",vers,@")"];

	[mailer setSubject:subjectVers];
	[mailer setMessageBody:[NSString stringWithFormat:LOCALIZED(@"FlyJB_FEEDBACKDATA"), deviceType, iOSVersion, buildNumber, JBSubstitutor, udid] isHTML:NO];
	[mailer setToRecipients:@[@"shg1725x@yahoo.com"]];
	[self.navigationController presentViewController:mailer animated:YES completion:nil];
	mailer.mailComposeDelegate = self;
	[mailer release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self dismissViewControllerAnimated: YES completion: nil];
}

- (void)Like
{
	if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
		SLComposeViewController *twitter = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
		[twitter setInitialText:LOCALIZED(@"FlyJB_LIKEDATA")];
		if (twitter != nil) {
			[[self navigationController] presentViewController:twitter animated:YES completion:nil];
		}
	}
	else {

		if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:LOCALIZED(@"FlyJB_LIKE") message:LOCALIZED(@"FlyJB_LIKE_INSTALLMSG") delegate:self cancelButtonTitle:LOCALIZED(@"FlyJB_CANCEL") otherButtonTitles:LOCALIZED(@"FlyJB_INSTALL_TWITTER"), nil];
			[alert show];
			alert.tag = INSTALL_TWITTER;
			return;
		}

		UIAlertController *alert = [UIAlertController
		                            alertControllerWithTitle:LOCALIZED(@"FlyJB_LIKE")
		                            message:LOCALIZED(@"FlyJB_LIKE_INSTALLMSG")
		                            preferredStyle:UIAlertControllerStyleAlert];

		UIAlertAction* ok = [UIAlertAction actionWithTitle:LOCALIZED(@"FlyJB_INSTALL_TWITTER") style:UIAlertActionStyleDefault
		                     handler:^(UIAlertAction * action){
		                             NSString *url = @"https://apps.apple.com/kr/app/twitter/id333903271";
		                             UIApplication *app = [UIApplication sharedApplication];
		                             [app openURL:[NSURL URLWithString:url]];
				     }];

		UIAlertAction* cancel = [UIAlertAction actionWithTitle:LOCALIZED(@"FlyJB_CANCEL") style:UIAlertActionStyleDefault
		                         handler:^(UIAlertAction * action) {
		                                 [alert dismissViewControllerAnimated:YES completion:nil];
					 }
		                        ];

		[alert addAction:ok];
		[alert addAction:cancel];

		[self presentViewController:alert animated:YES completion:nil];

	}
}

-(void)setSwitch:(NSNumber *)value forSpecifier:(PSSpecifier *)specifier {
	prefs_FlyJB [[specifier propertyForKey:@"displayIdentifier"]] = [NSNumber numberWithBool:[value boolValue]];
	[[prefs_FlyJB copy] writeToFile:PREFERENCE_FlyJB atomically:FALSE];
}
-(NSNumber *)getSwitch:(PSSpecifier *)specifier {
	return [prefs_FlyJB [[specifier propertyForKey:@"displayIdentifier"]] isEqual:@1] ? @1 : @0;
}

-(void)injectFlyJBX {
	pid_t pid;
	const char* args[] = {"/usr/bin/inject", "/usr/lib/FlyJBX.dylib", NULL};
	posix_spawn(&pid, "inject", NULL, NULL, (char* const*)args, NULL);
	const char* args2[] = {"/usr/bin/inject", "/usr/lib/FJDobby", NULL};
	posix_spawn(&pid, "inject", NULL, NULL, (char* const*)args2, NULL);
	const char* args3[] = {"/usr/bin/inject", "/usr/lib/libsubstrate.dylib", NULL};
	posix_spawn(&pid, "inject", NULL, NULL, (char* const*)args3, NULL);
	const char* args4[] = {"/usr/bin/inject", "/usr/lib/libsubstitute.dylib", NULL};
	posix_spawn(&pid, "inject", NULL, NULL, (char* const*)args4, NULL);
}

-(void)openWebsite:(PSSpecifier *)specifier {
	NSString *value = specifier.identifier;
	NSString *url = nil;
	if([value isEqualToString:@"ShowPatchData"]) {
		url = @"http://xsf1re.dothome.co.kr/flyjb/update.html";
	}
  if([value isEqualToString:@"ShowSourceCode"]) {
    url = @"https://github.com/XsF1re/FlyJB-X";
  }
	if([value isEqualToString:@"XsF1re"]) {
		url = @"https://twitter.com/XsF1re";
	}
	if([value isEqualToString:@"jmpews"]) {
		url = @"https://twitter.com/jmpews";
	}
	if([value isEqualToString:@"Sultan"]) {
		url = @"https://twitter.com/su8782";
	}
	if([value isEqualToString:@"yunzhimin"]) {
		url = @"https://twitter.com/yunzhimin";
	}
	if([value isEqualToString:@"guezomri"]) {
		url = @"https://twitter.com/guezomri";
	}
	if([value isEqualToString:@"t0mi"]) {
		url = @"https://twitter.com/___t0mi___";
	}
	UIApplication *app = [UIApplication sharedApplication];
	[app openURL:[NSURL URLWithString:url]];
}

-(void)resetPrefs:(id)sender {
	if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:LOCALIZED(@"FlyJB_TITLE") message:LOCALIZED(@"FlyJB_CHECKRESET") delegate:self cancelButtonTitle:LOCALIZED(@"FlyJB_CANCEL") otherButtonTitles:LOCALIZED(@"FlyJB_RESET"), nil];
		alert.tag = RESET_PREFS;
		[alert show];
		return;
	}
	UIAlertController *alert = [UIAlertController
	                            alertControllerWithTitle:LOCALIZED(@"FlyJB_TITLE")
	                            message:LOCALIZED(@"FlyJB_CHECKRESET")
	                            preferredStyle:UIAlertControllerStyleAlert];

	UIAlertAction* ok = [UIAlertAction actionWithTitle:LOCALIZED(@"FlyJB_RESET") style:UIAlertActionStyleDefault
	                     handler:^(UIAlertAction * action){

	                             [self resetPreferences];

			     }
	                    ];

	UIAlertAction* cancel = [UIAlertAction actionWithTitle:LOCALIZED(@"FlyJB_CANCEL") style:UIAlertActionStyleDefault
	                         handler:^(UIAlertAction * action) {
	                                 [alert dismissViewControllerAnimated:YES completion:nil];
				 }
	                        ];

	[alert addAction:ok];
	[alert addAction:cancel];

	[self presentViewController:alert animated:YES completion:nil];


}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

	if (alertView.tag == RESET_PREFS && buttonIndex == 1) {
		[self resetPreferences];
	}

	if (alertView.tag == INSTALL_TWITTER && buttonIndex == 1) {
		NSString *url = @"https://apps.apple.com/kr/app/twitter/id333903271";
		UIApplication *app = [UIApplication sharedApplication];
		[app openURL:[NSURL URLWithString:url]];
	}

}

- (void)resetPreferences {
	[[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Library/Preferences/FJMemory" error:NULL];
	[[NSFileManager defaultManager] removeItemAtPath:PREFERENCE_FlyJB error:NULL];
	[[NSFileManager defaultManager] removeItemAtPath:PREFERENCE_Cr4shF1x error:NULL];
	[[NSFileManager defaultManager] removeItemAtPath:PREFERENCE_Disabler error:NULL];

	if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:LOCALIZED(@"FlyJB_RESPRINGSOON") message:LOCALIZED(@"FlyJB_THANKS4TEST") delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
		[alert show];
		[self performSelector:@selector(respring:) withObject:nil afterDelay:3.0];
		return;
	}

	UIAlertController *alert_respring = [UIAlertController
	                                     alertControllerWithTitle:LOCALIZED(@"FlyJB_RESPRINGSOON")
	                                     message:LOCALIZED(@"FlyJB_THANKS4TEST")
	                                     preferredStyle:UIAlertControllerStyleAlert];
	[self presentViewController:alert_respring animated:YES completion:nil];
	[self performSelector:@selector(respring:) withObject:nil afterDelay:3.0];

}

- (void)respring:(id)sender {

	if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
		pid_t pid;
		const char* args[] = {"killall", "SpringBoard", NULL};
		posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
		return;
	}

	pid_t pid;
	const char* args[] = {"killall", "backboardd", NULL};
	posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
}

-(void)getPreference {
	if(![[NSFileManager defaultManager] fileExistsAtPath:PREFERENCE_FlyJB]) prefs_FlyJB = [[NSMutableDictionary alloc] init];
	else prefs_FlyJB = [[NSMutableDictionary alloc] initWithContentsOfFile:PREFERENCE_FlyJB];
}

@end
