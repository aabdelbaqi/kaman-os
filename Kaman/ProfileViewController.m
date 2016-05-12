//
//  ProfileViewController.m
//  Kaman
//
//  Created by Moin' Victor on 22/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import "ProfileViewController.h"
#import "ParallaxHeaderView.h"
#import "Utils.h"
#import "DetailKamanTableViewCell.h"
#import "Session.h"

@interface ProfileViewController ()

@property (nonatomic) UIImageView * imageView;
@property (nonatomic) ParallaxHeaderView *headerView;
@property (nonatomic) NSArray * profile_details;
@property (nonatomic) NSArray * profile_detail_labels;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) NSInteger totalRates;
@property (nonatomic) NSInteger positiveRates;


@end

@implementation ProfileViewController

- (IBAction)exit:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)editProfile:(id)sender
{
    [self performSegueWithIdentifier:@"edit_profile" sender:nil];
}


-(void) fetchMyRatings
{
    PFQuery *query = [PFQuery queryWithClassName:@"KamanerRating"];
    [query whereKey:@"RatedFor" equalTo:self.user];
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
            [self.tableView reloadData];
        }
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"My Profile"];
    
    
    [self.navigationController.navigationBar setBarTintColor:
     [UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:MyOrangeColor}];
    [self.navigationController.navigationItem.leftBarButtonItem setTintColor:MyOrangeColor];
    self.view.backgroundColor = MyBrownColor;

    
    self.profile_details = @[@"Age",@"KamansHosted",@"KamansAttended"];
    self.profile_detail_labels = @[@"Age",@"Kamans Attended",@"Kamans Hosted"];
    
    UINib *detailNib = [UINib nibWithNibName:@"DetailKamanTableViewCell" bundle:nil];
    [[self tableView] registerNib:detailNib forCellReuseIdentifier:@"DetailCell"];
    
    if(!self.user) {
        self.user = [PFUser currentUser];
    }
    
    self.tableView.tableFooterView = [UIView new];
     self.tableView.allowsSelection = NO;
    self.tableView.backgroundColor = MyBrownColor;

      [self.tableView setSeparatorColor:MyDarkGrayColor];
    
    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) setUpHeaderView
{
 
    if(profileHeaderView) {
        self.headerView = profileHeaderView;
    } else {
        self.headerView = [ParallaxHeaderView parallaxHeaderViewWithImage:[UIImage imageNamed:@"login-bg"] forSize:CGSizeMake(self.tableView.frame.size.width, self.tableView.frame.size.height - 300)];
        profileHeaderView = self.headerView;
    }
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0 , 120, 120)];
    self.imageView.center = self.headerView.center;
    //   self.imageView.frame = CGRectMake(self.imageView.center.x, self.imageView.center.y, 120, 120);
    // ParallaxHeaderView *headerView = [ParallaxHeaderView parallaxHeaderViewWithSubView:imageView];
    self.imageView.tag = 1000;
    [Utils setUIView:self.imageView backgroundColor:MyGreyColor andRoundedByRadius:self.imageView.frame.size.height/2 withBorderColor:[UIColor whiteColor]];
    self.imageView.frame = CGRectOffset(self.imageView.frame, 0.0f, -20.0f);
    
    
    [self.headerView addSubview:self.imageView];
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.imageView.center.y +100, self.headerView.frame.size.width, 20)];
    self.nameLabel.center = self.imageView.center;
    self.nameLabel.frame = CGRectMake(0, self.imageView.center.y +70, self.headerView.frame.size.width, 20);
    [self.nameLabel setFont:[UIFont systemFontOfSize:20]];
    [self.nameLabel setTextColor:[UIColor whiteColor]];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.tag = 1000;
    [self.headerView addSubview:self.nameLabel];
    
    UIButton *editProfileBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.nameLabel.center.y + 50, self.imageView.frame.size.width, 20)];
    editProfileBtn.center = self.nameLabel.center;
    editProfileBtn.frame = CGRectMake(editProfileBtn.center.x - 60, editProfileBtn.center.y + 20, self.imageView.frame.size.width, 20);
    [editProfileBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [editProfileBtn setTitle:@"Edit Profile" forState:UIControlStateNormal];
    [editProfileBtn setBackgroundColor:[UIColor clearColor]];
    editProfileBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    editProfileBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    editProfileBtn.tag = 1000;
    [editProfileBtn addTarget:self action:@selector(editProfile:) forControlEvents:UIControlEventTouchUpInside];
    
    if([self.user.objectId isEqualToString:[PFUser currentUser].objectId]) {
        [self.headerView addSubview:editProfileBtn];
    }
    
    [self.tableView setTableHeaderView:self.headerView];
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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setUpHeaderView];
    
    [self.nameLabel setText:[self.user displayName]];
    

    if([self.user profileImageURL]) {
        [self.imageView  sd_setImageWithURL:[NSURL URLWithString:[self.user profileImageURL]]
                                placeholderImage:[UIImage imageNamed:@"person"]
                                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                           [self.headerView setHeaderImage:image];
                                           
                                           
                                       }];
    } else {
        [self.imageView setImage:[UIImage imageNamed:@"person"]];
    }
    
    [(ParallaxHeaderView *)self.tableView.tableHeaderView layoutHeaderViewForScrollViewOffset:self.tableView.contentOffset];
    
    [self fetchMyRatings];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UISCrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView)
    {
        // pass the current offset of the UITableView so that the ParallaxHeaderView layouts the subViews.
        [(ParallaxHeaderView *)self.tableView.tableHeaderView layoutHeaderViewForScrollViewOffset:scrollView.contentOffset];
        
    }
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.profile_details count] + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailKamanTableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"DetailCell"];
    cell.backgroundColor = MyBrownColor;
    [cell.detailValueLabel setTextColor:MyDarkGrayColor];
    [cell.seperatorView setBackgroundColor:MyBrownColor];
    [cell.detailValueLabel setAlpha:1.0];
    [cell.rateLow setAlpha:0.0];
    [cell.rateHigh setAlpha:0.0];

    
    if (indexPath.row == 0) {
        NSString * range = @"<Age Hidden";
        NSDictionary * ageRange = [[PFUser currentUser] objectForKey:@"AgeRange"];
        if(ageRange) {
            if([ageRange objectForKey:@"min"]) {
                range = [NSString stringWithFormat:@"over %@",[ageRange objectForKey:@"min"]];
            } else if([ageRange objectForKey:@"max"]) {
                range = [NSString stringWithFormat:@"under %@",[ageRange objectForKey:@"max"]];
            }
        }
        [cell.detailTagLabel setText:[self.profile_detail_labels objectAtIndex:indexPath.row]];
          [cell.detailValueLabel setText:[Utils getPFUserAgeAsString:[PFUser currentUser] onNoAge:range]];
    } else if(indexPath.row == 3) {
        [cell.detailValueLabel setAlpha:0.0];
        [cell.rateLow setAlpha:1.0];
        [cell.rateHigh setAlpha:1.0];
        [cell.detailTagLabel setText:@"Kaman Level"];
        if(self.totalRates > 0) {
            double rate = self.positiveRates / self.totalRates;
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
        [cell.detailTagLabel setText:[self.profile_detail_labels objectAtIndex:indexPath.row]];
        
        NSArray *value = [self.user objectForKey:TRIM([self.profile_details objectAtIndex:indexPath.row - 1])];
        if(value) {
            [cell.detailValueLabel setText:[NSString stringWithFormat:@"%lu",[value count]]];
        } else {
            [cell.detailValueLabel setText:@"0"];
        }
    }
    
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.headerView != nil) {
        
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.tableFooterView = [UIView new];
        return 1;
        
    } else {
        
        UIView * progressHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        
        UIActivityIndicatorView  *av = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        av.frame = CGRectMake(round((progressHeader.frame.size.width - 150) / 2), round((progressHeader.frame.size.height - 150) / 2), 150,150);
        av.tag  = 1;
        [progressHeader addSubview:av];
        [av startAnimating];
        
        // [myView setBounds:self.tableView.bounds];
        // [myView setFrame: self.tableView.frame];
        
        self.tableView.backgroundView = progressHeader;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    
    return 0;
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
