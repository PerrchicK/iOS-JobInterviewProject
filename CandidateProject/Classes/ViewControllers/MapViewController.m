//
//  MapViewController.m
//  CandidateProject
//
//  Created by Perry Shalom on 7/9/15.
//  Copyright (c) 2015 PerrchicK. All rights reserved.
//

#import "MapViewController.h"

#import "ViewAnimator.h"
#import "PlacesWebRequestsHelper.h"
#import "Place.h"
#import "Prediction.h"
#import "PlaceInfoViewController.h"

// From CocoaPods
#import <GoogleMaps/GoogleMaps.h>
#import "CMPopTipView.h"

#define kDelayBeforeSearch 0.5
// From: http://gis.stackexchange.com/questions/7430/what-ratio-scales-do-google-maps-zoom-levels-correspond-to
#define kClosestZoomRatioScale 591657550.50
#define UIColorFromHexaRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface MapViewController ()<CLLocationManagerDelegate, GMSMapViewDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, PlaceInfoViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *btnCurrentCoordinate;
@property (strong, nonatomic) IBOutlet UILabel *lblAddress;
@property (strong, nonatomic) IBOutlet UILabel *lblPulse;
@property (nonatomic, strong) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchToolHeightConstraint;
@property (weak, nonatomic) IBOutlet UISlider *radiusSlider;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *btnMoveToCurrentLocation;
@property (weak, nonatomic) IBOutlet UIImageView *imgSearchNearbyPlaces;
@property (strong, nonatomic) IBOutlet UITableView *autocompleteResultsTableView;
@property (strong, nonatomic) NSArray *autocompleteResults;

@property (assign, nonatomic) BOOL isFirstLaunch;
@property (strong, nonatomic) CMPopTipView *popTip;

@property (strong, nonatomic) PlaceInfoViewController *placeInfoViewController;
@property (strong, nonatomic) GMSPlacesClient *placesClient;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *currentLocation;

@property (nonatomic, assign) CGFloat middleHeight;

@property (nonatomic, assign) BOOL isSearching;

@property (nonatomic, assign) NSTimeInterval delayFromLastCoordinateChange;
@property (nonatomic, assign) BOOL isUpdatingAddress;

- (IBAction)sliderValueChanged:(id)sender;
- (IBAction)btnMoveToCurrentLocationPressed:(id)sender;
- (IBAction)btnFindPlacesPressed:(id)sender;
- (IBAction)btnCurrentCoordinatePressed:(id)sender;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mapView.delegate = self;
    self.isSearching = NO;
    self.isUpdatingAddress = NO;
    self.isFirstLaunch = YES;

    self.placesClient = [[GMSPlacesClient alloc] init];

    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [self.locationManager startUpdatingLocation];
    [self _moveCameraToCurrentLocation];

    self.popTip = [[CMPopTipView alloc] init];

    [self _setAppearance];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.isFirstLaunch) {
        self.popTip.has3DStyle = NO;
        self.popTip.hasGradientBackground = NO;
        self.popTip.backgroundColor = UIColorFromHexaRGB(0x009dff);
        self.popTip.message = @"Use this slider to magnify / minify the radius of places nearby";
        self.isFirstLaunch = NO;
        [self.popTip presentPointingAtView:self.radiusSlider inView:self.view animated:YES];
    }
}

#pragma mark - CLLocationManager delegate methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if ([locations count]) {
        NSLog(@"Updated locations: %@", locations);
        if ([locations[0] isKindOfClass:[CLLocation class]]) {
            self.currentLocation = locations[0];
            [self _moveCameraToCurrentLocation];
        }
    }
}

#pragma mark - TableView data delegate methods

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = NSStringFromClass([NSString class]);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    Prediction *prediction = self.autocompleteResults[indexPath.row];
    cell.textLabel.text = prediction.predictionDescription;

    return cell;
}

#pragma mark - TableView delegate methods

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    tableView.hidden = self.autocompleteResults.count == 0;
    return self.autocompleteResults.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Prediction *prediction = self.autocompleteResults[indexPath.row];
    typeof(self) __weak weakSelf = self;
    [self.placesClient lookUpPlaceID:prediction.placeId callback:^(GMSPlace *place, NSError *error){
        typeof(self) strongSelf = weakSelf;
        [strongSelf _moveCameraToLocation:place.coordinate andZoom:18.0];
    }];

    self.autocompleteResults = @[];
    [self.autocompleteResultsTableView reloadData];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

#pragma mark - PlaceInfoViewController delegate methods

-(void)placeInfoViewControllerDone:(PlaceInfoViewController *)placeInfoViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)placeInfoViewController:(PlaceInfoViewController *)placeInfoViewController navigateToCoordinate:(CLLocationCoordinate2D)coordinate {
    typeof(self) __weak weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        typeof(self) strongSelf = weakSelf;
        [strongSelf _moveCameraToLocation:coordinate andZoom:18.0];
    }];
}

#pragma mark - Other delegate methods

-(void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    [self.locationManager stopUpdatingLocation];
    [self.searchBar resignFirstResponder];
    [self _setLocationText:position.target];

    // Prevent searching address every time the text changes, wait for the user to pause his movement on the map
    self.delayFromLastCoordinateChange = [[NSDate new] timeIntervalSince1970];
    dispatch_time_t dispatchTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDelayBeforeSearch * NSEC_PER_SEC));
    typeof(self) __weak weakSelf = self;
    dispatch_after(dispatchTime, dispatch_get_main_queue(), ^{
        if ([[NSDate new] timeIntervalSince1970] - self.delayFromLastCoordinateChange > kDelayBeforeSearch) {
            typeof(self) strongSelf = weakSelf;
            [strongSelf _updateAddressByLocation];
        }
    });
}

-(void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    // Zoom out
    [mapView animateToZoom:mapView.camera.zoom - 1.0];
}

-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    [self _presentPlaceInfoOfPlaceId:marker.userData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    typeof(self) __weak weakSelf = self;
    [PlacesWebRequestsHelper getAutocompleteFromPhrase:searchText completionBlock:^(BOOL succeeded, NSArray *predictions) {
        if (succeeded && predictions) {
            typeof(self) strongSelf = weakSelf;
            strongSelf.autocompleteResults = predictions;
            [strongSelf.autocompleteResultsTableView reloadData];
        }
    }];
}

#pragma mark - User interaction methods

- (IBAction)sliderValueChanged:(id)sender {
    if ([sender isKindOfClass:[UISlider class]]) {
        float sliderValue = [(UISlider *)sender value];
        CGFloat maxHeight = self.middleHeight * 2;
        self.searchToolHeightConstraint.constant = sliderValue * maxHeight;
    }
}

-(IBAction)btnMoveToCurrentLocationPressed:(id)sender {
    [self.locationManager startUpdatingLocation];
    [self _pulseWithColor:[UIColor orangeColor]];
}

- (IBAction)btnFindPlacesPressed:(id)sender {
    [self _searchPlacesInRadius];
}

- (IBAction)btnCurrentCoordinatePressed:(id)sender {
    // Copy coordinate to clipboard
    [[UIPasteboard generalPasteboard] setString:[self _coordinateAsString:self.mapView.camera.target]];
}

#pragma mark - Private methods

-(void)_setAppearance {
    // Setting text color of the search bar
    self.searchBar.placeholder = @"Search address...";
    [self _setTextColor:[UIColor whiteColor] inSubviewsOfView:self.searchBar];

    self.lblPulse.hidden = YES;

    [self.btnCurrentCoordinate setTitle:@"" forState:UIControlStateNormal];
    self.lblAddress.text = @"";
    self.searchToolHeightConstraint.constant *= 2;
    self.middleHeight = self.searchToolHeightConstraint.constant;
}

-(void)_moveCameraToCurrentLocation {
    [self _moveCameraToLocation:self.currentLocation.coordinate andZoom:15.0];
}

-(void)_moveCameraToLocation:(CLLocationCoordinate2D)coordinate andZoom:(float)zoomValue {
    [self.mapView animateToLocation:coordinate];
    [self.mapView animateToZoom:zoomValue];
}

-(void)_presentPlaceInfoOfPlaceId:(NSString *)placeId {
    typeof(self) __weak weakSelf = self;
    [self.placesClient lookUpPlaceID:placeId callback:^(GMSPlace *place, NSError *error){
        typeof(self) strongSelf = weakSelf;
        strongSelf.placeInfoViewController.place = place;
        [strongSelf presentViewController:self.placeInfoViewController animated:YES completion:nil];
    }];
}

-(void)_setTextColor:(UIColor *)textColor inSubviewsOfView:(UIView *)viewToSet {
    for (UIView *subView in viewToSet.subviews)
    {
        if ([subView isKindOfClass:[UITextField class]])
        {
            UITextField *searchBarTextField = (UITextField *)subView;
            searchBarTextField.textColor = textColor;
            break;
        } else {
            [self _setTextColor:textColor inSubviewsOfView:subView];
        }
    }
}

-(void)_searchPlacesInRadius {
    if (!self.isSearching) {
        self.isSearching = YES;
        CLLocationCoordinate2D coordinate = self.mapView.camera.target;

        [self _pulseWithColor:[UIColor greenColor]];

        CGFloat zoom = self.mapView.camera.zoom;
        CGFloat scale = kClosestZoomRatioScale / powf(2.0, zoom - 1);
        CGFloat metersPerPixel = scale/512;
        CGFloat range = self.radiusSlider.value * 2;
        NSInteger radius = range * metersPerPixel;

        typeof(self) __weak weakSelf = self;
        [PlacesWebRequestsHelper findPlacesNearbyCoordinate:coordinate radius:radius completionBlock:^(BOOL succeeded, NSArray *placesNearby) {
            typeof(self) strongSelf = weakSelf;
            strongSelf.isSearching = NO;
            if (succeeded) {
                [strongSelf _putPlacesOnMap:placesNearby];
            } else {
                [self _alertWithTitle:@"Error" message:@"Something went wrong"];
            }
        }];
    }
}

-(void)_pulseWithColor:(UIColor *)pulseColor {
    self.lblPulse.textColor = pulseColor;
    self.lblPulse.hidden = NO;
    self.lblPulse.alpha = 1.0;
    [ViewAnimator popView:self.lblPulse completion:^(BOOL finished) {
        [ViewAnimator fadeView:self.lblPulse fadeIn:NO duration:0.05 completion:nil];
    }];
}

-(void)_updateAddressByLocation {
    if (!self.isUpdatingAddress) {
        self.isUpdatingAddress = YES;

        typeof(self) __weak weakSelf = self;
        [PlacesWebRequestsHelper findAddressByCoordinate:self.mapView.camera.target completionBlock:^(BOOL succeeded, NSString *address) {
            typeof(self) strongSelf = weakSelf;
            strongSelf.isUpdatingAddress = NO;
            strongSelf.lblAddress.text = address;
            [ViewAnimator animateMovementOfView:strongSelf.lblAddress fromPoint:strongSelf.lblPulse.center toPoint:strongSelf.lblAddress.center completion:nil];
            [ViewAnimator popView:strongSelf.lblAddress completion:nil];
        }];
    }
}

-(void)_alertWithTitle:(NSString *)title message:(NSString *)message {
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}

-(NSString *)_coordinateAsString:(CLLocationCoordinate2D)locationCoordinate{
    return [NSString stringWithFormat:@"%f,%f", locationCoordinate.latitude, locationCoordinate.longitude];
}

-(void)_setLocationText:(CLLocationCoordinate2D)locationCoordinate {
    NSString *currentLocationStr = [NSString stringWithFormat:@"Current location:(%@)", [self _coordinateAsString:locationCoordinate]];
    [self.btnCurrentCoordinate setTitle:currentLocationStr forState:UIControlStateNormal];
}

-(void)_putPlacesOnMap:(NSArray *)placesArray {
    for (Place *place in placesArray) {
        GMSMarker *marker = [GMSMarker markerWithPosition:place.placePosition];
        marker.title = place.placeName;
        marker.map = self.mapView;
        marker.userData = place.placeId;
    }
}

#pragma mark - Getters

-(PlaceInfoViewController *)placeInfoViewController {
    if (!_placeInfoViewController) {
        _placeInfoViewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([PlaceInfoViewController class])];
        _placeInfoViewController.delegate = self;
    }

    return _placeInfoViewController;
}

@end