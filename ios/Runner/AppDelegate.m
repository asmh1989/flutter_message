#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import <Bugly/Bugly.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];
    [Bugly startWithAppId:@"c68b6c9b3d"];
    
    // Override point for customization after application launch.
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
