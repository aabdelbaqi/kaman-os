//
//  HostKamanViewController.m
//  Kaman
//
//  Created by Moin' Victor on 12/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import "HostKamanViewController.h"
#import "Utils.h"
#import "ActionSheetPicker.h"
#import "Session.h"
#import "AutocompletionTableView.h"
#import "InviteFriendsViewController.h"

@interface HostKamanViewController ()
@property (nonatomic, strong) AutocompletionTableView *autoCompleter;

@end
UITapGestureRecognizer *singleTap;

UITextField * activeField;
NSMutableArray *kamanPhotos;
CGFloat originalHeight;
PFObject *kamanArea;
BOOL savingKaman;
@implementation HostKamanViewController{
     GMSPlacesClient *_placesClient;
}
@synthesize autoCompleter = _autoCompleter;

- (IBAction)exit:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)submitClicked:(id)sender {
    
    if([self.nameTextField validate] && [self.dateTextField validate]
       && [self.timeTextField validate] && [self.areaTextField validate]
       && [self.addressTextField validate]) {
        
        if(![self.descTextView hasText]) {
            [Utils showMessageHUDInView:self.view withMessage:@"Enter Kaman Description" afterError:YES];
            [self.descTextView becomeFirstResponder];
            return;
        }
        
        if(!kamanPhotos || [kamanPhotos count] <=1 ) {
            [Utils showMessageHUDInView:self.view withMessage:@"Please upload at least 2 photos for this Kaman" afterError:YES];
            [self populateImages];
            return;
        }
        
        if(!kamanArea) {
            [Utils showMessageHUDInView:self.view withMessage:@"Please select nearest place around you from the drop down" afterError:YES];
            [self.areaTextField becomeFirstResponder];
            
        } else {
          //  [HUD dismissAnimated:YES];
            [self saveKamanInLocalArea];
        }
        
        
    }
    
}

-(void) saveKamanInLocalArea
{
    if(savingKaman) {
        return;
    }
    savingKaman = true;
    JGProgressHUD *HUD = [Utils showProgressDialogInView:self.view withMessage:@"Saving..."];
    NSDate *date = [Utils combineDate:[[Utils getDateFormatter_DD_MMMM_YYYY] dateFromString:self.dateTextField.text] withTime:[[Utils getTimeFormatter_H_MM_AMPM] dateFromString:self.timeTextField.text]];
        
        PFObject *kaman = self.kaman == nil? [PFObject objectWithClassName:@"Kaman"] : self.kaman;
        kaman[@"Name"] = self.nameTextField.text;
        kaman[@"Description"] = self.descTextView.text;
        kaman[@"Address"] = self.addressTextField.text;
        kaman[@"Area"] = kamanArea;
        kaman[@"Host"] = [PFUser currentUser];
        kaman[@"DateTime"] = date;
        kaman[@"Archived"] = [NSNumber numberWithBool:NO];
    
        PFRelation *relation = [kaman relationForKey:@"Photos"];
        
        if(kamanPhotos) {
            for (PFObject *photo in kamanPhotos) {
                [relation addObject:photo];
            }

        }
        
        [kaman saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [HUD dismissAnimated:YES];
            savingKaman = false;
            if(succeeded) {
                if(self.kaman == nil) { // dont update counter on edited kamans
                    [[PFUser currentUser] addUniqueObjectsFromArray:[NSArray arrayWithObject:kaman.objectId] forKey:@"KamansHosted"];
                    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if(error) {
                            [[PFUser currentUser] saveEventually];
                            NSLog(@"Error saving user invited kaman: %@",error.localizedDescription);
                        }
                    }];

                }
                double delayInSeconds = 3;
                 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds *   NSEC_PER_SEC));
                 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    // [self.navigationController popViewControllerAnimated:YES];
                   
                     // Subscibe to this party for Group chat
                     NSString * channel = [NSString stringWithFormat:@"KAMAN-%@", kaman.objectId];
                     PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                     [currentInstallation addUniqueObject:channel forKey:@"channels"];
                     [currentInstallation saveInBackground];
                     
                     [self inviteFriends:kaman];
                     
                 });

                
            } else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
               
            }
        }];
}

-(void) asyncUploadKamanImagefromImageView: (UIImageView*) imageView forKaman: (PFObject*) kaman afterButton :(UIButton*) button
{
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.indicatorView = [[JGProgressHUDPieIndicatorView alloc] initWithHUDStyle:HUD.style]; //Or JGProgressHUDRingIndicatorView
    HUD.detailTextLabel.text = @"0% Complete";
    
    HUD.layoutChangeAnimationDuration = 0.0;
    
    HUD.textLabel.text = @"Uploading...";
    [HUD showInView:self.view];
  //  [HUD dismissAfterDelay:10.0];
  
    NSData* data = UIImageJPEGRepresentation(imageView.image, 0.5f);
    PFFile *imageFile = [PFFile fileWithName:[NSString stringWithFormat: @"Kaman_image_%ld_%f.jpg", (long)imageView.tag,[[NSDate date] timeIntervalSince1970]] data: data];
    
    [button setImage:nil forState:UIControlStateNormal];
    [button setTintColor:MyGreyColor];
    [button setTitle:@"↑ 0%" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithPatternImage:imageView.image];
    button.alpha = 0.5;
    
    NSInteger index = (imageView.tag - 1);
     // Save the image to Parse
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error) {
            PFRelation *relation = [self.kaman relationForKey:@"Photos"];
            
            PFObject *kPhoto = [PFObject objectWithClassName:@"KamanPhoto"];
            [kPhoto setObject:imageFile forKey:@"ImageFile"];
            [kPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(succeeded) {
                    @try
                    {
                        PFObject * kPhoto2 = [kamanPhotos objectAtIndex:index];
                        [kPhoto2 deleteInBackground];
                        [kamanPhotos replaceObjectAtIndex:index withObject:kPhoto];
                        if(self.kaman) {
                            [relation removeObject:kPhoto2];
                            [relation addObject:kPhoto];
                            [self.kaman saveInBackground];
                        }
                        
                        
                    }
                    @catch (NSException *exception)
                    {
                        // Print exception information
                        NSLog( @"Error: %@", exception.reason );
                        [kamanPhotos addObject:kPhoto];
                        if(self.kaman) {
                            [relation addObject:kPhoto];
                            [self.kaman saveInBackground];
                        }
                    }
                    [self populateImages];
                } else {
                    // Error
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                    imageView.image = nil;
                    [self dismissHUD:HUD withSuccess:NO message:[error localizedDescription]];
                    [self populateImages];
                }
            }];
            
        } else {
            imageView.image = nil;
            [self dismissHUD:HUD withSuccess:NO message:[error localizedDescription]];
            [self populateImages];
        }
        [button setImage:[UIImage imageNamed:@"insert-image"] forState:UIControlStateNormal];
        [button setTitle:nil forState:UIControlStateNormal];
        button.backgroundColor = [UIColor clearColor];
        

    } progressBlock:^(int percentDone) {
        [button setTitle:[NSString stringWithFormat: @"↑ %d%%",percentDone ] forState:UIControlStateNormal];
         [button setImage:nil forState:UIControlStateNormal];
        [HUD setProgress:percentDone/100.0f animated:NO];
        HUD.detailTextLabel.text = [NSString stringWithFormat:@"%i%% Complete", percentDone];
        if(100 == percentDone) {
            [button setImage:[UIImage imageNamed:@"insert-image"] forState:UIControlStateNormal];
            [button setTitle:nil forState:UIControlStateNormal];
            button.backgroundColor = [UIColor clearColor];
            [self dismissHUD:HUD withSuccess:YES message:@"Success"];
        }
    }];
}


-(void) dismissHUD:(JGProgressHUD*) HUD withSuccess: (BOOL) success message:(NSString*) msg
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        HUD.textLabel.text = msg;
        HUD.detailTextLabel.text = nil;
        
        HUD.layoutChangeAnimationDuration = 0.3;
        HUD.indicatorView = success ? [[JGProgressHUDSuccessIndicatorView alloc] init] : [[JGProgressHUDErrorIndicatorView alloc] init];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HUD dismiss];
    });

}

-(IBAction) inviteFriends: (PFObject*) kaman
{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    InviteFriendsViewController *someViewController = [storyboard instantiateViewControllerWithIdentifier:@"invite_friends"];
    someViewController.kaman = kaman;
    [self.navigationController pushViewController:someViewController animated:YES];
}

- (AutocompletionTableView *)autoCompleter
{
    if (!_autoCompleter)
    {
        NSMutableDictionary *options = [NSMutableDictionary dictionaryWithCapacity:2];
        [options setValue:[NSNumber numberWithBool:YES] forKey:ACOCaseSensitive];
        [options setValue:nil forKey:ACOUseSourceFont];
        
        _autoCompleter = [[AutocompletionTableView alloc] initWithTextField:self.areaTextField inViewController:self withOptions:options];
        _autoCompleter.autoCompleteDelegate = self;
        _autoCompleter.suggestionsDictionary = [NSArray arrayWithObjects:@"hostel",@"caret",@"carrot",@"house",@"horse", nil];
    }
    return _autoCompleter;
}


-(void)handleSingleTap:(UITapGestureRecognizer *)sender{
    [self hideKeyboard];
    
}

-(void) sendGoogleAnalyticsTrackScreen
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Host A Kaman screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self sendGoogleAnalyticsTrackScreen];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Host A Kaman"];
    
     [self.navigationController.navigationBar setBarTintColor:
     [UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:MyOrangeColor}];
    [self.navigationController.navigationItem.leftBarButtonItem setTintColor:MyOrangeColor];
    self.view.backgroundColor = MyBrownColor;
    self.scrollView.backgroundColor = MyBrownColor;
    self.contentView.backgroundColor = MyBrownColor;
   
    
    [self.areaTextField addTarget:self.autoCompleter action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [self.areaTextField setBorderStyle:UITextBorderStyleRoundedRect];
    
     [Utils styleButton:self.submitButton bgColor:MyOrangeColor highlightColor:MyGreyColor];
    
    [Utils setUIView:self.imageView1 backgroundColor:[UIColor whiteColor] andRoundedByRadius:3  withBorderColor: MyGreyColor];
    [Utils setUIView:self.imageView2 backgroundColor:[UIColor whiteColor] andRoundedByRadius:3  withBorderColor: MyGreyColor];
    [Utils setUIView:self.imageView3 backgroundColor:[UIColor whiteColor] andRoundedByRadius:3  withBorderColor: MyGreyColor];
    [Utils setUIView:self.imageView4 backgroundColor:[UIColor whiteColor] andRoundedByRadius:3 withBorderColor: MyGreyColor];
    
    self.dateTextField.delegate = self;
    self.timeTextField.delegate = self;
    
    [Utils prefixImageNamed:@"calendar" toTextField:self.dateTextField];
    [Utils prefixImageNamed:@"clock" toTextField:self.timeTextField];
    
    // Do any additional setup after loading the view.
    [Utils styleTextView:self.descTextView];
    
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleTap];
    
    CGRect frame =  self.descTextView.frame;
    self.descTextViewHeightConstraint.constant = frame.size.width * 0.50;
    
    frame = self.imageView1.frame;
    for (NSLayoutConstraint *lc in @[self.imageView1HeightConstraint,self.imageView2HeightConstraint,self.imageView3HeightConstraint,self.imageView4HeightConstraint]) {
        lc.constant = /*IS_IPHONE_5 || IS_IPHONE_6 ? 64.0 :*/ frame.size.width;
    }
    
    frame = self.contentView.frame;
    frame.size.height = frame.size.height + frame.size.width * 0.25;
    [self.contentView setFrame:frame];
    
    //[self.view setNeedsDisplay];
     _placesClient = [[GMSPlacesClient alloc] init];
    
    [self setUIValuesIfNecessary];
    
}

-(void) setUIValuesIfNecessary
{
    
    kamanPhotos = [NSMutableArray new];
    
    if(self.kaman) {
        [self.nameTextField setText:[self.kaman objectForKey:@"Name"]];
        
        [self.addressTextField setText:[self.kaman objectForKey:@"Address"]];

        PFRelation *relation = [self.kaman relationForKey:@"Photos"];
        kamanArea = [self.kaman objectForKey:@"Area"];
        PFUser *kamanHost = [self.kaman objectForKey:@"Host"];
        NSDate *kamanDateTime = [self.kaman objectForKey:@"DateTime"];
        PFGeoPoint *kamanGeoPoint =  [kamanArea objectForKey:@"LatLong"];
        
        [self.areaTextField setText:[kamanArea objectForKey:@"Name"]];
        
         NSDateFormatter * formatter = [Utils getDateFormatter_DD_MMMM_YYYY];
        [self.dateTextField setText:[formatter stringFromDate:kamanDateTime]];
        
        formatter = [Utils getTimeFormatter_H_MM_AMPM];
        [self.timeTextField setText:[formatter stringFromDate:kamanDateTime]];
        
        [self.descTextView setText:[self.kaman objectForKey:@"Description"]];
        // generate a query based on that relation
        PFQuery *query = [relation query];
        [query orderByAscending:@"index"];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if(!error) {
                NSLog(@"Found %lu photos for %@",[objects count],[self.kaman objectForKey:@"Name"]);
                [kamanPhotos addObjectsFromArray:objects];
                [self populateImages];
            } else {
                NSLog(@"Error fetching photos for %@: %@",[self.kaman objectForKey:@"Name"],error);
            }
        }];
        
    }

}

-(void) populateImages
{
    NSArray * imageViews = @[self.imageView1,self.imageView2,self.imageView3,self.imageView4];
    int x = 0;
    for (UIImageView *imgV in imageViews) {
       imgV.image = nil;
    }
    
    for (PFObject *photoObj in kamanPhotos) {
        if(x == 4) {
            break;
        }
        [photoObj setObject:[NSNumber numberWithInt:x+1] forKey:@"index"];
        [photoObj saveInBackground];
        
        PFFile *imageFile = [photoObj objectForKey:@"ImageFile"];
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                
                UIImageView *_imageview = [imageViews objectAtIndex:[kamanPhotos indexOfObject:photoObj]];
                _imageview.image = image;
                // image can now be set on a UIImageView
            } else {
                NSLog(@"Error downloading first photo for %@: %@",[self.kaman objectForKey:@"Name"],error);
            }
        }];
        x+=1;
    }
}

-(IBAction)removeImage:(id)sender
{
    UIButton *button = sender;
    
    if(kamanPhotos != nil) {
         @try
        {
             if(self.kaman) {
                PFRelation *relation = [self.kaman relationForKey:@"Photos"];
                PFObject * kPhoto = [kamanPhotos objectAtIndex:(button.tag - 1)];
                [kPhoto deleteInBackground];
                [relation removeObject:kPhoto];
                [self.kaman saveInBackground];
            }
        }
        @catch (NSException *exception)
        {
            // Print exception information
            NSLog( @"NSRangeException caught" );
            NSLog( @"Reason: %@", exception.reason );
        }
        
        @try
        {
            
            [kamanPhotos removeObjectAtIndex:(button.tag - 1)];
        
        }
        @catch (NSException *exception)
        {
            // Print exception information
            NSLog( @"NSRangeException caught" );
            NSLog( @"Reason: %@", exception.reason );
        }

        switch (button.tag) {
            case 1:
                [self.imageView1 setImage:nil];
                break;
            case 2:
                [self.imageView2 setImage:nil];
                break;
            case 3:
                [self.imageView3 setImage:nil];
                break;
            case 4:
                [self.imageView4 setImage:nil];
                break;
        }
        [self populateImages];
    }
}

-(IBAction)onAddOrEditImage:(id)sender
{
    
    UIButton *button = sender;
    
    UIImagePickerController *pickerLibrary = [[UIImagePickerController alloc] init];
    pickerLibrary.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerLibrary.delegate = self;
    pickerLibrary.view.tag = button.tag;
     UIAlertController * view=   [UIAlertController
                                 alertControllerWithTitle:@"Kaman Image"
                                 message:@"Choose existing photo or take a new photo"
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* photo = [UIAlertAction
                         actionWithTitle:@"Choose from Photos"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             //set controller to pick from photo library
                             [view dismissViewControllerAnimated:YES completion:nil];
                              pickerLibrary.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                             [self presentModalViewController:pickerLibrary animated:YES];
                             
                         }];
    UIAlertAction* camera = [UIAlertAction
                            actionWithTitle:@"Take Photo"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                                //set controller to pick from camera
                                [view dismissViewControllerAnimated:YES completion:nil];
                                pickerLibrary.sourceType = UIImagePickerControllerSourceTypeCamera;
                                pickerLibrary.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                                [pickerLibrary setShowsCameraControls:YES];
                                [pickerLibrary setAllowsEditing:YES];
                                
                                [self presentViewController:pickerLibrary animated:YES
                                                 completion:^ {
                                                    // [pickerLibrary takePicture];
                                                 }];
                                
                            }];

    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [view addAction:camera];
    [view addAction:photo];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    UIImage *myImage = image;
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    switch (picker.view.tag) {
        case 1:
            [self.imageView1 setImage:myImage];
            [self asyncUploadKamanImagefromImageView:self.imageView1 forKaman:nil afterButton:self.imageSetButton1];
            break;
        case 2:
            [self.imageView2 setImage:myImage];
             [self asyncUploadKamanImagefromImageView:self.imageView2 forKaman:nil afterButton:self.imageSetButton2];
            break;
        case 3:
            [self.imageView3 setImage:myImage];
             [self asyncUploadKamanImagefromImageView:self.imageView3 forKaman:nil afterButton:self.imageSetButton3];
            break;
        case 4:
            [self.imageView4 setImage:myImage];
             [self asyncUploadKamanImagefromImageView:self.imageView4 forKaman:nil  afterButton:self.imageSetButton4];
            break;
        default:
            break;
    }
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    originalHeight = self.view.frame.size.height;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITextField Delegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if(textField == self.dateTextField) {
         [self hideKeyboard];
        [self createDatePickerAndShowStartingFrom:[self.dateTextField hasText] ? [self.dateTextField text] : nil];
        return NO;
    } else if(textField == self.timeTextField) {
         [self hideKeyboard];
        [self createTimePickerAndShowStartingFrom:[self.timeTextField hasText] ? [self.timeTextField text] : nil];
        return NO;
    } else {
        activeField = textField;
        if(textField == self.nameTextField) {
            return YES;
        }
        [self animateTextField: textField up: YES];
    }

    return YES;
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    int areaOffset = self.areaTextField.frame.origin.y  - self.nameTextField.frame.origin.y;
    int addressOffset = self.addressTextField.frame.origin.y  - self.descTextView.frame.origin.y;
    const int movementDistance = textField == self.areaTextField ? areaOffset
    
    : textField == self.addressTextField ? addressOffset : 200;
    
    if(up) {
        CGRect frame  = self.view.frame;
        frame.size.height = originalHeight + movementDistance + 200;
        [self.view setFrame:frame];
       if(self.areaTextField == textField) {
           [self.autoCompleter updateFrameAroundTextField:self.areaTextField inViewController:self];
           [self.view removeGestureRecognizer:singleTap];
        }
        [self.scrollView setContentOffset:
         CGPointMake(0, -self.scrollView.contentInset.top) animated:NO];
     
   } else {
       CGRect frame  = self.view.frame;
       frame.size.height = originalHeight;
       [self.view setFrame:frame];
       if(self.areaTextField == textField) {
           [self.view addGestureRecognizer:singleTap];
           [self.autoCompleter updateFrameAroundTextField:self.areaTextField inViewController:self];
       }

   }
    
    // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
   
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
    
    }


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField == self.nameTextField) {
        return;
    }

    [self animateTextField: textField up: NO];
}


-(void) createDatePickerAndShowStartingFrom: (NSString*) date{
    
    NSDateFormatter * formatter = [Utils getDateFormatter_DD_MMMM_YYYY];
    
    NSString *title = @"Kaman Date";
    
    ActionSheetDatePicker *datePicker =  [ActionSheetDatePicker showPickerWithTitle:title datePickerMode:UIDatePickerModeDate selectedDate:date == nil? [NSDate date] : [formatter dateFromString:date] minimumDate:[NSDate date] maximumDate:nil doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
       NSDate *selectDate = selectedDate;
       [self.dateTextField setText:[formatter stringFromDate:selectDate]];
       
    } cancelBlock:^(ActionSheetDatePicker *picker) {
        
    } origin:self.view];
    
    [datePicker setTapDismissAction:TapActionCancel];
}

-(void) createTimePickerAndShowStartingFrom: (NSString*) date{
    
    NSString *title = @"Kaman Time";
    
     NSDateFormatter * formatter = [Utils getTimeFormatter_H_MM_AMPM];
    
    
    ActionSheetDatePicker *timePicker =  [ActionSheetDatePicker showPickerWithTitle:title datePickerMode:UIDatePickerModeTime selectedDate:date == nil? [NSDate date] : [formatter dateFromString:date] doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
        NSDate *selectDate = selectedDate;
        [self.timeTextField setText:[formatter stringFromDate:selectDate]];
        
    } cancelBlock:^(ActionSheetDatePicker *picker) {
        
    } origin:self.view];
    
    [timePicker setMinuteInterval:15];
    [timePicker setTapDismissAction:TapActionCancel];
    [timePicker setMinimumDate:[NSDate date]];
    
}



-(void)hideKeyboard
{
    if(activeField != nil) {
        [activeField resignFirstResponder];
    }
    NSArray *subviews = [self.view subviews];
    for (id objects in subviews) {
        if ([objects isKindOfClass:[UITextField class]]) {
            UITextField *theTextField = objects;
            if ([objects isFirstResponder]) {
                [theTextField resignFirstResponder];
            }
        }
        if ([objects isKindOfClass:[UITextView class]]) {
            UITextView *theTextField = objects;
            if ([objects isFirstResponder]) {
                [theTextField resignFirstResponder];
            }
        }

    }
    [self.scrollView setContentOffset:
     CGPointMake(0, -self.scrollView.contentInset.top) animated:YES];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesBegan:touches withEvent:event];
  //  if(activeField != self.areaTextField)
    //    [self hideKeyboard];
    
}


#pragma mark - AutoCompleteTableViewDelegate

-(void)autoCompletion:(AutocompletionTableView *)completer didSelectAutoCompleteSuggestion:(GMSAutocompletePrediction *)prediction WithIndex:(NSInteger)index
{
    // invoked when an available suggestion is selected
    kamanArea = nil;
    [self.areaTextField setText:[prediction.attributedPrimaryText string]];
    [_placesClient lookUpPlaceID:prediction.placeID callback:^(GMSPlace *place, NSError *error) {
        if (error != nil) {
            NSLog(@"Place Details error %@", [error localizedDescription]);
            return;
        }
        
        if (place != nil) {
            NSLog(@"Place name %@", place.name);
            NSLog(@"Place address %@", place.formattedAddress);
            NSLog(@"Place placeID %@", place.placeID);
            NSLog(@"Place attributions %@", place.attributions);
            
            [Utils parseSmartStoreKamanArea:place.name fromCountry:currentLocality.countryName andCountryCode:currentLocality.countryCode withLocationLat:place.coordinate.latitude locationLon:place.coordinate.longitude onSuccess:^(id result) {
                kamanArea =  result;
                [self.areaTextField setText:place.name];
                
        
            } onError:^(NSError *error) {
                NSLog(@"Error: %@",error.localizedDescription);
            }];
        } else {
            NSLog(@"No place details for %@", prediction.placeID);
        }
    }];
    [self.view addGestureRecognizer:singleTap];
    [self hideKeyboard];
   // [self animateTextField:self.areaTextField up:NO];
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
