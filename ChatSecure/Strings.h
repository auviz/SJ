#import "OTRLanguageManager.h"

// DO NOT EDIT THIS FILE. EDIT strings.json then run python StringsConverter.py

#define OTRL_MSGEVENT_RCVDMSG_GENERAL_ERR_STRING [OTRLanguageManager translatedString: @"Received a general OTR error."]
#define errSSLCryptoString [OTRLanguageManager translatedString: @"Underlying cryptographic error"]
#define OFFLINE_STRING [OTRLanguageManager translatedString: @"Offline"]
#define ERROR_STRING [OTRLanguageManager translatedString: @"Error!"]
#define AIM_REMOVED_TITLE_STRING [OTRLanguageManager translatedString: @"AIM Support Removed"]
#define DELETE_CONVERSATIONS_ON_DISCONNECT_TITLE_STRING [OTRLanguageManager translatedString: @"Auto-delete"]
#define DONE_STRING [OTRLanguageManager translatedString: @"Done"]
#define errSSLPeerCertExpiredString [OTRLanguageManager translatedString: @"Certificate expired"]
#define CONVERSATION_NO_LONGER_SECURE_STRING [OTRLanguageManager translatedString: @"The conversation with %@ is no longer secure."]
#define USER_PASS_BLANK_STRING [OTRLanguageManager translatedString: @"You must enter a username and a password to login."]
#define THEIR_FINGERPRINT_STRING [OTRLanguageManager translatedString: @"Purported fingerprint for"]
#define errSSLPeerAuthCompletedString [OTRLanguageManager translatedString: @"Peer cert is valid, or was ignored if verification disabled"]
#define YOUR_STATUS_MESSAGE [OTRLanguageManager translatedString: @"You are: %@"]
#define PASSWORD_STRING [OTRLanguageManager translatedString: @"Password"]
#define ADVANCED_STRING [OTRLanguageManager translatedString: @"Advanced"]
#define CHAT_STATE_GONE_STRING [OTRLanguageManager translatedString: @"Gone"]
#define VERSION_STRING [OTRLanguageManager translatedString: @"Version"]
#define errSSLPeerCertUnknownString [OTRLanguageManager translatedString: @"Unknown certificate"]
#define ACCOUNT_DISCONNECTED_STRING [OTRLanguageManager translatedString: @"Account Disconnected"]
#define INITIATE_ENCRYPTED_CHAT_STRING [OTRLanguageManager translatedString: @"Initiate Encrypted Chat"]
#define INVALID_EMAIL_TITLE_STRING [OTRLanguageManager translatedString: @"Invalid Email"]
#define CONNECT_EXISTING_STRING [OTRLanguageManager translatedString: @"Connect to Existing Account"]
#define LOGOUT_STRING [OTRLanguageManager translatedString: @"Log Out"]
#define SEND_DELIVERY_RECEIPT_STRING [OTRLanguageManager translatedString: @"Send Delivery Receipts"]
#define ACCOUNT_DISCONNECTED_DESCRIPTION_STRING [OTRLanguageManager translatedString: @"Please log into this account before managing requests."]
#define USERNAME_STRING [OTRLanguageManager translatedString: @"Username"]
#define OTRL_MSGEVENT_RCVDMSG_FOR_OTHER_INSTANCE_STRING [OTRLanguageManager translatedString: @"Received and discarded a message intended for another instance."]
#define REQUIRE_TLS_STRING [OTRLanguageManager translatedString: @"Require TLS"]
#define OPEN_IN_TWITTER_STRING [OTRLanguageManager translatedString: @"Open in Twitter"]
#define TWITTER_STRING [OTRLanguageManager translatedString: @"Twitter"]
#define SEND_TYPING_NOTIFICATION_STRING [OTRLanguageManager translatedString: @"Send Typing Notification"]
#define CONNECTED_STRING [OTRLanguageManager translatedString: @"Connected"]
#define errSSLClientCertRequestedString [OTRLanguageManager translatedString: @"Server has requested a client cert"]
#define TOR_WARNING_MESSAGE_STRING [OTRLanguageManager translatedString: @"Tor is an experimental feature, please use with caution."]
#define CHAT_STATE_INACTVIE_STRING [OTRLanguageManager translatedString: @"Inactive"]
#define OTRL_MSGEVENT_MSG_REFLECTED_STRING [OTRLanguageManager translatedString: @"Received our own OTR messages."]
#define FORGOT_PASSPHRASE_STRING [OTRLanguageManager translatedString: @"Forgot Passphrase?"]
#define NO_ACCOUNT_SAVED_STRING [OTRLanguageManager translatedString: @"No Saved Accounts"]
#define errSSLClosedNoNotifyString [OTRLanguageManager translatedString: @"Server closed session with no notification"]
#define PUBLIC_KEY_ERROR_STRING [OTRLanguageManager translatedString: @"Could not retrieve public key from certificate"]
#define GROUPS_STRING [OTRLanguageManager translatedString: @"Groups"]
#define NEW_CERTIFICATE_STRING [OTRLanguageManager translatedString: @"New SSL Certificate"]
#define LOGIN_STRING [OTRLanguageManager translatedString: @"Log In"]
#define CHAT_STATE_PAUSED_STRING [OTRLanguageManager translatedString: @"Entered Text"]
#define REMOVE_STRING [OTRLanguageManager translatedString: @"Remove"]
#define CLEAR_ALL_HISTORY [OTRLanguageManager translatedString: @"Clear all history"]
#define errSSLPeerDecodeErrorString [OTRLanguageManager translatedString: @"Decoding error"]
#define iOS_SSL_ERROR_PART1_STRING [OTRLanguageManager translatedString: @"Your current iOS system version (%@) contains a serious security vulnerability. Please update to the latest version as soon as possible."]
#define errSSLRecordOverflowString [OTRLanguageManager translatedString: @"Record overflow"]
#define OTR_FINGERPRINTS_STRING [OTRLanguageManager translatedString: @"OTR Fingerprints"]

#define PIN_CODE [OTRLanguageManager translatedString: @"PIN-code"]
#define ENTERING_PROGRAM_BY_PIN [OTRLanguageManager translatedString: @"Entering program by PIN"]

#define errSSLDecryptionFailString [OTRLanguageManager translatedString: @"Decryption failure"]
#define ADD_STRING [OTRLanguageManager translatedString: @"Add"]
#define GITHUB_STRING [OTRLanguageManager translatedString: @"GitHub"]
#define OPEN_IN_FACEBOOK_STRING [OTRLanguageManager translatedString: @"Open in Facebook"]
#define HELP_TRANSLATE_STRING [OTRLanguageManager translatedString: @"Help Translate"]
#define CONVERSATION_SECURE_WARNING_STRING [OTRLanguageManager translatedString: @"This chat is secured"]
#define CHAT_INSTRUCTIONS_LABEL_STRING [OTRLanguageManager translatedString: @"Log in on the Settings page (found on top right corner of buddy list) and then select a buddy from the Buddy List to start chatting."]
#define DELETE_ACCOUNT_MESSAGE_STRING [OTRLanguageManager translatedString: @"Permanently delete"]
#define GROUP_STRING [OTRLanguageManager translatedString: @"Group"]
#define CREATED_BY_STRING [OTRLanguageManager translatedString: @"Created by"]
#define REMEMBER_USERNAME_STRING [OTRLanguageManager translatedString: @"Remember username"]
#define CONNECT_ANYWAY_STRING [OTRLanguageManager translatedString: @"Connect anyway"]
#define SAVE_STRING [OTRLanguageManager translatedString: @"Save"]
#define errSSLNoRootCertString [OTRLanguageManager translatedString: @"Cert chain not verified by root"]
#define IGNORE_STRING [OTRLanguageManager translatedString: @"Ignore"]
#define PENDING_APPROVAL_STRING [OTRLanguageManager translatedString: @"Pending Approval"]
#define LANGUAGE_ALERT_TITLE_STRING [OTRLanguageManager translatedString: @"Language Change"]
#define JABBER_STRING [OTRLanguageManager translatedString: @"Jabber (XMPP)"]
#define SECUR_STRING [OTRLanguageManager translatedString: @"Secur (Beta)"]
#define VERIFY_STRING [OTRLanguageManager translatedString: @"Verify"]
#define noErrString [OTRLanguageManager translatedString: @"No Error"]
#define errSSLBadConfigurationString [OTRLanguageManager translatedString: @"Configuration error"]
#define ADD_BUDDY_STRING [OTRLanguageManager translatedString: @"Add Buddy"]
#define errSSLPeerDecompressFailString [OTRLanguageManager translatedString: @"Decompression failure"]
#define XMPP_TOR_STRING [OTRLanguageManager translatedString: @"XMPP + Tor"]
#define REGISTER_ERROR_STRING [OTRLanguageManager translatedString: @"Error Registering Username"]
#define OTRL_MSGEVENT_RCVDMSG_UNREADABLE_STRING [OTRLanguageManager translatedString: @"Cannot read the received message."]
#define FONT_SIZE_DESCRIPTION_STRING [OTRLanguageManager translatedString: @"Size for font in chat view"]
#define errSSLPeerProtocolVersionString [OTRLanguageManager translatedString: @"Bad protocol version"]
#define CHANGE_PASSPHRASE_STRING [OTRLanguageManager translatedString: @"Change Passphrase"]
#define RECENT_STRING [OTRLanguageManager translatedString: @"Recent"]
#define errSSLBufferOverflowString [OTRLanguageManager translatedString: @"Insufficient buffer provided"]
#define iOS_SSL_ERROR_TITLE_STRING [OTRLanguageManager translatedString: @"iOS Vulnerability"]
#define NEW_UPDATE_IS_AVAILABLE [OTRLanguageManager translatedString: @"New update is available"]
#define REMIND_ME_LATER [OTRLanguageManager translatedString: @"Remind me later"]
#define INSTALL_NOW [OTRLanguageManager translatedString: @"Install now"]
#define COPY_STRING [OTRLanguageManager translatedString: @"Copy"]
#define GROUP_CHAT [OTRLanguageManager translatedString: @"Group chat"]
#define CONVERSATION_SECURE_AND_VERIFIED_WARNING_STRING [OTRLanguageManager translatedString: @"This chat is secured and verified"]
#define LOCKED_WARN_STRING [OTRLanguageManager translatedString: @"The fingerprint has not been verified"]
#define UNLOCK_STRING [OTRLanguageManager translatedString: @"Unlock"]
#define AGREE_STRING [OTRLanguageManager translatedString: @"Agree"]
#define BASIC_STRING [OTRLanguageManager translatedString: @"Basic"]
#define DONATE_STRING [OTRLanguageManager translatedString: @"Donate"]
#define errSSLModuleAttachString [OTRLanguageManager translatedString: @"Module attach failure"]
#define SEND_STRING [OTRLanguageManager translatedString: @"Send"]
#define RESOURCE_STRING [OTRLanguageManager translatedString: @"Resource"]
#define errSSLPeerAccessDeniedString [OTRLanguageManager translatedString: @"Access denied"]
#define errSSLPeerInternalErrorString [OTRLanguageManager translatedString: @"Internal error"]
#define OTRL_MSGEVENT_ENCRYPTION_ERROR_STRING [OTRLanguageManager translatedString: @"An error occured while encrypting a message and the message was not sent."]
#define LOGIN_TO_STRING [OTRLanguageManager translatedString: @"Login to"]
#define ALLOW_PLAIN_TEXT_AUTHENTICATION_STRING [OTRLanguageManager translatedString: @"Allow Plaintext Authentication"]
#define CHATS_STRING [OTRLanguageManager translatedString: @"Chats"]
#define SAVED_CERTIFICATES_STRING [OTRLanguageManager translatedString: @"Saved Certificates"]
#define NEW_ACCOUNT_STRING [OTRLanguageManager translatedString: @"New Account"]
#define DOMAIN_BLANK_ERROR_STRING [OTRLanguageManager translatedString: @"Domain needs to be set"]
#define REJECT_STRING [OTRLanguageManager translatedString: @"Reject"]
#define AWAY_MESSAGE_STRING [OTRLanguageManager translatedString: @"is now away"]
#define OPEN_IN_SAFARI_STRING [OTRLanguageManager translatedString: @"Open in Safari"]
#define AWAY_STRING [OTRLanguageManager translatedString: @"Away"]
#define HOSTNAME_STRING [OTRLanguageManager translatedString: @"Hostname"]
#define errSSLPeerInsufficientSecurityString [OTRLanguageManager translatedString: @"Insufficient security"]
#define PUSH_TITLE_STRING [OTRLanguageManager translatedString: @"Push"]
#define LANGUAGE_ALERT_MESSAGE_STRING [OTRLanguageManager translatedString: @"In order to change languages return to the home screen and remove ChatSecure from the recently used apps"]
#define SKIP_STRING [OTRLanguageManager translatedString: @"Skip"]
#define SOURCE_STRING [OTRLanguageManager translatedString: @"Check out the source here on Github"]
#define AIM_STRING [OTRLanguageManager translatedString: @"OSCAR Instant Messenger"]
#define DISCONNECTION_WARNING_DESC_STRING [OTRLanguageManager translatedString: @"1 Minute Alert Before Disconnection"]
#define MESSAGE_PLACEHOLDER_STRING [OTRLanguageManager translatedString: @"Message"]
#define OTRL_MSGEVENT_MSG_RESENT_STRING [OTRLanguageManager translatedString: @"The previous message was resent."]
#define OTRL_MSGEVENT_RCVDMSG_NOT_IN_PRIVATE_STRING [OTRLanguageManager translatedString: @"Received an encrypted message but cannot read it because no private connection is established yet."]
#define PAYMENTS_SETUP_ERROR_STRING [OTRLanguageManager translatedString: @"This device doesn't seem to be configured to make payments."]
#define CLEAR_CHAT_HISTORY_STRING [OTRLanguageManager translatedString: @"Clear Chat History"]
#define errSSLPeerDecryptionFailString [OTRLanguageManager translatedString: @"Decryption failed"]
#define errSSLPeerDecryptErrorString [OTRLanguageManager translatedString: @"Decryption error"]
#define ACCOUNTS_STRING [OTRLanguageManager translatedString: @"Accounts"]
#define ERROR_CREATING_ACCOUNT_STRING [OTRLanguageManager translatedString: @"Error Creating Account"]
#define errSSLCertExpiredString [OTRLanguageManager translatedString: @"Chain had an expired cert"]
#define DISCONNECTED_TITLE_STRING [OTRLanguageManager translatedString: @"Disconnected"]
#define CREATE_STRING [OTRLanguageManager translatedString: @"Create"]
#define errSSLHostNameMismatchString [OTRLanguageManager translatedString: @"Peer host name mismatch"]
#define errSSLNegotiationString [OTRLanguageManager translatedString: @"Cipher Suite negotiation failure"]
#define errSSLPeerExportRestrictionString [OTRLanguageManager translatedString: @"Export restriction"]
#define errSSLPeerHandshakeFailString [OTRLanguageManager translatedString: @"Handshake failure"]
#define GOOGLE_TALK_STRING [OTRLanguageManager translatedString: @"Google Talk"]
#define OTR_FINGERPRINTS_SUBTITLE_STRING [OTRLanguageManager translatedString: @"Manage OTR fingerprints"]
#define DISAGREE_STRING [OTRLanguageManager translatedString: @"Disagree"]
#define errSSLFatalAlertString [OTRLanguageManager translatedString: @"Fatal alert"]
#define iOS_SSL_ERROR_PART2_STRING [OTRLanguageManager translatedString: @"Settings -> General -> Software Update"]
#define SEND_FEEDBACK_STRING [OTRLanguageManager translatedString: @"Send Feedback"]
#define errSSLPeerNoRenegotiationString [OTRLanguageManager translatedString: @"No renegotiation allowed"]
#define REMEMBER_PASSPHRASE_INFO_STRING [OTRLanguageManager translatedString: @"Your password will be stored in the iOS Keychain of this device only, and is only as safe as your device passphrase or pin. However, it will not persist during a device backup/restore via iTunes, so please don't forget it, or you may lose your conversation history."]
#define SHARE_STRING [OTRLanguageManager translatedString: @"Share"]
#define OPPORTUNISTIC_OTR_SETTING_TITLE [OTRLanguageManager translatedString: @"Auto-start Encryption"]
#define AIM_REMOVED_MESSAGE_STRING [OTRLanguageManager translatedString: @"AIM support has been removed because our AIM library is no longer maintained and contains flaws. Please remove your account. Sorry!"]
#define NAME_STRING [OTRLanguageManager translatedString: @"Name"]
#define BLOCK_STRING [OTRLanguageManager translatedString: @"Block"]
#define ACCOUNT_FINGERPRINTS_STRING [OTRLanguageManager translatedString: @"Account Fingerprints"]
#define OK_STRING [OTRLanguageManager translatedString: @"OK"]
#define OPPORTUNISTIC_OTR_SETTING_DESCRIPTION [OTRLanguageManager translatedString: @"Enables opportunistic OTR"]
#define errSSLUnexpectedRecordString [OTRLanguageManager translatedString: @"Unexpected (skipped) record in DTLS"]
#define ENCRYPTION_ERROR_STRING [OTRLanguageManager translatedString: @"Encryption Error"]
#define PORT_STRING [OTRLanguageManager translatedString: @"Port"]
#define errSSLClosedAbortString [OTRLanguageManager translatedString: @"Connection closed via error"]
#define SECURITY_STRING [OTRLanguageManager translatedString: @"Security"]
#define SUBSCRIPTION_REQUEST_TITLE [OTRLanguageManager translatedString: @"Subscription Requests"]
#define LOCKED_ERROR_STRING [OTRLanguageManager translatedString: @"The fingerprint has changed and needs to be verified"]
#define VERIFY_FINGERPRINT_STRING [OTRLanguageManager translatedString: @"Verify Fingerprint"]
#define DELETE_ACCOUNT_TITLE_STRING [OTRLanguageManager translatedString: @"Delete Account?"]
#define SIGN_UP_STRING [OTRLanguageManager translatedString: @"Sign Up"]
#define errSSLPeerUnsupportedCertString [OTRLanguageManager translatedString: @"Bad unsupported cert format"]
#define OTRL_MSGEVENT_RCVDMSG_UNENCRYPTED_STRING [OTRLanguageManager translatedString: @"Received an unencrypted message."]
#define VERIFY_LATER_STRING [OTRLanguageManager translatedString: @"Verify Later"]
#define errSSLBadCipherSuiteString [OTRLanguageManager translatedString: @"Bad SSLCipherSuite"]
#define OFFLINE_MESSAGE_STRING [OTRLanguageManager translatedString: @"is now offline"]
#define errSSLBadRecordMacString [OTRLanguageManager translatedString: @"Bad MAC"]
#define LOCKED_SECURE_STRING [OTRLanguageManager translatedString: @"The conversation is secure and the fingerprint is verfied"]
#define CONNECT_FACEBOOK_STRING [OTRLanguageManager translatedString: @"Connect Facebook"]
#define DISMISS_STRING [OTRLanguageManager translatedString: @"Dismiss"]
#define EXPIRATION_STRING [OTRLanguageManager translatedString: @"Background session will expire in one minute."]
#define NOT_AVAILABLE_STRING [OTRLanguageManager translatedString: @"Not Available"]
#define DISCONNECT_FACEBOOK_STRING [OTRLanguageManager translatedString: @"Disconnect Facebook"]
#define LOGOUT_FROM_AIM_STRING [OTRLanguageManager translatedString: @"Logout from OSCAR?"]
#define errSSLPeerUnknownCAString [OTRLanguageManager translatedString: @"Unknown Cert Authority"]
#define XMPP_CERT_FAIL_STRING [OTRLanguageManager translatedString: @"There was an error validating the certificate for %@. This may indicate that someone is trying to intercept your communications."]
#define FACEBOOK_STRING [OTRLanguageManager translatedString: @"Facebook"]
#define errSSLPeerRecordOverflowString [OTRLanguageManager translatedString: @"Record overflow"]
#define ACCOUNT_STRING [OTRLanguageManager translatedString: @"Account"]
#define FACEBOOK_HELP_STRING [OTRLanguageManager translatedString: @"Your Facebook username is not the email address that you use to login to Facebook"]
#define errSSLInternalString [OTRLanguageManager translatedString: @"Internal error"]
#define CONNECTING_TO_TOR_STRING [OTRLanguageManager translatedString: @"Connecting to Tor"]
#define CHAT_STRING [OTRLanguageManager translatedString: @"Chat"]
#define OTRL_MSGEVENT_LOG_HEARTBEAT_RCVD_STRING [OTRLanguageManager translatedString: @"Received a heartbeat."]
#define DO_NOT_DISTURB_STRING [OTRLanguageManager translatedString: @"Do Not Disturb"]
#define errSSLProtocolString [OTRLanguageManager translatedString: @"SSL protocol error"]
#define CONVERSATIONS_STRING [OTRLanguageManager translatedString: @"Conversations"]
#define SHARE_MESSAGE_STRING [OTRLanguageManager translatedString: @"Chat with me securely"]
#define XMPP_FAIL_STRING [OTRLanguageManager translatedString: @"Failed to connect to XMPP server. Please check your login credentials and internet connection and try again."]
#define XMPP_PORT_FAIL_STRING [OTRLanguageManager translatedString: @"Domain needs to be set manually when specifying a custom port"]
#define VALID_CERTIFICATE_STRING [OTRLanguageManager translatedString: @"Valid certificate"]
#define errSSLPeerUnexpectedMsgString [OTRLanguageManager translatedString: @"Unexpected message received"]
#define DELETE_CONVERSATIONS_ON_DISCONNECT_DESCRIPTION_STRING [OTRLanguageManager translatedString: @"Delete chats on disconnect"]
#define SEARCH_STRING [OTRLanguageManager translatedString: @"Search"]
#define INVALID_EMAIL_DETAIL_STRING [OTRLanguageManager translatedString: @"Please choose a valid email address"]
#define XMPP_USERNAME_EXAMPLE_STRING [OTRLanguageManager translatedString: @"user@example.com"]
#define SECURITY_WARNING_DESCRIPTION_STRING [OTRLanguageManager translatedString: @"Warning: Use with caution! This may reduce your security."]
#define NOT_VERIFIED_STRING [OTRLanguageManager translatedString: @"Not Verified"]
#define INCOMING_STATUS_MESSAGE [OTRLanguageManager translatedString: @"New Status Message: %@"]
#define errSSLBadCertString [OTRLanguageManager translatedString: @"Bad certificate format"]
#define errSSLConnectionRefusedString [OTRLanguageManager translatedString: @"Peer dropped connection before responding"]
#define SECURITY_WARNING_STRING [OTRLanguageManager translatedString: @"Security Warning"]
#define VERIFIED_STRING [OTRLanguageManager translatedString: @"Verified"]
#define BUDDY_INFO_STRING [OTRLanguageManager translatedString: @"Buddy Info"]
#define MANAGE_CHATSECURE_PUSH_ACCOUNT_STRING [OTRLanguageManager translatedString: @"Manage ChatSecure Push account"]
#define CONNECTING_STRING [OTRLanguageManager translatedString: @"Connecting"]
#define DUPLICATE_ACCOUNT_MESSAGE_STRING [OTRLanguageManager translatedString: @"There already exists an account with this username."]
#define CHAT_STATE_COMPOSING_STRING [OTRLanguageManager translatedString: @"Typing"]
#define errSSLWouldBlockString [OTRLanguageManager translatedString: @"I/O would block (not fatal)"]
#define OTRL_MSGEVENT_ENCRYPTION_REQUIRED_STRING [OTRLanguageManager translatedString: @"Our policy requires encryption but we are trying to send an unencrypted message out."]
#define QR_CODE_INSTRUCTIONS_STRING [OTRLanguageManager translatedString: @"This QR Code contains a link to http://omniqrcode.com/q/chatsecure and will redirect to the App Store."]
#define REMEMBER_PASSWORD_STRING [OTRLanguageManager translatedString: @"Remember password"]
#define CONVERSATION_NOT_SECURE_WARNING_STRING [OTRLanguageManager translatedString: @"Warning: This chat is not encrypted"]
#define ALLOW_SSL_HOSTNAME_MISMATCH_STRING [OTRLanguageManager translatedString: @"Hostname Mismatch"]
#define CANCEL_ENCRYPTED_CHAT_STRING [OTRLanguageManager translatedString: @"Cancel Encrypted Chat"]
#define OTRL_MSGEVENT_SETUP_ERROR_STRING [OTRLanguageManager translatedString: @"A private conversation could not be set up."]
#define PROJECT_HOMEPAGE_STRING [OTRLanguageManager translatedString: @"Project Homepage"]
#define SETTINGS_STRING [OTRLanguageManager translatedString: @"Settings"]
#define SECURE_CONVERSATION_STRING [OTRLanguageManager translatedString: @"You must be in a secure conversation first."]
#define LOGOUT_FROM_XMPP_STRING [OTRLanguageManager translatedString: @"Logout from XMPP?"]
#define SSL_MISMATCH_STRING [OTRLanguageManager translatedString: @"SSL Hostname Mismatch"]
#define REMEMBER_PASSPHRASE_STRING [OTRLanguageManager translatedString: @"Remember Passphrase"]
#define PINNED_CERTIFICATES_STRING [OTRLanguageManager translatedString: @"Pinned Certificates"]
#define errSSLPeerBadCertString [OTRLanguageManager translatedString: @"Miscellaneous bad certificate"]
#define DEFAULT_BUDDY_GROUP_STRING [OTRLanguageManager translatedString: @"Buddies"]
#define OLD_STRING [OTRLanguageManager translatedString: @"Old"]
#define FORGOT_PASSPHRASE_INFO_STRING [OTRLanguageManager translatedString: @"Because the database contents is encrypted with your passphrase, you've lost access to your data and will need to delete and reinstall ChatSecure to continue. Password managers like 1Password or MiniKeePass can be helpful for generating and storing strong passwords."]
#define NEW_PASSPHRASE_STRING [OTRLanguageManager translatedString: @"New Passphrase"]
#define errSSLSessionNotFoundString [OTRLanguageManager translatedString: @"Attempt to restore an unknown session"]
#define INFO_STRING [OTRLanguageManager translatedString: @"Info"]
#define EXTENDED_AWAY_STRING [OTRLanguageManager translatedString: @"Extended Away"]
#define OTHER_STRING [OTRLanguageManager translatedString: @"Other"]
#define REPLY_STRING [OTRLanguageManager translatedString: @"Reply"]
#define IN_BAND_ERROR_STRING [OTRLanguageManager translatedString: @"The XMPP server does not support in-band registration"]
#define AVAILABLE_STRING [OTRLanguageManager translatedString: @"Available"]
#define CREATE_NEW_ACCOUNT_STRING [OTRLanguageManager translatedString: @"Create New Account"]
#define OPTIONAL_STRING [OTRLanguageManager translatedString: @"Optional"]
#define errSSLCertNotYetValidString [OTRLanguageManager translatedString: @"Chain had a cert not yet valid"]
#define errSSLPeerUserCancelledString [OTRLanguageManager translatedString: @"User canceled"]
#define DELIVERED_STRING [OTRLanguageManager translatedString: @"Delivered"]
#define ABOUT_STRING [OTRLanguageManager translatedString: @"About"]
#define REQUIRED_STRING [OTRLanguageManager translatedString: @"Required"]
#define DISCONNECTION_WARNING_STRING [OTRLanguageManager translatedString: @"When you leave this conversation it will be deleted forever."]
#define ABOUT_VERSION_STRING [OTRLanguageManager translatedString: @"About This Version"]
#define YOUR_FINGERPRINT_STRING [OTRLanguageManager translatedString: @"Fingerprint for you"]
#define COMPOSE_STRING [OTRLanguageManager translatedString: @"Compose"]
#define NEW_STRING [OTRLanguageManager translatedString: @"New"]
#define NEXT_STRING [OTRLanguageManager translatedString: @"Next"]
#define OSCAR_FAIL_STRING [OTRLanguageManager translatedString: @"Failed to start authenticating. Please try again."]
#define DUPLICATE_ACCOUNT_STRING [OTRLanguageManager translatedString: @"Duplicate account"]
#define CONTRIBUTE_TRANSLATION_STRING [OTRLanguageManager translatedString: @"Contribute a translation"]
#define LANGUAGE_STRING [OTRLanguageManager translatedString: @"Language"]
#define errSSLUnknownRootCertString [OTRLanguageManager translatedString: @"Valid cert chain, untrusted root"]
#define DISCONNECTED_MESSAGE_STRING [OTRLanguageManager translatedString: @"You (%@) have disconnected."]
#define SET_NEW_DATABASE_PASSPHRASE_STRING [OTRLanguageManager translatedString: @"Set new database passphrase"]
#define AVAILABLE_MESSAGE_STRING [OTRLanguageManager translatedString: @"is now available"]
#define OTRL_MSGEVENT_RCVDMSG_MALFORMED_STRING [OTRLanguageManager translatedString: @"The message received contains malformed data."]
#define errSSLPeerBadRecordMacString [OTRLanguageManager translatedString: @"Bad MAC"]
#define BLOCK_AND_REMOVE_STRING [OTRLanguageManager translatedString: @"Block & Remove"]
#define CREATING_ACCOUNT_STRING [OTRLanguageManager translatedString: @"Creating Account"]
#define DATABASE_SETUP_ERROR_STRING [OTRLanguageManager translatedString: @"An error occurred while setting up the database."]
#define errSSLIllegalParamString [OTRLanguageManager translatedString: @"Illegal parameter"]
#define OTRL_MSGEVENT_CONNECTION_ENDED_STRING [OTRLanguageManager translatedString: @"Message has not been sent because our buddy has ended the private conversation. We should either close the connection, or refresh it."]
#define DISCONNECTION_WARNING_TITLE_STRING [OTRLanguageManager translatedString: @"Sign out Warning"]
#define CHAT_STATE_ACTIVE_STRING [OTRLanguageManager translatedString: @"Active"]
#define BUDDY_LIST_STRING [OTRLanguageManager translatedString: @"Buddy List"]
#define errSSLPeerCertRevokedString [OTRLanguageManager translatedString: @"Certificate revoked"]
#define READ_STRING [OTRLanguageManager translatedString: @"Read"]
#define LOGGING_IN_STRING [OTRLanguageManager translatedString: @"Logging in..."]
#define GOOGLE_TALK_EXAMPLE_STRING [OTRLanguageManager translatedString: @"user@gmail.com"]
#define OTRL_MSGEVENT_RCVDMSG_UNRECOGNIZED_STRING [OTRLanguageManager translatedString: @"Cannot recognize the type of OTR message received."]
#define DONATE_MESSAGE_STRING [OTRLanguageManager translatedString: @"Your donation will help fund the continued development of ChatSecure."]
#define BUDDY_FINGERPRINTS_STRING [OTRLanguageManager translatedString: @"Buddy Fingerprints"]
#define errSSLXCertChainInvalidString [OTRLanguageManager translatedString: @"Invalid certificate chain"]
#define EMAIL_STRING [OTRLanguageManager translatedString: @"Email"]
#define BUNDLED_CERTIFICATES_STRING [OTRLanguageManager translatedString: @"Bundled Certificates"]
#define FONT_SIZE_STRING [OTRLanguageManager translatedString: @"Font Size"]
#define SHOW_USERVOICE_STRING [OTRLanguageManager translatedString: @"Would you like to connect to UserVoice to send feedback?"]
#define CURRENT_PASSPHRASE_STRING [OTRLanguageManager translatedString: @"Current Passphrase"]
#define SELF_SIGNED_SSL_STRING [OTRLanguageManager translatedString: @"Self Signed SSL"]
#define UNLOCKED_ALERT_STRING [OTRLanguageManager translatedString: @"The conversation is not secure"]
#define CANCEL_STRING [OTRLanguageManager translatedString: @"Cancel"]
#define OTRL_MSGEVENT_LOG_HEARTBEAT_SENT_STRING [OTRLanguageManager translatedString: @"Sent a heartbeat."]
#define errSSLClosedGracefulString [OTRLanguageManager translatedString: @"Connection closed gracefully"]
#define PINNED_CERTIFICATES_DESCRIPTION_STRING [OTRLanguageManager translatedString: @"Manage saved SSL certificates"]
#define CHATSECURE_PUSH_STRING [OTRLanguageManager translatedString: @"ChatSecure Push"]
#define LOGIN_AUTOMATICALLY_STRING [OTRLanguageManager translatedString: @"Login Automatically"]
#define DEFAULT_LANGUAGE_STRING NSLocalizedString(@"Default", @"default string to revert to normal language behaviour")
#define RENAME_STRING [OTRLanguageManager translatedString: @"Rename"]
#define ENTER_NEW_NAME [OTRLanguageManager translatedString: @"Enter the new name for"]

#define CHOOSE_PHOTO [OTRLanguageManager translatedString: @"Choose photo"]
#define FROM_PHOTO_LIBRARY [OTRLanguageManager translatedString: @"From Photo Library"]
#define FROM_CAMERA [OTRLanguageManager translatedString: @"From Camera"]
#define RESEND [OTRLanguageManager translatedString: @"Resend"]
#define NOT_DELIVERED [OTRLanguageManager translatedString: @"Not delivered"]
#define BACK_BTN [OTRLanguageManager translatedString: @"Back"]

#define RECIPIENTS [OTRLanguageManager translatedString: @"Recipients"]
#define MEMBERS [OTRLanguageManager translatedString: @"Members"]
#define ALREADY_AT_ROOM [OTRLanguageManager translatedString: @"Already at room"]
#define LEAVE_THE_ROOM [OTRLanguageManager translatedString: @"leave the room"]
#define YOU_ARE_THE_ADMINISTRATOR_OF_THE_ROOM [OTRLanguageManager translatedString: @"You are the administrator of the room"]
#define OWNER_OF_THIS_ROOM [OTRLanguageManager translatedString: @"owner of this room"]
#define DESTROY_THE_ROOM [OTRLanguageManager translatedString: @"Destroy the room"]
#define ADD_MEMBER [OTRLanguageManager translatedString: @"Add member"]
#define INVITE_TO_CHAT [OTRLanguageManager translatedString: @"invite to chat"]
#define SIGN_OUT_OF_ROOM [OTRLanguageManager translatedString: @"Sign out of room"]
#define MY_LOCATION [OTRLanguageManager translatedString: @"My Location"]
#define ACCESS_LOCATION  [OTRLanguageManager translatedString: @"Please turn on the geolocation to get access to all functions!"]
#define TAP_TO_OPEN [OTRLanguageManager translatedString: @"Tap to open"]
#define RENAMED_ROOM [OTRLanguageManager translatedString: @"renamed room"]
#define SUBMITTED_DATE [OTRLanguageManager translatedString: @"Submitted date"]
#define STATUS_STRING [OTRLanguageManager translatedString: @"Status"]
#define SUBMITTED_STRING [OTRLanguageManager translatedString: @"Submitted"]
#define LIFETIME_STRING [OTRLanguageManager translatedString: @"Lifetime"]
#define DETAILS_MESSAGE_STRING [OTRLanguageManager translatedString: @"Details of message"]
#define CANCEL_SENDING_STRING [OTRLanguageManager translatedString: @"Cancel the sending"]
#define CANCELED_STRING [OTRLanguageManager translatedString: @"Canceled"]
#define FAILED_TO_CANCEL_SENDING [OTRLanguageManager translatedString: @"Failed to cancel sending a message (message sent)."]
#define CHANGE_AVATAR_STRING [OTRLanguageManager translatedString: @"Change avatar"]
#define PLEASE_WAIT [OTRLanguageManager translatedString: @"Please wait..."]
#define WAITING_FOR_INTERNET_CONNECTION [OTRLanguageManager translatedString: @"Waiting for internet connection"]
#define KEEP_HISTORY_STRING [OTRLanguageManager translatedString: @"Keep a history"]
#define STORING_HISTORI_STRING [OTRLanguageManager translatedString: @"Storing the history on the server"]