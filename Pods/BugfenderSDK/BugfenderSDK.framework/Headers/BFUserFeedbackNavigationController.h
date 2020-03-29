//
//  BFUserFeedbackViewController.h
//  BugfenderSDK
//
//  Created by Rubén Vázquez Otero on 15/10/2018.
//  Copyright © 2018 Mobile Jazz. All rights reserved.
//

#if TARGET_OS_IOS

#import "BFUserFeedbackViewController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Navigation View Controller containing a BFUserFeedbackNavigationController as rootViewController
 */
@interface BFUserFeedbackNavigationController : UINavigationController



/**
 * Root View Controller containing a table with the textfields used to gather feedback
 */
@property (nonatomic, strong) BFUserFeedbackViewController *feedbackViewController;

/**
 Provides a View Controller to gather the feedback of the users and sent it to Bugfender.
 The returning BFUserFeedbackNavigationController has to be presented modally and it has it's own Send and Cancel buttons
 
 Additionally, it is possible to customize the aspect of the screen accessing BFUserFeedbackNavigationController.feedbackViewController
 
 @param title Title for the navigation bar
 @param hint Short text at the beginning
 @param subjectPlaceholder placeholder in the subject textfield
 @param messagePlaceholder placeholder in the message textfield
 @param sendButtonTitle title for the send button in the navigation bar
 @param cancelButtonTitle title for the cancel button
 @return BFUserFeedbackNavigationController containing a BFUserFeedbackViewController as root view controller
 */
+ (BFUserFeedbackNavigationController *)userFeedbackViewControllerWithTitle:(NSString *)title
                                                                       hint:(NSString *)hint
                                                         subjectPlaceholder:(NSString *)subjectPlaceholder
                                                         messagePlaceholder:(NSString *)messagePlaceholder
                                                            sendButtonTitle:(NSString *)sendButtonTitle
                                                          cancelButtonTitle:(NSString *)cancelButtonTitle
                                                                 completion:(void (^)(BOOL feedbackSent, NSURL * _Nullable url))completionBlock;


@end

NS_ASSUME_NONNULL_END
#endif
