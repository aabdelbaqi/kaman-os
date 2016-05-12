//
//  HomeViewController.h
//  Kaman
//
//  Created by Moin' Victor on 11/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "KamanDetailsViewController.h"

@interface HomeViewController : KamanDetailsViewController <CLLocationManagerDelegate, UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *notifbarButton;
@property (strong, nonatomic) CLLocationManager *locationManager;

-(void) updateNotifBadge;

@end
