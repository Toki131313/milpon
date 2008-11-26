//
//  TaskViewController.h
//  Milpon
//
//  Created by mootoh on 9/6/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTMTask.h"

@interface TaskViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate> {
   RTMTask *task;
   IBOutlet UITextField   *name;
   IBOutlet UITextField   *url;
   IBOutlet UITextField   *location;
   IBOutlet UITextField   *repeat;
   IBOutlet UITextField   *estimate;
   IBOutlet UITextField   *postponed;
   IBOutlet UITextField   *due;
   IBOutlet UIButton      *priorityButton;
   IBOutlet UITextField   *list;
   IBOutlet UITextView    *noteView;
   IBOutlet UIPageControl *notePages;

   UIView  *dialogView;
   NSArray *prioritySelections;
}

@property (nonatomic, retain) RTMTask *task;
@end
