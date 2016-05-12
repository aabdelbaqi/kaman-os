//
//  UserProfileViewController.m
//  Kaman
//
//  Created by Moin' Victor on 04/12/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import "UserProfileViewController.h"
#import "Utils.h"
#import "KamanActionButtonsView.h"
#import "PhotosKamanTableViewCell.h"
#import "DetailKamanTableViewCell.h"
#import "Session.h"

@interface UserProfileViewController ()

@property (nonatomic) NSArray * profile_details;
@property (nonatomic) NSArray * profile_detail_labels;
@property (nonatomic) NSInteger totalRates;
@property (nonatomic) NSInteger positiveRates;
@property (nonatomic) BOOL fetchedRates;
@end

@implementation UserProfileViewController


- (IBAction)exit:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
   
    self.tableView.backgroundColor = MyBrownColor;
    
    self.profile_details = @[@"KamansAttended",@"KamansHosted"];
    self.profile_detail_labels = @[@"Parties Attended",@"Parties Hosted"];
    
    UINib *photoNib = [UINib nibWithNibName:@"PhotosKamanTableViewCell" bundle:nil];
    [[self tableView] registerNib:photoNib forCellReuseIdentifier:@"PhotoCell"];
    
    UINib *detailNib = [UINib nibWithNibName:@"DetailKamanTableViewCell" bundle:nil];
    [[self tableView] registerNib:detailNib forCellReuseIdentifier:@"DetailCell"];
    
    [self.tableView setSeparatorColor:MyBrownColor];
    
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [UIView new];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.allowsSelection = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    [self.navigationController.navigationBar setBarTintColor:
     [UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:MyOrangeColor}];
    if(!self.users)
        self.users = [NSMutableArray new];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            return self.tableView.frame.size.height - 275;
            break;
        default:
            break;
    }
    return UITableViewAutomaticDimension;;//tableView.frame.size.height;
}

#pragma mark - Table view data source
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.users count] == 0 ? 0 : 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
    if ([self.users count] == 0 || !self.showButtons) {
        return nil;
    }
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"KamanActionButtonsView"
                                                      owner:self
                                                    options:nil];
    int startIndex;
#ifdef __IPHONE_2_1
    startIndex = 0;
#else
    startIndex = 1;
#endif
    KamanActionButtonsView *footerView = [ nibViews objectAtIndex: startIndex];
    footerView.backgroundColor = MyBrownColor;
    
    [Utils setUIView:footerView.acceptButton backgroundColor:MyOrangeColor andRoundedByRadius:2 withBorderColor: MyOrangeColor];
    [Utils setUIView:footerView.cancelButton backgroundColor:MyOrangeColor andRoundedByRadius:2 withBorderColor: MyOrangeColor];
    
    [footerView.acceptButton addTarget:self action:@selector(acceptClicked) forControlEvents:UIControlEventTouchUpInside];
    [footerView.cancelButton addTarget:self action:@selector(declineClicked) forControlEvents:UIControlEventTouchUpInside];
    [footerView.acceptButton setImage:[UIImage imageNamed:@"checkmark-white"] forState:UIControlStateNormal];
    [footerView.cancelButton setImage:[UIImage imageNamed:@"cancel-white"] forState:UIControlStateNormal];
    return footerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PFUser *kamaner = [self.users firstObject];
    if(self.fetchedRates != YES) {
        [self fetchRatings];
    }
    if (indexPath.row == 0) {
        PhotosKamanTableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"PhotoCell"];
        cell.backgroundColor = MyBrownColor;
        [cell.kamanImageView setUserInteractionEnabled:YES];
        
        if(self.headerPannable) {
            [cell.kamanView initDragEventsOnView:self.view onDismissCallBack:^(GGOverlayViewMode mode) {
                if(mode == GGOverlayViewModeLeft) {
                    [self declineClicked];
                } else {
                    [self acceptClicked];
                }
            }];
            [cell.nextKamanView setAlpha:1.0];
            [Utils setUIView:cell.nextKamanImageView backgroundColor:[UIColor whiteColor] andRoundedByRadius:10  withBorderColor: MyBrownColor];
            [Utils setUIView:cell.nextKamanView backgroundColor:[UIColor whiteColor] andRoundedByRadius:10  withBorderColor: MyGreyColor];
            cell.nextKamanImageView.image = [UIImage imageNamed:@"login-bg"];
            cell.nextKamanNameLabel.text = @"Loading Next...";
            
        } else {
            [cell.nextKamanView setAlpha:0.0];
        }

        PFGeoPoint *myPoint = [PFGeoPoint geoPointWithLatitude:currentLocality.lat longitude:currentLocality.lon];
        PFGeoPoint *kamanerPoint = [kamaner objectForKey:@"LastKnownLocation"];
        int kmAway = [myPoint distanceInKilometersTo:kamanerPoint];
        [cell.farRightLabel setText:[NSString stringWithFormat:@"    %dkm",kmAway]];
        UIImageView *img=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 16, 16)];
        img.image=[UIImage imageNamed:@"location-filled"];
        [cell.farRightLabel addSubview:img];
        
        cell.namePaddingConstraint.constant = 0.0f;
        [Utils setUIView:cell.kamanImageView backgroundColor:[UIColor whiteColor] andRoundedByRadius:10  withBorderColor: MyBrownColor];
        [Utils setUIView:cell.kamanView backgroundColor:MyBrownColor andRoundedByRadius:10  withBorderColor: MyBrownColor];
        cell.kamanImageView.image = [UIImage imageNamed:@"login-bg"];
        

        NSString * range = @"<Age Hidden";
        NSDictionary * ageRange = [kamaner objectForKey:@"AgeRange"];
        if(ageRange) {
            if([ageRange objectForKey:@"min"]) {
                range = [NSString stringWithFormat:@"over %@",[ageRange objectForKey:@"min"]];
            } else if([ageRange objectForKey:@"max"]) {
                range = [NSString stringWithFormat:@"under %@",[ageRange objectForKey:@"max"]];
            }
        }

        NSString * age = [Utils getPFUserAgeAsString:kamaner onNoAge:ageRange != nil ? range : @"<Age Hidded>"];
        [cell.kamanNameLabel setText:[@"<Age Hidden>" isEqualToString:age ] ? [kamaner displayName] :[NSString stringWithFormat:@"%@, %@",[kamaner displayName],age]];
        
    
        if([kamaner profileImageURL]) {
            [cell.kamanImageView  sd_setImageWithURL:[NSURL URLWithString:[kamaner profileImageURL]]
                                    placeholderImage:[UIImage imageNamed:@"login-bg"]
                                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                               
                                               
                                           }];
        } else {
            [cell.kamanImageView setImage:[UIImage imageNamed:@"login-bg"]];
        }
        
        return cell;
    } else {
        DetailKamanTableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"DetailCell"];
        cell.backgroundColor = MyBrownColor;
        [cell.detailValueLabel setTextColor:MyDarkGrayColor];
        [cell.seperatorView setBackgroundColor:MyGreyColor];
        [cell.detailValueLabel setAlpha:1.0];
        [cell.rateLow setAlpha:0.0];
        [cell.rateHigh setAlpha:0.0];
        
        if(indexPath.row == 4) {
            [cell.detailValueLabel setTextColor:MyBrownColor];
            [cell.seperatorView setBackgroundColor:MyBrownColor];
            [cell.detailTagLabel setTextColor:MyBrownColor];
        } else if(indexPath.row == 3) {
            [cell.detailValueLabel setAlpha:0.0];
            [cell.rateLow setAlpha:1.0];
            [cell.rateHigh setAlpha:1.0];
            [cell.detailTagLabel setText:@"Party Level"];
            if(self.totalRates > 0) {
                double rate = self.positiveRates / self.totalRates;
                NSLog(@"User rating %f",rate);
                if(rate >= 0.5) {
                    [cell.rateLow setTintColor:MyGreyColor];
                    [cell.rateHigh setTintColor:[UIColor blackColor]];
                } else {
                    [cell.rateLow setTintColor:[UIColor blackColor]];
                    [cell.rateHigh setTintColor:MyGreyColor];
                }
            } else {
                [cell.rateLow setTintColor:MyGreyColor];
                [cell.rateHigh setTintColor:MyGreyColor];
            }

        } else {
              [cell.detailTagLabel setText:[self.profile_detail_labels objectAtIndex:indexPath.row-1]];
            
            NSArray *value = [kamaner objectForKey:TRIM([self.profile_details objectAtIndex:indexPath.row - 1])];
            if(value) {
                [cell.detailValueLabel setText:[NSString stringWithFormat:@"%lu",[value count]]];
            } else {
                [cell.detailValueLabel setText:@"0"];
            }
        }
        return cell;
        
    }
}


-(void) fetchRatings
{
    PFUser *kamaner = [self.users firstObject];
    
    PFQuery *query = [PFQuery queryWithClassName:@"KamanerRating"];
    [query whereKey:@"RatedFor" equalTo:kamaner];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error) {
            self.totalRates = [objects count];
            self.positiveRates = 0;
            for (PFObject * obj in objects) {
                NSNumber * number = [obj objectForKey:@"IsPartyAnimal"];
                if([number boolValue] == YES) {
                    self.positiveRates += 1;
                }
            }
            self.fetchedRates = YES;
            [self.tableView reloadData];
        }
    }];
}

-(void)acceptClicked
{
     self.fetchedRates = NO;
    
}

-(void)declineClicked
{
     self.fetchedRates = NO;
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
