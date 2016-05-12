//
//  AutocompletionTableView.m
//
//  Created by Gushin Arseniy on 11.03.12.
//  Copyright (c) 2012 Arseniy Gushin. All rights reserved.
//

#import "AutocompletionTableView.h"
#import <GoogleMaps/GoogleMaps.h>
#import "Session.h"
@interface AutocompletionTableView () 
@property (nonatomic, strong) NSMutableArray *suggestionOptions; // of selected NSStrings
@property (nonatomic, strong) UITextField *textField; // will set automatically as user enters text
@property (nonatomic, strong) UIFont *cellLabelFont; // will copy style from assigned textfield
@end

@implementation AutocompletionTableView {
     GMSAutocompleteFetcher* _fetcher;
}
static NSString *kSortInputStringKey = @"sortInputString";
static NSString *kSortEditDistancesKey = @"editDistances";
static NSString *kSortObjectKey = @"sortObject";
static NSString *kKeyboardAccessoryInputKeyPath = @"autoCompleteTableAppearsAsKeyboardAccessory";

@synthesize suggestionsDictionary = _suggestionsDictionary;
@synthesize suggestionOptions = _suggestionOptions;
@synthesize textField = _textField;
@synthesize cellLabelFont = _cellLabelFont;
@synthesize options = _options;


-(void) updateFrameAroundTextField:(UITextField*) textField inViewController:(UIViewController *) parentViewController
{
    // frame must align to the textfield
    CGRect frame = CGRectMake(0, textField.frame.origin.y+textField.frame.size.height + 70, parentViewController.view.frame.size.width, 300);
    [self setFrame:frame];
}

#pragma mark - Initialization
- (UITableView *)initWithTextField:(UITextField *)textField inViewController:(UIViewController *) parentViewController withOptions:(NSDictionary *)options
{
    //set the options first
    self.options = options;
    
    // frame must align to the textfield 
    CGRect frame = CGRectMake(0, textField.frame.origin.y+textField.frame.size.height + 70, parentViewController.view.frame.size.width, 300);
    
    // save the font info to reuse in cells
    self.cellLabelFont = textField.font;
    
    self = [super initWithFrame:frame
             style:UITableViewStylePlain];
    
    self.delegate = self;
    self.dataSource = self;
    self.scrollEnabled = YES;
    
    // turn off standard correction
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    // to get rid of "extra empty cell" on the bottom
    // when there's only one cell in the table
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, textField.frame.size.width, 1)]; 
    v.backgroundColor = [UIColor clearColor];
    [self setTableFooterView:v];
    self.hidden = YES;  
    [parentViewController.view addSubview:self];

    // Set up the autocomplete filter.
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
  //  filter.type = kGMSPlacesAutocompleteTypeFilterEstablishment;
    filter.country = currentLocality.countryCode;
    // Create the fetcher.
    _fetcher = [[GMSAutocompleteFetcher alloc] initWithBounds:nil
                                                       filter:filter];
    _fetcher.delegate = self;

    return self;
}

#pragma mark - Logic staff

#pragma mark - GMSAutocompleteFetcherDelegate
- (void)didAutocompleteWithPredictions:(NSArray *)predictions {
    self.suggestionOptions = [NSMutableArray new];
    for (GMSAutocompletePrediction *prediction in predictions) {
        [self.suggestionOptions addObject:prediction];
    }
    [self reloadData];
}

-(void)didFailAutocompleteWithError:(NSError *)error{
    
    NSLog(@"%@",[NSString stringWithFormat:@"%@", error.localizedDescription]);
}

- (BOOL) substringIsInDictionary:(NSString *)subString
{
    /*if (_autoCompleteDelegate && [_autoCompleteDelegate respondsToSelector:@selector(autoCompletion:suggestionsFor:)]) {
        self.suggestionsDictionary = [_autoCompleteDelegate autoCompletion:self suggestionsFor:subString];
    }*/
     [_fetcher sourceTextHasChanged:subString];
   /* self.suggestionOptions = [self sortedCompletionsForString:subString
                                    withPossibleStrings:self.suggestionsDictionary];*/
    return YES;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.suggestionOptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
    if (cell == nil) 
    {
        cell = [[UITableViewCell alloc] 
                 initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
    }
    
    cell.textLabel.adjustsFontSizeToFitWidth = NO;
    GMSAutocompletePrediction  *pred = [self.suggestionOptions objectAtIndex:indexPath.row];
    UIFont *regularFont = [UIFont systemFontOfSize:[UIFont labelFontSize]];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    
    NSMutableAttributedString *bolded = [pred.attributedFullText mutableCopy];
    [bolded enumerateAttribute:kGMSAutocompleteMatchAttribute
                       inRange:NSMakeRange(0, bolded.length)
                       options:0
                    usingBlock:^(id value, NSRange range, BOOL *stop) {
                        UIFont *font = (value == nil) ? regularFont : boldFont;
                        [bolded addAttribute:NSFontAttributeName value:font range:range];
                    }];
    
    cell.textLabel.attributedText = bolded;
    //cell.textLabel.text = [pred.attributedFullText string];

    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GMSAutocompletePrediction  *pred = [self.suggestionOptions objectAtIndex:indexPath.row];
    [self.textField setText:[pred.attributedFullText string]];
    
    if (_autoCompleteDelegate && [_autoCompleteDelegate respondsToSelector:@selector(autoCompletion:didSelectAutoCompleteSuggestion:WithIndex:)]) {
        [_autoCompleteDelegate autoCompletion:self didSelectAutoCompleteSuggestion:pred WithIndex:indexPath.row];
    }
    
    [self hideOptionsView];
}


- (NSArray *)sortedCompletionsForString:(NSString *)inputString withPossibleStrings:(NSArray *)possibleTerms
{
    if([inputString isEqualToString:@""]){
        return possibleTerms;
    }
    
    
    NSMutableArray *editDistances = [NSMutableArray arrayWithCapacity:possibleTerms.count];
    
    
    for(NSObject *originalObject in possibleTerms) {
        
        NSString *currentString;
        if([originalObject isKindOfClass:[NSString class]]){
            currentString = (NSString *)originalObject;
        }
        
     
        NSUInteger maximumRange = (inputString.length < currentString.length) ? inputString.length : currentString.length;
        float editDistanceOfCurrentString = [inputString asciiLevenshteinDistanceWithString:[currentString substringWithRange:NSMakeRange(0, maximumRange)]];
        
        NSDictionary * stringsWithEditDistances = @{kSortInputStringKey : currentString ,
                                                    kSortObjectKey : originalObject,
                                                    kSortEditDistancesKey : [NSNumber numberWithFloat:editDistanceOfCurrentString]};
        [editDistances addObject:stringsWithEditDistances];
    }
    

    
    [editDistances sortUsingComparator:^(NSDictionary *string1Dictionary,
                                         NSDictionary *string2Dictionary){
        
        return [string1Dictionary[kSortEditDistancesKey]
                compare:string2Dictionary[kSortEditDistancesKey]];
        
    }];
    
    
    
    NSMutableArray *prioritySuggestions = [NSMutableArray array];
    NSMutableArray *otherSuggestions = [NSMutableArray array];
    for(NSDictionary *stringsWithEditDistances in editDistances){
        
    
        
        NSObject *autoCompleteObject = stringsWithEditDistances[kSortObjectKey];
        NSString *suggestedString = stringsWithEditDistances[kSortInputStringKey];
        
        NSArray *suggestedStringComponents = [suggestedString componentsSeparatedByString:@" "];
        BOOL suggestedStringDeservesPriority = NO;
        for(NSString *component in suggestedStringComponents){
            NSRange occurrenceOfInputString = [[component lowercaseString]
                                               rangeOfString:[inputString lowercaseString]];
            
            if (occurrenceOfInputString.length != 0 && occurrenceOfInputString.location == 0) {
                suggestedStringDeservesPriority = YES;
                [prioritySuggestions addObject:autoCompleteObject];
                break;
            }
            
            if([inputString length] <= 1){
                //if the input string is very short, don't check anymore components of the input string.
                break;
            }
        }
        
        if(!suggestedStringDeservesPriority){
            [otherSuggestions addObject:autoCompleteObject];
        }
        
    }
    
    NSMutableArray *results = [NSMutableArray array];
    [results addObjectsFromArray:prioritySuggestions];
    [results addObjectsFromArray:otherSuggestions];
    
    
    return [NSArray arrayWithArray:results];
}

#pragma mark - UITextField delegate
- (void)textFieldValueChanged:(UITextField *)textField
{
    self.textField = textField;
    NSString *curString = textField.text;
    
    if (![curString length])
    {
        [self hideOptionsView];
        return;
    } else if ([self substringIsInDictionary:curString])
        {
            [self showOptionsView];
            [self reloadData];
        } else [self hideOptionsView];
}

#pragma mark - Options view control
- (void)showOptionsView
{
    self.hidden = NO;
}

- (void) hideOptionsView
{
    self.hidden = YES;
}

@end
