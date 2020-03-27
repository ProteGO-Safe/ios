//
//  BFUserFeedbackViewController.h
//  BugfenderSDK
//
//  Created by Rubén Vázquez Otero on 16/10/2018.
//  Copyright © 2018 Mobile Jazz. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * BFUserFeedbackViewController provides a basic and configurable view controller to gather feedback from the users
 */
@interface BFUserFeedbackViewController : UITableViewController {
    
}

#pragma mark - Background colors

/**
 The background of the view controller
 */
@property (nonatomic, strong) UIColor *mainBackgroundColor;

/**
 Background for textfields
 */
@property (nonatomic, strong) UIColor *secondaryBackgroundColor;

#pragma mark - Hint

/**
 The hint is the upper text in the view controller.
 Use the hint give instructions to your users or just to thank them for providing feedback
 */
@property (nonatomic, strong) NSString *hint;

/**
 * Font from the hint
 */
@property (nonatomic, strong) UIFont *hintFont;

/**
 * Font color from the hint
 */
@property (nonatomic, strong) UIColor *hintFontColor;

#pragma mark - Subject

/**
 The subject of the feedback.
 Remember to provide a placeholder
 */
@property (nonatomic, strong) UIFont *subjectFont;

/**
 * Font color from the subject textfield
 */
@property (nonatomic, strong) UIColor *subjectFontColor;

/**
 * Font color for the placeholder of the subject textfield
 */
@property (nonatomic, strong) UIColor *subjectPlaceholderFontColor;

/**
 * Subject placeholder
 */
@property (nonatomic, strong) NSString *subjectPlaceholder;

#pragma mark - Message
/**
 The message of the feedback
 Remember to provide a placeholder 
 */
@property (nonatomic, strong) UIFont *messageFont;

/**
 * Message font color
 */
@property (nonatomic, strong) UIColor *messageFontColor;

/**
 * Message placeholder font color
 */
@property (nonatomic, strong) UIColor *messagePlaceholderFontColor;

/**
 * Message placeholder
 */
@property (nonatomic, strong) NSString *messagePlaceholder;

#pragma mark - Actions

/**
 * Hide view controller
 */
- (void)dismiss;

/**
 * Send feedback to Bugfender
 */
- (void)sendFeedback;

/**
 Pass a block if you want to be notified after feedback was sent (or not)
 */
@property (nonatomic, copy) void (^completionBlock)(BOOL feedbackSent, NSURL * _Nullable url);

@end

NS_ASSUME_NONNULL_END
