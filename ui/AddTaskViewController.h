//
//  AddTaskViewController.h
//  Milpon
//
//  Created by mootoh on 9/29/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import "Milpon.h"

@class RTMList;
@protocol HavingTag;

@interface AddTaskViewController : UITableViewController <TaskEditDelegate, HavingTag, UITextFieldDelegate>
{
   RTMList *list;
   NSDate *due;
   NSMutableArray *tags;
   NSString *note;   
   NSString *task_name;
   UITextField *name_text_field;

   UISegmentedControl *priority_segment_;
}

@property (nonatomic, retain) RTMList *list;
@property (nonatomic, retain) NSDate *due;
@property (nonatomic, retain) NSMutableArray *tags;
@property (nonatomic, retain) NSString *note;
@property (nonatomic, retain) NSString *task_name;

- (IBAction) cancel;

/**
 * @brief create RTMTask from given fields, then close the view.
 * @todo: add rrule
 */
- (IBAction) save;

@end
