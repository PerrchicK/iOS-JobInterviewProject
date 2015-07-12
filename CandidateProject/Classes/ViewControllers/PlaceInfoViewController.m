//
//  PlaceInfoViewController.m
//  CandidateProject
//
//  Created by Perry Shalom on 7/11/15.
//  Copyright (c) 2015 PerrchicK. All rights reserved.
//

#import "PlaceInfoViewController.h"

@interface PlaceInfoViewController()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblRatingHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *lblRating;
@property (weak, nonatomic) IBOutlet UILabel *lblPlaceName;
@property (weak, nonatomic) IBOutlet UIButton *btnAddress;
@property (weak, nonatomic) IBOutlet UIButton *btnPhoneNumber;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)btnClosePressed:(id)sender;
- (IBAction)btnPhonePressed:(id)sender;
- (IBAction)btnAddressPressed:(id)sender;

@end

#define kRatingLabelOriginalHeight 40.0
#define kTagForConfirmCallAlertView 3000

@implementation PlaceInfoViewController

-(void)viewDidLoad {
    [super viewDidLoad];

    self.btnAddress.titleLabel.numberOfLines = 0;

    self.webView.scalesPageToFit = YES;
    self.webView.layer.borderWidth = 1.0;
    self.webView.layer.borderColor = [UIColor blackColor].CGColor;
    // Use category
    [self.webView makeRoundCorners];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.lblPlaceName.text = self.place.name;

    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];

    NSInteger rating = ceilf(self.place.rating);
    if (rating) {
        self.lblRatingHeightConstraint.constant = kRatingLabelOriginalHeight;
        NSMutableString *ratingStringBuilder = [[NSMutableString alloc] initWithCapacity:rating];
        for (NSInteger i = 0; i < rating; i++) {
            [ratingStringBuilder appendString:@"⭐️"];
        }
        self.lblRating.text = [ratingStringBuilder description];
    } else {
        self.lblRatingHeightConstraint.constant = 0.0;
    }
    self.lblRating.hidden = !rating;

    [self.btnAddress setTitle:self.place.formattedAddress forState:UIControlStateNormal];
    [self.btnPhoneNumber setTitle:self.place.phoneNumber forState:UIControlStateNormal];

    if (self.place.website) {
        self.webView.hidden = NO;
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.place.website];
        [self.webView loadRequest:request];
    } else {
        self.webView.hidden = YES;
    }
}

#pragma mark - User interaction methods

- (IBAction)btnClosePressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(placeInfoViewControllerDone:)]) {
        [self.delegate placeInfoViewControllerDone:self];
    }
}

- (IBAction)btnPhonePressed:(id)sender {
    NSString *phoneNumber = [self _cleanPhoneNumber:self.btnPhoneNumber.titleLabel.text];
    if ([self _isPhoneNumberValid:phoneNumber]) {
        NSString *alertTitle = @"Shall we call?";
        NSString *alertMessage = @"This action will dial the place";
        NSString *cancelBtnTitle = @"No";
        NSString *okBtnTitle = @"Call";
        
        if ([UIAlertController class]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:cancelBtnTitle style:UIAlertActionStyleCancel handler:nil]];
            [alertController addAction:[UIAlertAction actionWithTitle:okBtnTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self _initiatePhoneCall:phoneNumber];
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                            message:alertMessage
                                                           delegate:self
                                                  cancelButtonTitle:cancelBtnTitle
                                                  otherButtonTitles:okBtnTitle, nil];
            alertView.tag = kTagForConfirmCallAlertView;
            [alertView show];
        }
    }
}

- (IBAction)btnAddressPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(placeInfoViewController:navigateToCoordinate:)]) {
        [self.delegate placeInfoViewController:self navigateToCoordinate:self.place.coordinate];
    }
}

#pragma mark - Private methods

-(NSString *)_cleanPhoneNumber:(NSString *)dirtyPhoneNumber {
    NSString *phoneNumber = dirtyPhoneNumber;
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return phoneNumber;
}

-(void)_initiatePhoneCall:(NSString *)phoneNumber {
    NSLog(@"Initiating a phone call to '%@'", phoneNumber);
    NSURL *phoneNumberURL = [NSURL URLWithString: [NSString stringWithFormat: @"tel://%@", phoneNumber]];
    [[UIApplication sharedApplication] openURL: phoneNumberURL];
}

-(BOOL)_isPhoneNumberValid:(NSString *)phoneNumber {
    NSString *phoneRegex = @"^((\\+)|(00))[0-9]{6,14}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat: @"SELF MATCHES %@", phoneRegex];
    
    return [phoneTest evaluateWithObject: phoneNumber];
}

#pragma mark - UIAlertView delegate method(s)

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kTagForConfirmCallAlertView && buttonIndex > 0) {
        NSString *phoneNumber = [self _cleanPhoneNumber:self.btnPhoneNumber.titleLabel.text];
        [self _initiatePhoneCall:phoneNumber];
    }
}

@end