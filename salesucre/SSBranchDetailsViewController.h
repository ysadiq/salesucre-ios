//
//  SSBranchDetailsViewController.h
//  salesucre
//
//  Created by Haitham Reda on 5/21/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface SSBranchDetailsViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *callButton;

@end
