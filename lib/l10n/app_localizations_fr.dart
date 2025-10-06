// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get activitiesFiltersTerminated => 'Terminées';

  @override
  String get activitiesFiltersUpcoming => 'À venir';

  @override
  String get activitiesMyActivities => 'Mes activités';

  @override
  String get activitiesNoActivities => 'Aucune activité trouvée.';

  @override
  String get activitiesReopen => 'Rouvrir l’activité';

  @override
  String get activityDetailsCancel => 'Annuler';

  @override
  String get activityDetailsConfirmDelete => 'Confirmer la suppression';

  @override
  String get activityDetailsDelete => 'Supprimer';

  @override
  String get activityDetailsDeleteError => 'Échec de la suppression de l’activité.';

  @override
  String get activityDetailsDeletePrompt => 'Êtes‑vous sûr de vouloir supprimer cette activité ?';

  @override
  String get activityDetailsDeleteSuccess => 'L’activité a été supprimée.';

  @override
  String get activityDetailsDeleted => 'Supprimée';

  @override
  String get activityDetailsDescription => 'Description';

  @override
  String get activityDetailsEdit => 'Modifier';

  @override
  String get activityDetailsParticipants => 'Participants';

  @override
  String get activityDetailsStatus => 'Statut';

  @override
  String get activityDetailsViewInsights => 'Voir les insights';

  @override
  String get activityInsightsTitle => 'Insights de l’activité';

  @override
  String get addNewUser => 'Ajouter un nouveau client';

  @override
  String get analyticsBookingGrowth => 'Croissance des réservations';

  @override
  String get analyticsCancel => 'Annuler';

  @override
  String get analyticsCustomerRetention => 'Rétention client';

  @override
  String get analyticsDownloadReport => 'Télécharger le rapport PDF';

  @override
  String get analyticsPeakHours => 'Heures de pointe';

  @override
  String get analyticsReportDate => 'Date du rapport';

  @override
  String get analyticsRevenueOverview => 'Aperçu des revenus';

  @override
  String get analyticsShare => 'Partager';

  @override
  String get analyticsShareMessage => 'Votre PDF a été enregistré dans le dossier Téléchargements.\nVoulez‑vous le partager maintenant ?';

  @override
  String get analyticsTitle => 'Analytique Business';

  @override
  String get analyticsToday => 'Aujourd’hui';

  @override
  String get analyticsTopActivity => 'Activité la plus populaire';

  @override
  String get analyticsTotalRevenue => 'Revenu total';

  @override
  String get analyticsYesterday => 'Hier';

  @override
  String get assignToActivity => 'Assigner à l’activité';

  @override
  String get authNotLoggedInMessage => 'Vous devez être connecté pour accéder à cette fonctionnalité.';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ? ';

  @override
  String get signIn => 'Se connecter';

  @override
  String get businessWelcomeTitle => 'Bienvenue sur votre tableau de bord !';

  @override
  String get businessWelcomeSubtitle => 'Gérez vos activités et interagissez facilement avec les utilisateurs.';

  @override
  String get createNewActivity => 'Créer une nouvelle activité';

  @override
  String get activitiesEmpty => 'Aucune activité pour l’instant';

  @override
  String get profileLastUpdated => 'Dernière mise à jour';

  @override
  String get viewDetails => 'Voir';

  @override
  String get buttonWebsite => 'Site web';

  @override
  String get buttonCall => 'Appeler';

  @override
  String get mapOpen => 'Ouvrir dans Plans';

  @override
  String get copy => 'Copier';

  @override
  String get copied => 'Copié !';

  @override
  String get badgeStripe => 'Stripe';

  @override
  String get labelDuration => 'Durée';

  @override
  String get authNotLoggedInTitle => 'Non connecté';

  @override
  String get appTitle => 'Hobby Sphere';

  @override
  String get splashLoading => 'Chargement…';

  @override
  String get bookingAbout => 'À propos';

  @override
  String get bookingApprove => 'Approuver';

  @override
  String get bookingBookNow => 'Réserver maintenant';

  @override
  String get bookingBooking => 'Réservation…';

  @override
  String get bookingCancel => 'Annuler';

  @override
  String get bookingCancelReason => 'Raison';

  @override
  String get bookingConfirmRejectMessage => 'Êtes‑vous sûr de vouloir rejeter cette réservation ?';

  @override
  String get bookingConfirmRejectTitle => 'Rejeter la réservation';

  @override
  String get bookingConfirmUnrejectMessage => 'Voulez‑vous annuler le rejet ?';

  @override
  String get bookingConfirmUnrejectTitle => 'Annuler le rejet';

  @override
  String get bookingConfirm_approveCancel => 'Approuver l’annulation';

  @override
  String get bookingConfirm_reject => 'Confirmer le rejet';

  @override
  String get bookingConfirm_rejectCancel => 'Rejeter l’annulation';

  @override
  String get bookingConfirm_unreject => 'Confirmer l’annulation du rejet';

  @override
  String get bookingErrorFailed => 'Échec de la réservation. Veuillez réessayer.';

  @override
  String get bookingErrorLoginRequired => 'Vous devez être connecté pour réserver.';

  @override
  String get bookingErrorMaxParticipantsReached => 'Vous ne pouvez pas réserver au‑delà du nombre maximum de participants.';

  @override
  String get bookingLocation => 'Lieu';

  @override
  String bookingMaxParticipants(int count) {
    return 'Max $count participants';
  }

  @override
  String get bookingMessage_approveCancel => 'Êtes‑vous sûr de vouloir approuver cette demande d’annulation ?';

  @override
  String get bookingMessage_reject => 'Êtes‑vous sûr de vouloir rejeter cette réservation ?';

  @override
  String get bookingMessage_rejectCancel => 'Êtes‑vous sûr de vouloir rejeter cette demande d’annulation ?';

  @override
  String get bookingMessage_unreject => 'Êtes‑vous sûr de vouloir annuler le rejet de cette réservation ?';

  @override
  String get bookingMethod => 'Mode de paiement';

  @override
  String get bookingMissing => 'Identifiant de réservation ou jeton manquant';

  @override
  String get bookingParticipants => 'Nombre de participants';

  @override
  String get bookingPaymentCash => 'Espèces';

  @override
  String get bookingPaymentMethod => 'Mode de paiement';

  @override
  String get bookingPerPerson => 'par personne';

  @override
  String get bookingPrice => 'Prix';

  @override
  String get bookingProcessing => 'Traitement…';

  @override
  String get bookingReject => 'Rejeter';

  @override
  String get bookingRejectCancel => 'Rejeter l’annulation';

  @override
  String get bookingTotal => 'Prix total';

  @override
  String get bookingTotalPrice => 'Prix total';

  @override
  String get bookingUnreject => 'Annuler le rejet';

  @override
  String get bookingUpdated => 'Réservation mise à jour avec succès';

  @override
  String get bookingsFiltersAll => 'Tout';

  @override
  String get bookingsFiltersCanceled => 'Annulées';

  @override
  String get bookingsFiltersCompleted => 'Terminées';

  @override
  String get bookingsFiltersPending => 'En attente';

  @override
  String get bookingsFiltersRejected => 'Rejetées';

  @override
  String bookingsNoBookings(String status) {
    return 'Aucune réservation trouvée pour « $status ».';
  }

  @override
  String get bookingsTitle => 'Réservations Business';

  @override
  String get businessCreateActivity => 'Créer une nouvelle activité';

  @override
  String get businessGreeting => 'Bonjour,';

  @override
  String get businessManageText => 'Gérez vos activités et interagissez facilement avec les utilisateurs.';

  @override
  String get businessNoActivities => 'Aucune activité trouvée. Commencez par en créer une !';

  @override
  String get businessUsers => 'Utilisateurs Business';

  @override
  String get businessWelcome => 'Bienvenue sur votre tableau de bord !';

  @override
  String get businessYourActivities => 'Vos activités';

  @override
  String get buttonCancel => 'Annuler';

  @override
  String get buttonConfirm => 'Confirmer';

  @override
  String get buttonDelete => 'Supprimer';

  @override
  String get buttonLoading => 'Chargement…';

  @override
  String get buttonLogin => 'Connexion';

  @override
  String get buttonLogout => 'Déconnexion';

  @override
  String get buttonOk => 'OK';

  @override
  String get buttonRegister => 'S’inscrire';

  @override
  String get buttonSendInvite => 'Envoyer l’invitation';

  @override
  String get buttonSubmit => 'Envoyer';

  @override
  String get buttonsCancel => 'Annuler';

  @override
  String get buttonsConfirm => 'Confirmer';

  @override
  String get buttonsContinue => 'Continuer';

  @override
  String get buttonsFinish => 'Terminer';

  @override
  String get buttonsLogin => 'Connexion';

  @override
  String get buttonsRegister => 'Inscription';

  @override
  String get buttonsSeeAll => 'Voir tout';

  @override
  String get buttonsSeeLess => 'Voir moins';

  @override
  String get buttonsSubmitting => 'Envoi…';

  @override
  String get calendarNoActivities => 'Aucune activité trouvée.';

  @override
  String get calendarNoActivitiesForDate => 'Aucune activité à la date sélectionnée.';

  @override
  String get calendarTabsPast => 'Activités passées';

  @override
  String get calendarTabsUpcoming => 'À venir';

  @override
  String get calendarTitle => 'Calendrier';

  @override
  String get cancel => 'Annuler';

  @override
  String get chatNoFriends => 'Ajoutez un ami pour commencer à discuter !';

  @override
  String get chatSubtitle => 'Touchez pour commencer à discuter';

  @override
  String get chatTitle => 'Mes amis';

  @override
  String get chatfriendSubtitle => 'Touchez pour commencer à discuter';

  @override
  String get chatfriendTitle => 'Mes amis';

  @override
  String get commentEmpty => 'Aucun commentaire pour l’instant.';

  @override
  String get commentLike => 'j’aime';

  @override
  String get commentLikes => 'j’aimes';

  @override
  String get commentPlaceholder => 'Écrire un commentaire…';

  @override
  String get commonAreYouSure => 'Êtes‑vous sûr ?';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonConfirm => 'Confirmer';

  @override
  String get confirm => 'Confirmer';

  @override
  String get create => 'Créer';

  @override
  String get createActivityActivityName => 'Nom de l’activité';

  @override
  String get createActivityActivityType => 'Type d’activité';

  @override
  String get createActivityChange => 'Changer';

  @override
  String get createActivityChooseLibrary => 'Choisir depuis la galerie';

  @override
  String get createActivityDescription => 'Description';

  @override
  String get createActivityEndDate => 'Date et heure de fin';

  @override
  String get createActivityErrorRequired => 'Veuillez remplir tous les champs obligatoires.';

  @override
  String get createActivityFail => 'Échec de la création de l’activité. Réessayez.';

  @override
  String get createActivityGetMyLocation => 'Obtenir ma position';

  @override
  String get createActivityLocation => 'Emplacement';

  @override
  String get createActivityLocationErrorPermission => 'Veuillez activer le GPS pour détecter votre position actuelle.';

  @override
  String get createActivityLocationErrorTimeout => 'La demande de localisation a expiré.';

  @override
  String get createActivityLocationErrorUnavailable => 'Impossible d’obtenir votre position.';

  @override
  String get createActivityMaxParticipants => 'Participants max';

  @override
  String get createActivityPickHint => 'Prendre une photo ou choisir depuis la galerie';

  @override
  String get createActivityPickImage => 'Choisir une image';

  @override
  String get createActivityPrice => 'Prix';

  @override
  String get createActivityRemovePhoto => 'Retirer la photo';

  @override
  String get createActivitySearchPlaceholder => 'Rechercher des types d’activité…';

  @override
  String get createActivitySelectType => 'Sélectionner le type d’activité';

  @override
  String get createActivityStartDate => 'Date et heure de début';

  @override
  String get createActivityStripeRequired => 'Vous devez connecter un compte Stripe avant de créer une activité.';

  @override
  String get createActivitySubmit => 'Envoyer';

  @override
  String get createActivitySuccess => 'Activité créée avec succès !';

  @override
  String get createActivityTakePhoto => 'Prendre une photo';

  @override
  String get createActivityTapToPick => 'Touchez pour choisir';

  @override
  String get createActivityTitle => 'Créer une activité';

  @override
  String get reopenedSuccessfully => 'rouverture réussie';

  @override
  String get updatedSuccessfully => 'mis à jour avec succès';

  @override
  String get createPostCancel => 'Annuler';

  @override
  String get createPostClose => 'Fermer';

  @override
  String get createPostEmojiTitle => 'Choisissez votre humeur';

  @override
  String get createPostEmptyError => 'Le contenu du post ne peut pas être vide.';

  @override
  String get createPostFail => 'Échec de la création du post';

  @override
  String get createPostFeeling => 'Humeur';

  @override
  String get createPostFriendsOnly => 'Amis uniquement';

  @override
  String get createPostHashtagsPlaceholder => '#hashtags (facultatif)';

  @override
  String get createPostImage => 'Image du post';

  @override
  String get createPostPhoto => 'Photo';

  @override
  String get createPostPickHint => 'Prendre une photo ou choisir depuis la galerie';

  @override
  String get createPostPlaceholder => 'À quoi pensez‑vous ?';

  @override
  String get createPostPost => 'Publier';

  @override
  String get createPostPublic => 'Public';

  @override
  String get createPostSelectEmojiTitle => 'Sélectionner un emoji';

  @override
  String get createPostSuccess => 'Votre post a été publié !';

  @override
  String get createPostVisibilityAnyone => 'Tout le monde';

  @override
  String get createPostVisibilityFriends => 'Amis';

  @override
  String get createPostVisibilityTitle => 'Visibilité du post';

  @override
  String get editActivityDescription => 'Description';

  @override
  String get editActivityEnd => 'Date et heure de fin';

  @override
  String get editActivityFailure => 'Échec de la mise à jour de l’activité.';

  @override
  String get editActivityLocation => 'Emplacement';

  @override
  String get editActivityName => 'Nom de l’activité';

  @override
  String get editActivityParticipants => 'Participants max';

  @override
  String get editActivityPrice => 'Prix ()';

  @override
  String get editActivityStart => 'Date et heure de début';

  @override
  String get editActivityStatus => 'Statut';

  @override
  String get editActivitySuccess => 'L’activité a été mise à jour avec succès.';

  @override
  String get editActivityTitle => 'Modifier l’activité';

  @override
  String get editActivityUpdate => 'Mettre à jour l’activité';

  @override
  String get editBusinessAddBanner => 'Ajouter une bannière';

  @override
  String get editBusinessAlert => 'Alerte';

  @override
  String get editBusinessBannerDeleted => 'Bannière supprimée.';

  @override
  String get editBusinessBannerHint => 'Prendre une photo ou choisir depuis la galerie';

  @override
  String get editBusinessBannerImage => 'Image de bannière';

  @override
  String get editBusinessBusinessName => 'Nom de l’entreprise';

  @override
  String get editBusinessCancel => 'Annuler';

  @override
  String get editBusinessConfirmDeleteMessage => 'Êtes‑vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.';

  @override
  String get editBusinessConfirmDeletePassword => 'Confirmer le mot de passe pour supprimer le compte';

  @override
  String get editBusinessConfirmDeleteTitle => 'Confirmer la suppression du compte';

  @override
  String get editBusinessConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get editBusinessCurrentPassword => 'Mot de passe actuel';

  @override
  String get editBusinessDelete => 'Supprimer';

  @override
  String get editBusinessDeleteAccount => 'Supprimer le compte';

  @override
  String get editBusinessDeleteFailed => 'Échec de la suppression du compte. Veuillez réessayer.';

  @override
  String get editBusinessDeleteLogoFailed => 'Échec de la suppression du logo.';

  @override
  String get editBusinessDeleting => 'Suppression…';

  @override
  String get editBusinessDescription => 'Description';

  @override
  String get editBusinessEmail => 'Email';

  @override
  String get editBusinessEnterPassword => 'Entrez votre mot de passe';

  @override
  String get editBusinessEnterPasswordToDelete => 'Veuillez entrer votre mot de passe pour supprimer le compte.';

  @override
  String get editBusinessErrorDelete => 'Échec de la suppression de l’entreprise.';

  @override
  String get editBusinessIncorrectPassword => 'Mot de passe incorrect. Veuillez réessayer.';

  @override
  String get editBusinessLogoDeleted => 'Logo supprimé.';

  @override
  String get editBusinessNewPassword => 'Nouveau mot de passe';

  @override
  String get editBusinessOk => 'OK';

  @override
  String get editBusinessPasswordMismatch => 'Les mots de passe ne correspondent pas.';

  @override
  String get editBusinessPasswordTooShort => 'Le mot de passe doit contenir au moins 8 caractères.';

  @override
  String get editBusinessPhoneNumber => 'Numéro de téléphone';

  @override
  String get editBusinessSaveChanges => 'Enregistrer les modifications';

  @override
  String get editBusinessSaving => 'Enregistrement…';

  @override
  String get editBusinessSuccessDelete => 'Entreprise supprimée avec succès.';

  @override
  String get editBusinessTitle => 'Modifier le profil entreprise';

  @override
  String get editBusinessUpdateFailed => 'Échec de la mise à jour du profil.';

  @override
  String get editBusinessUpdateSuccess => 'Profil entreprise mis à jour avec succès.';

  @override
  String get editBusinessWebsite => 'Site web';

  @override
  String get editProfileCancel => 'Annuler';

  @override
  String get editProfileConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get editProfileContact => 'Numéro de contact';

  @override
  String get editProfileCurrentPassword => 'Mot de passe actuel';

  @override
  String get editProfileDelete => 'Supprimer';

  @override
  String get editProfileDeleteAccount => 'Supprimer le compte';

  @override
  String get editProfileDeleteConfirmMsg => 'Êtes‑vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.';

  @override
  String get editProfileDeleteConfirmTitle => 'Confirmer la suppression du compte';

  @override
  String get editProfileDeleteFailed => 'Échec de la suppression du compte.';

  @override
  String get editProfileDeleteInfoWarning => 'Vous vous êtes connecté avec Google, veuillez définir un mot de passe d’abord si ce n’est pas déjà fait.';

  @override
  String get editProfileDeleteProfileImage => 'Supprimer la photo de profil';

  @override
  String get editProfileDeleteProfileImageConfirm => 'Êtes‑vous sûr de vouloir supprimer votre photo de profil ?';

  @override
  String get editProfileDeleteSuccess => 'Compte supprimé avec succès.';

  @override
  String get editProfileEmail => 'Email';

  @override
  String get editProfileFirstName => 'Prénom';

  @override
  String get editProfileImageSelectedSuccess => 'Image sélectionnée.';

  @override
  String get editProfileImageSelectionCancelled => 'Sélection d’image annulée.';

  @override
  String get editProfileImageSelectionError => 'Impossible d’ouvrir le sélecteur d’images.';

  @override
  String get editProfileLastName => 'Nom';

  @override
  String get editProfileNewPassword => 'Nouveau mot de passe';

  @override
  String get editProfilePasswordMismatch => 'Les mots de passe ne correspondent pas.';

  @override
  String get editProfilePasswordRequired => 'Veuillez entrer votre mot de passe actuel.';

  @override
  String get editProfilePickHint => 'Prendre une photo ou choisir depuis la galerie';

  @override
  String get editProfileProfileImage => 'photo de profil';

  @override
  String get editProfileProfileImageDeleted => 'Photo de profil supprimée.';

  @override
  String get editProfileSaveChanges => 'Enregistrer les modifications';

  @override
  String get editProfileSelectImage => 'Choisir une photo de profil';

  @override
  String get editProfileTitle => 'Modifier le profil';

  @override
  String get editProfileUpdateFailed => 'Échec de la mise à jour du profil.';

  @override
  String get editProfileUpdateSuccess => 'Profil mis à jour avec succès.';

  @override
  String get editProfileUsername => 'Nom d’utilisateur';

  @override
  String get editProfileWrongPassword => 'Mot de passe incorrect. Veuillez réessayer.';

  @override
  String get editProfileEmailInvalid => 'Veuillez entrer une adresse email valide.';

  @override
  String get email => 'Email';

  @override
  String get emailRegistrationContinue => 'Continuer';

  @override
  String get emailRegistrationCreatePassword => 'Créer un mot de passe';

  @override
  String get emailRegistrationEmailDesc => 'Vous recevrez un code de vérification par email. Votre adresse peut être utilisée pour vous connecter à d’autres, améliorer les annonces, etc., selon vos paramètres.';

  @override
  String get emailRegistrationEmailPlaceholder => 'Adresse email';

  @override
  String get emailRegistrationEnterEmail => 'Entrer l’email';

  @override
  String get emailRegistrationErrorGeneric => 'Une erreur s’est produite';

  @override
  String get emailRegistrationLoading => 'Chargement…';

  @override
  String get emailRegistrationPasswordPlaceholder => 'Entrer le mot de passe';

  @override
  String get emailRegistrationRule1 => '• 8 caractères (max 20)';

  @override
  String get emailRegistrationRule2 => '• 1 lettre, 1 chiffre, 1 caractère spécial (# ? ! @)';

  @override
  String get emailRegistrationSaveInfo => 'Recevoir du contenu tendance, des newsletters et des mises à jour par email';

  @override
  String get emailRegistrationSignUp => 'S’inscrire';

  @override
  String get emailRegistrationVerificationSent => 'Code de vérification envoyé par email.';

  @override
  String get exploreSubtitle => 'Découvrez différents profils d’entreprises et leurs services';

  @override
  String get exploreTitle => 'Explorer les entreprises';

  @override
  String get exportExcel => 'Exporter en Excel';

  @override
  String get exportPdf => 'Exporter en PDF';

  @override
  String get filtersAll => 'Tous';

  @override
  String get filtersNotPaid => 'Impayé';

  @override
  String get filtersPaid => 'Payé';

  @override
  String get firstName => 'Prénom';

  @override
  String get forgetPasswordEmailPlaceholder => 'Adresse email';

  @override
  String get forgetPasswordEnterEmail => 'Veuillez entrer votre email.';

  @override
  String get forgetPasswordGeneralError => 'Une erreur s’est produite. Réessayez.';

  @override
  String get forgetPasswordSendCode => 'Envoyer le code';

  @override
  String get forgetPasswordSending => 'Envoi…';

  @override
  String forgetPasswordSubtitle(String role) {
    return 'Réinitialisation du mot de passe pour : $role';
  }

  @override
  String get forgetPasswordTitle => 'Réinitialiser le mot de passe';

  @override
  String get forgetPasswordUnableToSend => 'Impossible d’envoyer le code de réinitialisation.';

  @override
  String get friendAccept => 'Accepter';

  @override
  String get friendAccepted => 'Demande d’ami acceptée.';

  @override
  String get friendCancel => 'Annuler la demande';

  @override
  String get friendCancelled => 'Demande annulée.';

  @override
  String get friendChat => 'Discuter';

  @override
  String get friendConfirmUnfriendText => 'Êtes‑vous sûr de vouloir retirer cet ami ?';

  @override
  String get friendConfirmUnfriendTitle => 'Retirer l’ami';

  @override
  String get friendErrorLoad => 'Échec du chargement des données.';

  @override
  String get friendFailedAction => 'Action échouée. Réessayez.';

  @override
  String get friendNoFriends => 'Vous n’avez pas encore d’amis. Commencez à en ajouter !';

  @override
  String friendNoUsersFound(String tab) {
    return 'Aucun utilisateur $tab trouvé.';
  }

  @override
  String get friendReject => 'Rejeter';

  @override
  String get friendRejected => 'Demande d’ami rejetée.';

  @override
  String get friendTabFriends => 'Amis';

  @override
  String get friendTabReceived => 'Reçues';

  @override
  String get friendTabSent => 'Envoyées';

  @override
  String get friendTab_friends => 'amis';

  @override
  String get friendTab_received => 'reçues';

  @override
  String get friendTab_sent => 'envoyées';

  @override
  String friendTotalFriends(int count) {
    return 'Vous avez $count amis';
  }

  @override
  String get friendUnfriend => 'Retirer l’ami';

  @override
  String get friendUnfriended => 'Ami retiré avec succès.';

  @override
  String get friendshipAccept => 'Accepter';

  @override
  String get friendshipAddFriendAll => 'Tous les utilisateurs';

  @override
  String get friendshipAddFriendAvailable => 'Disponibles à ajouter';

  @override
  String get friendshipAddFriendError => 'Échec de l’envoi de la demande d’ami.';

  @override
  String get friendshipAddFriendNoUsers => 'Aucun utilisateur trouvé.';

  @override
  String get friendshipAddFriendSearchPlaceholder => 'Rechercher des utilisateurs…';

  @override
  String get friendshipAddFriendSuccess => 'Demande d’ami envoyée.';

  @override
  String get friendshipAddFriendSuggested => 'Utilisateurs suggérés';

  @override
  String get friendshipAddFriendViewFriends => 'Voir les amis';

  @override
  String get friendshipAddFriendViewReceived => 'Voir les demandes reçues';

  @override
  String get friendshipAddFriendViewSent => 'Voir les demandes envoyées';

  @override
  String get friendshipBlock => 'Bloquer';

  @override
  String get friendshipCancelRequest => 'Annuler la demande';

  @override
  String get friendshipConfirmBlock => 'Êtes‑vous sûr de vouloir bloquer cet utilisateur ?';

  @override
  String get friendshipConfirmUnblock => 'Voulez‑vous débloquer cet utilisateur ?';

  @override
  String get friendshipConfirmUnfriend => 'Êtes‑vous sûr de vouloir retirer cet ami ?';

  @override
  String get friendshipErrorAlreadyFriends => 'Vous êtes déjà amis avec cet utilisateur.';

  @override
  String get friendshipErrorFailedAction => 'Action échouée. Veuillez réessayer.';

  @override
  String get friendshipErrorNotFound => 'Utilisateur introuvable.';

  @override
  String get friendshipErrorRequestExists => 'Demande d’ami déjà envoyée.';

  @override
  String get friendshipFriendAdded => 'Ami ajouté avec succès.';

  @override
  String get friendshipFriendBlocked => 'Utilisateur bloqué.';

  @override
  String get friendshipFriendRemoved => 'Ami supprimé.';

  @override
  String get friendshipFriendUnblocked => 'Utilisateur débloqué.';

  @override
  String get friendshipMyFriends => 'Mes amis';

  @override
  String get friendshipNoFriends => 'Vous n’avez pas encore ajouté d’amis.';

  @override
  String get friendshipNoRequests => 'Aucune demande d’ami trouvée.';

  @override
  String get friendshipReceivedRequests => 'Demandes reçues';

  @override
  String get friendshipReject => 'Rejeter';

  @override
  String get friendshipRequestAccepted => 'Demande d’ami acceptée.';

  @override
  String get friendshipRequestCancelled => 'Demande annulée.';

  @override
  String get friendshipRequestRejected => 'Demande d’ami rejetée.';

  @override
  String get friendshipRequestSent => 'Demande d’ami envoyée.';

  @override
  String get friendshipSendRequest => 'Envoyer une demande d’ami';

  @override
  String get friendshipSentRequests => 'Demandes envoyées';

  @override
  String get friendshipTitle => 'Demandes d’amis';

  @override
  String get friendshipUnblock => 'Débloquer';

  @override
  String get friendshipUnfriend => 'Retirer l’ami';

  @override
  String get generalLoading => 'Chargement…';

  @override
  String get globalError => 'Une erreur s’est produite';

  @override
  String get globalSuccess => 'Succès';

  @override
  String get homeActivityCategories => ' Catégories';

  @override
  String get homeCancelConfirm => 'Annuler ce ticket ?';

  @override
  String get homeCancelTitle => 'Confirmation';

  @override
  String get homeExploreActivities => 'Explorer les activités';

  @override
  String get homeExploreCategories => 'Explorer les catégories';

  @override
  String get homeExploreMessage => 'Trouvez de nouvelles expériences que vous allez adorer';

  @override
  String get homeFindActivity => 'Trouvez votre activité préférée';

  @override
  String get homeInterestBasedTitle => 'Les activités qui vous intéressent';

  @override
  String get homeLoadMore => 'Charger plus';

  @override
  String get homeLoadingActivities => 'Chargement des activités…';

  @override
  String get homeLoadingBookings => 'Chargement de vos réservations…';

  @override
  String get homeLoadingInterestActivities => 'Chargement des activités selon vos intérêts…';

  @override
  String get homeMoreActivities => 'Plus d’activités';

  @override
  String get homeNo => 'Non';

  @override
  String get homeNoActivities => 'Aucune activité trouvée pour cette catégorie.';

  @override
  String get homeSeeAll => 'Tout voir';

  @override
  String get homeSeeAllCategories => 'Voir toutes les catégories';

  @override
  String get homeShowAll => 'Tout afficher';

  @override
  String get homeShowLess => 'Afficher moins';

  @override
  String get homeWelcome => 'Bienvenue !';

  @override
  String get homeYes => 'Oui';

  @override
  String get homeYourBookings => 'Vos activités réservées';

  @override
  String get insightsAction => 'Action';

  @override
  String get insightsItem => 'Élément';

  @override
  String get insightsName => 'Nom du client';

  @override
  String get insightsPayment => 'Paiement';

  @override
  String get interestContinue => 'Continuer';

  @override
  String get interestLoadError => 'Échec du chargement des centres d’intérêt.';

  @override
  String get interestSaveError => 'Échec de l’enregistrement des centres d’intérêt.';

  @override
  String get interestSelectOne => 'Veuillez sélectionner un centre d’intérêt.';

  @override
  String get interestSkip => 'Ignorer';

  @override
  String get interestTitle => 'Qu’est‑ce qui vous intéresse ?';

  @override
  String get lastName => 'Nom';

  @override
  String get loginBusiness => 'Business';

  @override
  String get loginCancel => 'Annuler';

  @override
  String get loginConfirmReactivate => 'Voulez‑vous réactiver et continuer à utiliser ce compte ?';

  @override
  String get loginContinue => 'Continuer';

  @override
  String get loginEmail => 'Adresse email';

  @override
  String get loginErrorFailed => 'Échec de la connexion';

  @override
  String get loginErrorGoogle => 'Échec de la connexion Google';

  @override
  String get loginErrorRequired => 'Tous les champs sont obligatoires';

  @override
  String get loginFacebookSignIn => 'Continuer avec Facebook';

  @override
  String get loginForgetPassword => 'Mot de passe oublié ?';

  @override
  String get loginGoogleSignIn => 'Continuer avec Google';

  @override
  String get loginInstruction => 'Veuillez vous connecter avec votre email ou numéro de téléphone';

  @override
  String get loginLoading => 'Connexion…';

  @override
  String get loginLogin => 'Se connecter';

  @override
  String get loginNoAccount => 'Pas de compte ?';

  @override
  String get loginPassword => 'Mot de passe';

  @override
  String get loginPhone => 'Numéro de téléphone';

  @override
  String get loginRegister => 'S’inscrire';

  @override
  String get loginSuccessGoogle => 'Connexion Google réussie';

  @override
  String get loginSuccessLogin => 'Connexion réussie';

  @override
  String get loginTitle => 'Bon retour';

  @override
  String get loginPhoneInvalid => 'Numéro de téléphone invalide';

  @override
  String get loginUseEmailInstead => 'Utiliser l’email';

  @override
  String get loginUsePhoneInstead => 'Utiliser le téléphone';

  @override
  String get loginUser => 'Utilisateur';

  @override
  String get loginInactiveTitle => 'Compte inactif';

  @override
  String get loginInactiveMessage => 'Ce compte est inactif. Voulez‑vous le réactiver ?';

  @override
  String get loginWarningInactive => 'Ce compte était précédemment inactif et a été réactivé. Veuillez vérifier vos paramètres.';

  @override
  String get markAsPaid => 'Marquer comme payé';

  @override
  String get markAsPaidConfirmation => 'Êtes‑vous sûr de vouloir marquer cette réservation comme payée ?';

  @override
  String get myPostsConfirmDelete => 'Êtes‑vous sûr de vouloir supprimer ce post ?';

  @override
  String get myPostsDelete => 'Supprimer';

  @override
  String get myPostsEmpty => 'Aucun post trouvé.';

  @override
  String get myPostsSuccessDelete => 'Post supprimé avec succès';

  @override
  String get no => 'Non';

  @override
  String get noAvailableUsers => 'Aucun utilisateur disponible à assigner.';

  @override
  String get noBookings => 'Aucune réservation.';

  @override
  String get notPaid => 'Impayé';

  @override
  String get notificationDeleteError => 'Erreur de suppression de la notification :';

  @override
  String get notificationEmpty => 'Aucune notification disponible.';

  @override
  String get notificationFetchError => 'Erreur lors de la récupération des notifications :';

  @override
  String get noScreenForNotification => ' Aucun écran lié ';

  @override
  String get deletedSuccessfully => 'notification supprimée avec succès';

  @override
  String get markedAsRead => ' marqué comme lu';

  @override
  String get notificationMarkReadError => 'Échec du marquage comme lu :';

  @override
  String get onboardingAlreadyHaveAccount => 'Vous avez déjà un compte ? connexion';

  @override
  String get onboardingCreateAccount => 'Créer un compte';

  @override
  String get onboardingGetStarted => 'Commencer';

  @override
  String get onboardingSignIn => 'Se connecter';

  @override
  String get onboardingSubtitle => 'Découvrez des passions, connectez‑vous aux autres, développez vos compétences.';

  @override
  String get onboardingTitle => 'Votre porte d’entrée vers des loisirs passionnants';

  @override
  String get changeTheme => 'Changer le thème';

  @override
  String get selectLanguage => 'Choisir la langue';

  @override
  String get onbSkip => 'Ignorer';

  @override
  String get onbNext => 'Suivant';

  @override
  String get onbGetStarted => 'Commencer';

  @override
  String get onbTitle1 => 'Découvrir des activités';

  @override
  String get onbSubtitle1 => 'Trouvez des loisirs et événements près de chez vous.';

  @override
  String get onbTitle2 => 'Réserver en quelques secondes';

  @override
  String get onbSubtitle2 => 'Réservation simple, sécurisée et rapide.';

  @override
  String get onbTitle3 => 'Rejoindre la communauté';

  @override
  String get onbSubtitle3 => 'Connectez‑vous avec des personnes qui aiment ce que vous aimez.';

  @override
  String get paid => 'Payé';

  @override
  String get paymentConfirmation => 'Confirmer la réservation';

  @override
  String get privacyP1 => 'Nous respectons votre vie privée et protégeons vos informations personnelles.';

  @override
  String get privacyP2 => 'Lorsque vous utilisez notre application, nous pouvons collecter des informations de base pour améliorer votre expérience. Cela peut inclure votre nom, votre email et la façon dont vous utilisez l’app.';

  @override
  String get privacyP3 => 'Nous n’utilisons ces informations que pour améliorer l’application pour vous. Nous ne vendons pas vos données.';

  @override
  String get privacyP4 => 'Vos données sont stockées en toute sécurité. Vous pouvez nous contacter à tout moment pour toute question.';

  @override
  String get privacyP5 => 'En utilisant notre application, vous acceptez cette politique de confidentialité. Nous pourrons la mettre à jour et vous avertirons en cas de changement important.';

  @override
  String get privacyTitle => 'Politique de confidentialité';

  @override
  String get privacyUpdated => 'Dernière mise à jour : mai 2025';

  @override
  String get profileCalendar => 'Mon calendrier';

  @override
  String get profileConfirmDelete => 'Êtes‑vous sûr de vouloir supprimer définitivement votre compte ?';

  @override
  String get profileConfirmInactive => 'Confirmez le mot de passe pour désactiver votre compte';

  @override
  String get profileDeleteAccount => 'Supprimer le compte';

  @override
  String get profileEditProfile => 'Modifier le profil';

  @override
  String get profileEnterValidEmail => 'Veuillez entrer un email valide.';

  @override
  String get profileError => 'Une erreur s’est produite.';

  @override
  String get profileErrorSendingInvite => 'Échec de l’envoi de l’invitation.';

  @override
  String get profileGoogleNoPasswordNeeded => 'Vous vous êtes connecté avec Google. Pas de mot de passe requis.';

  @override
  String get profileGuest => 'Invité';

  @override
  String get profileInactiveInfo => 'Êtes‑vous sûr de vouloir désactiver votre compte ? Après 30 jours, il sera définitivement supprimé et vous ne pourrez plus vous connecter.';

  @override
  String get profileInviteManager => 'Inviter un manager';

  @override
  String get profileLanguage => 'Langue';

  @override
  String get profileLogoutConfirm => 'Êtes‑vous sûr de vouloir vous déconnecter ?';

  @override
  String get profileMakePrivate => 'Rendre le profil privé';

  @override
  String get profileMakePublic => 'Rendre le profil public';

  @override
  String get profileManageAccount => 'Gérer le compte';

  @override
  String get profileManagerEmail => 'Email du manager';

  @override
  String get profileMotto => 'Vivez votre passion !';

  @override
  String get profileMyInterests => 'Mes centres d’intérêt';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profilePrivacyPolicy => 'Politique de confidentialité';

  @override
  String get profilePrivate => 'Profil privé';

  @override
  String get profilePublic => 'Profil public';

  @override
  String get profileSetActive => 'Activer le compte';

  @override
  String get profileSetInactive => 'Désactiver le compte';

  @override
  String get profilebusinessAnalytics => 'Analytique';

  @override
  String get profilebusinessArabic => 'Arabe';

  @override
  String get profilebusinessCancel => 'Annuler';

  @override
  String get profilebusinessConfirmLogout => 'Êtes‑vous sûr de vouloir vous déconnecter ?';

  @override
  String get profilebusinessConnectStripe => 'Connecter le compte Stripe';

  @override
  String get profilebusinessConnecting => 'Connexion…';

  @override
  String get profilebusinessEditBusinessInfo => 'Modifier les infos entreprise';

  @override
  String get profilebusinessEnglish => 'Anglais';

  @override
  String get profilebusinessFrench => 'Français';

  @override
  String get profilebusinessGuest => 'Entreprise';

  @override
  String get profilebusinessLanguage => 'Langue';

  @override
  String get profilebusinessLogout => 'Déconnexion';

  @override
  String get profilebusinessMyActivities => 'Mes activités';

  @override
  String get profilebusinessPickLogo => 'Logo de l’entreprise';

  @override
  String get profilebusinessPickLogoHint => 'Prendre une photo ou choisir depuis la galerie';

  @override
  String get profilebusinessPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get profilebusinessResumeStripe => 'Reprendre l’onboarding Stripe';

  @override
  String get profilebusinessStripeConnected => 'Compte Stripe connecté';

  @override
  String get profilebusinessStripeNotConnected => 'Aucun compte Stripe connecté';

  @override
  String get profilebusinessTagline => 'Faisons grandir votre business avec HobbySphere..';

  @override
  String get reactivate => 'Réactiver';

  @override
  String get registerAddProfilePhoto => 'Touchez pour choisir une photo de profil';

  @override
  String get registerBusiness => 'Entreprise';

  @override
  String get registerBusinessName => 'Nom de l’entreprise';

  @override
  String get registerCompleteButtonsContinue => 'Continuer';

  @override
  String get registerCompleteButtonsFinish => 'Terminer';

  @override
  String get registerCompleteButtonsSeeAll => 'Tout voir';

  @override
  String get registerCompleteButtonsSeeLess => 'Voir moins';

  @override
  String get registerCompleteButtonsSubmitting => 'Envoi…';

  @override
  String get registerCompleteErrorsBusinessNameRequired => 'Le nom de l’entreprise est requis.';

  @override
  String get registerCompleteErrorsDescriptionRequired => 'La description est requise.';

  @override
  String get registerCompleteErrorsFirstNameRequired => 'Le prénom est requis.';

  @override
  String get registerCompleteErrorsGeneric => 'Une erreur s’est produite';

  @override
  String get registerCompleteErrorsLastNameRequired => 'Le nom est requis.';

  @override
  String get registerCompleteErrorsUsernameRequired => 'Le nom d’utilisateur est requis.';

  @override
  String get registerCompleteStep1BusinessName => 'Nom de l’entreprise';

  @override
  String get registerCompleteStep1FirstName => 'Prénom';

  @override
  String get registerCompleteStep1FirstNameQuestion => 'Comment vous appelez‑vous ?';

  @override
  String get registerCompleteStep1LastName => 'Nom';

  @override
  String get registerCompleteStep2BusinessDescription => 'Description de l’entreprise';

  @override
  String get registerCompleteStep2ChooseUsername => 'Choisissez un nom d’utilisateur';

  @override
  String get registerCompleteStep2Description => 'Description';

  @override
  String get registerCompleteStep2DescriptionHint1 => '• Décrivez clairement votre entreprise';

  @override
  String get registerCompleteStep2DescriptionHint2 => '• Restez concis et pertinent (≈250 caractères)';

  @override
  String get registerCompleteStep2Username => 'Nom d’utilisateur';

  @override
  String get registerCompleteStep2UsernameHint1 => '• Doit être unique';

  @override
  String get registerCompleteStep2UsernameHint2 => '• Pas d’espaces ni de symboles';

  @override
  String get registerCompleteStep2UsernameHint3 => '• Entre 3 et 15 caractères';

  @override
  String get registerCompleteStep2WebsiteUrl => 'URL du site (optionnel)';

  @override
  String get registerCompleteStep3BusinessLogo => 'logo entreprise';

  @override
  String get registerCompleteStep3ProfileImage => 'photo de profil';

  @override
  String get registerCompleteStep3PublicProfile => 'Profil public';

  @override
  String get registerCompleteStep3TapToChooseBanner => 'Touchez pour choisir la bannière entreprise';

  @override
  String registerCompleteStep3TapToChooseLogo(String type) {
    return 'Touchez pour choisir $type';
  }

  @override
  String get registerConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get registerDescription => 'Description';

  @override
  String get registerEmail => 'Email';

  @override
  String get registerErrorBusinessInfo => 'Informations entreprise manquantes.';

  @override
  String get registerErrorFailed => 'Échec de l’inscription';

  @override
  String get registerErrorLength => 'Le mot de passe doit contenir au moins 8 caractères.';

  @override
  String get registerErrorMatch => 'Les mots de passe ne correspondent pas.';

  @override
  String get registerErrorRequired => 'Email et mot de passe requis.';

  @override
  String get registerErrorSymbol => 'Le mot de passe doit inclure au moins un symbole.';

  @override
  String get registerErrorUserInfo => 'Informations utilisateur manquantes.';

  @override
  String get registerFirstName => 'Prénom';

  @override
  String get registerLastName => 'Nom';

  @override
  String get registerPassword => 'Mot de passe';

  @override
  String get registerPhoneNumber => 'Numéro de téléphone';

  @override
  String get registerPublicProfile => 'Rendre mon profil public';

  @override
  String get registerSelectBanner => 'Touchez pour choisir la bannière entreprise';

  @override
  String get registerSelectLogo => 'Touchez pour choisir le logo entreprise';

  @override
  String get registerSendCode => 'Envoyer le code de vérification';

  @override
  String get registerSuccessBusiness => 'Entreprise inscrite avec succès !';

  @override
  String get registerSuccessUser => 'Utilisateur inscrit avec succès !';

  @override
  String get registerTitle => 'Créer un compte';

  @override
  String get registerUser => 'Utilisateur';

  @override
  String get registerUsername => 'Nom d’utilisateur';

  @override
  String get registerWebsite => 'Site web';

  @override
  String get resetPasswordButton => 'Réinitialiser le mot de passe';

  @override
  String get resetPasswordConfirm => 'Confirmer le mot de passe';

  @override
  String get resetPasswordError => 'Une erreur s’est produite.';

  @override
  String get resetPasswordFail => 'Échec de la réinitialisation du mot de passe.';

  @override
  String get resetPasswordFillFields => 'Veuillez remplir tous les champs.';

  @override
  String get resetPasswordMismatch => 'Les mots de passe ne correspondent pas.';

  @override
  String get resetPasswordNew => 'Nouveau mot de passe';

  @override
  String get resetPasswordSuccess => 'Mot de passe réinitialisé avec succès !';

  @override
  String get resetPasswordTitle => 'Réinitialiser le mot de passe';

  @override
  String get resetPasswordUpdating => 'Mise à jour…';

  @override
  String get reviewAllReviews => 'Avis';

  @override
  String get reviewError => 'Échec de l’envoi de l’avis';

  @override
  String get reviewMissingData => 'Veuillez entrer un retour avant d’envoyer.';

  @override
  String get reviewPlaceholder => 'Racontez votre expérience…';

  @override
  String get reviewRating => 'Note';

  @override
  String get reviewSubmit => 'Envoyer l’avis';

  @override
  String get reviewSubmitting => 'Envoi…';

  @override
  String get reviewSuccess => 'Avis envoyé';

  @override
  String get reviewTitle => 'Ajoutez votre avis';

  @override
  String get reviewYourFeedback => 'Votre retour';

  @override
  String get reviewsNoReviews => 'Aucun avis trouvé.';

  @override
  String get reviewsTitle => 'Avis des clients';

  @override
  String get searchPlaceholder => 'Rechercher';

  @override
  String get selectMethodAlreadyHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get selectMethodContinue => 'Continuer';

  @override
  String get selectMethodContinueWithEmail => 'Continuer avec l’email';

  @override
  String get selectMethodContinueWithFacebook => 'Continuer avec Facebook';

  @override
  String get selectMethodContinueWithGoogle => 'Continuer avec Google';

  @override
  String get selectMethodCreatePassword => 'Créer un mot de passe';

  @override
  String get selectMethodEnterPassword => 'Entrer le mot de passe';

  @override
  String get selectMethodLoading => 'Chargement…';

  @override
  String get selectMethodLogin => 'Se connecter';

  @override
  String get selectMethodOr => 'ou';

  @override
  String get selectMethodPasswordRulesRule1 => '8 caractères (max 20)';

  @override
  String get selectMethodPasswordRulesRule2 => '1 lettre, 1 chiffre, 1 caractère spécial (# ? ! @)';

  @override
  String get selectMethodPasswordRulesRule3 => 'Mot de passe fort';

  @override
  String get selectMethodPhonePlaceholder => 'Numéro de téléphone';

  @override
  String get selectMethodRoleBusiness => 'Entreprise';

  @override
  String get selectMethodRoleUser => 'Utilisateur';

  @override
  String get selectMethodSaveInfo => 'Enregistrer les infos de connexion pour se connecter automatiquement la prochaine fois.';

  @override
  String get selectMethodSignUp => 'S’inscrire';

  @override
  String get selectMethodTitle => 'S’inscrire';

  @override
  String get singleChatAccessDeniedMsg => 'Vous n’êtes pas ami avec cet utilisateur.';

  @override
  String get singleChatAccessDeniedTitle => 'Accès refusé';

  @override
  String get singleChatBlock => 'Bloquer';

  @override
  String get singleChatBlockConfirm => 'Êtes‑vous sûr de vouloir bloquer cet utilisateur ?';

  @override
  String get singleChatBlockTitle => 'Bloquer l’utilisateur';

  @override
  String get singleChatBlockedByThem => 'Cet utilisateur vous a bloqué. Vous ne pouvez pas envoyer de messages.';

  @override
  String get singleChatCancel => 'Annuler';

  @override
  String get singleChatDelete => 'Supprimer';

  @override
  String get singleChatDeleteConfirm => 'Êtes‑vous sûr de vouloir supprimer les messages sélectionnés ?';

  @override
  String get singleChatDeleteTitle => 'Supprimer les messages';

  @override
  String get singleChatErrorFetching => 'Impossible de récupérer les messages.';

  @override
  String get singleChatErrorTitle => 'Erreur';

  @override
  String get singleChatInputPlaceholder => 'Écrire un message…';

  @override
  String get singleChatUnblock => 'Débloquer';

  @override
  String get singleChatUnblockConfirm => 'Êtes‑vous sûr de vouloir débloquer cet utilisateur ?';

  @override
  String get singleChatUnblockTitle => 'Débloquer l’utilisateur';

  @override
  String get singleChatYouBlocked => 'Vous avez bloqué cet utilisateur. Débloquez pour continuer à discuter.';

  @override
  String get socialAddPost => 'Publier';

  @override
  String get socialChat => 'Chat';

  @override
  String get socialEmpty => 'Aucun post disponible.';

  @override
  String get socialError => 'Une erreur inattendue s’est produite';

  @override
  String get socialNotifications => 'Alertes';

  @override
  String get socialMyPosts => 'Mes posts';

  @override
  String get myPostsTitle => 'Mes posts';

  @override
  String get deletePostTitle => 'Supprimer le post ?';

  @override
  String get deletePostConfirm => 'Cette action est irréversible.';

  @override
  String get deletePostSuccess => 'Post supprimé';

  @override
  String get deletePostFailed => 'Échec de la suppression';

  @override
  String get socialSearchFriend => 'Rechercher ';

  @override
  String get socialTitle => 'HobbySphere';

  @override
  String get stripeError => 'Erreur';

  @override
  String get stripePay50 => 'Payer 50 \$';

  @override
  String get stripePayNow => 'Procéder au paiement';

  @override
  String get stripePaymentFailed => 'Paiement échoué';

  @override
  String get stripeSuccessMessage => 'Paiement effectué !';

  @override
  String get stripeSuccessTitle => 'Succès';

  @override
  String get tabExplore => 'Explorer';

  @override
  String get tabHome => 'Accueil';

  @override
  String get tabProfile => 'Profil';

  @override
  String get tabSocial => 'Communauté';

  @override
  String get tabTickets => 'Tickets';

  @override
  String get tabSettings => 'Paramètres';

  @override
  String get tabnavigateActivities => 'Activités';

  @override
  String get tabnavigateAnalytics => 'Analytique';

  @override
  String get tabnavigateBookings => 'Réservations';

  @override
  String get tabnavigateHome => 'Accueil';

  @override
  String get tabActivities => 'Activités';

  @override
  String get tabAnalytics => 'Analytique';

  @override
  String get tabBookings => 'Réservations';

  @override
  String get tabnavigateProfile => 'Profil';

  @override
  String get ticketCancel => 'Annuler';

  @override
  String get ticketCancelConfirm => 'Êtes‑vous sûr de vouloir annuler ce ticket ?';

  @override
  String get ticketCancelTitle => 'Annuler le ticket';

  @override
  String get ticketConfirm => 'Confirmer';

  @override
  String get ticketDelete => 'Supprimer';

  @override
  String get ticketDeleteConfirm => 'Êtes‑vous sûr de vouloir supprimer définitivement ce ticket annulé ?';

  @override
  String get ticketDeleteTitle => 'Supprimer le ticket';

  @override
  String ticketEmpty(String status) {
    return 'Aucun ticket dans $status.';
  }

  @override
  String get ticketLocation => 'Lieu';

  @override
  String get ticketReturnConfirm => 'Voulez‑vous remettre ce ticket en En attente ?';

  @override
  String get ticketReturnTitle => 'Retour à En attente';

  @override
  String get ticketReturnToPending => 'Retour à En attente';

  @override
  String get ticketScreenTitle => 'Tickets';

  @override
  String get ticketStatusCanceled => 'Annulé';

  @override
  String get ticketStatusCompleted => 'Terminé';

  @override
  String get ticketStatusPending => 'En attente';

  @override
  String get ticketTime => 'Heure';

  @override
  String get ticketsTitle => 'Tickets';

  @override
  String get ticketsEmptyPending => 'Aucun ticket en attente.';

  @override
  String get ticketsEmptyCompleted => 'Aucun ticket terminé.';

  @override
  String get ticketsEmptyCanceled => 'Aucun ticket annulé.';

  @override
  String get ticketsEmptyGeneric => 'Aucun ticket trouvé.';

  @override
  String get ticketsDelete => 'Supprimer';

  @override
  String get ticketsDeleteTitle => 'Supprimer le ticket ?';

  @override
  String get ticketsDeleteConfirm => 'Cela supprimera le ticket annulé.';

  @override
  String get ticketsCancelRequested => 'demandes d’annulation de ticket';

  @override
  String get theme => 'thème';

  @override
  String get themeDark => 'Sombre';

  @override
  String get verifyCodeButton => 'Vérifier le code';

  @override
  String get verifyCodeFail => 'Échec de la vérification du code.';

  @override
  String get verifyCodeInvalid => 'Code invalide.';

  @override
  String get verifyCodePlaceholder => 'Code de vérification';

  @override
  String get verifyCodeRequired => 'Saisissez le code de vérification.';

  @override
  String get verifyCodeSubtitle => 'Nous avons envoyé un code à votre email';

  @override
  String get verifyCodeTitle => 'Entrer le code';

  @override
  String get verifyCodeVerifying => 'Vérification…';

  @override
  String get verifyEnterCode => 'Entrez le code de vérification à 6 chiffres';

  @override
  String get verifyFullCodeError => 'Veuillez entrer les 6 chiffres complets.';

  @override
  String get verifyInvalidCode => 'Code invalide ou expiré.';

  @override
  String get verifyResendBtn => 'Renvoyer le code';

  @override
  String get verifyResendFailed => 'Échec du renvoi du code.';

  @override
  String get verifyResent => 'Code renvoyé. Veuillez vérifier votre email ou téléphone.';

  @override
  String get verifySuccessBusiness => 'Compte entreprise vérifié avec succès !';

  @override
  String get verifySuccessUser => 'Compte vérifié avec succès !';

  @override
  String get verifyVerifyBtn => 'Vérifier';

  @override
  String get yes => 'Oui';

  @override
  String get fieldTitle => 'Titre';

  @override
  String get hintTitle => 'Titre de l’activité';

  @override
  String get selectActivityType => 'Sélectionner le type d’activité';

  @override
  String get fieldDescription => 'Description';

  @override
  String get hintDescription => 'Décrivez votre activité';

  @override
  String get searchLocation => 'Rechercher une adresse';

  @override
  String get getMyLocation => 'Obtenir ma position';

  @override
  String get fieldMaxParticipants => 'Participants max';

  @override
  String get hintMaxParticipants => 'Entrer un nombre';

  @override
  String get fieldPrice => 'Prix';

  @override
  String get fieldStartDateTime => 'Date et heure de début';

  @override
  String get fieldEndDateTime => 'Date et heure de fin';

  @override
  String get pickImage => 'Choisir une image';

  @override
  String get submit => 'Envoyer';

  @override
  String get errorAuthRequired => 'Vous devez être connecté.';

  @override
  String get bookingsMyBookings => 'Mes réservations';

  @override
  String get bookingsByUser => 'Réservé par';

  @override
  String get bookingsStatus => 'Statut';

  @override
  String get bookingsPaid => 'Payé';

  @override
  String get bookingsReject => 'Rejeter';

  @override
  String get bookingsUnreject => 'Annuler le rejet';

  @override
  String get bookingsMarkPaid => 'Marquer comme payé';

  @override
  String get bookingsDetails => 'Voir les détails';

  @override
  String get activitiesUnnamed => 'Activité sans nom';

  @override
  String get upcoming => 'À venir';

  @override
  String get terminated => 'Terminées';

  @override
  String get editBusinessInfo => 'Modifier les infos entreprise';

  @override
  String get myActivities => 'Mes activités';

  @override
  String get analytics => 'Analytique';

  @override
  String get notifications => 'Notifications';

  @override
  String get inviteManager => 'Inviter un manager';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get language => 'Langue';

  @override
  String get logout => 'Déconnexion';

  @override
  String get manageAccount => 'Gérer le compte';

  @override
  String get toggleVisibility => 'Basculer la visibilité';

  @override
  String get setInactive => 'Mettre le compte inactif';

  @override
  String get setActive => 'Réactiver le compte';

  @override
  String get deleteBusiness => 'Supprimer l’entreprise';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get enterPassword => 'Veuillez entrer votre mot de passe';

  @override
  String get statusUpdated => 'Statut mis à jour avec succès';

  @override
  String get visibilityUpdated => 'Visibilité mise à jour avec succès';

  @override
  String get businessDeleted => 'Entreprise supprimée avec succès';

  @override
  String get errorOccurred => 'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get publicProfile => 'Profil public';

  @override
  String get privateProfile => 'Profil privé';

  @override
  String get businessGrowMessage => 'Faisons grandir votre business avec HobbySphere..';

  @override
  String get stripeAccountConnected => 'Compte Stripe connecté';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get stripeAccountNotConnected => 'Compte Stripe non connecté';

  @override
  String get registerOnStripe => ' s’inscrire sur le compte Stripe';

  @override
  String get businessUsersTitle => 'Utilisateurs Business';

  @override
  String get addUser => 'Ajouter un utilisateur';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get provideEmailOrPhone => ' fournir un email ou un numéro de téléphone';

  @override
  String get alreadyBooked => ' déjà réservé';

  @override
  String get save => 'enregistrer';

  @override
  String get bookingsFiltersCancelRequested => 'demande d’annulation';

  @override
  String get inviteManagerTitle => 'Inviter un manager';

  @override
  String get inviteManagerInstruction => 'Entrez l’email du manager. Nous lui enverrons une invitation.';

  @override
  String get managerEmailLabel => 'Email du manager';

  @override
  String get managerEmailHint => 'nom@exemple.com';

  @override
  String get sendInvite => 'Envoyer l’invitation';

  @override
  String get sending => 'Envoi…';

  @override
  String get invalidEmail => 'Veuillez entrer une adresse email valide';

  @override
  String get deactivateTitle => 'Êtes‑vous sûr de vouloir désactiver votre compte ?';

  @override
  String get deactivateWarning => 'Après 30 jours, il sera définitivement supprimé et vous ne pourrez plus vous connecter.';

  @override
  String get currentPasswordLabel => 'Mot de passe actuel';

  @override
  String get fieldRequired => 'Ce champ est requis';

  @override
  String get bookingNotAvailable => 'Cette activité n’est pas disponible pour le nombre de participants sélectionné.';

  @override
  String get editInterestsTitle => 'Modifier vos centres d’intérêt';

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
  String get connectionConnecting => 'Connexion…';

  @override
  String get connectionOffline => 'Hors ligne';

  @override
  String get connectionTryAgain => 'Réessayer';

  @override
  String get splashNoConnectionTitle => 'Pas de connexion Internet';

  @override
  String get splashNoConnectionDesc => 'Veuillez vérifier le Wi-Fi ou les données mobiles puis réessayer.';

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
  String get registerPickFromCamera => 'take photo';

  @override
  String get registerPickFromGallery => 'choose from gallery';

  @override
  String get interestSaved => 'Centres d’intérêt enregistrés avec succès';

  @override
  String get selected => 'sélectionné(s)';

  @override
  String get somethingWentWrong => 'Un problème est survenu';

  @override
  String get retry => 'Réessayer';
}
