//
//  ViewController.h
//  Beerify
//
//  Created by Matthew Noakes on 10/9/16.
//  Copyright © 2016 Matthew Noakes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomIOSAlertView.h"
#import <Parse/Parse.h>
#import "ParseUI.h"
//#import "ParseFacebookUtils.h"


@interface ViewController : UIViewController < UITableViewDelegate, UITableViewDataSource> {
    
    NSMutableArray *contentList;
    NSMutableArray *filteredContentList;
    NSMutableArray *brewerys;
    NSMutableArray *list;
    NSMutableString *location;
    NSArray *filteredDetailLine;
    BOOL isSearching;
}
@property (strong, nonatomic) IBOutlet UITableView *tblContentList;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchBarController;
@property NSURL *imageURL;

@property NSArray *beerID;

@end

/*
@interface ViewController : UIViewController


@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;

@end

*/
