#include "FJOptimizeListController.h"
#import <AppList/AppList.h>
#define PREFERENCE_Optimize @"/var/mobile/Library/Preferences/kr.xsf1re.flyjb_optimize.plist"
NSMutableDictionary *prefs_Optimize;

static const NSBundle *tweakBundle;
#define LOCALIZED(str) [tweakBundle localizedStringForKey:str value:@"" table:nil]

static NSInteger DictionaryTextComparator(id a, id b, void *context) {
	return [[(__bridge NSDictionary *)context objectForKey:a] localizedCaseInsensitiveCompare:[(__bridge NSDictionary *)context objectForKey:b]];
}

@implementation FJOptimizeListController
- (NSArray *)specifiers {
	if (!_specifiers) {
		tweakBundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/FlyJBXPrefs.bundle"];
		[self getPreference];
		NSMutableArray *specifiers = [[NSMutableArray alloc] init];
		[specifiers addObject:[PSSpecifier preferenceSpecifierNamed:LOCALIZED(@"FlyJB_THIRDPARTYAPPS") target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil]];
		ALApplicationList *applicationList = [ALApplicationList sharedApplicationList];
		NSDictionary *applications = [applicationList applicationsFilteredUsingPredicate:[NSPredicate predicateWithFormat:@"isSystemApplication = FALSE"]];
		NSMutableArray *displayIdentifiers = [[applications allKeys] mutableCopy];
		[displayIdentifiers sortUsingFunction:DictionaryTextComparator context:(__bridge void *)applications];
		NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/kr.xsf1re.flyjb.plist"];
		for (NSString *displayIdentifier in displayIdentifiers)
		{
			if([prefs [displayIdentifier] boolValue]) {
				PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:applications[displayIdentifier] target:self set:@selector(setSwitch:forSpecifier:) get:@selector(getSwitch:) detail:nil cell:PSSwitchCell edit:nil];
				[specifier.properties setValue:displayIdentifier forKey:@"displayIdentifier"];
				UIImage *icon = [applicationList iconOfSize:ALApplicationIconSizeSmall forDisplayIdentifier:displayIdentifier];
				if (icon) [specifier setProperty:icon forKey:@"iconImage"];
				[specifiers addObject:specifier];
			}
		}

		_specifiers = [specifiers copy];
	}

	return _specifiers;
}

-(void)setSwitch:(NSNumber *)value forSpecifier:(PSSpecifier *)specifier {
	prefs_Optimize[[specifier propertyForKey:@"displayIdentifier"]] = [NSNumber numberWithBool:[value boolValue]];
	[[prefs_Optimize copy] writeToFile:PREFERENCE_Optimize atomically:FALSE];
}

-(NSNumber *)getSwitch:(PSSpecifier *)specifier {
	return [prefs_Optimize[[specifier propertyForKey:@"displayIdentifier"]] isEqual:@1] ? @1 : @0;
}
-(void)getPreference {
	if(![[NSFileManager defaultManager] fileExistsAtPath:PREFERENCE_Optimize]) prefs_Optimize = [[NSMutableDictionary alloc] init];
	else prefs_Optimize = [[NSMutableDictionary alloc] initWithContentsOfFile:PREFERENCE_Optimize];
}
@end
