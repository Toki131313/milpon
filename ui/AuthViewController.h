//
//  AuthViewController.h
//  Milpon
//
//  Created by mootoh on 10/22/08.
//  Copyright 2008 deadbeaf.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AuthViewController : UIViewController <UIWebViewDelegate>
{
   enum {
      STATE_INITIAL,
      STATE_SUBMITTED,
      STATE_WRONG_PASSWORD,
      STATE_USERINFO_ENTERED,
      STATE_SHOW_WEBVIEW,
      STATE_DONE
   } state;

   IBOutlet UIActivityIndicatorView *authActivity;
   IBOutlet UITextField *usernameField;
   IBOutlet UITextField *passwordField;
   IBOutlet UILabel *instructionLabel;
   IBOutlet UIButton *proceedButton;
   IBOutlet UIWebView *webView;
}

- (IBAction) proceedToAuthorization;
- (IBAction) getToken;
- (void) failedInAuthorization;

@end