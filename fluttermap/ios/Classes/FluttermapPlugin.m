#import "FluttermapPlugin.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface FluttermapPlugin()<CLLocationManagerDelegate>{
    CLLocationManager *locationMan;
    FlutterResult resultBak;
}
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLGeocoder *geoC;

@end


@implementation FluttermapPlugin

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.geoC = [[CLGeocoder alloc] init];
    }
    return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"hdkj/fluttermap"
            binaryMessenger:[registrar messenger]];
  FluttermapPlugin* instance = [[FluttermapPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getLocation" isEqualToString:call.method]) {
      if(self.currentLocation){
          [self sendCurrentLocation:self.currentLocation result:result];
          return;
      }
      if (!locationMan) {
          locationMan = [[CLLocationManager alloc]init];
          locationMan.delegate = self;
          //iOS 9（不包含iOS 9） 之前设置允许后台定位参数，保持不会被系统挂起
          [locationMan setPausesLocationUpdatesAutomatically:NO];
          //iOS 9（包含iOS 9）之后新特性：将允许出现这种场景，同一app中多个locationmanager：一些只能在前台定位，另一些可在后台定位，并可随时禁止其后台定位。
          //        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
          //            locationMan.allowsBackgroundLocationUpdates = YES;
          //        }
          [locationMan requestWhenInUseAuthorization];            //使用时获取定位的权限
          
      }
      [locationMan setDistanceFilter:30];

      //开始进行连续定位
      [locationMan startUpdatingLocation];
      [locationMan startUpdatingHeading];
      resultBak = result;
  } else if([@"openMap" isEqualToString:call.method]){
      double lat = [call.arguments[@"Lat"] doubleValue];
      double lng = [call.arguments[@"Lng"] doubleValue];
      NSString *address = call.arguments[@"Addr"];
      
      if([address length] > 0){
          MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat, lng) addressDictionary:nil]]; //目的地坐标
          toLocation.name = address; //目的地名字
          [toLocation openInMapsWithLaunchOptions:nil];
      } else {
          MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
          [currentLocation openInMapsWithLaunchOptions:nil];
      }
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)sendCurrentLocation:(CLLocation *)location result:(FlutterResult) result
{
    FlutterResult result2 = !result ? resultBak : result;

    [self.geoC reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if(!error)
        {
            CLPlacemark *pl = [placemarks firstObject];
            NSArray *lines = pl.addressDictionary[@"FormattedAddressLines"];
            
            NSString *addressString = [lines componentsJoinedByString:@"\n"];
            NSLog(@"%f----%f", pl.location.coordinate.latitude, pl.location.coordinate.longitude);
            
            if(result2){
                result2(@{
                         @"lat":@(pl.location.coordinate.latitude),
                         @"lng": @(pl.location.coordinate.longitude),
                         @"address":addressString
                         });
            }
        }
    }];
    
    resultBak = nil;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if(resultBak){
        resultBak(@{
                    @"error": @"定位失败"
                    });
    }
}
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if(status == kCLAuthorizationStatusRestricted||status == kCLAuthorizationStatusDenied)
    {
    }
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = [locations lastObject];
    if(location.coordinate.latitude != 0.0){
        self.currentLocation = [locations lastObject];
        [self sendCurrentLocation:location result:nil];
    }

}


- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    // 1.判断当前的角度是否有效(如果此值小于0,代表角度无效)
    if(newHeading.headingAccuracy < 0)
        return;
    // 2.获取当前设备朝向(磁北方向)
}

@end
