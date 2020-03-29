//
//  BugfenderSDK.h
//  BugfenderSDK
//  Copyright (c) 2014 Bugfender SL. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IOS

#import "BFUserFeedbackNavigationController.h"

#endif

NS_ASSUME_NONNULL_BEGIN

#define BFLibraryVersionNumber_0_1_0  0
#define BFLibraryVersionNumber_0_2_0  1
#define BFLibraryVersionNumber_0_2_1  2
#define BFLibraryVersionNumber_0_3_0  3
#define BFLibraryVersionNumber_0_3_1  4
#define BFLibraryVersionNumber_0_3_2  5
#define BFLibraryVersionNumber_0_3_3  6
#define BFLibraryVersionNumber_0_3_4  7
#define BFLibraryVersionNumber_0_3_5  8
#define BFLibraryVersionNumber_0_3_6  9
#define BFLibraryVersionNumber_0_3_7  10
#define BFLibraryVersionNumber_0_3_8  11
#define BFLibraryVersionNumber_0_3_9  12
#define BFLibraryVersionNumber_0_3_10  13
#define BFLibraryVersionNumber_0_3_11  14
#define BFLibraryVersionNumber_0_3_12  15
#define BFLibraryVersionNumber_0_3_13  16
#define BFLibraryVersionNumber_0_3_14  17
#define BFLibraryVersionNumber_0_3_15  18
#define BFLibraryVersionNumber_0_3_16  19
#define BFLibraryVersionNumber_0_3_17  20
#define BFLibraryVersionNumber_0_3_18  21
#define BFLibraryVersionNumber_0_3_19  22
#define BFLibraryVersionNumber_0_3_20  23
#define BFLibraryVersionNumber_0_3_21  24
#define BFLibraryVersionNumber_0_3_22  25
#define BFLibraryVersionNumber_0_3_23  26
#define BFLibraryVersionNumber_0_3_24  27
#define BFLibraryVersionNumber_0_3_25  28
#define BFLibraryVersionNumber_0_3_26  29
#define BFLibraryVersionNumber_0_3_27  30
#define BFLibraryVersionNumber_1_4_0  31
#define BFLibraryVersionNumber_1_4_1  32
#define BFLibraryVersionNumber_1_4_2  33
#define BFLibraryVersionNumber_1_4_3  34
#define BFLibraryVersionNumber_1_4_4  34 // Mistake: We released the version without incrementing the number.
#define BFLibraryVersionNumber_1_4_5  36
#define BFLibraryVersionNumber_1_4_6  37
#define BFLibraryVersionNumber_1_4_7  38
#define BFLibraryVersionNumber_1_4_8  39
#define BFLibraryVersionNumber_1_4_9  40
#define BFLibraryVersionNumber_1_4_10 41
#define BFLibraryVersionNumber_1_5_0  42
#define BFLibraryVersionNumber_1_5_1  43
#define BFLibraryVersionNumber_1_5_2  44
#define BFLibraryVersionNumber_1_5_3  45
#define BFLibraryVersionNumber_1_5_4  46
#define BFLibraryVersionNumber_1_5_5  47
#define BFLibraryVersionNumber_1_5_6  48
#define BFLibraryVersionNumber_1_6_0  49
#define BFLibraryVersionNumber_1_6_1  50
#define BFLibraryVersionNumber_1_6_2  51
#define BFLibraryVersionNumber_1_6_3  52
#define BFLibraryVersionNumber_1_6_4  53
#define BFLibraryVersionNumber_1_6_5  54
#define BFLibraryVersionNumber_1_6_6  55
#define BFLibraryVersionNumber_1_7_0  56
#define BFLibraryVersionNumber_1_8_0  57

/**
 * Current Bugfender version number.
 * @note This value can be compared with the defined macros BFLibraryVersionNumber_X_Y_Z.
 **/
FOUNDATION_EXPORT double const BFLibraryVersionNumber;

/** Defines the level of a log */
typedef NS_ENUM(NSUInteger, BFLogLevel)
{
    /** Default/Degug log level */
    BFLogLevelDefault       = 0,
    /** Warning log level */
    BFLogLevelWarning       = 1,
    /** Error log level */
    BFLogLevelError         = 2,
    /** Trace log level */
    BFLogLevelTrace         = 3,
    /** Info log level */
    BFLogLevelInfo          = 4,
    /** Fatal log level */
    BFLogLevelFatal         = 5
};

#define BFLog(args, ...)     BFLog2(BFLogLevelDefault, nil, args, ##__VA_ARGS__)
#define BFLogWarn(args, ...) BFLog2(BFLogLevelWarning, nil, args, ##__VA_ARGS__)
#define BFLogErr(args, ...)  BFLog2(BFLogLevelError, nil, args, ##__VA_ARGS__)
#define BFLogTrace(args, ...)  BFLog2(BFLogLevelTrace, nil, args, ##__VA_ARGS__)
#define BFLogInfo(args, ...)  BFLog2(BFLogLevelInfo, nil, args, ##__VA_ARGS__)
#define BFLogFatal(args, ...)  BFLog2(BFLogLevelFatal, nil, args, ##__VA_ARGS__)

#define BFLog2(logLevel, tagName, fmt, ...) \
[Bugfender logWithLineNumber:__LINE__ method:[NSString stringWithFormat:@"%s",__PRETTY_FUNCTION__] file:[[NSString stringWithFormat:@"%s",__FILE__] lastPathComponent] level:logLevel tag:tagName message:fmt == nil ? @"" : [NSString stringWithFormat:fmt, ##__VA_ARGS__]]



/**
 * Main Bugfender interface.
 **/
@interface Bugfender : NSObject

/** ******************************************************************** **
 * @name Configuration
 ** ******************************************************************** **/

/**
 * Sets the URL of the API
 * @note Usage of this function is not necessary in the general use case. Please use exclusively when
 * directed from technical support.
 * @warning This method must be called before activateLogger.
 * @param url URL of the API to use
 */
+ (void)setApiURL:(NSURL*)url;

/**
 * Sets the URL of the Bugfender Dashboard
 * @note Usage of this function is not necessary in the general use case. Please use exclusively when
 * directed from technical support.
 * @warning This method must be called before activateLogger.
 * @param url base URL of the Bugfender's dashboard
 */
+ (void)setBaseURL:(NSURL*)url;

/**
 * Activates the Bugfender logger for a specific app.
 * @param appKey The app key of the Bugfender application, get it in bugfender.com
 * @warning If Bugfender has already been initialized with a different app key `NSInvalidArgumentException` will be thrown.
 * @note This method needs to be called before any `BFLog` call, otherwise they will be ignored.
 **/
+ (void)activateLogger:(NSString*)appKey;

/**
 * Returns the app key.
 * @return The app key, or nil if Bugfender has not been initialized.
 **/
+ (nullable NSString*)appKey;

/**
 * Maximum space available to store local logs. This value is represented in bytes. Default value is 5242880 (1024*1024*5 = 5MB).
 * @note If maximumLocalStorageSize is 0 (zero), then there is no limit and everything will be stored locally.
 **/
+ (NSUInteger)maximumLocalStorageSize;

/**
 * Set the maximum space available to store local logs. This value is represented in bytes. There's a limit of 50 MB.
 * @param maximumLocalStorageSize Maximum space availalbe to store local logs, in bytes.
 **/
+ (void)setMaximumLocalStorageSize:(NSUInteger)maximumLocalStorageSize;

/**
 * Returns the device identifier used to identify the current device in the Bugfender website.
 * The device identifier is constant while the application is installed in the device.
 * @note This string can not be changed, but can be shown to the user or sent to your server, in order to
 * keep a relationship between a Bugfender device and a user or some other important event in your application.
 * 
 * @return A string identifying the device.
 **/
+ (NSString*)deviceIdentifier __deprecated_msg("Use deviceIdentifierUrl instead.");

/**
 * Returns a URL linking to the current device in bugfender.
 * The device identifier is constant while the application is installed in the device.
 * @note This url can be sent to your server and used to create integrations with other services. Also can be stored to
 * keep a relationship between a Bugfender device and a user or some other important event in your application.
 *
 * @return URL linking to the device in Bugfender
 **/
+ (nullable NSURL *)deviceIdentifierUrl;

/**
 *
 * The session identifier is constant while the application is running.
 * @return A string identifying the current session.
 */
+ (nullable NSString *)sessionIdentifier __deprecated_msg("Use sessionIdentifierUrl instead.");

/**
 *
 * The session identifier url is constant while the application is running.
 * @note This url can be sent to your server and used to create integrations with other services.
 * @return A URL linking to the current session in Bugfender.
 */
+ (nullable NSURL *)sessionIdentifierUrl;

/**
 * Synchronizes all logs with the server all the time, regardless if this device is enabled or not.
 * @note This method is useful when the logs should be sent to the server
 * regardless if the device is enabled in the Bugfender Console.
 *
 * Logs are synchronized continuously while forceEnabled is active.
 *
 * This command can be called anytime, and will take effect the next time the device is online.
 * @param enabled Whether logs should be sent regardless of the Bugfender Console settings.
 */
+(void) setForceEnabled:(BOOL)enabled;

/**
 * Gets the status of forceEnabled.
 * @see setForceEnabled
 */
+(BOOL) forceEnabled;

/**
 * Prints messages to console for debugging purposes.
 * @param enabled Whether printing to console is enabled or not. By default it is enabled.
 */
+(void) setPrintToConsole:(BOOL)enabled;

/**
 * Gets the status of printToConsole. printToConsole prints messages to console. By default it is enabled.
 */
+(BOOL) printToConsole;

#if TARGET_OS_IOS
/**
 * Logs all actions performed and screen changes in the application, such as button touches, swipes and gestures.
 */
+(void)enableUIEventLogging;
#endif

/**
 * Enable crash reporting tool functionality.
 */
+(void)enableCrashReporting;

/** ******************************************************************** **
 * @name Device details
 ** ******************************************************************** **/

/**
 * Sets a device detail with boolean type.
 * @note Similarly to an NSDictionary, where you can set key-value pairs
 * related to a Bugfender device.
 * @param b A boolean value.
 * @param key Key.
 */
+(void)setDeviceBOOL:(BOOL)b forKey:(NSString*)key;
/**
 * Sets a device detail with string type.
 * @note Similarly to an NSDictionary, where you can set key-value pairs
 * related to a Bugfender device.
 * @param s A string value. The maximum length allowed is 192 bytes.
 * @param key Key.
 */
+(void)setDeviceString:(NSString*)s forKey:(NSString*)key;
/**
 * Sets a device detail with integer type.
 * @note Similarly to an NSDictionary, where you can set key-value pairs
 * related to a Bugfender device.
 * @param i An UInt64 value.
 * @param key Key.
 */
+(void)setDeviceInteger:(UInt64)i forKey:(NSString*)key;
/**
 * Sets a device detail with double type.
 * @note Similarly to an NSDictionary, where you can set key-value pairs
 * related to a Bugfender device.
 * @param d A double value.
 * @param key Key.
 */
+(void)setDeviceDouble:(double)d forKey:(NSString*)key;
/**
 * Removes a device detail.
 * @note Similarly to an NSDictionary, where you can remove an existent key-value pair
 * related to a Bugfender device by indicating its key.
 * @param key Key.
 */
+(void)removeDeviceKey:(NSString*)key;

/** ******************************************************************** **
 * @name Logging
 ** ******************************************************************** **/

/**
 * Bugfender extended interface for logging, which takes a simple string as log message.
 * @note This command can be called anytime, and will take effect the next time the device is online.
 * For efficiency, several log lines can be sent together to the server with some delay.
 * @param lineNumber The line number of the log.
 * @param method The method where the log has happened.
 * @param file The file where the log has happened.
 * @param level Log level.
 * @param tag Tag to be applied to the log line.
 * @param message Message to be logged. The message will be logged verbatim, no interpretation will be performed.
 * @note  In Swift, prefer to use bfprint() in order to get file name and line number filled in automatically. In Objective-C you can use the BFLog or BFLog2 macros.
 **/
+ (void) logWithLineNumber:(NSInteger)lineNumber method:(NSString*)method file:(NSString*)file level:(BFLogLevel)level tag:(nullable NSString*)tag message:(NSString*)message NS_SWIFT_NAME(log(lineNumber:method:file:level:tag:message:));

/** ******************************************************************** **
 * @name Commands
 ** ******************************************************************** **/

/**
 * Synchronizes all logs with the server once, regardless if this device is enabled or not.
 * @note This method is useful when an error condition is detected and the logs should be sent to
 * the server for analysis, regardless if the device is enabled in the Bugfender Console.
 *
 * Logs are synchronized only once. After that, the logs are again sent according to the enabled flag
 * in the Bugfender Console.
 * 
 * This command can be called anytime, and will take effect the next time the device is online.
 */
+ (void) forceSendOnce;

#pragma mark - Issues
/**
 * Sends an issue
 * @note Sending an issue forces the logs of the current session being sent
 * to the server, and marks the session so that it is highlighted in the web console.
 * @param title Short description of the issue.
 * @param text Full details of the issue. Markdown format is accepted.
 * @return the issue identifier
 */
+ (nullable NSString *)sendIssueWithTitle:(NSString *)title text:(NSString *)text __deprecated_msg("Use sendIssueReturningUrlWithTitle:text: instead.");

/**
 * Sends an issue
 * @note Sending an issue forces the logs of the current session being sent
 * to the server, and marks the session so that it is highlighted in the web console.
 * @param title Short description of the issue.
 * @param text Full details of the issue. Markdown format is accepted.
 * @return an URL linking to the issue in Bugfender
 */
+ (nullable NSURL *)sendIssueReturningUrlWithTitle:(NSString *)title text:(NSString *)text;

#pragma mark - Crashes

/**
 * Sends a crash
 * @note This method will send immediately a crash to the server
 * it doesn't take into account if crash reporting is enabled or not
 * @param title Short description of the crash.
 * @param text Full details of the crarsh.
 * @return an URL linking to the crash in Bugfender
 */
+ (nullable NSURL *)sendCrashWithTitle:(NSString *)title text:(NSString *)text;

#if TARGET_OS_IOS

#pragma mark - User Feedback

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
                                                                 completion:(void (^ _Nullable )(BOOL feedbackSent, NSURL * _Nullable url))completionBlock;

#endif

/**
 Allows to create custom UI to gather user feedback and send to Bugfender.

 @param subject subject of the feedback
 @param message message of the feedback
 */
+ (void)sendUserFeedbackWithSubject:(NSString *)subject message:(NSString *)message __deprecated_msg("Use sendUserFeedbackReturningUrlWithSubject:message: instead.");

/**
 Allows to create custom UI to gather user feedback and send to Bugfender.
 
 @param subject subject of the feedback
 @param message message of the feedback
 @return URL linking to Bugfender
 */
+ (nullable NSURL *)sendUserFeedbackReturningUrlWithSubject:(NSString *)subject message:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
