//
//  NotificationsViewController.h
//  Kaman
//
//  Created by Moin' Victor on 23/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//


#import "MessagesViewController.h"
#import "Session.h"
#import "LocalNotif.h"
#import <DateTools/DateTools.h>

@implementation MessagesViewController

NSTimer *timer;
BOOL isLoading;
BOOL initialized;
NSMutableArray * locationsToLoad;
GMSPlacePicker * _placePicker;
UITapGestureRecognizer *mysingleTap;

- (IBAction)exit:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - View lifecycle


-(void)myhandleSingleTap:(UITapGestureRecognizer *)sender{
    [self hideKeyboard];
    
}

/**
 *  Override point for customization.
 *
 *  Customize your view.
 *  Look at the properties on `JSQMessagesViewController` and `JSQMessagesCollectionView` to see what is possible.
 *
 *  Customize your layout.
 *  Look at the properties on `JSQMessagesCollectionViewFlowLayout` to see what is possible.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBarTintColor:
     [UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:MyOrangeColor}];
    [self.navigationController.navigationItem.leftBarButtonItem setTintColor:MyOrangeColor];
    self.view.backgroundColor = MyBrownColor;
    
    mysingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myhandleSingleTap:)];
    [self.view addGestureRecognizer:mysingleTap];

    /**
     *  You MUST set your senderId and display name
     */
    self.senderId = [PFUser currentUser].objectId;
    self.senderDisplayName = [[PFUser currentUser] displayName];
    
    if(!self.messages ) {
        self.messages = [NSMutableArray new];
    }
    
    if(!self.users) {
        self.users = [NSMutableDictionary new];
    }
    [self.users setObject:[PFUser currentUser] forKey:self.senderId];
    
    
    if(self.isGroupChat) {
        [self searchAll];
    }
    
    if(!self.avatars) {
        self.avatars = [NSMutableDictionary new];
    }
   
    locationsToLoad = [NSMutableArray new];
    
    if([[PFUser currentUser] profileImageURL]) {
        [self loadAvatar:[PFUser currentUser]];
    }
    self.inputToolbar.contentView.textView.pasteDelegate = self;
    if(self.isGroupChat) {
        [Utils setTitle:[self.kaman objectForKey:@"Name"] withColor:MyOrangeColor andSubTitle:self.senderDisplayName withColor:MyOrangeColor onNavigationController:self];
    } else {
        for (PFUser * other in [self.users allValues]) {
            if(![other.objectId isEqualToString:self.senderId]) {
                [Utils setTitle:[other displayName] withColor:MyOrangeColor andSubTitle:[self.kaman objectForKey:@"Name"] withColor:MyOrangeColor onNavigationController:self];
                break;
            }
        }
    }
    
    /**
     *  You can set custom avatar sizes
     *
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    */
    
    /**
     *  Create message bubble images objects.
     *
     *  Be sure to create your bubble images one time and reuse them for good performance.
     *
     */
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:DesignersBrownColor];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:MyOutgoingChatBg];
    
   // self.showLoadEarlierMessagesHeader = YES;
    
    /*
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage jsq_defaultTypingIndicatorImage]
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(receiveMessagePressed:)];
     */
    
    /**
     *  Register custom menu actions for cells.
     */
    [JSQMessagesCollectionViewCell registerMenuAction:@selector(customAction:)];
    [UIMenuController sharedMenuController].menuItems = @[ [[UIMenuItem alloc] initWithTitle:@"Custom Action"
                                                                                      action:@selector(customAction:)] ];

    /**
     *  OPT-IN: allow cells to be deleted
     */
    [JSQMessagesCollectionViewCell registerMenuAction:@selector(delete:)];

    /**
     *  Customize your toolbar buttons
     *
     *  self.inputToolbar.contentView.leftBarButtonItem = custom button or nil to remove
     *  self.inputToolbar.contentView.rightBarButtonItem = custom button or nil to remove
     */

    /**
     *  Set a maximum height for the input toolbar
     *
     *  self.inputToolbar.maximumHeight = 150;
     */
    
    NSDate * kamanDate = [self.kaman objectForKey:@"DateTime"];
    if([kamanDate isEarlierThan:[NSDate date]]) {
        self.inputToolbar.contentView.leftBarButtonItem = nil;
        self.inputToolbar.contentView.rightBarButtonItem = nil;
        self.inputToolbar.contentView.textView.hidden = YES;
        [TSMessage showNotificationInViewController:self title:@"Kaman Out-Dated" subtitle:@"You can no longer reply or send text regarding this Kaman since its out dated." type:TSMessageNotificationTypeWarning];

    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    isLoading = NO;
    initialized = NO;
    [self loadMessages];
}

-(void) sendGoogleAnalyticsTrackScreen
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value: self.isGroupChat ? @"Group messages" : @"Private messages"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self sendGoogleAnalyticsTrackScreen];
    
    if (self.delegateModal) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                              target:self
                                                                                              action:@selector(closePressed:)];
    }
}

-(void)hideKeyboard
{
    
    [self.inputToolbar.contentView.textView resignFirstResponder];
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


-(void)searchAll
{
    [self searchKamanInvitedAttendees];
    [self searchKamanRequestedAttendees];
}

-(void)searchKamanRequestedAttendees
{
    PFRelation *relation = [self.kaman relationForKey:@"Requests"];
    
    // generate a query based on that relation
    PFQuery *query = [relation query];
    [query includeKey:@"RequestingUser"];
    [query whereKey:@"RequestingUser" notEqualTo:[PFUser currentUser]];
    [query whereKey:@"Accepted" equalTo:[NSNumber numberWithBool:YES]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error) {
            for (PFObject * obj in objects) {
                PFUser * user = [obj objectForKey:@"RequestingUser"];
                if(![[self.users allKeys] containsObject:user.objectId]) {
                    [self.users setObject:user forKey:user.objectId];
                }            }
            
        }
    }];
}

-(void)searchKamanInvitedAttendees
{
    PFRelation *relation = [self.kaman relationForKey:@"Invitations"];
    
    // generate a query based on that relation
    PFQuery *query = [relation query];
    [query includeKey:@"InvitedUser"];
    [query whereKey:@"InvitedUser" notEqualTo:[PFUser currentUser]];
    [query whereKey:@"Accepted" equalTo:[NSNumber numberWithBool:YES]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error) {
            for (PFObject * obj in objects) {
                PFUser * user = [obj objectForKey:@"InvitedUser"];
                if(![[self.users allKeys] containsObject:user.objectId]) {
                    [self.users setObject:user forKey:user.objectId];
                }
                
            }
        }
    }];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesBegan:touches withEvent:event];
    [self hideKeyboard];
    
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
    - (void)viewDidAppear:(BOOL)animated
    //-------------------------------------------------------------------------------------------------------------------------------------------------
    {
        [super viewDidAppear:animated];
        /**
         *  Enable/disable springy bubbles, default is NO.
         *  You must set this from `viewDidAppear:`
         *  Note: this feature is mostly stable, but still experimental
         */
        self.collectionView.collectionViewLayout.springinessEnabled = NO;
        timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loadMessages) userInfo:nil repeats:YES];
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------------
    - (void)viewWillDisappear:(BOOL)animated
    //-------------------------------------------------------------------------------------------------------------------------------------------------
    {
        [super viewWillDisappear:animated];
        [timer invalidate];
    }


- (void)closePressed:(UIBarButtonItem *)sender
{
    [self.delegateModal didDismissJSQDemoViewController:self];
}




#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    [self sendMessage:text Location:nil Picture:nil];
    
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    [self hideKeyboard];
    PFUser *host = [self.kaman objectForKey:@"Host"];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Media messages"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Send Location",nil];
    if([host.objectId isEqualToString:[PFUser currentUser].objectId]) {
         [sheet showFromToolbar:self.inputToolbar];
    }
   
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    switch (buttonIndex) {
        case 0:
            [self pickLocation];
            break;
            
        case 1:
        
           // __weak UICollectionView *weakView = self.collectionView;
          
        break;
        }
 
}



-(void) pickLocation
{
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(currentLocality.lat , currentLocality.lon);
    CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001);
    CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001);
    GMSCoordinateBounds *viewport = [[GMSCoordinateBounds alloc] initWithCoordinate:northEast
                                                                         coordinate:southWest];
    GMSPlacePickerConfig *config = [[GMSPlacePickerConfig alloc] initWithViewport:viewport];
    _placePicker = [[GMSPlacePicker alloc] initWithConfig:config];
    
    [_placePicker pickPlaceWithCallback:^(GMSPlace *place, NSError *error) {
        if (error != nil) {
            NSLog(@"Pick Place error %@", [error localizedDescription]);
            return;
        }
        
        if (place != nil) {
            NSLog(@"Place name %@", place.name);
            NSLog(@"Place address %@", place.formattedAddress);
            NSLog(@"Place attributions %@", place.attributions.string);
            [self sendMessage:place.name Location:[PFGeoPoint geoPointWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude] Picture:nil];
        } else {
            NSLog(@"No place selected");
        }
    }];
}



#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.item];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath
{
    [self.messages removeObjectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageData;
    }
    
    return self.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    /*if ([message.senderId isEqualToString:self.senderId]) {
        if (![NSUserDefaults outgoingAvatarSetting]) {
            return nil;
        }
    }
    else {
        if (![NSUserDefaults incomingAvatarSetting]) {
            return nil;
        }
    }*/
    
    
    return [self.avatars objectForKey:message.senderId];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    } else {
        if ([[msg.media class] isSubclassOfClass:[JSQLocationMediaItem class]]) {
            JSQLocationMediaItem *mediaLoc = (JSQLocationMediaItem*)msg.media;
            if([mediaLoc mediaView]) {
                [locationsToLoad removeObject:mediaLoc];
            }

        }
    }
    
    return cell;
}



#pragma mark - UICollectionView Delegate

#pragma mark - Custom menu items

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(customAction:)) {
        return YES;
    }

    return [super collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(customAction:)) {
        [self customAction:sender];
        return;
    }

    [super collectionView:collectionView performAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)customAction:(id)sender
{
    NSLog(@"Custom action received! Sender: %@", sender);

    [[[UIAlertView alloc] initWithTitle:@"Custom Action"
                               message:nil
                              delegate:nil
                     cancelButtonTitle:@"OK"
                      otherButtonTitles:nil]
     show];
}



#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *currentMessage = [self.messages objectAtIndex:indexPath.item];
    if(currentMessage.isMediaMessage && [[currentMessage.media class] isSubclassOfClass:[JSQLocationMediaItem class]]) {
        JSQLocationMediaItem *mediaLoc = (JSQLocationMediaItem*)currentMessage.media;
       if ([[UIApplication sharedApplication] canOpenURL:
             [NSURL URLWithString:@"comgooglemaps://"]]) {
            [[UIApplication sharedApplication] openURL:
             [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?q=%.6f,%.6f&center=%.6f,%.6f&zoom=15&views=traffic", mediaLoc.location.coordinate.latitude , mediaLoc.location.coordinate.longitude, mediaLoc.location.coordinate.latitude, mediaLoc.location.coordinate.longitude]]];
        } else {
            [[UIApplication sharedApplication] openURL:
             [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.google.com/maps?&z=15&q=%.6f+%.6f&ll=%.6f+%.6f", mediaLoc.location.coordinate.latitude , mediaLoc.location.coordinate.longitude, mediaLoc.location.coordinate.latitude, mediaLoc.location.coordinate.longitude]]];
        }
        
       /* // DOES NOT DISPLAY MARKER
        NSString *latlong = [NSString
        stringWithFormat: @"%f,%f",mediaLoc.location.coordinate.latitude,mediaLoc.location.coordinate.longitude];
        
        NSString *url = [NSString
                         stringWithFormat: @"comgooglemaps://?center=%@&zoom=15&views=traffic",
                         [latlong stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURL *locUrl = [NSURL URLWithString:url];
        if([[UIApplication sharedApplication] canOpenURL:locUrl]) {
            [[UIApplication sharedApplication] openURL: locUrl];
        } else {
            [[[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:mediaLoc.location.coordinate addressDictionary:nil]] openInMapsWithLaunchOptions:nil];
        } */
    }
    
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

#pragma mark - JSQMessagesComposerTextViewPasteDelegate methods


- (BOOL)composerTextView:(JSQMessagesComposerTextView *)textView shouldPasteWithSender:(id)sender
{
    if ([UIPasteboard generalPasteboard].image) {
        // If there's an image in the pasteboard, construct a media item with that image and `send` it.
        JSQPhotoMediaItem *item = [[JSQPhotoMediaItem alloc] initWithImage:[UIPasteboard generalPasteboard].image];
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:self.senderId
                                                 senderDisplayName:self.senderDisplayName
                                                              date:[NSDate date]
                                                             media:item];
        [self.messages addObject:message];
        [self finishSendingMessage];
        return NO;
    }
    return YES;
}

#pragma mark - Backend methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadMessages
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if([locationsToLoad count] > 0) {
        [self.collectionView reloadData];
    }
    
    if (isLoading == NO)
    {
        isLoading = YES;
        JSQMessage *message_last = [self.messages lastObject];
        
        PFQuery *query = [PFQuery queryWithClassName:@"KamanChat"];
        PFUser *recipient = nil;
        
        if(self.isGroupChat == NO) {
            // Find recipient, this is the other user if this is not a group chat
            if(!self.isGroupChat) {
                for (PFUser * usr in [self.users allValues]) {
                    if(![usr.objectId isEqualToString:self.senderId]) {
                        recipient = usr;
                        break;
                    }
                }
            }

            // from me to recipient
            PFQuery *fromQuery = [PFQuery queryWithClassName:@"KamanChat"];
            [fromQuery whereKey:@"Sender" equalTo:[PFUser currentUser]];
            [fromQuery whereKey:@"Recipient" equalTo:recipient];
            
            // from recipient to me
            PFQuery *toQuery = [PFQuery queryWithClassName:@"KamanChat"];
            [toQuery whereKey:@"Recipient" equalTo:[PFUser currentUser]];
            [toQuery whereKey:@"Sender" equalTo:recipient];
            // now OR the two queries above to get the list of people the user has chat with
            query = [PFQuery orQueryWithSubqueries:@[fromQuery, toQuery]];
        
        }
        [query whereKey:@"Kaman" equalTo:self.kaman];
        if (message_last != nil)
            [query whereKey:@"createdAt" greaterThan:message_last.date];
        [query whereKey:@"IsGroupChat" equalTo:[NSNumber numberWithBool:self.isGroupChat]];
        [query includeKey:@"Sender"];
        [query includeKey:@"Recipient"];
        [query orderByDescending:@"createdAt"];
        [query setLimit:50];

        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil)
             {
                 BOOL incoming = NO;
                 self.automaticallyScrollsToMostRecentMessage = NO;
                 for (PFObject *object in [objects reverseObjectEnumerator])
                 {
                     JSQMessage *message = [self addMessage:object];
                     if ([self incoming:message]) incoming = YES;
                 }
                 if ([objects count] != 0)
                 {
                     if (initialized && incoming)
                         [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
                     [self finishReceivingMessage];
                     [self scrollToBottomAnimated:NO];
                 }
                 self.automaticallyScrollsToMostRecentMessage = YES;
                 initialized = YES;
                 if(self.isGroupChat) {
                      [Utils deleteNotifsWithQuery:[NSString stringWithFormat: @"kamanId = '%@' AND type = '%@'",self.kaman.objectId,PUSH_TYPE_GROUP_MESSAGE]];
                 } else {
                     [Utils deleteNotifsWithQuery:[NSString stringWithFormat: @"kamanId = '%@' AND type = '%@' AND senderId = '%@'",self.kaman.objectId,PUSH_TYPE_CHAT_MESSAGE, recipient.objectId]];
                 }
             }
             else
                 [Utils showMessageHUDInView:self.view withMessage:[NSString stringWithFormat: @"Network error: %@",error.localizedDescription] afterError:YES];
             isLoading = NO;
         }];
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (JSQMessage *)addMessage:(PFObject *)object
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    JSQMessage *message;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    PFUser *user = object[@"Sender"];
    PFUser *rec_user = object[@"Recipient"];
    NSString *name = [user displayName];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    PFGeoPoint *fileLocation = object[@"LocationAttachment"];
    PFFile *filePicture = object[@"ImageAttachment"];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if ((filePicture == nil) && (fileLocation == nil))
    {
        message = [[JSQMessage alloc] initWithSenderId:user.objectId senderDisplayName:name date:object.createdAt text:object[@"Text"]];
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if (fileLocation != nil)
    {
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:fileLocation.latitude longitude:fileLocation.longitude];
        JSQLocationMediaItem *mediaItem = [[JSQLocationMediaItem alloc] initWithLocation:loc];
        mediaItem.appliesMediaViewMaskAsOutgoing = [user.objectId isEqualToString:self.senderId];
        [mediaItem mediaView];
        [locationsToLoad addObject:mediaItem];
        message = [[JSQMessage alloc] initWithSenderId:user.objectId senderDisplayName:name date:object.createdAt media:mediaItem];
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if (filePicture != nil)
    {
        JSQPhotoMediaItem *mediaItem = [[JSQPhotoMediaItem alloc] initWithImage:nil];
        mediaItem.appliesMediaViewMaskAsOutgoing = [user.objectId isEqualToString:self.senderId];
        message = [[JSQMessage alloc] initWithSenderId:user.objectId senderDisplayName:name date:object.createdAt media:mediaItem];
        //-----------------------------------------------------------------------------------------------------------------------------------------
        [filePicture getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
         {
             if (error == nil)
             {
                 mediaItem.image = [UIImage imageWithData:imageData];
                 [self.collectionView reloadData];
             }
         }];
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
        if(rec_user != nil) {
            [self loadAvatar:rec_user];
             [self.users setObject:rec_user forKey:rec_user.objectId];
        }
    [self loadAvatar:user];
    [self.users setObject:user forKey:user.objectId];
    [self.messages addObject:message];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    return message;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadAvatar:(PFUser *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [self.avatars setObject:[JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"person"]
                                                                       diameter:72.0]forKey:user.objectId];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSURL *imageURL = [NSURL URLWithString:[user profileImageURL]];
                       NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                       
                       //This is your completion handler
                       dispatch_sync(dispatch_get_main_queue(), ^{
                           //If self.image is atomic (not declared with nonatomic)
                           // you could have set it directly above
                           UIImage *image = [UIImage imageWithData:imageData];
                           JSQMessagesAvatarImage *wozImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:image
                                                                                                         diameter:72.0];
                           
                           [self.avatars setObject:wozImage forKey:user.objectId];
                           [self.collectionView reloadData];
                       });
                   });

    }

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendMessage:(NSString *)text Location:(PFGeoPoint *)location Picture:(UIImage *)picture
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    PFFile *filePicture = nil;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if (picture != nil)
    {
        text = @"[Picture message]";
        filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
        [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error != nil)
                 [Utils showMessageHUDInView:self.view withMessage:@"Error uploading image" afterError:YES];
         }];
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    
    PFUser *recipient = nil;
    // Find recipient, this is the other user if this is not a group chat
    if(!self.isGroupChat) {
        for (PFUser * usr in [self.users allValues]) {
            if(![usr.objectId isEqualToString:self.senderId]) {
                recipient = usr;
                break;
            }
        }
    }
    
    PFObject *object = [PFObject objectWithClassName:@"KamanChat"];
    object[@"Sender"] = [PFUser currentUser];
    if(!self.isGroupChat && recipient != nil) object[@"Recipient"] = recipient;
    object[@"IsGroupChat"] = [NSNumber numberWithBool:self.isGroupChat];
    object[@"Text"] = text;
    object[@"Kaman"] = self.kaman;
    if(location != nil) object[@"LocationAttachment"] = location;
    if (filePicture != nil) object[@"ImageAttachment"] = filePicture;
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error == nil)
         {
             [JSQSystemSoundPlayer jsq_playMessageSentSound];
             [self loadMessages];
         }
         else
             [Utils showMessageHUDInView:self.view withMessage:[NSString stringWithFormat: @"Network error: %@",error.localizedDescription] afterError:YES];
     }];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if(self.isGroupChat == YES) {
         NSString * channel = [NSString stringWithFormat:@"KAMAN-%@", self.kaman.objectId];
        [Utils sendPushFor:PUSH_TYPE_GROUP_MESSAGE toChannel:channel withMessage: [NSString stringWithFormat:@"%@ sent you a new message relating to %@",[[PFUser currentUser] displayName],[self.kaman objectForKey:@"Name"]] ForKaman:self.kaman targetUsers:[self.users allValues]];
    } else {
        if([recipient notifyMessages]) {
            [Utils sendPushFor:PUSH_TYPE_CHAT_MESSAGE toUser:recipient withMessage: [NSString stringWithFormat:@"%@ sent you a new message relating to %@",[[PFUser currentUser] displayName],[self.kaman objectForKey:@"Name"]] ForKaman:self.kaman];
        }
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [self finishSendingMessage];
}


#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)incoming:(JSQMessage *)message
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return ([message.senderId isEqualToString:self.senderId] == NO);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)outgoing:(JSQMessage *)message
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return ([message.senderId isEqualToString:self.senderId] == YES);
}


@end
