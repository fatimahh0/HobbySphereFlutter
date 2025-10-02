// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get activitiesFiltersTerminated => 'منتهية';

  @override
  String get activitiesFiltersUpcoming => 'قادمة';

  @override
  String get activitiesMyActivities => 'أنشطتي';

  @override
  String get activitiesNoActivities => 'لا توجد أنشطة.';

  @override
  String get activitiesReopen => 'إعادة فتح النشاط';

  @override
  String get activityDetailsCancel => 'إلغاء';

  @override
  String get activityDetailsConfirmDelete => 'تأكيد الحذف';

  @override
  String get activityDetailsDelete => 'حذف';

  @override
  String get activityDetailsDeleteError => 'فشل حذف النشاط.';

  @override
  String get activityDetailsDeletePrompt => 'هل أنت متأكد أنك تريد حذف هذا النشاط؟';

  @override
  String get activityDetailsDeleteSuccess => 'تم حذف النشاط.';

  @override
  String get activityDetailsDeleted => 'محذوف';

  @override
  String get activityDetailsDescription => 'الوصف';

  @override
  String get activityDetailsEdit => 'تعديل';

  @override
  String get activityDetailsParticipants => 'المشاركون';

  @override
  String get activityDetailsStatus => 'الحالة';

  @override
  String get activityDetailsViewInsights => 'عرض الإحصاءات';

  @override
  String get activityInsightsTitle => 'رؤى النشاط';

  @override
  String get addNewUser => 'إضافة عميل جديد';

  @override
  String get analyticsBookingGrowth => 'نمو الحجوزات';

  @override
  String get analyticsCancel => 'إلغاء';

  @override
  String get analyticsCustomerRetention => 'الاحتفاظ بالعملاء';

  @override
  String get analyticsDownloadReport => 'تنزيل تقرير PDF';

  @override
  String get analyticsPeakHours => 'ساعات الذروة';

  @override
  String get analyticsReportDate => 'تاريخ التقرير';

  @override
  String get analyticsRevenueOverview => 'نظرة عامة على الإيرادات';

  @override
  String get analyticsShare => 'مشاركة';

  @override
  String get analyticsShareMessage => 'تم حفظ ملف PDF في مجلد التنزيلات.\nهل ترغب بمشاركته الآن؟';

  @override
  String get analyticsTitle => 'تحليلات الأعمال';

  @override
  String get analyticsToday => 'اليوم';

  @override
  String get analyticsTopActivity => 'أفضل نشاط';

  @override
  String get analyticsTotalRevenue => 'إجمالي الإيرادات';

  @override
  String get analyticsYesterday => 'الأمس';

  @override
  String get assignToActivity => 'إسناد إلى نشاط';

  @override
  String get authNotLoggedInMessage => 'يجب تسجيل الدخول للوصول إلى هذه الميزة.';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟ ';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get businessWelcomeTitle => 'مرحبًا بك في لوحة التحكم!';

  @override
  String get businessWelcomeSubtitle => 'أدِر أنشطتك وتفاعل مع المستخدمين بسهولة.';

  @override
  String get createNewActivity => 'إنشاء نشاط جديد';

  @override
  String get activitiesEmpty => 'لا توجد أنشطة بعد';

  @override
  String get profileLastUpdated => 'آخر تحديث';

  @override
  String get viewDetails => 'عرض';

  @override
  String get buttonWebsite => 'الموقع';

  @override
  String get buttonCall => 'اتصال';

  @override
  String get mapOpen => 'افتح في الخرائط';

  @override
  String get copy => 'نسخ';

  @override
  String get copied => 'تم النسخ!';

  @override
  String get badgeStripe => 'سترايب';

  @override
  String get labelDuration => 'المدة';

  @override
  String get authNotLoggedInTitle => 'غير مسجل الدخول';

  @override
  String get appTitle => 'Hobby Sphere';

  @override
  String get splashLoading => 'جارٍ التحميل...';

  @override
  String get bookingAbout => 'حول';

  @override
  String get bookingApprove => 'موافقة';

  @override
  String get bookingBookNow => 'احجز الآن';

  @override
  String get bookingBooking => 'جارٍ الحجز...';

  @override
  String get bookingCancel => 'إلغاء';

  @override
  String get bookingCancelReason => 'السبب';

  @override
  String get bookingConfirmRejectMessage => 'هل أنت متأكد أنك تريد رفض هذا الحجز؟';

  @override
  String get bookingConfirmRejectTitle => 'رفض الحجز';

  @override
  String get bookingConfirmUnrejectMessage => 'هل تريد التراجع عن الرفض؟';

  @override
  String get bookingConfirmUnrejectTitle => 'التراجع عن الرفض';

  @override
  String get bookingConfirm_approveCancel => 'الموافقة على الإلغاء';

  @override
  String get bookingConfirm_reject => 'تأكيد الرفض';

  @override
  String get bookingConfirm_rejectCancel => 'رفض طلب الإلغاء';

  @override
  String get bookingConfirm_unreject => 'تأكيد التراجع عن الرفض';

  @override
  String get bookingErrorFailed => 'فشل الحجز. حاول مرة أخرى.';

  @override
  String get bookingErrorLoginRequired => 'يجب تسجيل الدخول لإتمام الحجز.';

  @override
  String get bookingErrorMaxParticipantsReached => 'لا يمكنك الحجز بأكثر من الحد الأقصى للمشاركين.';

  @override
  String get bookingLocation => 'الموقع';

  @override
  String bookingMaxParticipants(int count) {
    return 'الحد الأقصى $count مشاركًا';
  }

  @override
  String get bookingMessage_approveCancel => 'هل تريد الموافقة على طلب الإلغاء هذا؟';

  @override
  String get bookingMessage_reject => 'هل أنت متأكد أنك تريد رفض هذا الحجز؟';

  @override
  String get bookingMessage_rejectCancel => 'هل أنت متأكد أنك تريد رفض طلب الإلغاء هذا؟';

  @override
  String get bookingMessage_unreject => 'هل أنت متأكد أنك تريد التراجع عن رفض هذا الحجز؟';

  @override
  String get bookingMethod => 'طريقة الدفع';

  @override
  String get bookingMissing => 'معرّف الحجز أو الرمز مفقود';

  @override
  String get bookingParticipants => 'عدد المشاركين';

  @override
  String get bookingPaymentCash => 'نقدًا';

  @override
  String get bookingPaymentMethod => 'طريقة الدفع';

  @override
  String get bookingPerPerson => 'لكل شخص';

  @override
  String get bookingPrice => 'السعر';

  @override
  String get bookingProcessing => 'جارٍ المعالجة...';

  @override
  String get bookingReject => 'رفض';

  @override
  String get bookingRejectCancel => 'رفض الإلغاء';

  @override
  String get bookingTotal => 'السعر الإجمالي';

  @override
  String get bookingTotalPrice => 'السعر الإجمالي';

  @override
  String get bookingUnreject => 'إلغاء الرفض';

  @override
  String get bookingUpdated => 'تم تحديث الحجز بنجاح';

  @override
  String get bookingsFiltersAll => 'الكل';

  @override
  String get bookingsFiltersCanceled => 'ملغاة';

  @override
  String get bookingsFiltersCompleted => 'مكتملة';

  @override
  String get bookingsFiltersPending => 'قيد الانتظار';

  @override
  String get bookingsFiltersRejected => 'مرفوضة';

  @override
  String bookingsNoBookings(String status) {
    return 'لا توجد حجوزات ضمن \"$status\".';
  }

  @override
  String get bookingsTitle => 'حجوزات الأعمال';

  @override
  String get businessCreateActivity => 'إنشاء نشاط جديد';

  @override
  String get businessGreeting => 'مرحبًا،';

  @override
  String get businessManageText => 'أدِر أنشطتك وتفاعل مع المستخدمين بسهولة.';

  @override
  String get businessNoActivities => 'لا توجد أنشطة. ابدأ بإنشاء واحد!';

  @override
  String get businessUsers => 'مستخدمو النشاط التجاري';

  @override
  String get businessWelcome => 'مرحبًا بك في لوحة التحكم!';

  @override
  String get businessYourActivities => 'أنشطتك';

  @override
  String get buttonCancel => 'إلغاء';

  @override
  String get buttonConfirm => 'تأكيد';

  @override
  String get buttonDelete => 'حذف';

  @override
  String get buttonLoading => 'جارٍ التحميل...';

  @override
  String get buttonLogin => 'تسجيل الدخول';

  @override
  String get buttonLogout => 'تسجيل الخروج';

  @override
  String get buttonOk => 'حسنًا';

  @override
  String get buttonRegister => 'تسجيل';

  @override
  String get buttonSendInvite => 'إرسال دعوة';

  @override
  String get buttonSubmit => 'إرسال';

  @override
  String get buttonsCancel => 'إلغاء';

  @override
  String get buttonsConfirm => 'تأكيد';

  @override
  String get buttonsContinue => 'متابعة';

  @override
  String get buttonsFinish => 'إنهاء';

  @override
  String get buttonsLogin => 'تسجيل الدخول';

  @override
  String get buttonsRegister => 'تسجيل';

  @override
  String get buttonsSeeAll => 'عرض الكل';

  @override
  String get buttonsSeeLess => 'عرض أقل';

  @override
  String get buttonsSubmitting => 'جارٍ الإرسال...';

  @override
  String get calendarNoActivities => 'لا توجد أنشطة.';

  @override
  String get calendarNoActivitiesForDate => 'لا توجد أنشطة في التاريخ المحدد.';

  @override
  String get calendarTabsPast => 'أنشطة سابقة';

  @override
  String get calendarTabsUpcoming => 'قادمة';

  @override
  String get calendarTitle => 'التقويم';

  @override
  String get cancel => 'إلغاء';

  @override
  String get chatNoFriends => 'أضف صديقًا لبدء الدردشة!';

  @override
  String get chatSubtitle => 'اضغط لبدء الدردشة';

  @override
  String get chatTitle => 'أصدقائي';

  @override
  String get chatfriendSubtitle => 'اضغط لبدء الدردشة';

  @override
  String get chatfriendTitle => 'أصدقائي';

  @override
  String get commentEmpty => 'لا توجد تعليقات بعد.';

  @override
  String get commentLike => 'إعجاب';

  @override
  String get commentLikes => 'إعجابات';

  @override
  String get commentPlaceholder => 'اكتب تعليقًا...';

  @override
  String get commonAreYouSure => 'هل أنت متأكد؟';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonConfirm => 'تأكيد';

  @override
  String get confirm => 'تأكيد';

  @override
  String get create => 'إنشاء';

  @override
  String get createActivityActivityName => 'اسم النشاط';

  @override
  String get createActivityActivityType => 'نوع النشاط';

  @override
  String get createActivityChange => 'تغيير';

  @override
  String get createActivityChooseLibrary => 'اختيار من المكتبة';

  @override
  String get createActivityDescription => 'الوصف';

  @override
  String get createActivityEndDate => 'تاريخ ووقت الانتهاء';

  @override
  String get createActivityErrorRequired => 'يرجى تعبئة جميع الحقول المطلوبة.';

  @override
  String get createActivityFail => 'فشل إنشاء النشاط. حاول مرة أخرى.';

  @override
  String get createActivityGetMyLocation => 'احصل على موقعي';

  @override
  String get createActivityLocation => 'الموقع';

  @override
  String get createActivityLocationErrorPermission => 'يرجى تفعيل الـGPS لاكتشاف موقعك.';

  @override
  String get createActivityLocationErrorTimeout => 'انتهت مهلة تحديد الموقع.';

  @override
  String get createActivityLocationErrorUnavailable => 'تعذر الحصول على موقعك.';

  @override
  String get createActivityMaxParticipants => 'الحد الأقصى للمشاركين';

  @override
  String get createActivityPickHint => 'التقط صورة أو اختر من المكتبة';

  @override
  String get createActivityPickImage => 'اختر صورة';

  @override
  String get createActivityPrice => 'السعر';

  @override
  String get createActivityRemovePhoto => 'إزالة الصورة';

  @override
  String get createActivitySearchPlaceholder => 'ابحث عن أنواع الأنشطة...';

  @override
  String get createActivitySelectType => 'اختر نوع النشاط';

  @override
  String get createActivityStartDate => 'تاريخ ووقت البدء';

  @override
  String get createActivityStripeRequired => 'يجب ربط حساب Stripe قبل إنشاء نشاط.';

  @override
  String get createActivitySubmit => 'إرسال';

  @override
  String get createActivitySuccess => 'تم إنشاء النشاط بنجاح!';

  @override
  String get createActivityTakePhoto => 'التقاط صورة';

  @override
  String get createActivityTapToPick => 'اضغط للاختيار';

  @override
  String get createActivityTitle => 'إنشاء نشاط';

  @override
  String get reopenedSuccessfully => 'تمت إعادة الفتح بنجاح';

  @override
  String get updatedSuccessfully => 'تم التحديث بنجاح';

  @override
  String get createPostCancel => 'إلغاء';

  @override
  String get createPostClose => 'إغلاق';

  @override
  String get createPostEmojiTitle => 'اختر شعورك';

  @override
  String get createPostEmptyError => 'لا يمكن أن يكون محتوى المنشور فارغًا.';

  @override
  String get createPostFail => 'فشل إنشاء المنشور';

  @override
  String get createPostFeeling => 'شعور';

  @override
  String get createPostFriendsOnly => 'الأصدقاء فقط';

  @override
  String get createPostHashtagsPlaceholder => '#وسوم (اختياري)';

  @override
  String get createPostImage => 'صورة المنشور';

  @override
  String get createPostPhoto => 'صورة';

  @override
  String get createPostPickHint => 'التقط صورة أو اختر من المعرض';

  @override
  String get createPostPlaceholder => 'بماذا تفكر؟';

  @override
  String get createPostPost => 'نشر';

  @override
  String get createPostPublic => 'عام';

  @override
  String get createPostSelectEmojiTitle => 'اختر رمزًا تعبيريًا';

  @override
  String get createPostSuccess => 'تم نشر منشورك!';

  @override
  String get createPostVisibilityAnyone => 'أي شخص';

  @override
  String get createPostVisibilityFriends => 'الأصدقاء';

  @override
  String get createPostVisibilityTitle => 'خصوصية المنشور';

  @override
  String get editActivityDescription => 'الوصف';

  @override
  String get editActivityEnd => 'تاريخ ووقت الانتهاء';

  @override
  String get editActivityFailure => 'فشل تحديث النشاط.';

  @override
  String get editActivityLocation => 'الموقع';

  @override
  String get editActivityName => 'اسم النشاط';

  @override
  String get editActivityParticipants => 'الحد الأقصى للمشاركين';

  @override
  String get editActivityPrice => 'السعر ()';

  @override
  String get editActivityStart => 'تاريخ ووقت البدء';

  @override
  String get editActivityStatus => 'الحالة';

  @override
  String get editActivitySuccess => 'تم تحديث النشاط بنجاح.';

  @override
  String get editActivityTitle => 'تعديل النشاط';

  @override
  String get editActivityUpdate => 'تحديث النشاط';

  @override
  String get editBusinessAddBanner => 'إضافة بانر';

  @override
  String get editBusinessAlert => 'تنبيه';

  @override
  String get editBusinessBannerDeleted => 'تمت إزالة البانر.';

  @override
  String get editBusinessBannerHint => 'التقط صورة أو اختر من المعرض';

  @override
  String get editBusinessBannerImage => 'صورة البانر';

  @override
  String get editBusinessBusinessName => 'اسم النشاط التجاري';

  @override
  String get editBusinessCancel => 'إلغاء';

  @override
  String get editBusinessConfirmDeleteMessage => 'هل أنت متأكد أنك تريد حذف حسابك؟ لا يمكن التراجع.';

  @override
  String get editBusinessConfirmDeletePassword => 'تأكيد كلمة المرور لحذف الحساب';

  @override
  String get editBusinessConfirmDeleteTitle => 'تأكيد حذف الحساب';

  @override
  String get editBusinessConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get editBusinessCurrentPassword => 'كلمة المرور الحالية';

  @override
  String get editBusinessDelete => 'حذف';

  @override
  String get editBusinessDeleteAccount => 'حذف الحساب';

  @override
  String get editBusinessDeleteFailed => 'فشل حذف الحساب. حاول مرة أخرى.';

  @override
  String get editBusinessDeleteLogoFailed => 'فشل حذف الشعار.';

  @override
  String get editBusinessDeleting => 'جارٍ الحذف...';

  @override
  String get editBusinessDescription => 'الوصف';

  @override
  String get editBusinessEmail => 'البريد الإلكتروني';

  @override
  String get editBusinessEnterPassword => 'أدخل كلمة المرور';

  @override
  String get editBusinessEnterPasswordToDelete => 'يرجى إدخال كلمة المرور لحذف الحساب.';

  @override
  String get editBusinessErrorDelete => 'فشل حذف النشاط التجاري.';

  @override
  String get editBusinessIncorrectPassword => 'كلمة مرور غير صحيحة. حاول مجددًا.';

  @override
  String get editBusinessLogoDeleted => 'تمت إزالة الشعار.';

  @override
  String get editBusinessNewPassword => 'كلمة المرور الجديدة';

  @override
  String get editBusinessOk => 'حسنًا';

  @override
  String get editBusinessPasswordMismatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get editBusinessPasswordTooShort => 'يجب ألا تقل كلمة المرور عن 8 أحرف.';

  @override
  String get editBusinessPhoneNumber => 'رقم الهاتف';

  @override
  String get editBusinessSaveChanges => 'حفظ التغييرات';

  @override
  String get editBusinessSaving => 'جارٍ الحفظ...';

  @override
  String get editBusinessSuccessDelete => 'تم حذف النشاط التجاري بنجاح.';

  @override
  String get editBusinessTitle => 'تعديل ملف النشاط التجاري';

  @override
  String get editBusinessUpdateFailed => 'فشل تحديث الملف.';

  @override
  String get editBusinessUpdateSuccess => 'تم تحديث ملف النشاط التجاري بنجاح.';

  @override
  String get editBusinessWebsite => 'الموقع الإلكتروني';

  @override
  String get editProfileCancel => 'إلغاء';

  @override
  String get editProfileConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get editProfileContact => 'رقم التواصل';

  @override
  String get editProfileCurrentPassword => 'كلمة المرور الحالية';

  @override
  String get editProfileDelete => 'حذف';

  @override
  String get editProfileDeleteAccount => 'حذف الحساب';

  @override
  String get editProfileDeleteConfirmMsg => 'هل أنت متأكد أنك تريد حذف حسابك؟ لا يمكن التراجع.';

  @override
  String get editProfileDeleteConfirmTitle => 'تأكيد حذف الحساب';

  @override
  String get editProfileDeleteFailed => 'فشل حذف الحساب.';

  @override
  String get editProfileDeleteInfoWarning => 'قمت بتسجيل الدخول عبر Google، الرجاء تعيين كلمة مرور أولاً إن لم تكن موجودة.';

  @override
  String get editProfileDeleteProfileImage => 'إزالة صورة الملف';

  @override
  String get editProfileDeleteProfileImageConfirm => 'هل تريد حذف صورتك الشخصية؟';

  @override
  String get editProfileDeleteSuccess => 'تم حذف الحساب بنجاح.';

  @override
  String get editProfileEmail => 'البريد الإلكتروني';

  @override
  String get editProfileFirstName => 'الاسم الأول';

  @override
  String get editProfileImageSelectedSuccess => 'تم اختيار الصورة.';

  @override
  String get editProfileImageSelectionCancelled => 'تم إلغاء اختيار الصورة.';

  @override
  String get editProfileImageSelectionError => 'تعذر فتح منتقي الصور.';

  @override
  String get editProfileLastName => 'اسم العائلة';

  @override
  String get editProfileNewPassword => 'كلمة المرور الجديدة';

  @override
  String get editProfilePasswordMismatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get editProfilePasswordRequired => 'يرجى إدخال كلمة المرور الحالية.';

  @override
  String get editProfilePickHint => 'التقط صورة أو اختر من المعرض';

  @override
  String get editProfileProfileImage => 'صورة الملف';

  @override
  String get editProfileProfileImageDeleted => 'تمت إزالة صورة الملف.';

  @override
  String get editProfileSaveChanges => 'حفظ التغييرات';

  @override
  String get editProfileSelectImage => 'اختر صورة الملف';

  @override
  String get editProfileTitle => 'تعديل الملف الشخصي';

  @override
  String get editProfileUpdateFailed => 'فشل تحديث الملف.';

  @override
  String get editProfileUpdateSuccess => 'تم تحديث الملف بنجاح.';

  @override
  String get editProfileUsername => 'اسم المستخدم';

  @override
  String get editProfileWrongPassword => 'كلمة مرور غير صحيحة. حاول مجددًا.';

  @override
  String get editProfileEmailInvalid => 'يرجى إدخال بريد إلكتروني صالح.';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get emailRegistrationContinue => 'متابعة';

  @override
  String get emailRegistrationCreatePassword => 'إنشاء كلمة مرور';

  @override
  String get emailRegistrationEmailDesc => 'ستتلقى رمز تحقق عبر البريد الإلكتروني. قد يُستخدم بريدك لربطك بالآخرين وتحسين الإعلانات وغير ذلك وفق إعداداتك.';

  @override
  String get emailRegistrationEmailPlaceholder => 'عنوان البريد الإلكتروني';

  @override
  String get emailRegistrationEnterEmail => 'أدخل البريد الإلكتروني';

  @override
  String get emailRegistrationErrorGeneric => 'حدث خطأ ما';

  @override
  String get emailRegistrationLoading => 'جارٍ التحميل...';

  @override
  String get emailRegistrationPasswordPlaceholder => 'أدخل كلمة المرور';

  @override
  String get emailRegistrationRule1 => '• 8 أحرف (بحد أقصى 20)';

  @override
  String get emailRegistrationRule2 => '• حرف واحد ورقم واحد ورمز خاص (# ? ! @)';

  @override
  String get emailRegistrationSaveInfo => 'احصل على محتوى رائج ونشرات وتحديثات على بريدك';

  @override
  String get emailRegistrationSignUp => 'إنشاء حساب';

  @override
  String get emailRegistrationVerificationSent => 'تم إرسال رمز التحقق إلى البريد.';

  @override
  String get exploreSubtitle => 'اكتشف ملفات الأعمال المختلفة وخدماتها';

  @override
  String get exploreTitle => 'استكشف الأنشطة التجارية';

  @override
  String get exportExcel => 'تصدير Excel';

  @override
  String get exportPdf => 'تصدير PDF';

  @override
  String get filtersAll => 'الكل';

  @override
  String get filtersNotPaid => 'غير مدفوع';

  @override
  String get filtersPaid => 'مدفوع';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get forgetPasswordEmailPlaceholder => 'عنوان البريد الإلكتروني';

  @override
  String get forgetPasswordEnterEmail => 'يرجى إدخال بريدك الإلكتروني.';

  @override
  String get forgetPasswordGeneralError => 'حدث خطأ ما. حاول مجددًا.';

  @override
  String get forgetPasswordSendCode => 'إرسال الرمز';

  @override
  String get forgetPasswordSending => 'جارٍ الإرسال...';

  @override
  String forgetPasswordSubtitle(String role) {
    return 'إعادة تعيين كلمة المرور لـ: $role';
  }

  @override
  String get forgetPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get forgetPasswordUnableToSend => 'تعذر إرسال رمز الاستعادة.';

  @override
  String get friendAccept => 'قبول';

  @override
  String get friendAccepted => 'تم قبول طلب الصداقة.';

  @override
  String get friendCancel => 'إلغاء الطلب';

  @override
  String get friendCancelled => 'تم إلغاء الطلب.';

  @override
  String get friendChat => 'دردشة';

  @override
  String get friendConfirmUnfriendText => 'هل أنت متأكد أنك تريد إزالة هذا الصديق؟';

  @override
  String get friendConfirmUnfriendTitle => 'إلغاء الصداقة';

  @override
  String get friendErrorLoad => 'فشل تحميل البيانات.';

  @override
  String get friendFailedAction => 'فشلت العملية. حاول مجددًا.';

  @override
  String get friendNoFriends => 'ليس لديك أصدقاء بعد. ابدأ بالإضافة!';

  @override
  String friendNoUsersFound(String tab) {
    return 'لم يتم العثور على مستخدمين في $tab.';
  }

  @override
  String get friendReject => 'رفض';

  @override
  String get friendRejected => 'تم رفض طلب الصداقة.';

  @override
  String get friendTabFriends => 'الأصدقاء';

  @override
  String get friendTabReceived => 'الواردة';

  @override
  String get friendTabSent => 'المرسلة';

  @override
  String get friendTab_friends => 'أصدقاء';

  @override
  String get friendTab_received => 'واردة';

  @override
  String get friendTab_sent => 'مرسلة';

  @override
  String friendTotalFriends(int count) {
    return 'لديك $count صديقًا';
  }

  @override
  String get friendUnfriend => 'إلغاء الصداقة';

  @override
  String get friendUnfriended => 'تمت إزالة الصديق.';

  @override
  String get friendshipAccept => 'قبول';

  @override
  String get friendshipAddFriendAll => 'كل المستخدمين';

  @override
  String get friendshipAddFriendAvailable => 'متاحون للإضافة';

  @override
  String get friendshipAddFriendError => 'فشل إرسال طلب الصداقة.';

  @override
  String get friendshipAddFriendNoUsers => 'لم يتم العثور على مستخدمين.';

  @override
  String get friendshipAddFriendSearchPlaceholder => 'ابحث عن المستخدمين...';

  @override
  String get friendshipAddFriendSuccess => 'تم إرسال طلب الصداقة.';

  @override
  String get friendshipAddFriendSuggested => 'مستخدمون مقترحون';

  @override
  String get friendshipAddFriendViewFriends => 'عرض الأصدقاء';

  @override
  String get friendshipAddFriendViewReceived => 'عرض الطلبات الواردة';

  @override
  String get friendshipAddFriendViewSent => 'عرض الطلبات المرسلة';

  @override
  String get friendshipBlock => 'حظر';

  @override
  String get friendshipCancelRequest => 'إلغاء الطلب';

  @override
  String get friendshipConfirmBlock => 'هل تريد حظر هذا المستخدم؟';

  @override
  String get friendshipConfirmUnblock => 'هل تريد إلغاء الحظر؟';

  @override
  String get friendshipConfirmUnfriend => 'هل تريد إزالة هذا الصديق؟';

  @override
  String get friendshipErrorAlreadyFriends => 'أنت بالفعل صديق لهذا المستخدم.';

  @override
  String get friendshipErrorFailedAction => 'فشلت العملية. حاول مجددًا.';

  @override
  String get friendshipErrorNotFound => 'المستخدم غير موجود.';

  @override
  String get friendshipErrorRequestExists => 'تم إرسال طلب صداقة مسبقًا.';

  @override
  String get friendshipFriendAdded => 'تمت إضافة الصديق.';

  @override
  String get friendshipFriendBlocked => 'تم حظر المستخدم.';

  @override
  String get friendshipFriendRemoved => 'تمت إزالة الصديق.';

  @override
  String get friendshipFriendUnblocked => 'تم إلغاء الحظر.';

  @override
  String get friendshipMyFriends => 'أصدقائي';

  @override
  String get friendshipNoFriends => 'لم تقم بإضافة أصدقاء بعد.';

  @override
  String get friendshipNoRequests => 'لا توجد طلبات صداقة.';

  @override
  String get friendshipReceivedRequests => 'طلبات واردة';

  @override
  String get friendshipReject => 'رفض';

  @override
  String get friendshipRequestAccepted => 'تم قبول طلب الصداقة.';

  @override
  String get friendshipRequestCancelled => 'تم إلغاء الطلب.';

  @override
  String get friendshipRequestRejected => 'تم رفض طلب الصداقة.';

  @override
  String get friendshipRequestSent => 'تم إرسال طلب الصداقة.';

  @override
  String get friendshipSendRequest => 'إرسال طلب صداقة';

  @override
  String get friendshipSentRequests => 'طلبات مرسلة';

  @override
  String get friendshipTitle => 'طلبات الصداقة';

  @override
  String get friendshipUnblock => 'إلغاء الحظر';

  @override
  String get friendshipUnfriend => 'إلغاء الصداقة';

  @override
  String get generalLoading => 'جارٍ التحميل...';

  @override
  String get globalError => 'حدث خطأ ما';

  @override
  String get globalSuccess => 'تم بنجاح';

  @override
  String get homeActivityCategories => ' الفئات';

  @override
  String get homeCancelConfirm => 'إلغاء هذه التذكرة؟';

  @override
  String get homeCancelTitle => 'تأكيد';

  @override
  String get homeExploreActivities => 'استكشف الأنشطة';

  @override
  String get homeExploreCategories => 'استكشف الفئات';

  @override
  String get homeExploreMessage => 'اكتشف تجارب جديدة ستحبها';

  @override
  String get homeFindActivity => 'ابحث عن نشاطك المفضل';

  @override
  String get homeInterestBasedTitle => 'الأنشطة التي تهمك';

  @override
  String get homeLoadMore => 'تحميل المزيد';

  @override
  String get homeLoadingActivities => 'جارٍ تحميل الأنشطة...';

  @override
  String get homeLoadingBookings => 'جارٍ تحميل حجوزاتك...';

  @override
  String get homeLoadingInterestActivities => 'جارٍ تحميل الأنشطة حسب الاهتمام...';

  @override
  String get homeMoreActivities => 'المزيد من الأنشطة';

  @override
  String get homeNo => 'لا';

  @override
  String get homeNoActivities => 'لا توجد أنشطة لهذه الفئة.';

  @override
  String get homeSeeAll => 'عرض الكل';

  @override
  String get homeSeeAllCategories => 'عرض كل الفئات';

  @override
  String get homeShowAll => 'عرض الكل';

  @override
  String get homeShowLess => 'عرض أقل';

  @override
  String get homeWelcome => 'أهلًا!';

  @override
  String get homeYes => 'نعم';

  @override
  String get homeYourBookings => 'حجوزاتك';

  @override
  String get insightsAction => 'الإجراء';

  @override
  String get insightsItem => 'العنصر';

  @override
  String get insightsName => 'اسم العميل';

  @override
  String get insightsPayment => 'الدفع';

  @override
  String get interestContinue => 'متابعة';

  @override
  String get interestLoadError => 'فشل تحميل الاهتمامات.';

  @override
  String get interestSaveError => 'فشل حفظ الاهتمامات.';

  @override
  String get interestSelectOne => 'يرجى اختيار اهتمام.';

  @override
  String get interestSkip => 'تخطي';

  @override
  String get interestTitle => 'ما الذي يهمك؟';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get loginBusiness => 'نشاط تجاري';

  @override
  String get loginCancel => 'إلغاء';

  @override
  String get loginConfirmReactivate => 'هل تريد إعادة تفعيل هذا الحساب والمتابعة؟';

  @override
  String get loginContinue => 'متابعة';

  @override
  String get loginEmail => 'البريد الإلكتروني';

  @override
  String get loginErrorFailed => 'فشل تسجيل الدخول';

  @override
  String get loginErrorGoogle => 'فشل تسجيل الدخول عبر Google';

  @override
  String get loginErrorRequired => 'جميع الحقول مطلوبة';

  @override
  String get loginFacebookSignIn => 'المتابعة عبر فيسبوك';

  @override
  String get loginForgetPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get loginGoogleSignIn => 'المتابعة عبر Google';

  @override
  String get loginInstruction => 'يرجى تسجيل الدخول عبر البريد أو الهاتف';

  @override
  String get loginLoading => 'جارٍ تسجيل الدخول...';

  @override
  String get loginLogin => 'تسجيل الدخول';

  @override
  String get loginNoAccount => 'لا تملك حسابًا؟';

  @override
  String get loginPassword => 'كلمة المرور';

  @override
  String get loginPhone => 'رقم الهاتف';

  @override
  String get loginRegister => 'إنشاء حساب';

  @override
  String get loginSuccessGoogle => 'تم تسجيل الدخول عبر Google';

  @override
  String get loginSuccessLogin => 'تم تسجيل الدخول بنجاح';

  @override
  String get loginTitle => 'مرحبًا بعودتك';

  @override
  String get loginPhoneInvalid => 'رقم هاتف غير صالح';

  @override
  String get loginUseEmailInstead => 'استخدم البريد بدلًا من ذلك';

  @override
  String get loginUsePhoneInstead => 'استخدم الهاتف بدلًا من ذلك';

  @override
  String get loginUser => 'مستخدم';

  @override
  String get loginInactiveTitle => 'الحساب غير نشط';

  @override
  String get loginInactiveMessage => 'هذا الحساب غير نشط. هل ترغب في إعادة تفعيله؟';

  @override
  String get loginWarningInactive => 'كان هذا الحساب غير نشط وتمت إعادة تفعيله. يرجى مراجعة إعداداتك.';

  @override
  String get markAsPaid => 'وضع علامة مدفوع';

  @override
  String get markAsPaidConfirmation => 'هل تريد وضع علامة مدفوع على هذا الحجز؟';

  @override
  String get myPostsConfirmDelete => 'هل تريد حذف هذا المنشور؟';

  @override
  String get myPostsDelete => 'حذف';

  @override
  String get myPostsEmpty => 'لا توجد منشورات.';

  @override
  String get myPostsSuccessDelete => 'تم حذف المنشور بنجاح';

  @override
  String get no => 'لا';

  @override
  String get noAvailableUsers => 'لا يوجد مستخدمون لإسنادهم.';

  @override
  String get noBookings => 'لا توجد حجوزات.';

  @override
  String get notPaid => 'غير مدفوع';

  @override
  String get notificationDeleteError => 'خطأ حذف الإشعار:';

  @override
  String get notificationEmpty => 'لا توجد إشعارات.';

  @override
  String get notificationFetchError => 'خطأ في جلب الإشعارات:';

  @override
  String get noScreenForNotification => ' لا توجد شاشة مرتبطة ';

  @override
  String get deletedSuccessfully => 'تم حذف الإشعار بنجاح';

  @override
  String get markedAsRead => ' تم تعليمها كمقروءة';

  @override
  String get notificationMarkReadError => 'فشل وضع علامة مقروء:';

  @override
  String get onboardingAlreadyHaveAccount => 'لديك حساب؟ تسجيل الدخول';

  @override
  String get onboardingCreateAccount => 'إنشاء حساب';

  @override
  String get onboardingGetStarted => 'ابدأ';

  @override
  String get onboardingSignIn => 'تسجيل الدخول';

  @override
  String get onboardingSubtitle => 'اكتشف الشغف، تواصل مع الآخرين، وطوّر مهاراتك.';

  @override
  String get onboardingTitle => 'بوابتك إلى هوايات ممتعة';

  @override
  String get changeTheme => 'تغيير السمة';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get onbSkip => 'تخطي';

  @override
  String get onbNext => 'التالي';

  @override
  String get onbGetStarted => 'ابدأ الآن';

  @override
  String get onbTitle1 => 'اكتشف الأنشطة';

  @override
  String get onbSubtitle1 => 'اعثر على الهوايات والفعاليات بالقرب منك.';

  @override
  String get onbTitle2 => 'احجز في ثوانٍ';

  @override
  String get onbSubtitle2 => 'حجز بسيط وآمن وسريع.';

  @override
  String get onbTitle3 => 'انضم للمجتمع';

  @override
  String get onbSubtitle3 => 'تواصل مع من يشاركونك الشغف.';

  @override
  String get paid => 'مدفوع';

  @override
  String get paymentConfirmation => 'تأكيد الحجز';

  @override
  String get privacyP1 => 'نحترم خصوصيتك ونلتزم بحماية معلوماتك الشخصية.';

  @override
  String get privacyP2 => 'عند استخدام التطبيق قد نجمع معلومات أساسية لتحسين تجربتك، مثل الاسم والبريد وطريقة الاستخدام.';

  @override
  String get privacyP3 => 'نستخدم هذه المعلومات لتحسين التطبيق فقط. لا نبيع معلوماتك.';

  @override
  String get privacyP4 => 'تُخزن بياناتك بأمان ويمكنك التواصل معنا في أي وقت.';

  @override
  String get privacyP5 => 'باستخدامك التطبيق فأنت توافق على سياسة الخصوصية. قد نحدّثها مستقبلًا وسنبلغك بالتغييرات المهمة.';

  @override
  String get privacyTitle => 'سياسة الخصوصية';

  @override
  String get privacyUpdated => 'آخر تحديث: مايو 2025';

  @override
  String get profileCalendar => 'تقويمي';

  @override
  String get profileConfirmDelete => 'هل تريد حذف حسابك نهائيًا؟';

  @override
  String get profileConfirmInactive => 'أكّد كلمة المرور لتعطيل الحساب';

  @override
  String get profileDeleteAccount => 'حذف الحساب';

  @override
  String get profileEditProfile => 'تعديل الملف';

  @override
  String get profileEnterValidEmail => 'يرجى إدخال بريد صالح.';

  @override
  String get profileError => 'حدث خطأ ما.';

  @override
  String get profileErrorSendingInvite => 'فشل إرسال الدعوة.';

  @override
  String get profileGoogleNoPasswordNeeded => 'سجلت عبر Google. لا حاجة لكلمة مرور.';

  @override
  String get profileGuest => 'ضيف';

  @override
  String get profileInactiveInfo => 'هل تريد تعطيل حسابك؟ بعد 30 يومًا سيتم حذفه نهائيًا ولن تتمكن من تسجيل الدخول.';

  @override
  String get profileInviteManager => 'دعوة مدير';

  @override
  String get profileLanguage => 'اللغة';

  @override
  String get profileLogoutConfirm => 'هل تريد تسجيل الخروج؟';

  @override
  String get profileMakePrivate => 'جعل الملف خاصًا';

  @override
  String get profileMakePublic => 'جعل الملف عامًا';

  @override
  String get profileManageAccount => 'إدارة الحساب';

  @override
  String get profileManagerEmail => 'بريد المدير';

  @override
  String get profileMotto => 'عِش هوايتك!';

  @override
  String get profileMyInterests => 'اهتماماتي';

  @override
  String get profileNotifications => 'الإشعارات';

  @override
  String get profilePrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get profilePrivate => 'ملف خاص';

  @override
  String get profilePublic => 'ملف عام';

  @override
  String get profileSetActive => 'تفعيل الحساب';

  @override
  String get profileSetInactive => 'تعطيل الحساب';

  @override
  String get profilebusinessAnalytics => 'التحليلات';

  @override
  String get profilebusinessArabic => 'العربية';

  @override
  String get profilebusinessCancel => 'إلغاء';

  @override
  String get profilebusinessConfirmLogout => 'هل تريد تسجيل الخروج؟';

  @override
  String get profilebusinessConnectStripe => 'ربط حساب سترايب';

  @override
  String get profilebusinessConnecting => 'جارٍ الربط...';

  @override
  String get profilebusinessEditBusinessInfo => 'تعديل معلومات النشاط';

  @override
  String get profilebusinessEnglish => 'الإنجليزية';

  @override
  String get profilebusinessFrench => 'الفرنسية';

  @override
  String get profilebusinessGuest => 'نشاط تجاري';

  @override
  String get profilebusinessLanguage => 'اللغة';

  @override
  String get profilebusinessLogout => 'تسجيل الخروج';

  @override
  String get profilebusinessMyActivities => 'أنشطتي';

  @override
  String get profilebusinessPickLogo => 'شعار النشاط';

  @override
  String get profilebusinessPickLogoHint => 'التقاط صورة أو اختيار من المعرض';

  @override
  String get profilebusinessPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get profilebusinessResumeStripe => 'متابعة إعداد سترايب';

  @override
  String get profilebusinessStripeConnected => 'تم ربط حساب سترايب';

  @override
  String get profilebusinessStripeNotConnected => 'لا يوجد حساب سترايب مرتبط';

  @override
  String get profilebusinessTagline => 'لننمو بعملك مع HobbySphere..';

  @override
  String get reactivate => 'إعادة تفعيل';

  @override
  String get registerAddProfilePhoto => 'اضغط لاختيار صورة الملف';

  @override
  String get registerBusiness => 'نشاط تجاري';

  @override
  String get registerBusinessName => 'اسم النشاط التجاري';

  @override
  String get registerCompleteButtonsContinue => 'متابعة';

  @override
  String get registerCompleteButtonsFinish => 'إنهاء';

  @override
  String get registerCompleteButtonsSeeAll => 'عرض الكل';

  @override
  String get registerCompleteButtonsSeeLess => 'عرض أقل';

  @override
  String get registerCompleteButtonsSubmitting => 'جارٍ الإرسال...';

  @override
  String get registerCompleteErrorsBusinessNameRequired => 'اسم النشاط مطلوب.';

  @override
  String get registerCompleteErrorsDescriptionRequired => 'الوصف مطلوب.';

  @override
  String get registerCompleteErrorsFirstNameRequired => 'الاسم الأول مطلوب.';

  @override
  String get registerCompleteErrorsGeneric => 'حدث خطأ ما';

  @override
  String get registerCompleteErrorsLastNameRequired => 'اسم العائلة مطلوب.';

  @override
  String get registerCompleteErrorsUsernameRequired => 'اسم المستخدم مطلوب.';

  @override
  String get registerCompleteStep1BusinessName => 'اسم النشاط التجاري';

  @override
  String get registerCompleteStep1FirstName => 'الاسم الأول';

  @override
  String get registerCompleteStep1FirstNameQuestion => 'ما اسمك؟';

  @override
  String get registerCompleteStep1LastName => 'اسم العائلة';

  @override
  String get registerCompleteStep2BusinessDescription => 'وصف النشاط التجاري';

  @override
  String get registerCompleteStep2ChooseUsername => 'اختر اسم مستخدم';

  @override
  String get registerCompleteStep2Description => 'الوصف';

  @override
  String get registerCompleteStep2DescriptionHint1 => '• صفْ نشاطك بوضوح';

  @override
  String get registerCompleteStep2DescriptionHint2 => '• اجعله موجزًا وملائمًا (حد ~250 حرفًا)';

  @override
  String get registerCompleteStep2Username => 'اسم المستخدم';

  @override
  String get registerCompleteStep2UsernameHint1 => '• يجب أن يكون فريدًا';

  @override
  String get registerCompleteStep2UsernameHint2 => '• دون مسافات أو رموز';

  @override
  String get registerCompleteStep2UsernameHint3 => '• بين 3–15 حرفًا';

  @override
  String get registerCompleteStep2WebsiteUrl => 'رابط الموقع (اختياري)';

  @override
  String get registerCompleteStep3BusinessLogo => 'شعار النشاط';

  @override
  String get registerCompleteStep3ProfileImage => 'صورة الملف';

  @override
  String get registerCompleteStep3PublicProfile => 'ملف عام';

  @override
  String get registerCompleteStep3TapToChooseBanner => 'اضغط لاختيار بانر النشاط';

  @override
  String registerCompleteStep3TapToChooseLogo(String type) {
    return 'اضغط لاختيار $type';
  }

  @override
  String get registerConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get registerDescription => 'الوصف';

  @override
  String get registerEmail => 'البريد الإلكتروني';

  @override
  String get registerErrorBusinessInfo => 'معلومات النشاط التجاري مفقودة.';

  @override
  String get registerErrorFailed => 'فشل التسجيل';

  @override
  String get registerErrorLength => 'يجب ألا تقل كلمة المرور عن 8 أحرف.';

  @override
  String get registerErrorMatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get registerErrorRequired => 'البريد وكلمة المرور مطلوبان.';

  @override
  String get registerErrorSymbol => 'يجب أن تتضمن كلمة المرور رمزًا واحدًا على الأقل.';

  @override
  String get registerErrorUserInfo => 'معلومات المستخدم مفقودة.';

  @override
  String get registerFirstName => 'الاسم الأول';

  @override
  String get registerLastName => 'اسم العائلة';

  @override
  String get registerPassword => 'كلمة المرور';

  @override
  String get registerPhoneNumber => 'رقم الهاتف';

  @override
  String get registerPublicProfile => 'اجعل ملفي عامًا';

  @override
  String get registerSelectBanner => 'اضغط لاختيار بانر النشاط';

  @override
  String get registerSelectLogo => 'اضغط لاختيار شعار النشاط';

  @override
  String get registerSendCode => 'إرسال رمز التحقق';

  @override
  String get registerSuccessBusiness => 'تم تسجيل النشاط التجاري!';

  @override
  String get registerSuccessUser => 'تم تسجيل المستخدم!';

  @override
  String get registerTitle => 'إنشاء حساب';

  @override
  String get registerUser => 'مستخدم';

  @override
  String get registerUsername => 'اسم المستخدم';

  @override
  String get registerWebsite => 'الموقع';

  @override
  String get resetPasswordButton => 'إعادة تعيين كلمة المرور';

  @override
  String get resetPasswordConfirm => 'تأكيد كلمة المرور';

  @override
  String get resetPasswordError => 'حدث خطأ ما.';

  @override
  String get resetPasswordFail => 'فشل إعادة تعيين كلمة المرور.';

  @override
  String get resetPasswordFillFields => 'يرجى تعبئة كل الحقول.';

  @override
  String get resetPasswordMismatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get resetPasswordNew => 'كلمة مرور جديدة';

  @override
  String get resetPasswordSuccess => 'تمت إعادة تعيين كلمة المرور!';

  @override
  String get resetPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get resetPasswordUpdating => 'جارٍ التحديث...';

  @override
  String get reviewAllReviews => 'المراجعات';

  @override
  String get reviewError => 'فشل إرسال المراجعة';

  @override
  String get reviewMissingData => 'أدخل ملاحظاتك قبل الإرسال.';

  @override
  String get reviewPlaceholder => 'اكتب تجربتك...';

  @override
  String get reviewRating => 'التقييم';

  @override
  String get reviewSubmit => 'إرسال المراجعة';

  @override
  String get reviewSubmitting => 'جارٍ الإرسال...';

  @override
  String get reviewSuccess => 'تم إرسال المراجعة';

  @override
  String get reviewTitle => 'أضف مراجعتك';

  @override
  String get reviewYourFeedback => 'ملاحظاتك';

  @override
  String get reviewsNoReviews => 'لا توجد مراجعات.';

  @override
  String get reviewsTitle => 'مراجعات العملاء';

  @override
  String get searchPlaceholder => 'بحث';

  @override
  String get selectMethodAlreadyHaveAccount => 'لديك حساب؟';

  @override
  String get selectMethodContinue => 'متابعة';

  @override
  String get selectMethodContinueWithEmail => 'المتابعة بالبريد';

  @override
  String get selectMethodContinueWithFacebook => 'المتابعة عبر فيسبوك';

  @override
  String get selectMethodContinueWithGoogle => 'المتابعة عبر Google';

  @override
  String get selectMethodCreatePassword => 'إنشاء كلمة مرور';

  @override
  String get selectMethodEnterPassword => 'أدخل كلمة المرور';

  @override
  String get selectMethodLoading => 'جارٍ التحميل...';

  @override
  String get selectMethodLogin => 'تسجيل الدخول';

  @override
  String get selectMethodOr => 'أو';

  @override
  String get selectMethodPasswordRulesRule1 => '8 أحرف (بحد أقصى 20)';

  @override
  String get selectMethodPasswordRulesRule2 => 'حرف ورقم ورمز خاص (# ? ! @)';

  @override
  String get selectMethodPasswordRulesRule3 => 'كلمة مرور قوية';

  @override
  String get selectMethodPhonePlaceholder => 'رقم الهاتف';

  @override
  String get selectMethodRoleBusiness => 'نشاط تجاري';

  @override
  String get selectMethodRoleUser => 'مستخدم';

  @override
  String get selectMethodSaveInfo => 'احفظ معلومات الدخول لتسجيل الدخول تلقائيًا لاحقًا.';

  @override
  String get selectMethodSignUp => 'إنشاء حساب';

  @override
  String get selectMethodTitle => 'إنشاء حساب';

  @override
  String get singleChatAccessDeniedMsg => 'لست صديقًا لهذا المستخدم.';

  @override
  String get singleChatAccessDeniedTitle => 'الوصول مرفوض';

  @override
  String get singleChatBlock => 'حظر';

  @override
  String get singleChatBlockConfirm => 'هل تريد حظر هذا المستخدم؟';

  @override
  String get singleChatBlockTitle => 'حظر المستخدم';

  @override
  String get singleChatBlockedByThem => 'قام هذا المستخدم بحظرك. لا يمكنك إرسال رسائل.';

  @override
  String get singleChatCancel => 'إلغاء';

  @override
  String get singleChatDelete => 'حذف';

  @override
  String get singleChatDeleteConfirm => 'هل تريد حذف الرسائل المحددة؟';

  @override
  String get singleChatDeleteTitle => 'حذف الرسائل';

  @override
  String get singleChatErrorFetching => 'تعذر جلب الرسائل.';

  @override
  String get singleChatErrorTitle => 'خطأ';

  @override
  String get singleChatInputPlaceholder => 'اكتب رسالة...';

  @override
  String get singleChatUnblock => 'إلغاء الحظر';

  @override
  String get singleChatUnblockConfirm => 'هل تريد إلغاء حظر هذا المستخدم؟';

  @override
  String get singleChatUnblockTitle => 'إلغاء حظر المستخدم';

  @override
  String get singleChatYouBlocked => 'لقد قمت بحظر هذا المستخدم. ألغِ الحظر للمتابعة.';

  @override
  String get socialAddPost => 'منشور';

  @override
  String get socialChat => 'دردشة';

  @override
  String get socialEmpty => 'لا توجد منشورات.';

  @override
  String get socialError => 'حدث خطأ غير متوقع';

  @override
  String get socialNotifications => 'التنبيهات';

  @override
  String get socialMyPosts => 'منشوراتي';

  @override
  String get myPostsTitle => 'منشوراتي';

  @override
  String get deletePostTitle => 'حذف المنشور؟';

  @override
  String get deletePostConfirm => 'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get deletePostSuccess => 'تم حذف المنشور';

  @override
  String get deletePostFailed => 'فشل الحذف';

  @override
  String get socialSearchFriend => 'بحث ';

  @override
  String get socialTitle => 'HobbySphere';

  @override
  String get stripeError => 'خطأ';

  @override
  String get stripePay50 => 'ادفع \$50';

  @override
  String get stripePayNow => 'المتابعة للدفع';

  @override
  String get stripePaymentFailed => 'فشل الدفع';

  @override
  String get stripeSuccessMessage => 'اكتمل الدفع!';

  @override
  String get stripeSuccessTitle => 'نجاح';

  @override
  String get tabExplore => 'استكشاف';

  @override
  String get tabHome => 'الرئيسية';

  @override
  String get tabProfile => 'الملف الشخصي';

  @override
  String get tabSocial => 'المجتمع';

  @override
  String get tabTickets => 'التذاكر';

  @override
  String get tabSettings => 'الإعدادات';

  @override
  String get tabnavigateActivities => 'الأنشطة';

  @override
  String get tabnavigateAnalytics => 'التحليلات';

  @override
  String get tabnavigateBookings => 'الحجوزات';

  @override
  String get tabnavigateHome => 'الرئيسية';

  @override
  String get tabActivities => 'الأنشطة';

  @override
  String get tabAnalytics => 'التحليلات';

  @override
  String get tabBookings => 'الحجوزات';

  @override
  String get tabnavigateProfile => 'الملف';

  @override
  String get ticketCancel => 'إلغاء';

  @override
  String get ticketCancelConfirm => 'هل تريد إلغاء هذه التذكرة؟';

  @override
  String get ticketCancelTitle => 'إلغاء التذكرة';

  @override
  String get ticketConfirm => 'تأكيد';

  @override
  String get ticketDelete => 'حذف';

  @override
  String get ticketDeleteConfirm => 'هل تريد حذف هذه التذكرة الملغاة نهائيًا؟';

  @override
  String get ticketDeleteTitle => 'حذف التذكرة';

  @override
  String ticketEmpty(String status) {
    return 'لا توجد تذاكر في $status.';
  }

  @override
  String get ticketLocation => 'الموقع';

  @override
  String get ticketReturnConfirm => 'هل تريد إرجاع التذكرة إلى قيد الانتظار؟';

  @override
  String get ticketReturnTitle => 'إرجاع إلى الانتظار';

  @override
  String get ticketReturnToPending => 'إرجاع إلى قيد الانتظار';

  @override
  String get ticketScreenTitle => 'التذاكر';

  @override
  String get ticketStatusCanceled => 'ملغاة';

  @override
  String get ticketStatusCompleted => 'مكتملة';

  @override
  String get ticketStatusPending => 'قيد الانتظار';

  @override
  String get ticketTime => 'الوقت';

  @override
  String get ticketsTitle => 'التذاكر';

  @override
  String get ticketsEmptyPending => 'لا توجد تذاكر معلّقة.';

  @override
  String get ticketsEmptyCompleted => 'لا توجد تذاكر مكتملة.';

  @override
  String get ticketsEmptyCanceled => 'لا توجد تذاكر ملغاة.';

  @override
  String get ticketsEmptyGeneric => 'لا توجد تذاكر.';

  @override
  String get ticketsDelete => 'حذف';

  @override
  String get ticketsDeleteTitle => 'حذف التذكرة؟';

  @override
  String get ticketsDeleteConfirm => 'سيتم حذف التذكرة الملغاة.';

  @override
  String get ticketsCancelRequested => 'طلبات إلغاء التذكرة';

  @override
  String get theme => 'السمة';

  @override
  String get themeDark => 'داكن';

  @override
  String get verifyCodeButton => 'تحقق من الرمز';

  @override
  String get verifyCodeFail => 'فشل التحقق من الرمز.';

  @override
  String get verifyCodeInvalid => 'رمز غير صالح.';

  @override
  String get verifyCodePlaceholder => 'رمز التحقق';

  @override
  String get verifyCodeRequired => 'أدخل رمز التحقق.';

  @override
  String get verifyCodeSubtitle => 'أرسلنا رمزًا إلى بريدك';

  @override
  String get verifyCodeTitle => 'أدخل الرمز';

  @override
  String get verifyCodeVerifying => 'جارٍ التحقق...';

  @override
  String get verifyEnterCode => 'أدخل رمز التحقق المؤلف من 6 أرقام';

  @override
  String get verifyFullCodeError => 'يرجى إدخال الرمز الكامل المكوّن من 6 أرقام.';

  @override
  String get verifyInvalidCode => 'رمز غير صالح أو منتهي.';

  @override
  String get verifyResendBtn => 'إعادة إرسال الرمز';

  @override
  String get verifyResendFailed => 'فشل إعادة إرسال الرمز.';

  @override
  String get verifyResent => 'تمت إعادة إرسال الرمز. تحقق من بريدك أو هاتفك.';

  @override
  String get verifySuccessBusiness => 'تم توثيق حساب النشاط التجاري!';

  @override
  String get verifySuccessUser => 'تم توثيق الحساب بنجاح!';

  @override
  String get verifyVerifyBtn => 'تحقق';

  @override
  String get yes => 'نعم';

  @override
  String get fieldTitle => 'العنوان';

  @override
  String get hintTitle => 'عنوان النشاط';

  @override
  String get selectActivityType => 'اختر نوع النشاط';

  @override
  String get fieldDescription => 'الوصف';

  @override
  String get hintDescription => 'صف نشاطك';

  @override
  String get searchLocation => 'ابحث عن العنوان';

  @override
  String get getMyLocation => 'احصل على موقعي';

  @override
  String get fieldMaxParticipants => 'الحد الأقصى للمشاركين';

  @override
  String get hintMaxParticipants => 'أدخل رقمًا';

  @override
  String get fieldPrice => 'السعر';

  @override
  String get fieldStartDateTime => 'تاريخ ووقت البدء';

  @override
  String get fieldEndDateTime => 'تاريخ ووقت الانتهاء';

  @override
  String get pickImage => 'اختر صورة';

  @override
  String get submit => 'إرسال';

  @override
  String get errorAuthRequired => 'يجب تسجيل الدخول.';

  @override
  String get bookingsMyBookings => 'حجوزاتي';

  @override
  String get bookingsByUser => 'حجز بواسطة';

  @override
  String get bookingsStatus => 'الحالة';

  @override
  String get bookingsPaid => 'مدفوع';

  @override
  String get bookingsReject => 'رفض';

  @override
  String get bookingsUnreject => 'إلغاء الرفض';

  @override
  String get bookingsMarkPaid => 'وضع كمدفوع';

  @override
  String get bookingsDetails => 'عرض التفاصيل';

  @override
  String get activitiesUnnamed => 'نشاط غير مسمى';

  @override
  String get upcoming => 'قادمة';

  @override
  String get terminated => 'منتهية';

  @override
  String get editBusinessInfo => 'تعديل معلومات النشاط';

  @override
  String get myActivities => 'أنشطتي';

  @override
  String get analytics => 'تحليلات';

  @override
  String get notifications => 'إشعارات';

  @override
  String get inviteManager => 'دعوة مدير';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get language => 'اللغة';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get manageAccount => 'إدارة الحساب';

  @override
  String get toggleVisibility => 'تبديل الظهور';

  @override
  String get setInactive => 'تعطيل الحساب';

  @override
  String get setActive => 'إعادة تفعيل الحساب';

  @override
  String get deleteBusiness => 'حذف النشاط';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get enterPassword => 'أدخل كلمة المرور';

  @override
  String get statusUpdated => 'تم تحديث الحالة';

  @override
  String get visibilityUpdated => 'تم تحديث الظهور';

  @override
  String get businessDeleted => 'تم حذف النشاط التجاري';

  @override
  String get errorOccurred => 'حدث خطأ. حاول مجددًا.';

  @override
  String get publicProfile => 'ملف عام';

  @override
  String get privateProfile => 'ملف خاص';

  @override
  String get businessGrowMessage => 'لننمو بعملك مع HobbySphere..';

  @override
  String get stripeAccountConnected => 'حساب سترايب متصل';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get stripeAccountNotConnected => 'حساب سترايب غير متصل';

  @override
  String get registerOnStripe => ' سجّل على حساب سترايب';

  @override
  String get businessUsersTitle => 'مستخدمو النشاط';

  @override
  String get addUser => 'إضافة مستخدم';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get provideEmailOrPhone => ' أدخل البريد أو رقم الهاتف';

  @override
  String get alreadyBooked => ' محجوز مسبقًا';

  @override
  String get save => 'حفظ';

  @override
  String get bookingsFiltersCancelRequested => 'طلب إلغاء';

  @override
  String get inviteManagerTitle => 'دعوة مدير';

  @override
  String get inviteManagerInstruction => 'أدخل بريد المدير. سنرسل له دعوة.';

  @override
  String get managerEmailLabel => 'بريد المدير';

  @override
  String get managerEmailHint => 'name@example.com';

  @override
  String get sendInvite => 'إرسال الدعوة';

  @override
  String get sending => 'جارٍ الإرسال…';

  @override
  String get invalidEmail => 'يرجى إدخال بريد صالح';

  @override
  String get deactivateTitle => 'هل تريد تعطيل حسابك؟';

  @override
  String get deactivateWarning => 'بعد 30 يومًا سيتم حذفه نهائيًا ولن تتمكن من تسجيل الدخول.';

  @override
  String get currentPasswordLabel => 'كلمة المرور الحالية';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب';

  @override
  String get bookingNotAvailable => 'هذا النشاط غير متاح لعدد المشاركين المحدد.';

  @override
  String get editInterestsTitle => 'تعديل اهتماماتك';

  @override
  String get notLoggedInTitle => 'Not Logged In';

  @override
  String get notLoggedInMessage => 'You must be logged in to access this feature.';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get getStarted => 'Get Started';

  @override
  String get connectionConnecting => 'جارٍ الاتصال…';

  @override
  String get connectionOffline => 'لا يوجد اتصال';

  @override
  String get connectionTryAgain => 'أعد المحاولة';

  @override
  String get splashNoConnectionTitle => 'لا يوجد اتصال بالإنترنت';

  @override
  String get splashNoConnectionDesc => 'يرجى التحقق من الواي فاي أو بيانات الهاتف ثم أعد المحاولة.';

  @override
  String get splashServerDownTitle => 'Server is unavailable';

  @override
  String get splashServerDownDesc => 'We’re online, but can’t reach the server right now. Please try again in a moment.';

  @override
  String get connectionServerDown => 'Server unavailable';

  @override
  String get stripeConnectRequiredTitle => 'Stripe account required';

  @override
  String get stripeConnectRequiredDesc => 'To publish an activity and receive payments, please connect your Stripe account first.';

  @override
  String get interestSaved => 'تم حفظ الاهتمامات';

  @override
  String get selected => 'محدّد';

  @override
  String get somethingWentWrong => 'حدث خطأ ما';

  @override
  String get retry => 'إعادة المحاولة';
}
