//
//  ViewController.m
//  Beerify
//
//  Created by Matthew Noakes on 10/9/16.
//  Copyright © 2016 Matthew Noakes. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import <pop/POP.h>

@import CoreLocation;

@interface ViewController () <PFSignUpViewControllerDelegate, PFLogInViewControllerDelegate, CLLocationManagerDelegate, CustomIOSAlertViewDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;




@end

@implementation ViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewDidAppear:(BOOL)animated {
    if (![PFUser currentUser]) { // No user logged in
        
        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
        [logInViewController setDelegate:self]; // Set ourselves as the delegate
        
        logInViewController.fields = (PFLogInFieldsUsernameAndPassword
                                  | PFLogInFieldsLogInButton
                                  | PFLogInFieldsSignUpButton
                                  | PFLogInFieldsPasswordForgotten
                                  | PFLogInFieldsDismissButton
                                  );
        
        // Create the sign up view controller
        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController];
        
        // Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:nil];
        
        //[self dismissViewControllerAnimated:YES completion:nil];
        
        //[self dismissViewController:logInViewController];
        }
         
}


- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)signUpViewControllerDidCancelSignUP:(PFSignUpViewController *)signUpController {
    [self dismissModalViewControllerAnimated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Create the log in view controller
    
    
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    //[self.tblContentList removeFromSuperview];
    //[self.searchBar removeFromSuperview];
    
    
    
    
    
    //contentList = [[NSMutableArray alloc] initWithObjects:@"iPhone", @"iPod", @"iPod touch", @"iMac", @"Mac Pro", @"iBook",@"MacBook", @"MacBook Pro", @"PowerBook", nil];
    
    list = [[NSMutableArray alloc] init];
    contentList = [[NSMutableArray alloc] init];
    
    filteredContentList = [[NSMutableArray alloc] init];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //[errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"%@", [locations lastObject]);
}
/*
- (void)viewDidUnload {
    
    [self setTblContentList:nil];
    [self setSearchBar:nil];
    [self setSearchBarController:nil];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
*/

-(void) getLocationManager
{
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    POPSpringAnimation *sprintAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    sprintAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
    sprintAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(4, 4)];
    sprintAnimation.springBounciness = 20.f;
    [cell pop_addAnimation:sprintAnimation forKey:@"size"];
    
    //NSString *cellText = cell.textLabel.text;
    
    //NSLog(@"%@", _beerID[indexPath.row]);
    NSString *urlOne = [NSString stringWithFormat:@"http://api.brewerydb.com/v2/beer/%@?withBreweries=Y&key=142f4ee97b2b084721cf79e028699ae0", _beerID[indexPath.row]];//, _beerID[indexPath.row]];
    //NSString *urlTwo = [NSString stringWithFormat: @"&type=beer&withBreweries=Y&key=142f4ee97b2b084721cf79e028699ae0"];
    //NSLog(@"%@", urlOne);
    
    
    //NSString *finalString = [NSString stringWithFormat:@"%@%@%@", urlOne, self.beerID, urlTwo];
    NSURL *URL = [NSURL URLWithString:urlOne];//"http://api.brewerydb.com/v2/search?q=Goosinator&type=beer&withBreweries=Y&key=710a74cd5bd2b6a837128341d5bf892f"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    //NSLog(@"%@", finalString);
    
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        //NSError *error;
        //NSMutableArray *returnedDict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
        
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSDictionary *forDict = [responseObject objectForKey:@"data"];
            
            //NSLog(@"This is the url: %@",forDict);// [[forDict objectForKey:@"labels"] objectForKey:@"icon"]);//[[forDict objectForKey:@"labels"] valueForKey:@"large"]);
            
            UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:[forDict valueForKey:@"name"] message:@"This" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(220, 10, 40, 40)];
            _imageURL = [NSURL URLWithString:[[forDict objectForKey:@"labels"] objectForKey:@"large"]];
            
            location = [NSMutableString stringWithFormat:@"%@+%@+%@",[[[[[forDict valueForKey:@"breweries"]objectAtIndex:0] valueForKey:@"locations"] objectAtIndex:0] valueForKey:@"streetAddress"], [[[[[forDict valueForKey:@"breweries"]objectAtIndex:0] valueForKey:@"locations"] objectAtIndex:0] valueForKey:@"locality"], [[[[[forDict valueForKey:@"breweries"]objectAtIndex:0] valueForKey:@"locations"] objectAtIndex:0] valueForKey:@"region"]];
            
           location = [location stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            NSLog(@"%@", location);
            
            //NSLog(@"%@+%@+%@", [[[[[forDict valueForKey:@"breweries"]objectAtIndex:0] valueForKey:@"locations"] objectAtIndex:0] valueForKey:@"streetAddress"], [[[[[forDict valueForKey:@"breweries"]objectAtIndex:0] valueForKey:@"locations"] objectAtIndex:0] valueForKey:@"locality"], [[[[[forDict valueForKey:@"breweries"]objectAtIndex:0] valueForKey:@"locations"] objectAtIndex:0] valueForKey:@"region"]);
            
           //  = [searching stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            //http://maps.apple.com/?address=1,Infinite+Loop,Cupertino,California
            
            //NSLog(@"%@",  [[[[forDict valueForKey:@"breweries"]objectAtIndex:0] valueForKey:@"locations"] objectAtIndex:0]);// valueForKey:@"longitude"]);
            
            //location = [NSMutableArray arrayWithObjects:[[[[[forDict valueForKey:@"breweries"]objectAtIndex:0] valueForKey:@"locations"] objectAtIndex:0] valueForKey:@"latitude"], [[[[[forDict valueForKey:@"breweries"]objectAtIndex:0] valueForKey:@"locations"] objectAtIndex:0] valueForKey:@"longitude"], nil];
            
            //NSLog(@"%@ %@", location[0], location[1]);
            
            //NSLog(@"%@", [[[responseObject objectForKey:@"data" ] objectForKey:@"breweries"]valueForKey:@"name"]); //objectForKey:@"locations"]); //valueForKey:@"lattitude"]);//data, breweries, locations, (lattitude, longitude)

            //data, (abv)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSData *imageData = [NSData dataWithContentsOfURL:_imageURL];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *image = [UIImage imageWithData:imageData];
                    [imageView setImage:image];
                    [successAlert addSubview:imageView];
                   // [successAlert show];
/////////////////////
/////////////////////
                    
                    
                    
                    
                    
                    
                    
                    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
                    
                    
                    
                    // Add some custom content to the alert view
                    [alertView setContainerView:[self createDemoView]];
                    
                    // Modify the parameters
                    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"OK", @"Location", nil]];
                    [alertView setDelegate:self];
                    
                    // You may use a Block, rather than a delegate.
                    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
                        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
                        [alertView close];
                    }];
                    
                    [alertView setUseMotionEffects:true];
                    
                    // And launch the dialog
                    [alertView show];
                    
                    
                    
                    
                    // Update the UI
                    //self.imageView.image = [UIImage imageWithData:imageData];
                });
            });
            
            
    //////////////////////////
            
            
            
            
            
            //NSLog(@"%@", forDict);//[forDict valueForKey:@"name"]);
            
        }
    }];

    [dataTask resume];

    
    //NSLog(@"%ld", indexPath.row + 1);
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOSAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    NSLog(@"Delegate: Button at position %d is clicked on alertView %d.", (int)buttonIndex, (int)[alertView tag]);
    
    if ((int)buttonIndex==0){
        NSLog(@"this should run");
    } else {
        
        NSString *urlString = [NSString stringWithFormat:@"http://maps.apple.com/?address=%@", location];
        
        NSURL *url = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:url];
    }
    [alertView close];
}


- (UIView *)createDemoView
{
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 200)];
    
    //NSURL *imageURL = [NSURL URLWithString:@"http://d1mxp0yvealdwc.cloudfront.net/e92c939d-e83b-4592-b367-327fa67339fb/1001 123.jpg"];
    //NSLog(@"imge %@",_imageURL);
    
    NSData *imageData = [NSData dataWithContentsOfURL:_imageURL];
    //NSLog(@"imge %@",imageData);
    UIImage *image = [UIImage imageWithData:imageData];
    //NSLog(@"imge %@",image);
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 270, 180)];
    [imageView setImage:image];
    [demoView addSubview:imageView];
    
    return demoView;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
        return [filteredContentList count];
    
   }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    
    POPSpringAnimation *sprintAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    sprintAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
    sprintAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(4, 4)];
    sprintAnimation.springBounciness = 20.f;
    [cell pop_addAnimation:sprintAnimation forKey:@"size"];
    cell.textLabel.text = [filteredContentList objectAtIndex:indexPath.row];
    //cell.detailTextLabel.text = [list objectAtIndex:indexPath.row];
    
   
    // Configure the cell...
    
    //  cell.textLabel.text = [contentList objectAtIndex:indexPath.row];
   

    //if (isSearching) {
    /*
    if (!filteredContentList){
        cell.textLabel.text = [contentList objectAtIndex:indexPath.row];
      
    }
    else {
        cell.textLabel.text = [filteredContentList objectAtIndex:indexPath.row];
          NSLog(@"%@", cell.textLabel.text);

    }
    */
    return cell;
    
}

/*
- (void)searchTableList {
    NSString *searchString = _searchBar.text;
    
    for (NSString *tempStr in contentList) {
        NSComparisonResult result = [tempStr compare:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchString length])];
        if (result == NSOrderedSame) {
            [filteredContentList addObject:tempStr];
        }
    }
}
*/
#pragma mark - Search Implementation
/*
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    isSearching = YES;
}
 */
/*
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"Text change - %d",isSearching);
    
    //Remove all objects first.
    //[filteredContentList removeAllObjects];
    
    if([searchText length] != 0) {
        isSearching = YES;
        [self searchTableList];
    }
    else {
        isSearching = NO;
    }
    [self.tblContentList reloadData];
}
*/
-(void) breweryDBSearch
{/*
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    //NSString *searching =
    
    NSMutableString *foo = [NSMutableString stringWithFormat:@"%@", self.searchBar.text];
    NSString *searching = [foo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *urlOne = [NSString stringWithFormat:@"http://api.brewerydb.com/v2/search?q=" ];
    NSString *urlTwo = [NSString stringWithFormat:@"&type=beer&withBreweries=Y&key=710a74cd5bd2b6a837128341d5bf892f" ];
   //hell NSLog(@"%@", _searchBar.text);

    
    NSString *finalString = [NSString stringWithFormat:@"%@%@%@", urlOne, searching, urlTwo];
    NSURL *URL = [NSURL URLWithString:finalString];//"http://api.brewerydb.com/v2/search?q=Goosinator&type=beer&withBreweries=Y&key=710a74cd5bd2b6a837128341d5bf892f"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    //NSLog(@"%@", finalString);
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        //NSError *error;
        //NSMutableArray *returnedDict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
        
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                for (NSDictionary *forDict in [responseObject objectForKey:@"data"]){
                NSLog(@"%@", forDict);//[forDict valueForKey:@"nameDisplay"]); //[forDict valueForKey:@"nameDisplay"]);
                    // self.searchDisplayController.active = YES;
                    //self.searchDisplayController.searchBar.text = @"New search string";
                    [self searchTableList];
                    
                }
                //NSLog(@"%@", [[responseObject objectForKey:@"data"]objectAtIndex:0]);
            });
        }
    }];
    [dataTask resume];
*/
}



- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Cancel clicked");
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    //NSLog(@"%@", searchBar.text);
    
        //NSString *searching = [NSString stringWithFormat:@"%@", searchBar.text];
    
    NSString *foo = [NSMutableString stringWithFormat:@"%@", searchBar.text];
    NSString *searching = [foo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //NSString *string = @"Lorem    ipsum dolar   sit  amet.";
    //string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSArray *components = [searching componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    components = [components filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self <> ''"]];
    
    searching = [components componentsJoinedByString:@" "];
    
    searching = [searching stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    NSString *urlOne = [NSString stringWithFormat:@"http://api.brewerydb.com/v2/search?q="];
    NSString *urlTwo = [NSString stringWithFormat: @"&type=beer&withBreweries=Y&key=142f4ee97b2b084721cf79e028699ae0"];
    //NSLog(@"%@", searching);
    
    
    NSString *finalString = [NSString stringWithFormat:@"%@%@%@", urlOne, searching, urlTwo];
    NSURL *URL = [NSURL URLWithString:finalString];//"http://api.brewerydb.com/v2/search?q=Goosinator&type=beer&withBreweries=Y&key=710a74cd5bd2b6a837128341d5bf892f"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    //NSLog(@"%@", finalString);
    
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        //NSError *error;
        //NSMutableArray *returnedDict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
        
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSDictionary *forDict = [responseObject objectForKey:@"data"];
            filteredContentList = [forDict valueForKey:@"name"];
            
            NSArray *thisString;  //[forDict valueForKey:@"abv"];
            
            
            if ([forDict valueForKey:@"abv"] != [NSNull null]) {
                // do something because the object is null
                
                 //list = [forDict valueForKey:@"abv"];
            }
            
                      // NSLog(@"%@ - %@", [[[[[forDict valueForKey:@"breweries"]objectAtIndex:0] valueForKey:@"locations"] objectAtIndex:0] valueForKey:@"latitude"], [[[[[forDict valueForKey:@"breweries"]objectAtIndex:0] valueForKey:@"locations"] objectAtIndex:0] valueForKey:@"longitude"]); //valueForKey:@"name"]);
            
            //filteredDetailLine = [[forDict objectForKey:@"name"] objectForKey:@"abv"];
            
            self.beerID = [forDict valueForKey:@"id"];
            
            
            
            //NSLog(@"%@", responseObject);

            
            [self.searchDisplayController.searchResultsTableView reloadData];

            
            [self.tblContentList reloadData];
            
            [self.view endEditing:YES];
            
            
            
            
            //NSLog(@"%@", filteredDetailLine);
            
        }
    }];
    [dataTask resume];
}

@end


/*
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"Is this running?");
    
    //UIAlertView *thisAlert = [[UIAlertView alloc] initWithTitle:_searchBar.text message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    //[thisAlert show];
    
    //

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:@"http://api.brewerydb.com/v2/search?q=Goosinator&type=beer&withBreweries=Y&key=710a74cd5bd2b6a837128341d5bf892f"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
       //NSError *error;
        //NSMutableArray *returnedDict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
        
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                for (NSDictionary *forDict in [responseObject objectForKey:@"data"]){
                    NSLog(@"%@", forDict);//[forDict valueForKey:@"nameDisplay"]); //[forDict valueForKey:@"nameDisplay"]);
                   // self.searchDisplayController.active = YES;
                    //self.searchDisplayController.searchBar.text = @"New search string";
                    
                }
                //NSLog(@"%@", [[responseObject objectForKey:@"data"]objectAtIndex:0]);
            });
                  }
    }];
    [dataTask resume];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // NSLog(@" in method 2");
    // Return the number of rows in the section.
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath    *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlayerCell" forIndexPath:indexPath];

    //cell.textLabel.text = [forDid]
    return cell;
}

- (IBAction)refresh:(id)sender
{
};


@end
*/
