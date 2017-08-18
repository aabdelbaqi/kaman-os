//
//  KamanDetailsViewController.h
//  Kaman
//
//  Created by Moin' Victor on 27/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utils.h"
#import "NYTPhoto.h"

#define TABLE_SIZE_BASIC 2
#define TABLE_SIZE_DETAILS 10

@interface KamanPhoto: NSObject <NYTPhoto>
@property UIImage *photo, *placeHolderPhoto;
@property NSString *title;
-(instancetype) initWithTitle: (NSString*) title photo:(UIImage*) photo placeHolder: (UIImage*) placeholder;
@end


@interface KamanDetailsViewController : UITableViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property BOOL showAddress;
@property NSMutableDictionary *kamanPhotosDict;
@property NSMutableArray *kamanImages, *kamanImageUrls;
@property NSInteger tableSize;
@property NSMutableDictionary *maleAttendees,*femaleAttendees;
@property NSMutableArray *attendees, *friendsOfMyFbFriends;
@property NSMutableArray *kamans;
@property NSString * customTitle;
@property BOOL showButtons;
@property BOOL headerPannable;

-(void) onKamanPictureClicked;
-(void) onViewDetailsClicked;

-(void) onAccept;


-(void) onDecline;

@end
