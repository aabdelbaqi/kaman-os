//
//  KamanDetailsViewController.m
//  Kaman
//
//  Created by Moin' Victor on 27/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import "KamanDetailsViewController.h"
#import "Utils.h"
#import "KamansTableEmptyView.h"
#import "BasicKamansTableViewCell.h"
#import "PhotosKamanTableViewCell.h"
#import "KamanActionButtonsView.h"
#import "DetailKamanTableViewCell.h"
#import "ParallaxHeaderView.h"
#import "UIImage+ImageEffects.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "AFTableViewCell.h"
#import "Session.h"
#import "AttendeeCollectionViewCell.h"
#import "JTSImageViewController.h"
#import "UserProfileViewController.h"
#import "NYTPhotosViewController.h"


@implementation KamanPhoto

-(UIImage *)image
{
    return self.photo;
}

-(UIImage *)placeholderImage
{
    return self.placeHolderPhoto;
}

-(NSAttributedString *)attributedCaptionTitle
{
    return [[NSAttributedString alloc] initWithString:self.title];
}

-(NSAttributedString *)attributedCaptionSummary
{
    return nil;
}

-(NSAttributedString *)attributedCaptionCredit
{
    return nil;
}

-(instancetype) initWithTitle: (NSString*) title photo:(UIImage*) photo placeHolder: (UIImage*) placeholder
{
    self = [super init];
    if(self) {
        self.placeHolderPhoto = placeholder;
        self.photo = photo;
        self.title = title;
    }
    return self;
}

-(NSData *)imageData
{
    NSData *imgData= UIImageJPEGRepresentation([self image],0.0);
    return imgData;
}

@end


@interface KamanDetailsViewController ()
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;
@property (nonatomic,strong) NSTimer * imagesCheckTimer;
@end

@implementation KamanDetailsViewController
BOOL reloadOnViewDidAppear = true;

- (IBAction)exit:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *badicNib = [UINib nibWithNibName:@"BasicKamansTableViewCell" bundle:nil];
    [[self tableView] registerNib:badicNib forCellReuseIdentifier:@"BasicCell"];
    
    UINib *photoNib = [UINib nibWithNibName:@"PhotosKamanTableViewCell" bundle:nil];
    [[self tableView] registerNib:photoNib forCellReuseIdentifier:@"PhotoCell"];
    
    [[self tableView] registerClass:[UITableViewCell class] forCellReuseIdentifier:@"DescTitle"];
    [[self tableView] registerClass:[UITableViewCell class] forCellReuseIdentifier:@"DescCell"];
     [[self tableView] registerClass:[AFTableViewCell class] forCellReuseIdentifier:@"AttendeesCell"];
    
    UINib *detailNib = [UINib nibWithNibName:@"DetailKamanTableViewCell" bundle:nil];
    [[self tableView] registerNib:detailNib forCellReuseIdentifier:@"DetailCell"];
    
    [self.tableView setSeparatorColor:MyDarkGrayColor];
    
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [UIView new];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.allowsSelection = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    [self.navigationController.navigationBar setBarTintColor:
     [UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:MyOrangeColor}];
    
    reloadOnViewDidAppear = true;
    self.kamanPhotosDict = [NSMutableDictionary new];
    self.attendees = [NSMutableArray new];
    self.kamanImages = [NSMutableArray new];
    self.kamanImageUrls = [NSMutableArray new];
    self.maleAttendees = [NSMutableDictionary new];
    self.femaleAttendees = [NSMutableDictionary new];
    self.friendsOfMyFbFriends = [NSMutableArray new];
    
    if(!self.customTitle) {
        UIImage *img = [UIImage imageNamed:@"kaman-logo"];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [imgView setImage:img];
        // setContent mode aspect fit
        [imgView setContentMode:UIViewContentModeScaleAspectFit];
        self.navigationItem.titleView = imgView;
    } else {
        [self setTitle:self.customTitle];
    }
    
    self.view.backgroundColor = MyBrownColor;
    self.tableView.backgroundColor = MyBrownColor;
    
    self.tableSize = TABLE_SIZE_BASIC;
    self.contentOffsetDictionary = [NSMutableDictionary dictionary];

}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView  reloadData];
    [self setTimeerToLoadImages];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewWillDisappear:animated];
    [self.imagesCheckTimer invalidate];
}

-(void) setTimeerToLoadImages
{

    self.imagesCheckTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(loadKamanImages) userInfo:nil repeats:YES];
}

-(void) loadKamanImages
{
    if([self.kamans count] == 0) {
        return;
    }
    if([self.kamanImages count] >= 2) {
        [self.imagesCheckTimer invalidate];
        return;
    }
    PFObject *kaman = [self.kamans firstObject];
    [self loadImagesForKaman:kaman aroundCell:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)findAttendees: (PFObject*) kaman
{
    PFUser * host = [kaman objectForKey:@"Host"];
    
    if([host[@"Gender"] isEqualToString:@"Female"]) {
        [self.femaleAttendees setObject:host forKey:host.objectId];
    } else if([host[@"Gender"] isEqualToString:@"Male"]){
        [self.maleAttendees setObject:host forKey:host.objectId];
    }
    PFRelation *relation = [kaman relationForKey:@"Requests"];
    
    // generate a query based on that relation
    PFQuery *query = [relation query];
    [query includeKey:@"RequestingUser"];
    [query includeKey:@"Kaman.Host"];
    [query whereKey:@"Accepted" equalTo:@YES];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error) {
            if([objects count] > 0) {
                for (PFObject * request in objects) {
                    PFUser * attendee = [request objectForKey:@"RequestingUser"];
                    if([attendee[@"Gender"] isEqualToString:@"Female"]) {
                        [self.femaleAttendees setObject:attendee forKey:attendee.objectId];
                    } else if([attendee[@"Gender"] isEqualToString:@"Male"]){
                        [self.maleAttendees setObject:attendee forKey:attendee.objectId];
                    }
                    
                    if([[PFUser currentUser] isFacebookFriendsWith:attendee]) {
                        NSArray * attendeeFriendsIds = [attendee objectForKey:@"FBFriendsUserIDs"];
                        for (NSString* fbid in attendeeFriendsIds) {
                            if(![self.friendsOfMyFbFriends containsObject:fbid]) {
                                [self.friendsOfMyFbFriends addObject:fbid ];
                            }
                        }
                    }
                    BOOL contains = NO;
                    for (PFObject *att in self.attendees) {
                        if([attendee.objectId isEqualToString:att.objectId]) {
                            contains = YES;
                            break;
                        }
                    }
                    
                    if(!contains) {
                        [self.attendees addObject:attendee];
                    }
                }
                [self.tableView reloadData];
            }
        }
        
        PFRelation *relation2 = [kaman relationForKey:@"Invitations"];
        
        // generate a query based on that relation
        PFQuery *query2 = [relation2 query];
        [query2 includeKey:@"InvitedUser"];
        [query2 includeKey:@"Kaman.Host"];
        [query2 whereKey:@"Accepted" equalTo:@YES];
        [query2 findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if(!error) {
                if([objects count] > 0) {
                    for (PFObject * request in objects) {
                        PFUser * attendee = [request objectForKey:@"InvitedUser"];
                        if([attendee[@"Gender"] isEqualToString:@"Female"]) {
                            [self.femaleAttendees setObject:attendee forKey:attendee.objectId];
                        } else if([attendee[@"Gender"] isEqualToString:@"Male"]){
                            [self.maleAttendees setObject:attendee forKey:attendee.objectId];
                        }
                        
                        BOOL contains = NO;
                        for (PFObject *att in self.attendees) {
                            if([attendee.objectId isEqualToString:att.objectId]) {
                                contains = YES;
                                break;
                            }
                        }
                        
                        if(!contains) {
                            [self.attendees addObject:attendee];
                        }
                    }
                    [self.tableView reloadData];
                }
            }
        }];

    }];

}

#pragma mark -  TableView

-(CGFloat) calculate2ndRowHeight
{
    CGFloat _1stRowHeight = (self.tableView.frame.size.width - 40);
    CGFloat footerHeight = 60.0f;
    CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
    
    BOOL canScroll = self.tableSize == TABLE_SIZE_DETAILS;;
    if(canScroll == NO) {
        [self.tableView setContentOffset:
        CGPointMake(0, -self.tableView.contentInset.top) animated:NO];
    }
    self.tableView.scrollEnabled = canScroll;
    return self.tableSize == TABLE_SIZE_BASIC ?
    
    self.view.frame.size.height - _1stRowHeight - footerHeight - navBarHeight :
    
    100.0f;
}

-(CGFloat) smallItemsWidth
{
    CGFloat space = (self.tableView.frame.size.width - 20);
    
    return (space - 10) / 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            return self.tableView.frame.size.width - 20;
        case 1:
            return [self calculate2ndRowHeight];
        case 9:
            if([self.attendees count] == 0) {
                return 0.0;
            }
            return 100.0;
        default:
            break;
    }
    return UITableViewAutomaticDimension;;//tableView.frame.size.height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if ([self.kamans count] > 0) {
        
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.tableFooterView = [UIView new];
        return 1;
        
    } else {
        
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        
        NSString *text = @"Nothing to show :(";
        
        messageLabel.text = text;
        messageLabel.textColor = MyOrangeColor;
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font =  [UIFont systemFontOfSize:14];
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    
    return 0;
}


-(void) closePhotos: (id) sender
{
    [self.presentedViewController dismissModalViewControllerAnimated:YES];
}

-(void)imageTapped: (UITapGestureRecognizer*) sender
{
   /*KamanImagesViewController *imagesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"kaman_images"];
    imagesViewController.images = [NSMutableArray arrayWithArray:self.kamanImages];
   [self.navigationController  pushViewController:imagesViewController animated:YES];
  */
    
    
    
    if(self.kamanImages.count == 0) {
        return;
    }
    
    if([self.kamanImages count] < 2) {
        [self loadKamanImages];
        JGProgressHUD * hud = [Utils showProgressDialogInView:self.view withMessage:@"Please wait..."];
        [Utils runAfterDelay:3.0 block:^{
            [hud dismiss];
            [self showPhotos];
        }];
    } else {
        [self showPhotos];
    }
}

-(void) showPhotos
{
    
    NYTPhotosViewController *photosController =
    [[NYTPhotosViewController alloc] initWithPhotos:self.kamanImages];
    [photosController setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:photosController action:@selector(doneButtonTapped:)]];
    
    [self presentViewController:photosController animated:YES completion:nil];
    [self onKamanPictureClicked];
 
}

-(void) kamanHostImageTapped: (UITapGestureRecognizer*) sender
{
    PFObject *kaman = [self.kamans firstObject];
    PFUser *kamanHost = [kaman objectForKey:@"Host"];
    [self takeToProfleFor:kamanHost isHost:YES];
}

-(void) attendeeImageTapped: (UITapGestureRecognizer*) sender
{
     UIImageView * imageView = (UIImageView*)sender.view;
     PFUser * attendee = [self.attendees objectAtIndex:imageView.tag];
     [self takeToProfleFor:attendee isHost:NO];
}


-(void) takeToProfleFor:(PFUser*) user isHost: (BOOL)isHost
{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    PFObject *kaman = [self.kamans firstObject];
    UserProfileViewController *someViewController = [storyboard instantiateViewControllerWithIdentifier:@"user_profile"];
    someViewController.users = [NSMutableArray arrayWithObject:user];
    someViewController.kaman = kaman;
    
    [Utils setTitle:isHost ? @"Host Profile" : @"Attendee Profile" withColor:MyOrangeColor andSubTitle:kaman != nil ? [kaman objectForKey:@"Name"] :@"Party" withColor:MyOrangeColor onNavigationController:someViewController];
    
    [self.navigationController pushViewController:someViewController animated:YES];
}


-(void) loadImagesForKaman: (PFObject*) kaman aroundCell: (PhotosKamanTableViewCell*) cell
{
    NSArray *kamanPhotos = [self.kamanPhotosDict objectForKey:kaman.objectId];
    PFObject *firstPhotoObj = [kamanPhotos firstObject];
    PFFile *firstImageFile = [firstPhotoObj objectForKey:@"ImageFile"];
    for (PFObject * obj in kamanPhotos) {
        PFFile *imageFile = [obj objectForKey:@"ImageFile"];
        if(![self.kamanImageUrls containsObject:imageFile.url]) {
            [self.kamanImageUrls addObject:imageFile.url];
            
            [imageFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
                if(error) {
                    [self.kamanImageUrls removeObject:imageFile.url];
                } else {
                    UIImage *image = [UIImage imageWithData:data];
                    if([imageFile.url isEqualToString:firstImageFile.url]) {
                        if(cell != nil)
                            cell.kamanImageView.image = image;
                    }
                    KamanPhoto *photo =[[KamanPhoto alloc] initWithTitle: [kaman objectForKey:@"Name"] photo:image placeHolder:[UIImage imageNamed:@"login-bg"]];
                    [self.kamanImages addObject:photo];
                    if([self.kamanImages count] >= 2) {
                        [self.imagesCheckTimer invalidate];
                    }
                }
            }];
        }
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *kaman = [self.kamans firstObject];
    if([self.attendees count] == 0) {
        [self findAttendees:kaman];
        [self setTimeerToLoadImages];
    }
    PFObject *kamanArea = [kaman objectForKey:@"Area"];
    [kamanArea fetchIfNeededInBackground];
    PFUser *kamanHost = [kaman objectForKey:@"Host"];
    [kamanHost fetchIfNeededInBackground];
    if (indexPath.row == 0) {
        PhotosKamanTableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"PhotoCell"];
        cell.backgroundColor = MyBrownColor;
        
        if(self.headerPannable) {
            [cell.kamanView initDragEventsOnView:self.view onDismissCallBack:^(GGOverlayViewMode mode) {
                if(mode == GGOverlayViewModeLeft) {
                    [self onDecline];
                } else {
                     [self onAccept];
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
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
        singleTap.numberOfTapsRequired = 1;
        [cell.kamanImageView setUserInteractionEnabled:YES];
        [cell.kamanImageView addGestureRecognizer:singleTap];
        
       
        [cell.kamanHostImageView setAlpha:1.0];
        UITapGestureRecognizer *singleProfileTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(kamanHostImageTapped:)];
        singleProfileTap.numberOfTapsRequired = 1;
        [cell.kamanHostImageView setUserInteractionEnabled:YES];
        [cell.kamanHostImageView addGestureRecognizer:singleProfileTap];
        
        
        [Utils setUIView:cell.kamanHostImageView backgroundColor:MyGreyColor andRoundedByRadius:cell.kamanHostImageView.frame.size.height/2 withBorderColor:[UIColor whiteColor]];
        
        
        if([kamanHost profileImageURL]) {
            //NSURLRequest *urlRequest = [NSURLRequest requestWithURL:
            //                            [NSURL URLWithString:url]];
            
            
            cell.kamanHostImageView.contentMode = UIViewContentModeScaleAspectFill;
            [cell.kamanHostImageView sd_setImageWithURL:[NSURL URLWithString:[kamanHost profileImageURL]]
                                       placeholderImage:[UIImage imageNamed:@"person"]
                                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                              }];
        }

        cell.kamanNameLabel.text = [kaman objectForKey:@"Name"];
        [Utils setUIView:cell.kamanImageView backgroundColor:[UIColor whiteColor] andRoundedByRadius:10  withBorderColor: MyBrownColor];
        [Utils setUIView:cell.kamanView backgroundColor:[UIColor whiteColor] andRoundedByRadius:10  withBorderColor: MyGreyColor];
        
        NSArray *kamanPhotos = [self.kamanPhotosDict objectForKey:kaman.objectId];
        if(!kamanPhotos || [kamanPhotos count] == 0) {
            cell.kamanImageView.image = [UIImage imageNamed:@"login-bg"];
        
            // create a relation based on the authors key
            PFRelation *relation = [kaman relationForKey:@"Photos"];
            
            // generate a query based on that relation
            PFQuery *query = [relation query];
            [query orderByAscending:@"index"];
            [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                if(!error) {
                    [self.kamanPhotosDict removeObjectForKey:kaman.objectId];
                    [self.kamanPhotosDict setObject:objects forKey:kaman.objectId];
                    [self.tableView reloadData];
                } else {
                    NSLog(@"Error fetching photos for %@: %@",[kaman objectForKey:@"Name"],error);
                }
            }];
        } else {
            [self loadImagesForKaman:kaman aroundCell:cell];
        }
     
        return cell;
    } else if (indexPath.row == 1) {
        NSDate *kamanDateTime = [kaman objectForKey:@"DateTime"];
        
        PFGeoPoint *kamanGeoPoint =  [kamanArea objectForKey:@"LatLong"];
        
        BasicKamansTableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"BasicCell"];
        cell.backgroundColor = MyBrownColor;
        
        cell.leftView.backgroundColor = MyBrownColor;
        cell.rightView.backgroundColor = MyBrownColor;
        
        
        [cell.dateLabel setText:[[Utils getDateFormatter_MMM_D] stringFromDate:kamanDateTime]];
        [cell.timeLabel setText:[[Utils getTimeFormatter_H_MM_AMPM] stringFromDate:kamanDateTime]];
        [cell.rsvpLabel setText:[NSString stringWithFormat:@"%lu",[self.attendees count]]];
        
        [cell.detailsButton addTarget:self action:@selector(showDetails:) forControlEvents:UIControlEventTouchUpInside];
      
        cell.flagLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(flagKaman:)];
        singleTap.numberOfTapsRequired = 1;
        [cell.flagLabel addGestureRecognizer:singleTap];
        UIImageView *img=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 16, 16)];
        img.image=[UIImage imageNamed:@"flag"];
        [cell.flagLabel addSubview:img];
        [cell.flagLabel setText:@"       Flag as Inappropriate"];
        
        if(self.tableSize == TABLE_SIZE_DETAILS) {
            [cell.detailsButton setAlpha:0.0f];
            cell.flagHeightConstraint.constant = -35.0f;
        } else {
            [cell.detailsButton setAlpha:1.0f];
            cell.flagHeightConstraint.constant = 7.0f;
        }
        
        int kmAway = [kamanGeoPoint distanceInKilometersTo:[PFGeoPoint geoPointWithLatitude:currentLocality.lat longitude:currentLocality.lon]];
        [cell.distanceLabel setText:[NSString stringWithFormat:@" %d KM",kmAway]];
        
        
        [cell.detailsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [Utils setUIView:cell.detailsButton backgroundColor:MyBrownColor andRoundedByRadius:3  withBorderColor: MyGreyColor];
        
        [Utils setUIView:cell.dateView backgroundColor:MyBrownColor andRoundedByRadius:5 withBorderColor: MyGreyColor];
        [Utils setUIView:cell.timeView backgroundColor:MyBrownColor andRoundedByRadius:5 withBorderColor: MyGreyColor];
        [Utils setUIView:cell.locationView backgroundColor:MyBrownColor andRoundedByRadius:5 withBorderColor: MyGreyColor];
        [Utils setUIView:cell.rsvpView backgroundColor:MyBrownColor andRoundedByRadius:5 withBorderColor: MyGreyColor];
        
        [cell.dateLabel setTextColor:MyDarkGrayColor];
        [cell.timeLabel setTextColor:MyDarkGrayColor];
        [cell.distanceLabel setTextColor:MyDarkGrayColor];
        [cell.rsvpLabel setTextColor:MyDarkGrayColor];
        
        return cell;
        
    } else if (indexPath.row == 2) {
        UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"DescTitle"];
        cell.backgroundColor = MyBrownColor;
        [cell.textLabel setText:[NSString stringWithFormat:@" %@", @"Description"]];
        [cell.textLabel setFont:[UIFont systemFontOfSize:18]];
        //[cell.textLabel setTextColor:MyGreyColor];
        return cell;
    } else if (indexPath.row == 3) {
        UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"DescCell"];
        cell.backgroundColor = MyBrownColor;
        [cell.textLabel setText:[NSString stringWithFormat:@" %@", [kaman objectForKey: @"Description"]]];
        [cell.textLabel setFont:[UIFont systemFontOfSize:15]];
        [cell.textLabel setTextColor:MyDarkGrayColor];
        return cell;
    } else if (indexPath.row == 9) {
        
        AFTableViewCell *cell = (AFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AttendeesCell"];
        
        if (!cell)
        {
            cell = [[AFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AttendeesCell"];
        }
         cell.backgroundColor = MyBrownColor;
        
        return cell;
    } else {
        DetailKamanTableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"DetailCell"];
        cell.backgroundColor = MyBrownColor;
        [cell.detailValueLabel setTextColor:MyDarkGrayColor];
        [cell.seperatorView setBackgroundColor:MyGreyColor];
        
        if (indexPath.row == 4) {
            [cell.detailTagLabel setText:@"Host"];
            [cell.detailValueLabel setText:[NSString stringWithFormat:@"       %@",[kamanHost displayName]]];
            UIImageView *img=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 24, 24)];
            img.image=[UIImage imageNamed:@"person"];
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(kamanHostImageTapped:)];
            singleTap.numberOfTapsRequired = 1;
            [img setUserInteractionEnabled:YES];
            [img addGestureRecognizer:singleTap];
            [Utils setUIView:img backgroundColor:MyGreyColor andRoundedByRadius:img.frame.size.height/2 withBorderColor:[UIColor whiteColor]];
            [cell.detailValueLabel addSubview:img];
            
           
            if([kamanHost profileImageURL]) {
                //NSURLRequest *urlRequest = [NSURLRequest requestWithURL:
                //                            [NSURL URLWithString:url]];
                
                img.contentMode = UIViewContentModeScaleAspectFill;
                [img sd_setImageWithURL:[NSURL URLWithString:[kamanHost profileImageURL]]
                       placeholderImage:[UIImage imageNamed:@"person"]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                              }];
                
                /*
                 AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
                 requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
                 [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSLog(@"Response: %@", responseObject);
                 
                 img.image = responseObject;
                 
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 NSLog(@"Image error: %@", error);
                 }];
                 [requestOperation start];
                 */
            }
            
        } else if(indexPath.row == 5) {
            [cell.detailTagLabel setText:@"Area"];
            [cell.detailValueLabel setText:[kamanArea objectForKey:@"Name"]];
        } else if(indexPath.row == 6) {
            [cell.detailTagLabel setText:@"Address"];
            if(self.showAddress) {
                [cell.detailValueLabel setText:[kaman objectForKey:@"Address"]];
            } else {
                [cell.detailValueLabel setText:@"Revealed if Accepted"];
            }
        } else if(indexPath.row == 7) {
            [cell.detailTagLabel setText:@"M/F Ratio"];
            [cell.detailValueLabel setText:[NSString stringWithFormat:@"%lu:%lu",[self.maleAttendees count],[self.femaleAttendees count]]];
        }else if(indexPath.row == 8) {
            [cell.detailTagLabel setText:@"Accepted Attendees"];
            [cell.detailValueLabel setText:[NSString stringWithFormat:@"%lu",[self.attendees count]]];
        }
        
        return cell;
        
    }
    return nil;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
    if ([self.kamans count] == 0 || !self.showButtons) {
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
    
    [footerView.acceptButton addTarget:self action:@selector(onAccept) forControlEvents:UIControlEventTouchUpInside];
    [footerView.cancelButton addTarget:self action:@selector(onDecline) forControlEvents:UIControlEventTouchUpInside];
    [footerView.acceptButton setImage:[UIImage imageNamed:@"checkmark-white"] forState:UIControlStateNormal];
    [footerView.cancelButton setImage:[UIImage imageNamed:@"cancel-white"] forState:UIControlStateNormal];
    return footerView;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.kamans count] == 0 ? 0 : self.tableSize;
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(AFTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell class] == [AFTableViewCell class]) {
        AFTableViewCell *cellRef = cell;
        [cellRef setCollectionViewDataSourceDelegate:self indexPath:indexPath];
        NSInteger index = cellRef.collectionView.tag;
        
        CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
        [cellRef.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
    }
    
}

-(void) onAccept
{
    
}


-(void) onDecline
{
    
}


-(void) onViewDetailsClicked
{
    
}

-(void)onKamanPictureClicked
{
    
}

-(IBAction)showDetails:(id)sender
{
    self.tableSize = TABLE_SIZE_DETAILS;
    [self.tableView reloadData];
    [self onViewDetailsClicked];
}

-(IBAction)flagKaman:(id)sender {
    PFObject *kaman = [self.kamans firstObject];
    reloadOnViewDidAppear = false;
    [Utils showConfirmDialogInContoller:self titled:@"Report Posting"
                                message:@"If this Kaman has inappropriate content or contains commercial Ads, pressing OK will flag it for removal and our team will take appropriate action. The Kaman will immediately be hidden from your feed.Do you wish to proceed? " onButtonClicked:^(id result) {
                                     reloadOnViewDidAppear = true;
        NSNumber *b = result;
        if(b.intValue == 1) {
            PFObject *kamanFlag = [PFObject objectWithClassName:@"FlaggedKamans"];
            [kamanFlag setObject:[PFUser currentUser] forKey:@"FlaggedBy"];
            [kamanFlag setObject:kaman forKey:@"Kaman"];
            [kamanFlag setObject:[NSNumber numberWithBool:NO] forKey:@"Accepted"];
            [kamanFlag saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                
                if (error) {
                    [kamanFlag saveEventually];
                }
                
                [[PFUser currentUser] addUniqueObject:kaman.objectId forKey:@"ArchivedKamans"];
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if(error) {
                        [[PFUser currentUser] saveEventually];
                    }
                }];
                [self onDecline];
                
            }];
             
        }
        
    }];
}


#pragma mark collection view cell paddings
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 3.0;
}

#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
   // NSArray *collectionViewArray = self.colorArray[[(AFIndexedCollectionView *)collectionView indexPath].row];
    return self.attendees.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AttendeeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = MyBrownColor;
    cell.profileImageView.tag = indexPath.item;
    PFUser * attendee = [self.attendees objectAtIndex:indexPath.item];
    //NSArray *collectionViewArray = self.colorArray[[(AFIndexedCollectionView *)collectionView indexPath].row];
 
    [cell.friendShipLabel setText:[[PFUser currentUser].objectId isEqualToString:attendee.objectId] ? @"You" : [[PFUser currentUser] isFacebookFriendsWith:attendee] ? @"1st" : [self.friendsOfMyFbFriends containsObject:[attendee objectForKey:@"FBUserID"]] ? @"2nd" : @""];
    
    [cell.profileNameLabel setText:[NSString stringWithFormat:@"%@",[attendee displayName]]];
    [cell.profileNameLabel setTextColor:MyDarkGrayColor];
    [Utils setUIView:cell.profileImageView backgroundColor:MyGreyColor andRoundedByRadius:cell.profileImageView.frame.size.height/2 withBorderColor:[UIColor whiteColor]];
    
    UITapGestureRecognizer *singleProfileTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(attendeeImageTapped:)];
    singleProfileTap.numberOfTapsRequired = 1;
    [cell.profileImageView setUserInteractionEnabled:YES];
    [cell.profileImageView addGestureRecognizer:singleProfileTap];
    
    if([attendee profileImageURL]) {
        
        cell.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
        [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:[attendee profileImageURL]]
               placeholderImage:[UIImage imageNamed:@"person"]
                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                      }];
        
    }
    //cell  = collectionViewArray[indexPath.item];
    
    return cell;
}

#pragma mark - UIScrollViewDelegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![scrollView isKindOfClass:[UICollectionView class]]) return;
    
    CGFloat horizontalOffset = scrollView.contentOffset.x;
    
    UICollectionView *collectionView = (UICollectionView *)scrollView;
    NSInteger index = collectionView.tag;
    self.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
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
