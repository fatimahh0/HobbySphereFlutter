import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @activitiesFiltersTerminated.
  ///
  /// In en, this message translates to:
  /// **'Terminated'**
  String get activitiesFiltersTerminated;

  /// No description provided for @activitiesFiltersUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get activitiesFiltersUpcoming;

  /// No description provided for @activitiesMyActivities.
  ///
  /// In en, this message translates to:
  /// **'My Activities'**
  String get activitiesMyActivities;

  /// No description provided for @activitiesNoActivities.
  ///
  /// In en, this message translates to:
  /// **'No activities found.'**
  String get activitiesNoActivities;

  /// No description provided for @activitiesReopen.
  ///
  /// In en, this message translates to:
  /// **'Reopen Activity'**
  String get activitiesReopen;

  /// No description provided for @activityDetailsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get activityDetailsCancel;

  /// No description provided for @activityDetailsConfirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get activityDetailsConfirmDelete;

  /// No description provided for @activityDetailsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get activityDetailsDelete;

  /// No description provided for @activityDetailsDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete activity.'**
  String get activityDetailsDeleteError;

  /// No description provided for @activityDetailsDeletePrompt.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this activity?'**
  String get activityDetailsDeletePrompt;

  /// No description provided for @activityDetailsDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Activity has been deleted.'**
  String get activityDetailsDeleteSuccess;

  /// No description provided for @activityDetailsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get activityDetailsDeleted;

  /// No description provided for @activityDetailsDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get activityDetailsDescription;

  /// No description provided for @activityDetailsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get activityDetailsEdit;

  /// No description provided for @activityDetailsParticipants.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get activityDetailsParticipants;

  /// No description provided for @activityDetailsStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get activityDetailsStatus;

  /// No description provided for @activityDetailsViewInsights.
  ///
  /// In en, this message translates to:
  /// **'View Insights'**
  String get activityDetailsViewInsights;

  /// No description provided for @activityInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity Insights'**
  String get activityInsightsTitle;

  /// No description provided for @addNewUser.
  ///
  /// In en, this message translates to:
  /// **'Add New Client'**
  String get addNewUser;

  /// No description provided for @analyticsBookingGrowth.
  ///
  /// In en, this message translates to:
  /// **'Booking Growth'**
  String get analyticsBookingGrowth;

  /// No description provided for @analyticsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get analyticsCancel;

  /// No description provided for @analyticsCustomerRetention.
  ///
  /// In en, this message translates to:
  /// **'Customer Retention'**
  String get analyticsCustomerRetention;

  /// No description provided for @analyticsDownloadReport.
  ///
  /// In en, this message translates to:
  /// **'Download PDF Report'**
  String get analyticsDownloadReport;

  /// No description provided for @analyticsPeakHours.
  ///
  /// In en, this message translates to:
  /// **'Peak Hours'**
  String get analyticsPeakHours;

  /// No description provided for @analyticsReportDate.
  ///
  /// In en, this message translates to:
  /// **'Report Date'**
  String get analyticsReportDate;

  /// No description provided for @analyticsRevenueOverview.
  ///
  /// In en, this message translates to:
  /// **'Revenue Overview'**
  String get analyticsRevenueOverview;

  /// No description provided for @analyticsShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get analyticsShare;

  /// No description provided for @analyticsShareMessage.
  ///
  /// In en, this message translates to:
  /// **'Your PDF has been saved in the Downloads folder.\nWould you like to share it now?'**
  String get analyticsShareMessage;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Business Analytics'**
  String get analyticsTitle;

  /// No description provided for @analyticsToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get analyticsToday;

  /// No description provided for @analyticsTopActivity.
  ///
  /// In en, this message translates to:
  /// **'Top Activity'**
  String get analyticsTopActivity;

  /// No description provided for @analyticsTotalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get analyticsTotalRevenue;

  /// No description provided for @analyticsYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get analyticsYesterday;

  /// No description provided for @assignToActivity.
  ///
  /// In en, this message translates to:
  /// **'Assign to Activity'**
  String get assignToActivity;

  /// No description provided for @authNotLoggedInMessage.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to access this feature.'**
  String get authNotLoggedInMessage;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @businessWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to your dashboard!'**
  String get businessWelcomeTitle;

  /// No description provided for @businessWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your activities and engage with users easily.'**
  String get businessWelcomeSubtitle;

  /// No description provided for @createNewActivity.
  ///
  /// In en, this message translates to:
  /// **'Create New Activity'**
  String get createNewActivity;

  /// No description provided for @activitiesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No activities yet'**
  String get activitiesEmpty;

  /// No description provided for @authNotLoggedInTitle.
  ///
  /// In en, this message translates to:
  /// **'Not Logged In'**
  String get authNotLoggedInTitle;

  /// App title
  ///
  /// In en, this message translates to:
  /// **'Hobby Sphere'**
  String get appTitle;

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get splashLoading;

  /// No description provided for @bookingAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get bookingAbout;

  /// No description provided for @bookingApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get bookingApprove;

  /// No description provided for @bookingBookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookingBookNow;

  /// No description provided for @bookingBooking.
  ///
  /// In en, this message translates to:
  /// **'Booking...'**
  String get bookingBooking;

  /// No description provided for @bookingCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get bookingCancel;

  /// No description provided for @bookingCancelReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get bookingCancelReason;

  /// No description provided for @bookingConfirmRejectMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reject this booking?'**
  String get bookingConfirmRejectMessage;

  /// No description provided for @bookingConfirmRejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject Booking'**
  String get bookingConfirmRejectTitle;

  /// No description provided for @bookingConfirmUnrejectMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to undo the rejection?'**
  String get bookingConfirmUnrejectMessage;

  /// No description provided for @bookingConfirmUnrejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Undo Rejection'**
  String get bookingConfirmUnrejectTitle;

  /// No description provided for @bookingConfirm_approveCancel.
  ///
  /// In en, this message translates to:
  /// **'Approve Cancellation'**
  String get bookingConfirm_approveCancel;

  /// No description provided for @bookingConfirm_reject.
  ///
  /// In en, this message translates to:
  /// **'Confirm Reject'**
  String get bookingConfirm_reject;

  /// No description provided for @bookingConfirm_rejectCancel.
  ///
  /// In en, this message translates to:
  /// **'Reject Cancellation'**
  String get bookingConfirm_rejectCancel;

  /// No description provided for @bookingConfirm_unreject.
  ///
  /// In en, this message translates to:
  /// **'Confirm Unreject'**
  String get bookingConfirm_unreject;

  /// No description provided for @bookingErrorFailed.
  ///
  /// In en, this message translates to:
  /// **'Booking failed. Please try again.'**
  String get bookingErrorFailed;

  /// No description provided for @bookingErrorLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to book.'**
  String get bookingErrorLoginRequired;

  /// No description provided for @bookingErrorMaxParticipantsReached.
  ///
  /// In en, this message translates to:
  /// **'You cannot book more than the maximum allowed participants.'**
  String get bookingErrorMaxParticipantsReached;

  /// No description provided for @bookingLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get bookingLocation;

  /// No description provided for @bookingMaxParticipants.
  ///
  /// In en, this message translates to:
  /// **'Max {count} participants'**
  String bookingMaxParticipants(int count);

  /// No description provided for @bookingMessage_approveCancel.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to approve this cancellation request?'**
  String get bookingMessage_approveCancel;

  /// No description provided for @bookingMessage_reject.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reject this booking?'**
  String get bookingMessage_reject;

  /// No description provided for @bookingMessage_rejectCancel.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reject this cancellation request?'**
  String get bookingMessage_rejectCancel;

  /// No description provided for @bookingMessage_unreject.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unreject this booking?'**
  String get bookingMessage_unreject;

  /// No description provided for @bookingMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get bookingMethod;

  /// No description provided for @bookingMissing.
  ///
  /// In en, this message translates to:
  /// **'Booking ID or token is missing'**
  String get bookingMissing;

  /// No description provided for @bookingParticipants.
  ///
  /// In en, this message translates to:
  /// **'Number of Participants'**
  String get bookingParticipants;

  /// No description provided for @bookingPaymentCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get bookingPaymentCash;

  /// No description provided for @bookingPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get bookingPaymentMethod;

  /// No description provided for @bookingPerPerson.
  ///
  /// In en, this message translates to:
  /// **'per person'**
  String get bookingPerPerson;

  /// No description provided for @bookingPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get bookingPrice;

  /// No description provided for @bookingProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get bookingProcessing;

  /// No description provided for @bookingReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get bookingReject;

  /// No description provided for @bookingRejectCancel.
  ///
  /// In en, this message translates to:
  /// **'Reject Cancellation'**
  String get bookingRejectCancel;

  /// No description provided for @bookingTotal.
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get bookingTotal;

  /// No description provided for @bookingTotalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get bookingTotalPrice;

  /// No description provided for @bookingUnreject.
  ///
  /// In en, this message translates to:
  /// **'Unreject'**
  String get bookingUnreject;

  /// No description provided for @bookingUpdated.
  ///
  /// In en, this message translates to:
  /// **'Booking updated successfully'**
  String get bookingUpdated;

  /// No description provided for @bookingsFiltersAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get bookingsFiltersAll;

  /// No description provided for @bookingsFiltersCanceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get bookingsFiltersCanceled;

  /// No description provided for @bookingsFiltersCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get bookingsFiltersCompleted;

  /// No description provided for @bookingsFiltersPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get bookingsFiltersPending;

  /// No description provided for @bookingsFiltersRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get bookingsFiltersRejected;

  /// No description provided for @bookingsNoBookings.
  ///
  /// In en, this message translates to:
  /// **'No bookings found for \"{status}\".'**
  String bookingsNoBookings(String status);

  /// No description provided for @bookingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Business Bookings'**
  String get bookingsTitle;

  /// No description provided for @businessCreateActivity.
  ///
  /// In en, this message translates to:
  /// **'Create New Activity'**
  String get businessCreateActivity;

  /// No description provided for @businessGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello,'**
  String get businessGreeting;

  /// No description provided for @businessManageText.
  ///
  /// In en, this message translates to:
  /// **'Manage your activities and engage with users easily.'**
  String get businessManageText;

  /// No description provided for @businessNoActivities.
  ///
  /// In en, this message translates to:
  /// **'No activities found. Start by creating one!'**
  String get businessNoActivities;

  /// No description provided for @businessUsers.
  ///
  /// In en, this message translates to:
  /// **'Business Users'**
  String get businessUsers;

  /// No description provided for @businessWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to your dashboard!'**
  String get businessWelcome;

  /// No description provided for @businessYourActivities.
  ///
  /// In en, this message translates to:
  /// **'Your Activities'**
  String get businessYourActivities;

  /// No description provided for @buttonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// No description provided for @buttonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get buttonConfirm;

  /// No description provided for @buttonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get buttonDelete;

  /// No description provided for @buttonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get buttonLoading;

  /// No description provided for @buttonLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get buttonLogin;

  /// No description provided for @buttonLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get buttonLogout;

  /// No description provided for @buttonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get buttonOk;

  /// No description provided for @buttonRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get buttonRegister;

  /// No description provided for @buttonSendInvite.
  ///
  /// In en, this message translates to:
  /// **'Send Invite'**
  String get buttonSendInvite;

  /// No description provided for @buttonSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get buttonSubmit;

  /// No description provided for @buttonsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonsCancel;

  /// No description provided for @buttonsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get buttonsConfirm;

  /// No description provided for @buttonsContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get buttonsContinue;

  /// No description provided for @buttonsFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get buttonsFinish;

  /// No description provided for @buttonsLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get buttonsLogin;

  /// No description provided for @buttonsRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get buttonsRegister;

  /// No description provided for @buttonsSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get buttonsSeeAll;

  /// No description provided for @buttonsSeeLess.
  ///
  /// In en, this message translates to:
  /// **'See Less'**
  String get buttonsSeeLess;

  /// No description provided for @buttonsSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get buttonsSubmitting;

  /// No description provided for @calendarNoActivities.
  ///
  /// In en, this message translates to:
  /// **'No activities found.'**
  String get calendarNoActivities;

  /// No description provided for @calendarNoActivitiesForDate.
  ///
  /// In en, this message translates to:
  /// **'No activities for the selected date.'**
  String get calendarNoActivitiesForDate;

  /// No description provided for @calendarTabsPast.
  ///
  /// In en, this message translates to:
  /// **'Past Activities'**
  String get calendarTabsPast;

  /// No description provided for @calendarTabsUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get calendarTabsUpcoming;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @chatNoFriends.
  ///
  /// In en, this message translates to:
  /// **'Add a friend to start chatting!'**
  String get chatNoFriends;

  /// No description provided for @chatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to start chatting'**
  String get chatSubtitle;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'My Friends'**
  String get chatTitle;

  /// No description provided for @chatfriendSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to start chatting'**
  String get chatfriendSubtitle;

  /// No description provided for @chatfriendTitle.
  ///
  /// In en, this message translates to:
  /// **'My Friends'**
  String get chatfriendTitle;

  /// No description provided for @commentEmpty.
  ///
  /// In en, this message translates to:
  /// **'No comments yet.'**
  String get commentEmpty;

  /// No description provided for @commentLike.
  ///
  /// In en, this message translates to:
  /// **'like'**
  String get commentLike;

  /// No description provided for @commentLikes.
  ///
  /// In en, this message translates to:
  /// **'likes'**
  String get commentLikes;

  /// No description provided for @commentPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Write a comment...'**
  String get commentPlaceholder;

  /// No description provided for @commonAreYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get commonAreYouSure;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @createActivityActivityName.
  ///
  /// In en, this message translates to:
  /// **'Activity Name'**
  String get createActivityActivityName;

  /// No description provided for @createActivityActivityType.
  ///
  /// In en, this message translates to:
  /// **'Activity Type'**
  String get createActivityActivityType;

  /// No description provided for @createActivityChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get createActivityChange;

  /// No description provided for @createActivityChooseLibrary.
  ///
  /// In en, this message translates to:
  /// **'Choose from library'**
  String get createActivityChooseLibrary;

  /// No description provided for @createActivityDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get createActivityDescription;

  /// No description provided for @createActivityEndDate.
  ///
  /// In en, this message translates to:
  /// **'End Date & Time'**
  String get createActivityEndDate;

  /// No description provided for @createActivityErrorRequired.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields.'**
  String get createActivityErrorRequired;

  /// No description provided for @createActivityFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to create activity. Try again.'**
  String get createActivityFail;

  /// No description provided for @createActivityGetMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Get My Location'**
  String get createActivityGetMyLocation;

  /// No description provided for @createActivityLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get createActivityLocation;

  /// No description provided for @createActivityLocationErrorPermission.
  ///
  /// In en, this message translates to:
  /// **'Please enable GPS to detect your current location.'**
  String get createActivityLocationErrorPermission;

  /// No description provided for @createActivityLocationErrorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Location request timed out.'**
  String get createActivityLocationErrorTimeout;

  /// No description provided for @createActivityLocationErrorUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unable to get your location.'**
  String get createActivityLocationErrorUnavailable;

  /// No description provided for @createActivityMaxParticipants.
  ///
  /// In en, this message translates to:
  /// **'Max Participants'**
  String get createActivityMaxParticipants;

  /// No description provided for @createActivityPickHint.
  ///
  /// In en, this message translates to:
  /// **'Take a photo or choose from library'**
  String get createActivityPickHint;

  /// No description provided for @createActivityPickImage.
  ///
  /// In en, this message translates to:
  /// **'Pick an Image'**
  String get createActivityPickImage;

  /// No description provided for @createActivityPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get createActivityPrice;

  /// No description provided for @createActivityRemovePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get createActivityRemovePhoto;

  /// No description provided for @createActivitySearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search activity types...'**
  String get createActivitySearchPlaceholder;

  /// No description provided for @createActivitySelectType.
  ///
  /// In en, this message translates to:
  /// **'Select Activity Type'**
  String get createActivitySelectType;

  /// No description provided for @createActivityStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date & Time'**
  String get createActivityStartDate;

  /// No description provided for @createActivityStripeRequired.
  ///
  /// In en, this message translates to:
  /// **'You must connect a Stripe account before creating an activity.'**
  String get createActivityStripeRequired;

  /// No description provided for @createActivitySubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get createActivitySubmit;

  /// No description provided for @createActivitySuccess.
  ///
  /// In en, this message translates to:
  /// **'Activity created successfully!'**
  String get createActivitySuccess;

  /// No description provided for @createActivityTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get createActivityTakePhoto;

  /// No description provided for @createActivityTapToPick.
  ///
  /// In en, this message translates to:
  /// **'Tap to pick'**
  String get createActivityTapToPick;

  /// No description provided for @createActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Activity'**
  String get createActivityTitle;

  /// No description provided for @createPostCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get createPostCancel;

  /// No description provided for @createPostClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get createPostClose;

  /// No description provided for @createPostEmojiTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your feeling'**
  String get createPostEmojiTitle;

  /// No description provided for @createPostEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Post content cannot be empty.'**
  String get createPostEmptyError;

  /// No description provided for @createPostFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to create post'**
  String get createPostFail;

  /// No description provided for @createPostFeeling.
  ///
  /// In en, this message translates to:
  /// **'Feeling'**
  String get createPostFeeling;

  /// No description provided for @createPostFriendsOnly.
  ///
  /// In en, this message translates to:
  /// **'Friends Only'**
  String get createPostFriendsOnly;

  /// No description provided for @createPostHashtagsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'#hashtags (optional)'**
  String get createPostHashtagsPlaceholder;

  /// No description provided for @createPostImage.
  ///
  /// In en, this message translates to:
  /// **'Post image'**
  String get createPostImage;

  /// No description provided for @createPostPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get createPostPhoto;

  /// No description provided for @createPostPickHint.
  ///
  /// In en, this message translates to:
  /// **'Take a photo or choose from gallery'**
  String get createPostPickHint;

  /// No description provided for @createPostPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind?'**
  String get createPostPlaceholder;

  /// No description provided for @createPostPost.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get createPostPost;

  /// No description provided for @createPostPublic.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get createPostPublic;

  /// No description provided for @createPostSelectEmojiTitle.
  ///
  /// In en, this message translates to:
  /// **'Select an Emoji'**
  String get createPostSelectEmojiTitle;

  /// No description provided for @createPostSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your post has been published!'**
  String get createPostSuccess;

  /// No description provided for @createPostVisibilityAnyone.
  ///
  /// In en, this message translates to:
  /// **'Anyone'**
  String get createPostVisibilityAnyone;

  /// No description provided for @createPostVisibilityFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get createPostVisibilityFriends;

  /// No description provided for @createPostVisibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Post Visibility'**
  String get createPostVisibilityTitle;

  /// No description provided for @editActivityDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get editActivityDescription;

  /// No description provided for @editActivityEnd.
  ///
  /// In en, this message translates to:
  /// **'End Date & Time'**
  String get editActivityEnd;

  /// No description provided for @editActivityFailure.
  ///
  /// In en, this message translates to:
  /// **'Failed to update activity.'**
  String get editActivityFailure;

  /// No description provided for @editActivityLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get editActivityLocation;

  /// No description provided for @editActivityName.
  ///
  /// In en, this message translates to:
  /// **'Activity Name'**
  String get editActivityName;

  /// No description provided for @editActivityParticipants.
  ///
  /// In en, this message translates to:
  /// **'Max Participants'**
  String get editActivityParticipants;

  /// No description provided for @editActivityPrice.
  ///
  /// In en, this message translates to:
  /// **'Price ()'**
  String get editActivityPrice;

  /// No description provided for @editActivityStart.
  ///
  /// In en, this message translates to:
  /// **'Start Date & Time'**
  String get editActivityStart;

  /// No description provided for @editActivityStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get editActivityStatus;

  /// No description provided for @editActivitySuccess.
  ///
  /// In en, this message translates to:
  /// **'Activity has been updated successfully.'**
  String get editActivitySuccess;

  /// No description provided for @editActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Activity'**
  String get editActivityTitle;

  /// No description provided for @editActivityUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update Activity'**
  String get editActivityUpdate;

  /// No description provided for @editBusinessAddBanner.
  ///
  /// In en, this message translates to:
  /// **'Add banner'**
  String get editBusinessAddBanner;

  /// No description provided for @editBusinessAlert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get editBusinessAlert;

  /// No description provided for @editBusinessBannerDeleted.
  ///
  /// In en, this message translates to:
  /// **'Banner removed.'**
  String get editBusinessBannerDeleted;

  /// No description provided for @editBusinessBannerHint.
  ///
  /// In en, this message translates to:
  /// **'Take a photo or choose from gallery'**
  String get editBusinessBannerHint;

  /// No description provided for @editBusinessBannerImage.
  ///
  /// In en, this message translates to:
  /// **'Banner image'**
  String get editBusinessBannerImage;

  /// No description provided for @editBusinessBusinessName.
  ///
  /// In en, this message translates to:
  /// **'Business Name'**
  String get editBusinessBusinessName;

  /// No description provided for @editBusinessCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get editBusinessCancel;

  /// No description provided for @editBusinessConfirmDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get editBusinessConfirmDeleteMessage;

  /// No description provided for @editBusinessConfirmDeletePassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password to Delete Account'**
  String get editBusinessConfirmDeletePassword;

  /// No description provided for @editBusinessConfirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Account Deletion'**
  String get editBusinessConfirmDeleteTitle;

  /// No description provided for @editBusinessConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get editBusinessConfirmPassword;

  /// No description provided for @editBusinessCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get editBusinessCurrentPassword;

  /// No description provided for @editBusinessDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get editBusinessDelete;

  /// No description provided for @editBusinessDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get editBusinessDeleteAccount;

  /// No description provided for @editBusinessDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete the account. Please try again.'**
  String get editBusinessDeleteFailed;

  /// No description provided for @editBusinessDeleteLogoFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete logo.'**
  String get editBusinessDeleteLogoFailed;

  /// No description provided for @editBusinessDeleting.
  ///
  /// In en, this message translates to:
  /// **'Deleting...'**
  String get editBusinessDeleting;

  /// No description provided for @editBusinessDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get editBusinessDescription;

  /// No description provided for @editBusinessEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get editBusinessEmail;

  /// No description provided for @editBusinessEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get editBusinessEnterPassword;

  /// No description provided for @editBusinessEnterPasswordToDelete.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password to delete the account.'**
  String get editBusinessEnterPasswordToDelete;

  /// No description provided for @editBusinessErrorDelete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete business.'**
  String get editBusinessErrorDelete;

  /// No description provided for @editBusinessIncorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Please try again.'**
  String get editBusinessIncorrectPassword;

  /// No description provided for @editBusinessLogoDeleted.
  ///
  /// In en, this message translates to:
  /// **'Logo removed.'**
  String get editBusinessLogoDeleted;

  /// No description provided for @editBusinessNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get editBusinessNewPassword;

  /// No description provided for @editBusinessOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get editBusinessOk;

  /// No description provided for @editBusinessPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get editBusinessPasswordMismatch;

  /// No description provided for @editBusinessPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters long.'**
  String get editBusinessPasswordTooShort;

  /// No description provided for @editBusinessPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get editBusinessPhoneNumber;

  /// No description provided for @editBusinessSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get editBusinessSaveChanges;

  /// No description provided for @editBusinessSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get editBusinessSaving;

  /// No description provided for @editBusinessSuccessDelete.
  ///
  /// In en, this message translates to:
  /// **'Business deleted successfully.'**
  String get editBusinessSuccessDelete;

  /// No description provided for @editBusinessTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Business Profile'**
  String get editBusinessTitle;

  /// No description provided for @editBusinessUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile.'**
  String get editBusinessUpdateFailed;

  /// No description provided for @editBusinessUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Business profile updated successfully.'**
  String get editBusinessUpdateSuccess;

  /// No description provided for @editBusinessWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get editBusinessWebsite;

  /// No description provided for @editProfileCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get editProfileCancel;

  /// No description provided for @editProfileConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get editProfileConfirmPassword;

  /// No description provided for @editProfileContact.
  ///
  /// In en, this message translates to:
  /// **'Contact Number'**
  String get editProfileContact;

  /// No description provided for @editProfileCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get editProfileCurrentPassword;

  /// No description provided for @editProfileDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get editProfileDelete;

  /// No description provided for @editProfileDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get editProfileDeleteAccount;

  /// No description provided for @editProfileDeleteConfirmMsg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get editProfileDeleteConfirmMsg;

  /// No description provided for @editProfileDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Account Deletion'**
  String get editProfileDeleteConfirmTitle;

  /// No description provided for @editProfileDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account.'**
  String get editProfileDeleteFailed;

  /// No description provided for @editProfileDeleteInfoWarning.
  ///
  /// In en, this message translates to:
  /// **'You signed in with Google, please set a password first if not already set.'**
  String get editProfileDeleteInfoWarning;

  /// No description provided for @editProfileDeleteProfileImage.
  ///
  /// In en, this message translates to:
  /// **'Remove Profile Image'**
  String get editProfileDeleteProfileImage;

  /// No description provided for @editProfileDeleteProfileImageConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your profile picture?'**
  String get editProfileDeleteProfileImageConfirm;

  /// No description provided for @editProfileDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully.'**
  String get editProfileDeleteSuccess;

  /// No description provided for @editProfileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get editProfileEmail;

  /// No description provided for @editProfileFirstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get editProfileFirstName;

  /// No description provided for @editProfileImageSelectedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Image selected.'**
  String get editProfileImageSelectedSuccess;

  /// No description provided for @editProfileImageSelectionCancelled.
  ///
  /// In en, this message translates to:
  /// **'Image selection cancelled.'**
  String get editProfileImageSelectionCancelled;

  /// No description provided for @editProfileImageSelectionError.
  ///
  /// In en, this message translates to:
  /// **'Could not open image picker.'**
  String get editProfileImageSelectionError;

  /// No description provided for @editProfileLastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get editProfileLastName;

  /// No description provided for @editProfileNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get editProfileNewPassword;

  /// No description provided for @editProfilePasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get editProfilePasswordMismatch;

  /// No description provided for @editProfilePasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your current password.'**
  String get editProfilePasswordRequired;

  /// No description provided for @editProfilePickHint.
  ///
  /// In en, this message translates to:
  /// **'Take a photo or choose from gallery'**
  String get editProfilePickHint;

  /// No description provided for @editProfileProfileImage.
  ///
  /// In en, this message translates to:
  /// **'profile image'**
  String get editProfileProfileImage;

  /// No description provided for @editProfileProfileImageDeleted.
  ///
  /// In en, this message translates to:
  /// **'Profile image removed.'**
  String get editProfileProfileImageDeleted;

  /// No description provided for @editProfileSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get editProfileSaveChanges;

  /// No description provided for @editProfileSelectImage.
  ///
  /// In en, this message translates to:
  /// **'Select Profile Image'**
  String get editProfileSelectImage;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @editProfileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile.'**
  String get editProfileUpdateFailed;

  /// No description provided for @editProfileUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully.'**
  String get editProfileUpdateSuccess;

  /// No description provided for @editProfileUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get editProfileUsername;

  /// No description provided for @editProfileWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Please try again.'**
  String get editProfileWrongPassword;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailRegistrationContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get emailRegistrationContinue;

  /// No description provided for @emailRegistrationCreatePassword.
  ///
  /// In en, this message translates to:
  /// **'Create password'**
  String get emailRegistrationCreatePassword;

  /// No description provided for @emailRegistrationEmailDesc.
  ///
  /// In en, this message translates to:
  /// **'You’ll receive a verification code via email. Your email address may be used to connect you with others, improve ads, and more, depending on your settings.'**
  String get emailRegistrationEmailDesc;

  /// No description provided for @emailRegistrationEmailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailRegistrationEmailPlaceholder;

  /// No description provided for @emailRegistrationEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get emailRegistrationEnterEmail;

  /// No description provided for @emailRegistrationErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get emailRegistrationErrorGeneric;

  /// No description provided for @emailRegistrationLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get emailRegistrationLoading;

  /// No description provided for @emailRegistrationPasswordPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get emailRegistrationPasswordPlaceholder;

  /// No description provided for @emailRegistrationRule1.
  ///
  /// In en, this message translates to:
  /// **'• 8 characters (20 max)'**
  String get emailRegistrationRule1;

  /// No description provided for @emailRegistrationRule2.
  ///
  /// In en, this message translates to:
  /// **'• 1 letter, 1 number, 1 special character (# ? ! @)'**
  String get emailRegistrationRule2;

  /// No description provided for @emailRegistrationSaveInfo.
  ///
  /// In en, this message translates to:
  /// **'Get trending content, newsletters, and updates sent to your email'**
  String get emailRegistrationSaveInfo;

  /// No description provided for @emailRegistrationSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get emailRegistrationSignUp;

  /// No description provided for @emailRegistrationVerificationSent.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent to email.'**
  String get emailRegistrationVerificationSent;

  /// No description provided for @exploreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover different business profiles and their services'**
  String get exploreSubtitle;

  /// No description provided for @exploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore Businesses'**
  String get exploreTitle;

  /// No description provided for @exportExcel.
  ///
  /// In en, this message translates to:
  /// **'Export Excel'**
  String get exportExcel;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @filtersAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filtersAll;

  /// No description provided for @filtersNotPaid.
  ///
  /// In en, this message translates to:
  /// **'Not Paid'**
  String get filtersNotPaid;

  /// No description provided for @filtersPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get filtersPaid;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @forgetPasswordEmailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get forgetPasswordEmailPlaceholder;

  /// No description provided for @forgetPasswordEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email.'**
  String get forgetPasswordEnterEmail;

  /// No description provided for @forgetPasswordGeneralError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get forgetPasswordGeneralError;

  /// No description provided for @forgetPasswordSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get forgetPasswordSendCode;

  /// No description provided for @forgetPasswordSending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get forgetPasswordSending;

  /// No description provided for @forgetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Resetting password for: {role}'**
  String forgetPasswordSubtitle(String role);

  /// No description provided for @forgetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get forgetPasswordTitle;

  /// No description provided for @forgetPasswordUnableToSend.
  ///
  /// In en, this message translates to:
  /// **'Unable to send reset code.'**
  String get forgetPasswordUnableToSend;

  /// No description provided for @friendAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get friendAccept;

  /// No description provided for @friendAccepted.
  ///
  /// In en, this message translates to:
  /// **'Friend request accepted.'**
  String get friendAccepted;

  /// No description provided for @friendCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get friendCancel;

  /// No description provided for @friendCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled.'**
  String get friendCancelled;

  /// No description provided for @friendChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get friendChat;

  /// No description provided for @friendConfirmUnfriendText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unfriend this user?'**
  String get friendConfirmUnfriendText;

  /// No description provided for @friendConfirmUnfriendTitle.
  ///
  /// In en, this message translates to:
  /// **'Unfriend'**
  String get friendConfirmUnfriendTitle;

  /// No description provided for @friendErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data.'**
  String get friendErrorLoad;

  /// No description provided for @friendFailedAction.
  ///
  /// In en, this message translates to:
  /// **'Action failed. Try again.'**
  String get friendFailedAction;

  /// No description provided for @friendNoFriends.
  ///
  /// In en, this message translates to:
  /// **'You don’t have any friends yet. Start adding some!'**
  String get friendNoFriends;

  /// No description provided for @friendNoUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No {tab} users found.'**
  String friendNoUsersFound(String tab);

  /// No description provided for @friendReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get friendReject;

  /// No description provided for @friendRejected.
  ///
  /// In en, this message translates to:
  /// **'Friend request rejected.'**
  String get friendRejected;

  /// No description provided for @friendTabFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friendTabFriends;

  /// No description provided for @friendTabReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get friendTabReceived;

  /// No description provided for @friendTabSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get friendTabSent;

  /// No description provided for @friendTab_friends.
  ///
  /// In en, this message translates to:
  /// **'friends'**
  String get friendTab_friends;

  /// No description provided for @friendTab_received.
  ///
  /// In en, this message translates to:
  /// **'received'**
  String get friendTab_received;

  /// No description provided for @friendTab_sent.
  ///
  /// In en, this message translates to:
  /// **'sent'**
  String get friendTab_sent;

  /// No description provided for @friendTotalFriends.
  ///
  /// In en, this message translates to:
  /// **'You have {count} friends'**
  String friendTotalFriends(int count);

  /// No description provided for @friendUnfriend.
  ///
  /// In en, this message translates to:
  /// **'Unfriend'**
  String get friendUnfriend;

  /// No description provided for @friendUnfriended.
  ///
  /// In en, this message translates to:
  /// **'Unfriended successfully.'**
  String get friendUnfriended;

  /// No description provided for @friendshipAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get friendshipAccept;

  /// No description provided for @friendshipAddFriendAll.
  ///
  /// In en, this message translates to:
  /// **'All Users'**
  String get friendshipAddFriendAll;

  /// No description provided for @friendshipAddFriendAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available to add'**
  String get friendshipAddFriendAvailable;

  /// No description provided for @friendshipAddFriendError.
  ///
  /// In en, this message translates to:
  /// **'Failed to send friend request.'**
  String get friendshipAddFriendError;

  /// No description provided for @friendshipAddFriendNoUsers.
  ///
  /// In en, this message translates to:
  /// **'No users found.'**
  String get friendshipAddFriendNoUsers;

  /// No description provided for @friendshipAddFriendSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search users...'**
  String get friendshipAddFriendSearchPlaceholder;

  /// No description provided for @friendshipAddFriendSuccess.
  ///
  /// In en, this message translates to:
  /// **'Friend request sent.'**
  String get friendshipAddFriendSuccess;

  /// No description provided for @friendshipAddFriendSuggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested Users'**
  String get friendshipAddFriendSuggested;

  /// No description provided for @friendshipAddFriendViewFriends.
  ///
  /// In en, this message translates to:
  /// **'View Friends'**
  String get friendshipAddFriendViewFriends;

  /// No description provided for @friendshipAddFriendViewReceived.
  ///
  /// In en, this message translates to:
  /// **'View Received Requests'**
  String get friendshipAddFriendViewReceived;

  /// No description provided for @friendshipAddFriendViewSent.
  ///
  /// In en, this message translates to:
  /// **'View Sent Requests'**
  String get friendshipAddFriendViewSent;

  /// No description provided for @friendshipBlock.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get friendshipBlock;

  /// No description provided for @friendshipCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get friendshipCancelRequest;

  /// No description provided for @friendshipConfirmBlock.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to block this user?'**
  String get friendshipConfirmBlock;

  /// No description provided for @friendshipConfirmUnblock.
  ///
  /// In en, this message translates to:
  /// **'Do you want to unblock this user?'**
  String get friendshipConfirmUnblock;

  /// No description provided for @friendshipConfirmUnfriend.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unfriend this user?'**
  String get friendshipConfirmUnfriend;

  /// No description provided for @friendshipErrorAlreadyFriends.
  ///
  /// In en, this message translates to:
  /// **'You are already friends with this user.'**
  String get friendshipErrorAlreadyFriends;

  /// No description provided for @friendshipErrorFailedAction.
  ///
  /// In en, this message translates to:
  /// **'Action failed. Please try again.'**
  String get friendshipErrorFailedAction;

  /// No description provided for @friendshipErrorNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found.'**
  String get friendshipErrorNotFound;

  /// No description provided for @friendshipErrorRequestExists.
  ///
  /// In en, this message translates to:
  /// **'Friend request already sent.'**
  String get friendshipErrorRequestExists;

  /// No description provided for @friendshipFriendAdded.
  ///
  /// In en, this message translates to:
  /// **'Friend added successfully.'**
  String get friendshipFriendAdded;

  /// No description provided for @friendshipFriendBlocked.
  ///
  /// In en, this message translates to:
  /// **'User has been blocked.'**
  String get friendshipFriendBlocked;

  /// No description provided for @friendshipFriendRemoved.
  ///
  /// In en, this message translates to:
  /// **'Friend removed.'**
  String get friendshipFriendRemoved;

  /// No description provided for @friendshipFriendUnblocked.
  ///
  /// In en, this message translates to:
  /// **'User has been unblocked.'**
  String get friendshipFriendUnblocked;

  /// No description provided for @friendshipMyFriends.
  ///
  /// In en, this message translates to:
  /// **'My Friends'**
  String get friendshipMyFriends;

  /// No description provided for @friendshipNoFriends.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added any friends yet.'**
  String get friendshipNoFriends;

  /// No description provided for @friendshipNoRequests.
  ///
  /// In en, this message translates to:
  /// **'No friend requests found.'**
  String get friendshipNoRequests;

  /// No description provided for @friendshipReceivedRequests.
  ///
  /// In en, this message translates to:
  /// **'Received Requests'**
  String get friendshipReceivedRequests;

  /// No description provided for @friendshipReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get friendshipReject;

  /// No description provided for @friendshipRequestAccepted.
  ///
  /// In en, this message translates to:
  /// **'Friend request accepted.'**
  String get friendshipRequestAccepted;

  /// No description provided for @friendshipRequestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled.'**
  String get friendshipRequestCancelled;

  /// No description provided for @friendshipRequestRejected.
  ///
  /// In en, this message translates to:
  /// **'Friend request rejected.'**
  String get friendshipRequestRejected;

  /// No description provided for @friendshipRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Friend request sent.'**
  String get friendshipRequestSent;

  /// No description provided for @friendshipSendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Friend Request'**
  String get friendshipSendRequest;

  /// No description provided for @friendshipSentRequests.
  ///
  /// In en, this message translates to:
  /// **'Sent Requests'**
  String get friendshipSentRequests;

  /// No description provided for @friendshipTitle.
  ///
  /// In en, this message translates to:
  /// **'Friend Requests'**
  String get friendshipTitle;

  /// No description provided for @friendshipUnblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get friendshipUnblock;

  /// No description provided for @friendshipUnfriend.
  ///
  /// In en, this message translates to:
  /// **'Unfriend'**
  String get friendshipUnfriend;

  /// No description provided for @generalLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get generalLoading;

  /// No description provided for @globalError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get globalError;

  /// No description provided for @globalSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get globalSuccess;

  /// No description provided for @homeActivityCategories.
  ///
  /// In en, this message translates to:
  /// **' Categories'**
  String get homeActivityCategories;

  /// No description provided for @homeCancelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel this ticket?'**
  String get homeCancelConfirm;

  /// No description provided for @homeCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get homeCancelTitle;

  /// No description provided for @homeExploreActivities.
  ///
  /// In en, this message translates to:
  /// **'Explore Activities'**
  String get homeExploreActivities;

  /// No description provided for @homeExploreCategories.
  ///
  /// In en, this message translates to:
  /// **'Explore Categories'**
  String get homeExploreCategories;

  /// No description provided for @homeExploreMessage.
  ///
  /// In en, this message translates to:
  /// **'Find new experiences you’ll love'**
  String get homeExploreMessage;

  /// No description provided for @homeFindActivity.
  ///
  /// In en, this message translates to:
  /// **'Find your favourite activity'**
  String get homeFindActivity;

  /// No description provided for @homeInterestBasedTitle.
  ///
  /// In en, this message translates to:
  /// **'The Activities that interest you'**
  String get homeInterestBasedTitle;

  /// No description provided for @homeLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get homeLoadMore;

  /// No description provided for @homeLoadingActivities.
  ///
  /// In en, this message translates to:
  /// **'Loading activities...'**
  String get homeLoadingActivities;

  /// No description provided for @homeLoadingBookings.
  ///
  /// In en, this message translates to:
  /// **'Loading your bookings...'**
  String get homeLoadingBookings;

  /// No description provided for @homeLoadingInterestActivities.
  ///
  /// In en, this message translates to:
  /// **'Loading interest-based activities...'**
  String get homeLoadingInterestActivities;

  /// No description provided for @homeMoreActivities.
  ///
  /// In en, this message translates to:
  /// **'More Activities'**
  String get homeMoreActivities;

  /// No description provided for @homeNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get homeNo;

  /// No description provided for @homeNoActivities.
  ///
  /// In en, this message translates to:
  /// **'No activities found for this category.'**
  String get homeNoActivities;

  /// No description provided for @homeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get homeSeeAll;

  /// No description provided for @homeSeeAllCategories.
  ///
  /// In en, this message translates to:
  /// **'See All Categories'**
  String get homeSeeAllCategories;

  /// No description provided for @homeShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show All'**
  String get homeShowAll;

  /// No description provided for @homeShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get homeShowLess;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get homeWelcome;

  /// No description provided for @homeYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get homeYes;

  /// No description provided for @homeYourBookings.
  ///
  /// In en, this message translates to:
  /// **'Your Bookings Activities'**
  String get homeYourBookings;

  /// No description provided for @insightsAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get insightsAction;

  /// No description provided for @insightsItem.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get insightsItem;

  /// No description provided for @insightsName.
  ///
  /// In en, this message translates to:
  /// **'Client Name'**
  String get insightsName;

  /// No description provided for @insightsPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get insightsPayment;

  /// No description provided for @interestContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get interestContinue;

  /// No description provided for @interestLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load interests.'**
  String get interestLoadError;

  /// No description provided for @interestSaveError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save interests.'**
  String get interestSaveError;

  /// No description provided for @interestSelectOne.
  ///
  /// In en, this message translates to:
  /// **'Please select an interest.'**
  String get interestSelectOne;

  /// No description provided for @interestSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get interestSkip;

  /// No description provided for @interestTitle.
  ///
  /// In en, this message translates to:
  /// **'What are you into?'**
  String get interestTitle;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @loginBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get loginBusiness;

  /// No description provided for @loginCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get loginCancel;

  /// No description provided for @loginConfirmReactivate.
  ///
  /// In en, this message translates to:
  /// **'Do you want to reactivate and continue using this account?'**
  String get loginConfirmReactivate;

  /// No description provided for @loginContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get loginContinue;

  /// No description provided for @loginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get loginEmail;

  /// No description provided for @loginErrorFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginErrorFailed;

  /// No description provided for @loginErrorGoogle.
  ///
  /// In en, this message translates to:
  /// **'Google login failed'**
  String get loginErrorGoogle;

  /// No description provided for @loginErrorRequired.
  ///
  /// In en, this message translates to:
  /// **'All fields are required'**
  String get loginErrorRequired;

  /// No description provided for @loginFacebookSignIn.
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get loginFacebookSignIn;

  /// No description provided for @loginForgetPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get loginForgetPassword;

  /// No description provided for @loginGoogleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get loginGoogleSignIn;

  /// No description provided for @loginInstruction.
  ///
  /// In en, this message translates to:
  /// **'Please log in with your email or phone number'**
  String get loginInstruction;

  /// No description provided for @loginLoading.
  ///
  /// In en, this message translates to:
  /// **'Logging in...'**
  String get loginLoading;

  /// No description provided for @loginLogin.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginLogin;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccount;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get loginPhone;

  /// No description provided for @loginRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get loginRegister;

  /// No description provided for @loginSuccessGoogle.
  ///
  /// In en, this message translates to:
  /// **'Google login successful'**
  String get loginSuccessGoogle;

  /// No description provided for @loginSuccessLogin.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccessLogin;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// No description provided for @loginPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get loginPhoneInvalid;

  /// No description provided for @loginUseEmailInstead.
  ///
  /// In en, this message translates to:
  /// **'Use Email Instead'**
  String get loginUseEmailInstead;

  /// No description provided for @loginUsePhoneInstead.
  ///
  /// In en, this message translates to:
  /// **'Use Phone Instead'**
  String get loginUsePhoneInstead;

  /// No description provided for @loginUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get loginUser;

  /// No description provided for @loginInactiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Account inactive'**
  String get loginInactiveTitle;

  /// No description provided for @loginInactiveMessage.
  ///
  /// In en, this message translates to:
  /// **'This account is inactive.Would you like to reactivate it?'**
  String get loginInactiveMessage;

  /// No description provided for @loginWarningInactive.
  ///
  /// In en, this message translates to:
  /// **'This account was previously inactive and has been reactivated. Please review your settings.'**
  String get loginWarningInactive;

  /// No description provided for @markAsPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as Paid'**
  String get markAsPaid;

  /// No description provided for @markAsPaidConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to mark this booking as paid?'**
  String get markAsPaidConfirmation;

  /// No description provided for @myPostsConfirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this post?'**
  String get myPostsConfirmDelete;

  /// No description provided for @myPostsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get myPostsDelete;

  /// No description provided for @myPostsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No posts found.'**
  String get myPostsEmpty;

  /// No description provided for @myPostsSuccessDelete.
  ///
  /// In en, this message translates to:
  /// **'Post deleted successfully'**
  String get myPostsSuccessDelete;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @noAvailableUsers.
  ///
  /// In en, this message translates to:
  /// **'No users available to assign.'**
  String get noAvailableUsers;

  /// No description provided for @noBookings.
  ///
  /// In en, this message translates to:
  /// **'No bookings found.'**
  String get noBookings;

  /// No description provided for @notPaid.
  ///
  /// In en, this message translates to:
  /// **'Not Paid'**
  String get notPaid;

  /// No description provided for @notificationDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Delete notification error:'**
  String get notificationDeleteError;

  /// No description provided for @notificationEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications available.'**
  String get notificationEmpty;

  /// No description provided for @notificationFetchError.
  ///
  /// In en, this message translates to:
  /// **'Error fetching notifications:'**
  String get notificationFetchError;

  /// No description provided for @notificationMarkReadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to mark as read:'**
  String get notificationMarkReadError;

  /// No description provided for @onboardingAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?login'**
  String get onboardingAlreadyHaveAccount;

  /// No description provided for @onboardingCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get onboardingCreateAccount;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get onboardingSignIn;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover passions, Connect with others, Grow your skills.'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Your gateway to exciting hobbies'**
  String get onboardingTitle;

  /// No description provided for @changeTheme.
  ///
  /// In en, this message translates to:
  /// **'Change Theme'**
  String get changeTheme;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @onbSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onbSkip;

  /// No description provided for @onbNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onbNext;

  /// No description provided for @onbGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onbGetStarted;

  /// No description provided for @onbTitle1.
  ///
  /// In en, this message translates to:
  /// **'Discover Activities'**
  String get onbTitle1;

  /// No description provided for @onbSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Find hobbies and events near you.'**
  String get onbSubtitle1;

  /// No description provided for @onbTitle2.
  ///
  /// In en, this message translates to:
  /// **'Book in Seconds'**
  String get onbTitle2;

  /// No description provided for @onbSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Simple, secure, and fast booking.'**
  String get onbSubtitle2;

  /// No description provided for @onbTitle3.
  ///
  /// In en, this message translates to:
  /// **'Join the Community'**
  String get onbTitle3;

  /// No description provided for @onbSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Connect with people who love what you love.'**
  String get onbSubtitle3;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @paymentConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get paymentConfirmation;

  /// No description provided for @privacyP1.
  ///
  /// In en, this message translates to:
  /// **'We respect your privacy and are committed to protecting your personal information.'**
  String get privacyP1;

  /// No description provided for @privacyP2.
  ///
  /// In en, this message translates to:
  /// **'When you use our app, we may collect some basic information to improve your experience. This could include things like your name, email, and how you use the app.'**
  String get privacyP2;

  /// No description provided for @privacyP3.
  ///
  /// In en, this message translates to:
  /// **'We only use this information to make the app work better for you. We do not sell your information.'**
  String get privacyP3;

  /// No description provided for @privacyP4.
  ///
  /// In en, this message translates to:
  /// **'Your data is stored safely, and you can contact us anytime if you have questions or concerns.'**
  String get privacyP4;

  /// No description provided for @privacyP5.
  ///
  /// In en, this message translates to:
  /// **'By using our app, you agree to this privacy policy. We may update it in the future, and we’ll let you know if anything important changes.'**
  String get privacyP5;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyTitle;

  /// No description provided for @privacyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: May 2025'**
  String get privacyUpdated;

  /// No description provided for @profileCalendar.
  ///
  /// In en, this message translates to:
  /// **'My Calendar'**
  String get profileCalendar;

  /// No description provided for @profileConfirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete your account?'**
  String get profileConfirmDelete;

  /// No description provided for @profileConfirmInactive.
  ///
  /// In en, this message translates to:
  /// **'Confirm password to deactivate your account'**
  String get profileConfirmInactive;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get profileDeleteAccount;

  /// No description provided for @profileEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditProfile;

  /// No description provided for @profileEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email.'**
  String get profileEnterValidEmail;

  /// No description provided for @profileError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get profileError;

  /// No description provided for @profileErrorSendingInvite.
  ///
  /// In en, this message translates to:
  /// **'Failed to send invite.'**
  String get profileErrorSendingInvite;

  /// No description provided for @profileGoogleNoPasswordNeeded.
  ///
  /// In en, this message translates to:
  /// **'You signed in with Google. No password required.'**
  String get profileGoogleNoPasswordNeeded;

  /// No description provided for @profileGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get profileGuest;

  /// No description provided for @profileInactiveInfo.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to deactivate your account? After 30 days, it will be permanently deleted and you won\'t be able to log in again.'**
  String get profileInactiveInfo;

  /// No description provided for @profileInviteManager.
  ///
  /// In en, this message translates to:
  /// **'Invite Manager'**
  String get profileInviteManager;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get profileLogoutConfirm;

  /// No description provided for @profileMakePrivate.
  ///
  /// In en, this message translates to:
  /// **'Make Profile Private'**
  String get profileMakePrivate;

  /// No description provided for @profileMakePublic.
  ///
  /// In en, this message translates to:
  /// **'Make Profile Public'**
  String get profileMakePublic;

  /// No description provided for @profileManageAccount.
  ///
  /// In en, this message translates to:
  /// **'Manage Account'**
  String get profileManageAccount;

  /// No description provided for @profileManagerEmail.
  ///
  /// In en, this message translates to:
  /// **'Manager Email'**
  String get profileManagerEmail;

  /// No description provided for @profileMotto.
  ///
  /// In en, this message translates to:
  /// **'Live your hobby!'**
  String get profileMotto;

  /// No description provided for @profileMyInterests.
  ///
  /// In en, this message translates to:
  /// **'My Interests'**
  String get profileMyInterests;

  /// No description provided for @profileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profilePrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get profilePrivacyPolicy;

  /// No description provided for @profilePrivate.
  ///
  /// In en, this message translates to:
  /// **'Private Profile'**
  String get profilePrivate;

  /// No description provided for @profilePublic.
  ///
  /// In en, this message translates to:
  /// **'Public Profile'**
  String get profilePublic;

  /// No description provided for @profileSetActive.
  ///
  /// In en, this message translates to:
  /// **'Set Account to Active'**
  String get profileSetActive;

  /// No description provided for @profileSetInactive.
  ///
  /// In en, this message translates to:
  /// **'Set Account to Inactive'**
  String get profileSetInactive;

  /// No description provided for @profilebusinessAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get profilebusinessAnalytics;

  /// No description provided for @profilebusinessArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get profilebusinessArabic;

  /// No description provided for @profilebusinessCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profilebusinessCancel;

  /// No description provided for @profilebusinessConfirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get profilebusinessConfirmLogout;

  /// No description provided for @profilebusinessConnectStripe.
  ///
  /// In en, this message translates to:
  /// **'Connect Stripe Account'**
  String get profilebusinessConnectStripe;

  /// No description provided for @profilebusinessConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get profilebusinessConnecting;

  /// No description provided for @profilebusinessEditBusinessInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit Business Info'**
  String get profilebusinessEditBusinessInfo;

  /// No description provided for @profilebusinessEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get profilebusinessEnglish;

  /// No description provided for @profilebusinessFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get profilebusinessFrench;

  /// No description provided for @profilebusinessGuest.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get profilebusinessGuest;

  /// No description provided for @profilebusinessLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profilebusinessLanguage;

  /// No description provided for @profilebusinessLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profilebusinessLogout;

  /// No description provided for @profilebusinessMyActivities.
  ///
  /// In en, this message translates to:
  /// **'My Activities'**
  String get profilebusinessMyActivities;

  /// No description provided for @profilebusinessPickLogo.
  ///
  /// In en, this message translates to:
  /// **'Business logo'**
  String get profilebusinessPickLogo;

  /// No description provided for @profilebusinessPickLogoHint.
  ///
  /// In en, this message translates to:
  /// **'Take a photo or choose from gallery'**
  String get profilebusinessPickLogoHint;

  /// No description provided for @profilebusinessPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get profilebusinessPrivacyPolicy;

  /// No description provided for @profilebusinessResumeStripe.
  ///
  /// In en, this message translates to:
  /// **'Resume Stripe Onboarding'**
  String get profilebusinessResumeStripe;

  /// No description provided for @profilebusinessStripeConnected.
  ///
  /// In en, this message translates to:
  /// **'Stripe account connected'**
  String get profilebusinessStripeConnected;

  /// No description provided for @profilebusinessStripeNotConnected.
  ///
  /// In en, this message translates to:
  /// **'No Stripe account connected'**
  String get profilebusinessStripeNotConnected;

  /// No description provided for @profilebusinessTagline.
  ///
  /// In en, this message translates to:
  /// **'Let’s grow your business with HobbySphere..'**
  String get profilebusinessTagline;

  /// No description provided for @reactivate.
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get reactivate;

  /// No description provided for @registerAddProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose profile photo'**
  String get registerAddProfilePhoto;

  /// No description provided for @registerBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get registerBusiness;

  /// No description provided for @registerBusinessName.
  ///
  /// In en, this message translates to:
  /// **'Business Name'**
  String get registerBusinessName;

  /// No description provided for @registerCompleteButtonsContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get registerCompleteButtonsContinue;

  /// No description provided for @registerCompleteButtonsFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get registerCompleteButtonsFinish;

  /// No description provided for @registerCompleteButtonsSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get registerCompleteButtonsSeeAll;

  /// No description provided for @registerCompleteButtonsSeeLess.
  ///
  /// In en, this message translates to:
  /// **'See Less'**
  String get registerCompleteButtonsSeeLess;

  /// No description provided for @registerCompleteButtonsSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get registerCompleteButtonsSubmitting;

  /// No description provided for @registerCompleteErrorsBusinessNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Business name is required.'**
  String get registerCompleteErrorsBusinessNameRequired;

  /// No description provided for @registerCompleteErrorsDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required.'**
  String get registerCompleteErrorsDescriptionRequired;

  /// No description provided for @registerCompleteErrorsFirstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required.'**
  String get registerCompleteErrorsFirstNameRequired;

  /// No description provided for @registerCompleteErrorsGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get registerCompleteErrorsGeneric;

  /// No description provided for @registerCompleteErrorsLastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name is required.'**
  String get registerCompleteErrorsLastNameRequired;

  /// No description provided for @registerCompleteErrorsUsernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required.'**
  String get registerCompleteErrorsUsernameRequired;

  /// No description provided for @registerCompleteStep1BusinessName.
  ///
  /// In en, this message translates to:
  /// **'Business Name'**
  String get registerCompleteStep1BusinessName;

  /// No description provided for @registerCompleteStep1FirstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get registerCompleteStep1FirstName;

  /// No description provided for @registerCompleteStep1FirstNameQuestion.
  ///
  /// In en, this message translates to:
  /// **'What\'s your name?'**
  String get registerCompleteStep1FirstNameQuestion;

  /// No description provided for @registerCompleteStep1LastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get registerCompleteStep1LastName;

  /// No description provided for @registerCompleteStep2BusinessDescription.
  ///
  /// In en, this message translates to:
  /// **'Business Description'**
  String get registerCompleteStep2BusinessDescription;

  /// No description provided for @registerCompleteStep2ChooseUsername.
  ///
  /// In en, this message translates to:
  /// **'Choose a username'**
  String get registerCompleteStep2ChooseUsername;

  /// No description provided for @registerCompleteStep2Description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get registerCompleteStep2Description;

  /// No description provided for @registerCompleteStep2DescriptionHint1.
  ///
  /// In en, this message translates to:
  /// **'• Describe your business clearly'**
  String get registerCompleteStep2DescriptionHint1;

  /// No description provided for @registerCompleteStep2DescriptionHint2.
  ///
  /// In en, this message translates to:
  /// **'• Keep it short and relevant (max ~250 chars)'**
  String get registerCompleteStep2DescriptionHint2;

  /// No description provided for @registerCompleteStep2Username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get registerCompleteStep2Username;

  /// No description provided for @registerCompleteStep2UsernameHint1.
  ///
  /// In en, this message translates to:
  /// **'• Must be unique'**
  String get registerCompleteStep2UsernameHint1;

  /// No description provided for @registerCompleteStep2UsernameHint2.
  ///
  /// In en, this message translates to:
  /// **'• No spaces or symbols'**
  String get registerCompleteStep2UsernameHint2;

  /// No description provided for @registerCompleteStep2UsernameHint3.
  ///
  /// In en, this message translates to:
  /// **'• Between 3–15 characters'**
  String get registerCompleteStep2UsernameHint3;

  /// No description provided for @registerCompleteStep2WebsiteUrl.
  ///
  /// In en, this message translates to:
  /// **'Website URL (optional)'**
  String get registerCompleteStep2WebsiteUrl;

  /// No description provided for @registerCompleteStep3BusinessLogo.
  ///
  /// In en, this message translates to:
  /// **'business logo'**
  String get registerCompleteStep3BusinessLogo;

  /// No description provided for @registerCompleteStep3ProfileImage.
  ///
  /// In en, this message translates to:
  /// **'profile image'**
  String get registerCompleteStep3ProfileImage;

  /// No description provided for @registerCompleteStep3PublicProfile.
  ///
  /// In en, this message translates to:
  /// **'Public Profile'**
  String get registerCompleteStep3PublicProfile;

  /// No description provided for @registerCompleteStep3TapToChooseBanner.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose business banner'**
  String get registerCompleteStep3TapToChooseBanner;

  /// No description provided for @registerCompleteStep3TapToChooseLogo.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose {type}'**
  String registerCompleteStep3TapToChooseLogo(String type);

  /// No description provided for @registerConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get registerConfirmPassword;

  /// No description provided for @registerDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get registerDescription;

  /// No description provided for @registerEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get registerEmail;

  /// No description provided for @registerErrorBusinessInfo.
  ///
  /// In en, this message translates to:
  /// **'Business information is missing.'**
  String get registerErrorBusinessInfo;

  /// No description provided for @registerErrorFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registerErrorFailed;

  /// No description provided for @registerErrorLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get registerErrorLength;

  /// No description provided for @registerErrorMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get registerErrorMatch;

  /// No description provided for @registerErrorRequired.
  ///
  /// In en, this message translates to:
  /// **'Email and password are required.'**
  String get registerErrorRequired;

  /// No description provided for @registerErrorSymbol.
  ///
  /// In en, this message translates to:
  /// **'Password must include at least one symbol.'**
  String get registerErrorSymbol;

  /// No description provided for @registerErrorUserInfo.
  ///
  /// In en, this message translates to:
  /// **'User information is missing.'**
  String get registerErrorUserInfo;

  /// No description provided for @registerFirstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get registerFirstName;

  /// No description provided for @registerLastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get registerLastName;

  /// No description provided for @registerPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPassword;

  /// No description provided for @registerPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get registerPhoneNumber;

  /// No description provided for @registerPublicProfile.
  ///
  /// In en, this message translates to:
  /// **'Make my profile public'**
  String get registerPublicProfile;

  /// No description provided for @registerSelectBanner.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose business banner'**
  String get registerSelectBanner;

  /// No description provided for @registerSelectLogo.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose business logo'**
  String get registerSelectLogo;

  /// No description provided for @registerSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Code'**
  String get registerSendCode;

  /// No description provided for @registerSuccessBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business registered successfully!'**
  String get registerSuccessBusiness;

  /// No description provided for @registerSuccessUser.
  ///
  /// In en, this message translates to:
  /// **'User registered successfully!'**
  String get registerSuccessUser;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @registerUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get registerUser;

  /// No description provided for @registerUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get registerUsername;

  /// No description provided for @registerWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get registerWebsite;

  /// No description provided for @resetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordButton;

  /// No description provided for @resetPasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get resetPasswordConfirm;

  /// No description provided for @resetPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get resetPasswordError;

  /// No description provided for @resetPasswordFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to reset password.'**
  String get resetPasswordFail;

  /// No description provided for @resetPasswordFillFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields.'**
  String get resetPasswordFillFields;

  /// No description provided for @resetPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get resetPasswordMismatch;

  /// No description provided for @resetPasswordNew.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get resetPasswordNew;

  /// No description provided for @resetPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully!'**
  String get resetPasswordSuccess;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordUpdating.
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get resetPasswordUpdating;

  /// No description provided for @reviewAllReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewAllReviews;

  /// No description provided for @reviewError.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit review'**
  String get reviewError;

  /// No description provided for @reviewMissingData.
  ///
  /// In en, this message translates to:
  /// **'Please enter feedback before submitting.'**
  String get reviewMissingData;

  /// No description provided for @reviewPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Write your experience...'**
  String get reviewPlaceholder;

  /// No description provided for @reviewRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get reviewRating;

  /// No description provided for @reviewSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get reviewSubmit;

  /// No description provided for @reviewSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get reviewSubmitting;

  /// No description provided for @reviewSuccess.
  ///
  /// In en, this message translates to:
  /// **'Review submitted'**
  String get reviewSuccess;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Your Review'**
  String get reviewTitle;

  /// No description provided for @reviewYourFeedback.
  ///
  /// In en, this message translates to:
  /// **'Your Feedback'**
  String get reviewYourFeedback;

  /// No description provided for @reviewsNoReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews found.'**
  String get reviewsNoReviews;

  /// No description provided for @reviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer Reviews'**
  String get reviewsTitle;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchPlaceholder;

  /// No description provided for @selectMethodAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get selectMethodAlreadyHaveAccount;

  /// No description provided for @selectMethodContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get selectMethodContinue;

  /// No description provided for @selectMethodContinueWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Continue with Email'**
  String get selectMethodContinueWithEmail;

  /// No description provided for @selectMethodContinueWithFacebook.
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get selectMethodContinueWithFacebook;

  /// No description provided for @selectMethodContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get selectMethodContinueWithGoogle;

  /// No description provided for @selectMethodCreatePassword.
  ///
  /// In en, this message translates to:
  /// **'Create password'**
  String get selectMethodCreatePassword;

  /// No description provided for @selectMethodEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get selectMethodEnterPassword;

  /// No description provided for @selectMethodLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get selectMethodLoading;

  /// No description provided for @selectMethodLogin.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get selectMethodLogin;

  /// No description provided for @selectMethodOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get selectMethodOr;

  /// No description provided for @selectMethodPasswordRulesRule1.
  ///
  /// In en, this message translates to:
  /// **'8 characters (20 max)'**
  String get selectMethodPasswordRulesRule1;

  /// No description provided for @selectMethodPasswordRulesRule2.
  ///
  /// In en, this message translates to:
  /// **'1 letter, 1 number, 1 special character (# ? ! @)'**
  String get selectMethodPasswordRulesRule2;

  /// No description provided for @selectMethodPasswordRulesRule3.
  ///
  /// In en, this message translates to:
  /// **'Strong password'**
  String get selectMethodPasswordRulesRule3;

  /// No description provided for @selectMethodPhonePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get selectMethodPhonePlaceholder;

  /// No description provided for @selectMethodRoleBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get selectMethodRoleBusiness;

  /// No description provided for @selectMethodRoleUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get selectMethodRoleUser;

  /// No description provided for @selectMethodSaveInfo.
  ///
  /// In en, this message translates to:
  /// **'Save login info on your devices to log in automatically next time.'**
  String get selectMethodSaveInfo;

  /// No description provided for @selectMethodSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get selectMethodSignUp;

  /// No description provided for @selectMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get selectMethodTitle;

  /// No description provided for @singleChatAccessDeniedMsg.
  ///
  /// In en, this message translates to:
  /// **'You are not friends with this user.'**
  String get singleChatAccessDeniedMsg;

  /// No description provided for @singleChatAccessDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Access Denied'**
  String get singleChatAccessDeniedTitle;

  /// No description provided for @singleChatBlock.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get singleChatBlock;

  /// No description provided for @singleChatBlockConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to block this user?'**
  String get singleChatBlockConfirm;

  /// No description provided for @singleChatBlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get singleChatBlockTitle;

  /// No description provided for @singleChatBlockedByThem.
  ///
  /// In en, this message translates to:
  /// **'This user has blocked you. You can\'t send messages.'**
  String get singleChatBlockedByThem;

  /// No description provided for @singleChatCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get singleChatCancel;

  /// No description provided for @singleChatDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get singleChatDelete;

  /// No description provided for @singleChatDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the selected messages?'**
  String get singleChatDeleteConfirm;

  /// No description provided for @singleChatDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Messages'**
  String get singleChatDeleteTitle;

  /// No description provided for @singleChatErrorFetching.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch messages.'**
  String get singleChatErrorFetching;

  /// No description provided for @singleChatErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get singleChatErrorTitle;

  /// No description provided for @singleChatInputPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get singleChatInputPlaceholder;

  /// No description provided for @singleChatUnblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get singleChatUnblock;

  /// No description provided for @singleChatUnblockConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unblock this user?'**
  String get singleChatUnblockConfirm;

  /// No description provided for @singleChatUnblockTitle.
  ///
  /// In en, this message translates to:
  /// **'Unblock User'**
  String get singleChatUnblockTitle;

  /// No description provided for @singleChatYouBlocked.
  ///
  /// In en, this message translates to:
  /// **'You have blocked this user. Unblock to continue chatting.'**
  String get singleChatYouBlocked;

  /// No description provided for @socialAddPost.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get socialAddPost;

  /// No description provided for @socialChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get socialChat;

  /// No description provided for @socialEmpty.
  ///
  /// In en, this message translates to:
  /// **'No posts available.'**
  String get socialEmpty;

  /// No description provided for @socialError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get socialError;

  /// No description provided for @socialMyPosts.
  ///
  /// In en, this message translates to:
  /// **'My Posts'**
  String get socialMyPosts;

  /// No description provided for @socialNotifications.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get socialNotifications;

  /// No description provided for @socialSearchFriend.
  ///
  /// In en, this message translates to:
  /// **'Search '**
  String get socialSearchFriend;

  /// No description provided for @socialTitle.
  ///
  /// In en, this message translates to:
  /// **'HobbySphere'**
  String get socialTitle;

  /// No description provided for @stripeError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get stripeError;

  /// No description provided for @stripePay50.
  ///
  /// In en, this message translates to:
  /// **'Pay \$50'**
  String get stripePay50;

  /// No description provided for @stripePayNow.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Payment'**
  String get stripePayNow;

  /// No description provided for @stripePaymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get stripePaymentFailed;

  /// No description provided for @stripeSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Payment completed!'**
  String get stripeSuccessMessage;

  /// No description provided for @stripeSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get stripeSuccessTitle;

  /// No description provided for @tabExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get tabExplore;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @tabSocial.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get tabSocial;

  /// No description provided for @tabTickets.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get tabTickets;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @tabnavigateActivities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get tabnavigateActivities;

  /// No description provided for @tabnavigateAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get tabnavigateAnalytics;

  /// No description provided for @tabnavigateBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get tabnavigateBookings;

  /// No description provided for @tabnavigateHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabnavigateHome;

  /// No description provided for @tabActivities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get tabActivities;

  /// No description provided for @tabAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get tabAnalytics;

  /// No description provided for @tabBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get tabBookings;

  /// No description provided for @tabnavigateProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabnavigateProfile;

  /// No description provided for @ticketCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get ticketCancel;

  /// No description provided for @ticketCancelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this ticket?'**
  String get ticketCancelConfirm;

  /// No description provided for @ticketCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Ticket'**
  String get ticketCancelTitle;

  /// No description provided for @ticketConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get ticketConfirm;

  /// No description provided for @ticketDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get ticketDelete;

  /// No description provided for @ticketDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete this canceled ticket?'**
  String get ticketDeleteConfirm;

  /// No description provided for @ticketDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Ticket'**
  String get ticketDeleteTitle;

  /// No description provided for @ticketEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tickets in {status}.'**
  String ticketEmpty(String status);

  /// No description provided for @ticketLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get ticketLocation;

  /// No description provided for @ticketReturnConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to move this ticket back to Pending?'**
  String get ticketReturnConfirm;

  /// No description provided for @ticketReturnTitle.
  ///
  /// In en, this message translates to:
  /// **'Return to Pending'**
  String get ticketReturnTitle;

  /// No description provided for @ticketReturnToPending.
  ///
  /// In en, this message translates to:
  /// **'Return to Pending'**
  String get ticketReturnToPending;

  /// No description provided for @ticketScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get ticketScreenTitle;

  /// No description provided for @ticketStatusCanceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get ticketStatusCanceled;

  /// No description provided for @ticketStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get ticketStatusCompleted;

  /// No description provided for @ticketStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get ticketStatusPending;

  /// No description provided for @ticketTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get ticketTime;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'theme'**
  String get theme;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @verifyCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get verifyCodeButton;

  /// No description provided for @verifyCodeFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to verify code.'**
  String get verifyCodeFail;

  /// No description provided for @verifyCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid code.'**
  String get verifyCodeInvalid;

  /// No description provided for @verifyCodePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verifyCodePlaceholder;

  /// No description provided for @verifyCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code.'**
  String get verifyCodeRequired;

  /// No description provided for @verifyCodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to your email'**
  String get verifyCodeSubtitle;

  /// No description provided for @verifyCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Code'**
  String get verifyCodeTitle;

  /// No description provided for @verifyCodeVerifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get verifyCodeVerifying;

  /// No description provided for @verifyEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit verification code'**
  String get verifyEnterCode;

  /// No description provided for @verifyFullCodeError.
  ///
  /// In en, this message translates to:
  /// **'Please enter the full 6-digit code.'**
  String get verifyFullCodeError;

  /// No description provided for @verifyInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired code.'**
  String get verifyInvalidCode;

  /// No description provided for @verifyResendBtn.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get verifyResendBtn;

  /// No description provided for @verifyResendFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to resend code.'**
  String get verifyResendFailed;

  /// No description provided for @verifyResent.
  ///
  /// In en, this message translates to:
  /// **'Code resent. Please check your email or phone.'**
  String get verifyResent;

  /// No description provided for @verifySuccessBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business account verified successfully!'**
  String get verifySuccessBusiness;

  /// No description provided for @verifySuccessUser.
  ///
  /// In en, this message translates to:
  /// **'Account verified successfully!'**
  String get verifySuccessUser;

  /// No description provided for @verifyVerifyBtn.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyVerifyBtn;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
