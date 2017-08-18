//
//  EditAccountViewController.m
//  Kaman
//
//  Created by Moin' Victor on 22/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import "EditAccountViewController.h"
#import "Utils.h"
#import "ActionSheetPicker.h"

@interface EditAccountViewController ()

@end


@implementation EditAccountViewController

- (IBAction)exit:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)createGenderPickerWithInitial: (NSString*) gender {
    NSString *title = @"Gender";
    
    int initial = [gender isEqualToString:@"Male"] ? 0: 1;
    NSArray * genders = @[@"Male",@"Female"];
    
    ActionSheetStringPicker *genderPicker =  [ActionSheetStringPicker showPickerWithTitle:title rows:genders initialSelection:initial doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        PFUser *user = [PFUser currentUser];
        [user setObject: [genders objectAtIndex:selectedIndex] forKey:@"Gender"];
        
        [user saveEventually:^(BOOL succeeded, NSError *error) {
            if (!error) {
                NSLog(@"Saved Gender");
            }
            else{
                // Error
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        [self.genderTextfield setText:[genders objectAtIndex:selectedIndex]];

    } cancelBlock:^(ActionSheetStringPicker *picker) {
        
    } origin:self.view];
    
}

-(void) createDatePickerAndShowStartingFrom: (NSString*) date{
        
        NSDateFormatter * formatter = [Utils getDateFormatter_DD_MMMM_YYYY];
        
        NSString *title = @"Date Of Birth";
        
        ActionSheetDatePicker *datePicker =  [ActionSheetDatePicker showPickerWithTitle:title datePickerMode:UIDatePickerModeDate selectedDate:date == nil? [NSDate date] : [formatter dateFromString:date] minimumDate:nil maximumDate:[NSDate date] doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
            NSDate *selectDate = selectedDate;
            [self.dobTextfield setText:[formatter stringFromDate:selectDate]];
            PFUser *user = [PFUser currentUser];
            [user setObject: selectedDate forKey:@"DateOfBirth"];
            
            [user saveEventually:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"Saved date of birth");
                }
                else{
                    // Error
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
            

            
        } cancelBlock:^(ActionSheetDatePicker *picker) {
            
        } origin:self.view];
        
        [datePicker setTapDismissAction:TapActionCancel];
        [datePicker setMinimumDate:[NSDate date]];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if(textField == self.dobTextfield) {
        [self hideKeyboard];
        [self createDatePickerAndShowStartingFrom:[self.dobTextfield hasText] ? [self.dobTextfield text] : nil];
        return NO;
    } else if(textField == self.genderTextfield) {
         [self hideKeyboard];
        [self createGenderPickerWithInitial:[self.genderTextfield hasText] ? [self.genderTextfield text] : nil];
        return NO;
    } /*else {
        activeField = textField;
        if(textField == self.nameTextField) {
            return YES;
        }
        [self animateTextField: textField up: YES];
    }*/
    
    return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField == self.nameTextfield) {
        PFUser *user = [PFUser currentUser];
        [user setObject: [textField hasText] ? [textField text] : [NSNull null] forKey:@"CustomProfileName"];
        
        [user saveEventually:^(BOOL succeeded, NSError *error) {
            if (!error) {
                NSLog(@"Saved profile name");
            }
            else{
                // Error
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];

        
        return;
    }
    
   // [self animateTextField: textField up: NO];
}

-(void)hideKeyboard
{
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
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
 
 [super touchesBegan:touches withEvent:event];
 [self hideKeyboard];
 
 }
 

-(IBAction)onAddOrEditImage:(id)sender
{
    
    UIButton *button = sender;
    
    UIImagePickerController *pickerLibrary = [[UIImagePickerController alloc] init];
    pickerLibrary.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerLibrary.delegate = self;
    pickerLibrary.view.tag = button.tag;
    UIAlertController * view=   [UIAlertController
                                 alertControllerWithTitle:@"Profile Image"
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


-(void) asyncUploadKamanImagefromImageView: (UIImageView*) imageView forUser: (PFUser*) user afterButton :(UIButton*) button
{
    
    if(!imageView.image) {
        return;
    }
    NSData* data = UIImageJPEGRepresentation(imageView.image, 0.5f);
    PFFile *imageFile = [PFFile fileWithName:[NSString stringWithFormat: @"Profile_image_%ld_%f.jpg", (long)imageView.tag,[[NSDate date] timeIntervalSince1970]] data: data];
    
    [button setImage:nil forState:UIControlStateNormal];
    [button setTintColor:MyGreyColor];
    [button setTitle:@"↑ 0%" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithPatternImage:imageView.image];
    button.alpha = 0.5;
    
    // Save the image to Parse
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error) {
            
            NSLog(@"Saved image %@",imageFile.url);
            if(user) {
                [user setObject:imageFile.url forKey:@"CustomProfileImage"];
                
                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        NSLog(@"Saved");
                    }
                    else{
                        // Error
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                    }
                }];
            }
            
            
        }
        [button setImage:[UIImage imageNamed:@"insert-image"] forState:UIControlStateNormal];
        [button setTitle:nil forState:UIControlStateNormal];
        button.backgroundColor = [UIColor clearColor];
        
        
    } progressBlock:^(int percentDone) {
        NSLog(@"Uploading image %d%%",percentDone);
        [button setTitle:[NSString stringWithFormat: @"↑ %d%%",percentDone ] forState:UIControlStateNormal];
        [button setImage:nil forState:UIControlStateNormal];
        if(100 == percentDone) {
            [button setImage:[UIImage imageNamed:@"insert-image"] forState:UIControlStateNormal];
            [button setTitle:nil forState:UIControlStateNormal];
            button.backgroundColor = [UIColor clearColor];
            
        }
    }];
    
    
}


- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    UIImage *myImage = image;
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [self.profileImageView setImage:myImage];
     [self asyncUploadKamanImagefromImageView:self.profileImageView forUser:[PFUser currentUser] afterButton:self.chooseImageButton];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Edit Account"];
    
    [self.navigationController.navigationBar setBarTintColor:
     [UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:MyOrangeColor}];
    [self.navigationController.navigationItem.leftBarButtonItem setTintColor:MyOrangeColor];
    self.view.backgroundColor = MyBrownColor;

    [Utils postfixImageNamed:@"calendar" toTextField:self.dobTextfield];
    
    [Utils setUIView:self.changeImageButton backgroundColor:MyGreyColor andRoundedByRadius:5 withBorderColor:[UIColor blackColor]];
    
    [Utils setUIView:self.profileImageView backgroundColor:[UIColor whiteColor] andRoundedByRadius:3  withBorderColor: nil];
    
    if([[PFUser currentUser] profileImageURL]) {
        
        [self.profileImageView  sd_setImageWithURL:[NSURL URLWithString:[[PFUser currentUser] profileImageURL]]
                                  placeholderImage:[UIImage imageNamed:@"person"]
                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                             
                                             
                                         }];
    } else {
        [self.profileImageView setImage:[UIImage imageNamed:@"person"]];
    }
    

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSString *name = [[PFUser currentUser] objectForKey:@"CustomProfileName"];
    if([name isEqual:[NSNull null]] || name == nil) {
        name = [[PFUser currentUser] objectForKey:@"SocialProfileName"];
    }
    [self.nameTextfield setText:name];
    
    NSString *gender = [[PFUser currentUser] objectForKey:@"Gender"];
    [self.genderTextfield setText:gender];

    NSDate *dob = [[PFUser currentUser] objectForKey:@"DateOfBirth"];
    if(dob) {
        [self.dobTextfield setText:[[Utils getDateFormatter_DD_MMMM_YYYY] stringFromDate:dob]];
    }
    
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
