//
//  IndoorViewController.m
//  Inside building
//
//  Created by Мария Тимофеева on 30.05.17.
//  Copyright © 2017 Мария Тимофеева. All rights reserved.
//

#import "IndoorViewController.h"
#define FloorPlanId  @"9e1b59f1-8436-463a-8f8c-b1b8c3aef7f9"
#define Location ID  @"b103297f-1be8-4944-8748-ebdfaa9f8a05"
#define kAPIKey @"af69986c-d43a-4024-a24b-affaff93903c"
#define kAPISecret @"eGOBegooo7fYsis8sK0iKGsrrlYqpPGFhtwQuXZxLmvZKE3WAcTrXNxXQanw3US6MY1QQint4ZMRi5yokdEJFrcrt+AQwHxN5jBZXj6zGZUeAuj/TiOvxBpoQ2+qdw=="
@interface MapOverlay : NSObject <MKOverlay>
- (id)initWithFloorPlan:(IAFloorPlan *)floorPlan andRotatedRect:(CGRect)rotated;
- (MKMapRect)boundingMapRect;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property CLLocationCoordinate2D center;
@property MKMapRect rect;

@end

@implementation MapOverlay

- (id)initWithFloorPlan:(IAFloorPlan *)floorPlan andRotatedRect:(CGRect)rotated
{
    self = [super init];
    if (self != nil) {
        
        _center = floorPlan.center;
        MKMapPoint topLeft = MKMapPointForCoordinate(floorPlan.topLeft);
        _rect = MKMapRectMake(topLeft.x + rotated.origin.x, topLeft.y + rotated.origin.y,
                              rotated.size.width, rotated.size.height);
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    return self.center;
}

- (MKMapRect)boundingMapRect {
    return _rect;
}

@end

@interface IndoorViewController ()<MKMapViewDelegate, IALocationManagerDelegate> {
    IALocationManager *locationManager;
    IAResourceManager *resourceManager;
    IAFloorPlan *fp;
    
    UIImage *fpImage;
    MKMapView *map;
    MKMapCamera *camera;
    MKCircle *circle;
    MapOverlay *mapOverlay;
    
}
@property CGRect rotated;
@end

@implementation IndoorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    
    locationManager = [IALocationManager sharedInstance];
    locationManager.delegate = self;
  
    // Set IndoorAtlas API key and secret
    [locationManager setApiKey:kAPIKey andSecret:kAPISecret];
    IALocation *iaLoc = [IALocation locationWithFloorPlanId:FloorPlanId];
    locationManager.location = iaLoc;
    
    map = [MKMapView new];
    [self.view addSubview:map];
    map.frame = self.view.bounds;
    map.delegate = self;
    
    if (circle != nil) {
        [map removeOverlay:circle];
    }
    
    circle = [MKCircle circleWithCenterCoordinate:iaLoc.location.coordinate radius:3];
    [map addOverlay:circle];
    
    if (camera == nil) {
        camera = [MKMapCamera cameraLookingAtCenterCoordinate:iaLoc.location.coordinate fromEyeCoordinate:iaLoc.location.coordinate eyeAltitude:300];
        
        map.camera = camera;
    }
    
    resourceManager = [IAResourceManager resourceManagerWithLocationManager:locationManager];
    [resourceManager fetchFloorPlanWithId:FloorPlanId andCompletion:^(IAFloorPlan *floorPlan, NSError *error) {
        if (error) {
            NSLog(@"opps, there was error: %@", error);
            return;
        }
        NSLog(@"fetched floor plan with id: %@", FloorPlanId);
        
    }];
    
}

- (void)indoorLocationManager:(IALocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    IALocation* loc = [locations lastObject];
    CLLocationCoordinate2D latlng = loc.location.coordinate;
    NSLog(@"Location lat,long: %lf,%lf", latlng.latitude, latlng.longitude);
}

- (void)indoorLocationManager:(IALocationManager*)manager didEnterRegion:(IARegion*)region
{
    (void) manager;
    NSLog(@"Floor plan changed to %@", region.identifier);
//    updateCamera = true
    
    [resourceManager fetchFloorPlanWithId:region.identifier andCompletion:^(IAFloorPlan *floorPlan, NSError *error) {
        if (!error) {
            fp =floorPlan;
            [resourceManager fetchFloorPlanImageWithId:region.identifier andCompletion:^(NSData *imageData, NSError *error){
                __weak typeof(self) weakSelf = self;
                fpImage = [[UIImage alloc] initWithData:imageData];
                [weakSelf changeMapOverlay];
            }];
        } else {
            NSLog(@"Error fetching floorplan");
        }
    }];
}

- (void)changeMapOverlay
{
    if (mapOverlay)
        [map removeOverlay:mapOverlay];
    
    // Create mapOverlay. See example application.
    mapOverlay = [[MapOverlay alloc] initWithFloorPlan:fp andRotatedRect:self.rotated];
    [map addOverlay:mapOverlay];
}

// Delegate method from the MKMapViewDelegate protocol.
-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    MKCircleView *circleView = [[MKCircleView alloc] initWithCircle:(MKCircle *)overlay];
    circleView.fillColor =  [UIColor colorWithRed:0 green:0.647 blue:0.961 alpha:1.0];
    return circleView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
