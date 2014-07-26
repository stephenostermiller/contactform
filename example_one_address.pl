#!/usr/bin/perl -T -w

use strict;

# Contact Form is a Perl script that you can run on your website that will
# allow others to send you email through a web interface.
# See: http://ostermiller.org/contactform/
# Copyright (C) 2002-2014 Stephen Ostermiller
# http://ostermiller.org/contact.pl?regarding=Contact+Form
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later versicon.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# See copying.txt for details.

my($SubmittedData, $mail_message, $AliasesMap, $AliasesOrdered,
$FieldMap, @Field_Order, $template_error, $field_name_to,
$field_name_from_email, $field_name_from_name, $field_name_subject,
$field_name_regarding, $field_name_referrer, $NO_DESCRIPTION,
$VERSION, $LETTER, $DIGIT, $DOSEOL, $EOL, $LETTER_DIGIT,
$LETTER_DIGIT_HYPHEN, $HEX_DIGIT, $QUOTEDSTRING, $ATOM, $SUBDOMAIN, $WORD,
$DOMAIN, $LOCALPART, $EMAIL, $PHONE_DIGIT, $PHONE, $ZIPCODE, $PRICE, $FLOAT,
$INTEGER, $SOMETHING, $ANYTHING, $ONE_LINE_REQUIRED, $ONE_LINE_OPTIONAL,
$ZIPCODE_REQUIRED, $ZIPCODE_OPTIONAL, $PHONE_REQUIRED, $PHONE_OPTIONAL,
$EMAIL_REQUIRED, $EMAIL_OPTIONAL, $PRICE_REQUIRED, $PRICE_OPTIONAL,
$FLOAT_REQUIRED, $FLOAT_OPTIONAL, $INTEGER_REQUIRED, $INTEGER_OPTIONAL,
$BLANK, $PHONE_NO_AREA_CODE_OPTIONAL, $PHONE_NO_AREA_CODE_REQUIRED,
$PHONE_NO_AREA_CODE, $Aliases, $captcha, $FormFields, $disallowed_text,
$translations, $settings,$captchaResult,$userLangs
);

sub settings(){

	# If the configuration file is set, then anything in the configuration
	# file over rides settings directly in this file.
	# It is recommended that the configuration file live outside of
	# webserver document root and it should be accessed by absolute path
	# here.  For example: $settings->{'configuration_file'} = "/etc/contact_form.conf"
	$settings->{'configuration_file'} = 'example_one_address.xml';

	# List of email address to which mail can be sent.
	#
	# Mail cannot be sent to any email address which is not on this list.
	# If a single address is listed, it will be a hidden value on the
	# form, otherwise, the user will be presented with a pulldown menu
	# of aliases to which email can be sent.
	# The addresses listed here are never visible via served web pages.
	#
	# Both the names and the addresses here can be (but don't have to be)
	# translated. You might want to translate names for functional duties
	# such as 'webmaster' or 'customer support'.  You might want to put in
	# translations for the email addresses when different people or teams
	# would want to recieve the email in a different language.
	$Aliases = [
		'contact_administrator_name', 'contact_administrator_email',

		#### The following aliases are commented out examples, remove the leading # sign to use them

		## A simple example of mail sent to John Smith
		#'John Smith','john@yoursite.tld',

		## Here both the name and the email are translated.
		## Translations can be edited in the translations section.
		#'contact_customer_support_name','contact_customer_support_email',

		## Just the name is translated
		#'contact_postmaster_name','postmaster@yoursite.tld',

		## A mailing list with multiple addresses separated by commas
		#'two people','webmaster@yoursite.tld,postmaster@yoursite.tld',
	];

	# The email address that appears in the From and Sender field of sent
	# emails.  The email address of the user will then be used in the
	# Reply-To field, making it possible to respond to users.
	#
	# Historically, this contact form has put the user's email address in
	# the From field. That doesn't work well. Your mail server may not
	# accept mail, or will mark mail as spam, if it is sent on behalf of
	# the user but  doesn't come from the user's designated email server.
	# This behavior is still available by specifying 'user' as the value.
	#
	# If this is left blank, the from Field will be the same as the To field.
	#
	# Example: $settings->{'sender_email'} = "john.smith@example.com";
	$settings->{'sender_email'} = '';

	# Modify the following to control how the HTML pages look

	# Page structure -- the look and feel of the page
	# This variable may be either changed directly, or if the
	# page_template_file variable is set, this variable is
	# ignored and the template file is used instead.
	# Contact form can place content into any of four places:
	# $title -- the title of the page
	# $css -- style rules that control how the form looks
	# $javascript -- client side validation rules.
	# $content -- the form itself.
	# The css and title variables are optional and can easily
	# be omitted and replaced with your own elements to better
	# suit your taste.  The form will not work properly if either
	# the javascript or content variables are removed or duplicated.
	# This may be a translation key for providing different templates
	# for different languages.
	$settings->{'page_template'} =
	'<html>
	<head>
	<title>$title</title>
	$css
	$javascript
	</head>
	<body class="contactform cf_body" id="cf_body">
	<h1 class="contactform cf_header" id="cf_titleheader">$title</h1>
	$content
	</body>
	</html>
	';

	# if the template file is set, the page_template variable
	# is ignored and the template is loaded from the named file.
	# for example:
	# $settings->{'page_template_file'} = "mytemplate.html";
	# or
	# $settings->{'page_template_file'} = "/home/me/contact.template";
	# If this file is set, the file will be read every time this script
	# is called, not the most efficient, but very convenient.
	# The template file must be in the same format as the page_template
	# variable above
	$settings->{'page_template_file'} = '';

	# Whether or not to show a link to the contact form website.
	# Set to 0 to disable.
	# If you do remove the link, please tell your friends about contact form,
	# link to contact form somewhere else, write a blog entry about
	# contact form, post in a forum about contact form, or otherwise
	# spread the word.
	$settings->{'show_contact_form_link'} = 1;

	# FormFields is the list of questions the user is expected
	# to answer. The questions will appear in the same order as
	# they are ordered here. You may safely remove the subject,
	# email, name, and message from the form. The to field should
	# not be removed. The name of each field should contain only
	# letters, numbers, and underscore.  Spaces or symbols should
	# not be used.  Each has several attributes that control the
	# display of the question to the user.
	#
	# "required"
	# a regular expression that describes what a valid submission looks
	# like.  By default, any entry at all is allowed.
	# Consider using the following pre-defined regular expressions:
	# $SOMETHING, $ANYTHING, $ONE_LINE_REQUIRED, $ONE_LINE_OPTIONAL,
	# $ZIPCODE_REQUIRED, $ZIPCODE_OPTIONAL, $PHONE_REQUIRED,
	# $PHONE_OPTIONAL, $EMAIL_REQUIRED, $EMAIL_OPTIONAL, $PRICE_REQUIRED,
	# $PRICE_OPTIONAL, $FLOAT_REQUIRED, $FLOAT_OPTIONAL,
	# $INTEGER_REQUIRED, $INTEGER_OPTIONAL, $BLANK, $PHONE_NO_AREA_CODE_OPTIONAL,
	# $PHONE_NO_AREA_CODE_REQUIRED
	#
	# "error"
	# A user friendly error message for each required
	# element that a user gets wrong.
	#
	# "type"
	# Type of input in web pages for each field.
	# Currently supported are 'text', 'hidden', 'radio',
	# 'select', and 'textarea'
	# If there is no type, 'text' is assumed.
	# Setting the type for the to field will have no effect since
	# the to field is handled specially.
	#
	# "description"
	# Description to appear next to entry forms and in
	# the email or $NO_DESCRIPTION for none
	# If no description is given the field name followed
	# by a colon is used
	#
	# "selected"
	# For fields of type "select", or "radio" indicates
	# the default selection
	#
	# "special"
	# Any special purpose for which the field is used.
	# Must be one of "to", "from", "name", "subject",
	# "regarding", or "referrer"
	#
	$FormFields = [
		'to', {
			'required' => $ONE_LINE_REQUIRED,
			'error' => 'field_to_error.',
			'description' => 'field_to_description',
			# Alias of the address put in the "To:" field of the email.
			'special' => 'to',
			'show_in_message' => 'false',
		},
		'email', {
			'required' => $EMAIL_REQUIRED,
			'error' => 'field_email_error',
			'type' => 'text',
			'description' => 'field_email_description',
			# Put in the "From:" field of the email as the email of the person it is from
			'special' => 'from',
			'show_in_message' => 'false',
		},
		'confirm', {
			# This is a field designed to thwart automated submissions
			# This field is not visible to the user.
			# Bots may attempt to fill it in which will prevent submission.
			'required' => $BLANK,
			'error' => 'field_trap_error',
			'type' => 'trap',
			'description' => 'field_trap_description',
		},
		'name', {
			'required' => $ONE_LINE_OPTIONAL,
			'error' => 'field_name_error',
			'type' => 'text',
			'description' => 'field_name_description',
			# Put in the "From:" field of the email as the name of the person it is from
			'special' => 'name',
			'show_in_message' => 'false',
		},
		'subject', {
			'required' => $ONE_LINE_REQUIRED,
			'error' => 'field_subject_error',
			'type' => 'text',
			'description' => 'field_subject_description',
			# Put in the "Subject:" field of the email.
			'special' => 'subject',
			'show_in_message' => 'false',
		},
		'message', {
			'required' => $SOMETHING,
			'error' => 'field_message_error',
			'type' => 'textarea',
			'description' => $NO_DESCRIPTION,
		},
		'regarding', {
			'required' => $ANYTHING,
			'error' => '',
			'type' => 'hidden',
			'description' => $NO_DESCRIPTION,
			# Put in the "Subject:" field of the email in parenthesis.
			'special' => 'regarding',
			'show_in_message' => 'false',
		},
		'referrer', {
			'required' => $ANYTHING,
			'error' => '',
			'type' => 'hidden',
			'description' => $NO_DESCRIPTION,
			# The original referring url.
			'special' => 'referrer',
			'show_in_message' => 'false',
		},
		# The following fields are disabled examples, remove the 'enabled' => 1 line to use them
		'phone', {
			'required' => $PHONE_OPTIONAL,
			'error' => 'field_phone_error',
			'type' => 'text',
			'description' => 'field_phone_description',
			'enabled' => 0,
		},
		'fax', {
			'required' => $PHONE_OPTIONAL,
			'error' => 'field_fax_error',
			'type' => 'text',
			'description' => 'field_fax_description',
			'enabled' => 0,
		},
		'address1', {
			'required' => $ONE_LINE_OPTIONAL,
			'error' => 'field_address_error',
			'type' => 'text',
			'description' => 'field_address_description',
			'enabled' => 0,
		},
		'address2', {
			'required' => $ONE_LINE_OPTIONAL,
			'error' => 'field_address_error',
			'type' => 'text',
			'description' => $NO_DESCRIPTION,
			'enabled' => 0,
		},
		'city', {
			'required' => '^(?:[a-zA-Z ]*)$',
			'error' => 'field_city_error',
			'type' => 'text',
			'description' => 'field_city_description',
			'enabled' => 0,
		},
		'state', {
			'required' => '^(?:AL|AK|AS|AZ|AR|CA|CO|CT|DE|DC|FL|GA|GU|HI|ID|IL|IN|IA|KS|KY|LA|ME|MD|MH|MA|MI|FM|MN|MS|MO|MT|NE|NV|NH|NJ|NM|NY|NC|ND|MP|OH|OK|OR|PW|PA|PR|RI|SC|SD|TN|TX|UT|VT|VA|VI|WA|WV|WI|WY)$',
			'error' => 'field_state_error',
			'type' => 'select',
			'description' => 'field_state_description',
			'enabled' => 0,
		},
		'zip', {
			'required' => $ZIPCODE_OPTIONAL,
			'error' => 'field_zip_error',
			'type' => 'text',
			'description' => 'field_zip_description',
			'enabled' => 0,
		},
		'most_basic_question', {
			# uses the default values for required, error, type, and description
			'enabled' => 0,
		},
		'color', {
			# A required select drop down
			'type' => 'select',
			'required' => 'field_color_required',
			'error' => 'field_color_error',
			'description' => 'field_color_description',
			'enabled' => 0,
		},
		'vegetable', {
			# An optional select drop down
			'type' => 'select',
			'required' => 'field_vegetable_required',
			'error' => 'field_vegetable_description',
			'description' => 'field_vegetable_description',
			'enabled' => 0,
		},
		'letter', {
			# A select drop down with a pre-filled option
			'type' => 'select',
			'required' => 'field_letter_required',
			'error' => 'field_letter_error',
			'description' => 'field_letter_description',
			'selected' => 'field_letter_selected',
			'enabled' => 0,
		},
		'yes_no', {
			# required radio buttons
			'type' => 'radio',
			'required' => 'field_yes_no_required',
			'error' => 'field_yes_no_error',
			'description' => 'field_yes_no_description',
			'enabled' => 0,
		},
		'true_false', {
			# radio buttons with a prefilled option
			'type' => 'radio',
			'required' => 'field_true_false_required',
			'error' => 'field_true_false_error',
			'description' => 'field_true_false_description',
			'selected' => 'field_true_false_selected',
			'enabled' => 0,
		},
		'vegetable2', {
			# optional radio buttons
			'type' => 'radio',
			'required' => 'field_vegetable2_required',
			'error' => 'field_vegetable_error',
			'description' => 'field_vegetable_description',
			'enabled' => 0,
		},
		'about', {
			# prefilled
			'type' => 'text',
			'required' => $ANYTHING,
			'error' => 'field_about_error',
			'description' => 'field_about_description',
			'default' => 'field_about_default',
			'enabled' => 0,
		},
	];

	# Captcha settings -- Displays distorted text that the user
	# must type in to prove that they are human.
	# Sign up for a recaptach account at http://recaptcha.net/
	# enter the public and private keys that they give you here
	# Your server must have the Captcha::reCAPTCHA library installed.
	# To install it, talk to your admin or use the command line:
	# cpan install 'Captcha::reCAPTCHA'
	$settings->{'recaptcha_public_key'} = '';
	$settings->{'recaptcha_private_key'} = '';

	# The name of the field for submit/preview action
	$settings->{'field_name_submit'} = 'do';

	# Regular expression describing urls which can host forms
	# pointing to this program. The referral URL is generated on the
	# client side by the browser. Therefore it useless to prevent
	# unauthorized submission by mail software robots. You can
	# prevent somebody from reliably hosting, on another server,
	# a form pointing to this email software.
	# Consider the following options:
	# This form can be used from any site at all: .*
	# This form can only be used from pages on yoursite.tld: ^http[s]?\:\/\/yoursite\.tld\/
	# This form can only be used from pages on the domain or ip address: ^http[s]?\:\/\/((yoursite\.tld)|(127\.0\.0\.1))\/
	# This form can only be used from a specific page: ^http[s]?\:\/\/yoursite\.tld\/directory\/page\.html\$
	$settings->{'allowedReferers'} = '.*';

	# Regular expressions for text that is not allowed in any fields.
	# Messages may be translation keys.
	$disallowed_text = {
		"\\<[ \\r\\n\\t]*[Aa][ \\r\\n\\t]","error_disallow_html_formatted_links",
		"\\[[ \\r\\n\\t]*[Uu][Rr][Ll][ \\r\\n\\t]*\\=","error_disallow_board_formatted_links",
	};

	# Whether or not users are required to preview
	# their message before sending.
	# 0 -- preview disabled (allows users to send mail the fastest)
	# 1 -- preview required (best for spam prevention)
	# 2 -- preview available, but not required  (most choice for users)
	$settings->{'require_preview'} = 1;

	# Whether or not to include the "To: <alias>" field in the email body.
	# This is usually desired when there are multiple recipients so that
	# each recipient can tell that the email was sent to multiple people.
	# yes -- always include the to field
	# multiple -- include the to field only when there are multiple recipients
	# no -- do not include the to field
	$settings->{'show_to_in_message'} = 'multiple';

	# The character set for the contact page.
	$settings->{'charset'} = 'UTF-8';

	# Command line program used to send email
	# '/usr/lib/sendmail -i -t' almost always works fine
	$settings->{'sendmail'} = '/usr/lib/sendmail -i -t';

	# Whether or not to include javascript that checks the form
	# before it is submitted.
	# This is generally good, but it increases the page size, increases the
	# complexity of the page, and could alert hackers to the
	# regular expressions you are using for verification.
	# Set to 0 to disable, 1 to enable.
	$settings->{'use_client_side_verification'} = 1;

	# This should be either 'POST' or 'GET'
	$settings->{'submit_method'} = 'POST';

	# Placed next to form elements that must be filled in
	# The required marker can be set to a translation key
	# such that translated text for something like "REQUIRED"
	# is shown to users rather than an asterisk.
	$settings->{'required_marker'} = '<span class="contactform cf_required">*</span>';

	# Text that should always go at the beginning of the subject
	# of emails that this contact form sends out.  This could be
	# useful as a signal for filtering email or seeing which emails
	# come in through contact form when scanning your inbox.
	# eg $settings->{'subject_prepend'} = '[WEB]';
	# This may be (but does not have to be) set to a translation key.
	$settings->{'subject_prepend'} = '';

	# Style rules for the input page.
	# to put question and answer on the same line use:
	# .cf_userentry, .cf_radioselection { display:inline; margin-left:0.25cm; }
	$settings->{'input_page_css'} =
	'<style>
	.cf_error { color:red; }
	.cf_textentry { min-width:300px; width:100%; max-width:600px; width:expression(document.body.clientWidth>600?"600px":"auto");}
	.cf_instructions { margin-bottom:1em; }
	textarea.contactform { height:4in; }
	.cf_required { color:green; }
	#cf_version { text-align:right; }
	#cf_global_error { margin-bottom:0.25cm; }
	.cf_field { margin-bottom:0.5cm; }
	.cf_nt { display:none; }
	.cf_preview { border:thin black ridge; padding:1cm; max-width:600px; width:expression(document.body.clientWidth>600?"600px":"auto");margin-bottom:1cm;}
	</style>
	';

	# Style rules for thank you page
	$settings->{'sent_page_css'} =
	'<style>
	.cf_thankyou { margin-bottom:1em; }
	.cf_sent { border:thin black ridge; padding:1cm; max-width:600px; width:expression(document.body.clientWidth>600?"600px":"auto");}
	#cf_version { text-align:right; }
	</style>';

	# Link to favicon, placed in the head after the JavaScript
	$settings->{'icon_link'}='<link rel="icon" href="'.&escapeHTML($ENV{'SCRIPT_NAME'}).'/contactformicon.png" type="image/png">';

	# Form copyright header placed in the head after the JavaScript
	$settings->{'copyright_link'} = '<link rel="copyright" href="http://ostermiller.org/contactform/" type="text/html">';

	# Redirect to this url after the message has been sent
	# By default there is no redirect.  The url must
	# be fully qualified (must start with http://)
	# Example: $settings->{'redirect_url_sent'} = "http://example.com/";
	# This may be set to a translation key for redirecting to different
	# urls in different languages.
	$settings->{'redirect_url_sent'} = "";

	# Show the sent confirmation for this many seconds before redirecting
	# after the message has been sent if the redirect_url_sent has been defined.
	# If zero is specified, the message sent confirmation will not
	# be shown at all (you can redirect to your own thank you)
	$settings->{'redirect_delay_sent'} = 15;

	# The language to display to the user if the users preferred
	# language cannot be determined.
	$settings->{'default_language'} = 'en';

	# A list of allowed languages separated by spaces.
	# eg $settings->{'allowed_languages'} = 'en en_US fr de';
	# Contact form will only be shown in the languages listed.
	# If allowed_languages is blank, then any language for which
	# translations exist may be shown.
	$settings->{'allowed_languages'} = '';

	# Parameter name that specifies the language in which
	# contact form should be shown or blank not to use.
	# If this parameter is not used or not present,
	# contact form tries to detect the language from the
	# users browser settings, then falls back to the default
	# language setting.  A link to contact form with the param
	# might look something like this:
	# /contact.pl?cflang=de
	$settings->{'language_param'} = 'cflang';

	# The text shown to users by contact form. Each item should be
	# translated into each language used.
	#
	# Language keys: lower case two letter language code, optionally
	# followed by an underscore and uppercase two letter country code.
	# eg. en or en_US
	#
	# Translation keys: All lowercase letters, numbers, and underscores.
	# Each must contain at least one underscore.  New keys may be
	# added when adding new fields.
	#
	# NOTE to translators: Use a UTF-8 capable editor when saving
	# translations.  Text in curly braces in the translations such
	# as {required_marker} or {server_administrator} is replaced
	# automatically and should not be translated.
	$translations = {
		# English
		'en' => {
			# Core messaging
			'input_page_title' => 'Contact Us',
			'input_page_instructions' => 'Fill out the form below to send your comments.',
			'required_marker_description' => '{required_marker} denotes a required field.',
			'preview_button' => 'Preview',
			'send_button' => 'Send',
			'preview_page_instructions' => 'Please review your message before sending it. Changes can be made below.',
			'sent_page_title' => 'Message Sent',
			'sent_page_thank_you' => 'Thank you for your comments!',
			'email_header_to' => 'To:',
			'email_header_from' => 'From:',
			'email_header_subject' => 'Subject:',
			'contact_form_version' => 'Contact Form {version_number}',
			# Core fields
			'field_to_description' => 'To',
			'field_to_error' => 'You must specify a recipient.',
			'field_email_description' => 'Your email address:',
			'field_email_error' => 'The email address you entered does not appear to be valid.',
			'field_email_default' => 'nobody',
			'field_trap_description' => 'Leave blank:',
			'field_trap_error' => 'This field should be left blank.',
			'field_name_description' => 'Your name:',
			'field_name_error' => 'You must enter your name.',
			'field_subject_description' => 'Subject:',
			'field_subject_error' => 'You must enter a subject.',
			'field_subject_default' => 'Website Form Submission',
			'field_message_error' => 'You must enter a message.',
			'field_captcha_description' => 'Prove that you are a human:',
			'field_captcha_error' => 'Captcha problem',
			# Error messaging
			'error_get_post_only' => "This form must be submitted via either 'GET' or 'POST'.",
			'error_bad_referrer' => 'This form cannot be submitted from {referrer}.',
			'error_bad_recipient' => 'Your message cannot be sent to the specified recipient.',
			'error_generic_field' => "The field '{field_key}' does not appear to be valid.",
			'error_correction_required' => 'Please correct the error to continue.',
			'error_corrections_required' => 'Please correct all errors to continue.',
			'error_disallow_html_formatted_links' => 'You appear to be trying to include HTML formatted links.  Links should not be formatted like this.',
			'error_disallow_board_formatted_links' => 'You appear to be trying to include message board formatted links.  Links should not be formatted like this.',
			'error_module_missing_title' => '{perl_module} Perl Module Not Installed',
			'error_module_missing_no_config_file' => 'Install the {perl_module} module or do not use the configuration file feature',
			'error_module_missing_no_captcha' => 'Install the {perl_module} module or do not use the captcha feature',
			'error_bad_config_file_title' => 'Could Not Read Configuration File',
			'error_bad_config_file' => 'Check configuration file existence, permissions, and validity of XML; or do not use a configuration file.',
			'error_template_file_problem' => 'The template file could not be opened.',
			# Configuration examples
			'contact_administrator_name' => 'administrator',
			'contact_customer_support_name' => 'Customer Support',
			'contact_customer_support_email' => 'support@yoursite.tld',
			'contact_postmaster_name' => 'postmaster',
			'field_phone_error' => 'The phone number you entered does not appear to be valid.',
			'field_phone_description' => 'Phone Number:',
			'field_fax_error' => 'The fax number you entered does not appear to be valid.',
			'field_fax_description' => 'Fax Number:',
			'field_address_error' => 'Please enter your address.',
			'field_address_description' => 'Address:',
			'field_city_error' => 'Your city does not appear to be valid.',
			'field_city_description' => 'City:',
			'field_state_error' => 'Please choose your state.',
			'field_state_description' => 'State:',
			'field_zip_error' => 'Your zipcode does not appear to be valid.',
			'field_zip_description' => 'Zipcode:',
			'field_color_required' => '^(?:Red|Orange|Yellow|Green|Blue|Purple|Black|White)$',
			'field_color_error' => 'Please choose a color.',
			'field_color_description' => 'Choose a color:',
			'field_vegetable_required' => '^(?:|Corn|Peas|Beans|Carrots|Broccoli)$',
			'field_vegetable_error' => 'Please choose a valid vegetable.',
			'field_vegetable_description' => 'Which (if any) is your favorite vegetable:',
			'field_letter_required' => '^(?:A|B|C|D)$',
			'field_letter_error' => 'Please choose on of the four letters.',
			'field_letter_description' => 'Choose a letter (C is selected by default):',
			'field_letter_selected' => 'C',
			'field_yes_no_required' => '^(?:yes|no)$',
			'field_yes_no_error' => 'Please answer the yes/no question',
			'field_yes_no_description' => 'Yes or no:',
			'field_true_false_required' => '^(?:true|false)$',
			'field_true_false_error' => 'Please answer the true/false question',
			'field_true_false_description' => 'True or false (false is selected by default):',
			'field_true_false_selected' => 'false',
			'field_vegetable2_required' => '^(?:|Lettuce|Tomato|Brussel Sprouts)$',
			'field_about_error' => 'Please enter what this message is about.',
			'field_about_description' => 'What is this message about:',
			'field_about_default' => 'Email',
			# No translation needed
			'contact_administrator_email' => '{server_admin}',
		},
		# Dutch (Nederlands)
		# Copyright 2011 Piet Tutelaers
		# http://tuite.nl/contact.html
		'nl' => {
			# Hoofdmeldingen
			'input_page_title' => 'Neem contact met ons op',
			'input_page_instructions' => 'Vul dit formulier in als u opmerkingen heeft.',
			'required_marker_description' => '{required_marker} geeft een verplicht veld aan.',
			'preview_button' => 'Bericht bekijken',
			'send_button' => 'Versturen',
			'preview_page_instructions' => 'Controleer uw bericht a.u.b. voordat u het gaat versturen. Veranderingen kunnen hieronder worden aangebracht.',
			'sent_page_title' => 'Bericht verstuurd',
			'sent_page_thank_you' => 'Bedankt voor uw commentaar!',
			'email_header_to' => 'Aan:',
			'email_header_from' => 'Van:',
			'email_header_subject' => 'Onderwerp:',
			'contact_form_version' => 'Contactformulier {version_number}',
			# Hoofdvelden
			'field_to_description' => 'Aan',
			'field_to_error' => 'U moet een geadresseerde opgeven.',
			'field_email_description' => 'Uw e-mailadres:',
			'field_email_error' => 'Het door u opgegeven e-mailadres klopt niet.',
			'field_email_default' => 'onbekend',
			'field_trap_description' => 'Blanco laten:',
			'field_trap_error' => 'Dit veld blanco laten.',
			'field_name_description' => 'Uw naam:',
			'field_name_error' => 'Vul hier uw naam in.',
			'field_subject_description' => 'Onderwerp:',
			'field_subject_error' => 'U moet hier een onderwerp opgeven.',
			'field_subject_default' => 'Website formulier verzending',
			'field_message_error' => 'U moet hier een bericht invoeren.',
			'field_captcha_description' => 'Bewijs dat u een mens bent:',
			'field_captcha_error' => 'Captcha probleem',
			# Foutmeldingen
			'error_get_post_only' => "Dit formulier moet worden verstuurd via 'GET' of 'POST'.",
			'error_bad_referrer' => 'Dit formulier kan niet worden verstuurd van {referrer}.',
			'error_bad_recipient' => 'Uw bericht kan niet worden verstuurd naar de opgegeven geadresseerde.',
			'error_generic_field' => "Het opgegeven veld '{field_key}' lijkt niet te bestaan.",
			'error_correction_required' => 'Korrigeer de fout voordat u verder gaat.',
			'error_corrections_required' => 'Korrigeer alle fouten voordat u verder gaat.',
			'error_disallow_html_formatted_links' => 'Het lijkt erop dat u links gebruikt in HTML formaat. Dergelijke links kunnen niet gebruikt worden.',
			'error_disallow_board_formatted_links' => 'Het lijkt erop dat u	links gebruikt in prikbord formaat. Dergelijke links kunnen niet gebruikt worden.',
			'error_module_missing_title' => '{perl_module} Perl module niet geïnstalleerd.',
			'error_module_missing_no_config_file' => 'Installeer de {perl_module} module of gebruik geen configuratiebestand".',
			'error_module_missing_no_captcha' => 'Installeer de {perl_module} module of gebruik geen "captcha".',
			'error_bad_config_file_title' => 'Configuratiebestand kan niet gelezen worden',
			'error_bad_config_file' => 'Controleer of er een configuratiebestand aanwezig is, de permissies en geldigheid van de XML; of gebruik geen configuratiebestand.',
			'error_template_file_problem' => 'Het templatebestand kan niet worden geopend.',
			# Configuratie voorbeelden
			'contact_administrator_name' => 'beheerder',
			'contact_customer_support_name' => 'Klantenondersteuning',
			'contact_customer_support_email' => 'support@yoursite.tld',
			'contact_postmaster_name' => 'postmaster',
			'field_phone_error' => 'Het opgegeven telefoonnummer lijkt ongeldig.',
			'field_phone_description' => 'Telefoonnummer:',
			'field_fax_error' => 'Het opgegeven faxnummer lijkt ongeldig.',
			'field_fax_description' => 'Faxnummer:',
			'field_address_error' => 'Geef a.u.b. uw adres.',
			'field_address_description' => 'Adres:',
			'field_city_error' => 'De opgegeven woonplaats lijkt ongeldig.',
			'field_city_description' => 'Woonplaats:',
			'field_state_error' => 'Geef a.u.b. uw provincie.',
			'field_state_description' => 'Provincie:',
			'field_zip_error' => 'De opgegeven postcode lijkt ongeldig.',
			'field_zip_description' => 'Postcode:',
			'field_color_required' => '^(?:Rood|Oranje|Geel|Groen|Blauw|Paars|Zwart|Wit)$',
			'field_color_error' => 'Kies een kleur a.u.b.',
			'field_color_description' => 'Kies een kleur:',
			'field_vegetable_required' => '^(?:|Maïs|Erwten|Bonen|Wortels|Broccoli)$',
			'field_vegetable_error' => 'Kies een geldige groente a.u.b.',
			'field_vegetable_description' => 'Wat (indien van toepassing) is je favouriete groente:',
			'field_letter_required' => '^(?:A|B|C|D)$',
			'field_letter_error' => 'Kies a.u.b. één van de vier letters.',
			'field_letter_description' => 'Kies een letter (anders wordt C gekozen):',
			'field_letter_selected' => 'C',
			'field_yes_no_required' => '^(?:ja|nee)$',
			'field_yes_no_error' => 'Beantwoord a.u.b. de ja/nee vraag',
			'field_yes_no_description' => 'Ja of nee:',
			'field_true_false_required' => '^(?:waar|onwaar)$',
			'field_true_false_error' => 'Beantwoord a.u.b. de waar/onwaar vraag',
			'field_true_false_description' => 'Waar of onwaar (onwaar is standaard):',
			'field_true_false_selected' => 'onwaar',
			'field_vegetable2_required' => '^(?:|Sla|Tomaat|Spruitjes)$',
			'field_about_error' => 'Geef a.u.b. aan waarover dit bericht gaat.',
			'field_about_description' => 'Waarover gaat dit bericht:',
			'field_about_default' => 'E-mail',
		},
		# Pig Latin (for testing)
		'pig' => {
			# Core messaging
			'input_page_title' => 'Ontactcay Uslay',
			'input_page_instructions' => 'Illfay outyay ethay ormfay elowbay ootay endsay oryay ommentscay.',
			'required_marker_description' => '{required_marker} enotesday ayay equiredray ieldfay.',
			'preview_button' => 'Eviewpray',
			'send_button' => 'Endsay',
			'preview_page_instructions' => 'Easeplay eviewray oryay essagemay eforeBay endingsay ityay. Angeschay ancay ebay ademay elowbay.',
			'sent_page_title' => 'Essagemay Entsay',
			'sent_page_thank_you' => 'Ankthay ooyay orfay oryay ommentsCay!',
   			'email_header_to' => 'Ootay:',
			'email_header_from' => 'Omfray:',
			'email_header_subject' => 'Ubjectsay:',
			'contact_form_version' => 'Ontactcay Ormfay {version_number}',
			# Core fields
			'field_to_description' => 'Ootay:',
			'field_to_error' => 'Ouyay ustmay ecifyspay ayay ecipientray.',
			'field_email_description' => 'Ouryay emailyay addressyay:',
			'field_email_error' => 'Ethay emailyay addressyay ouyay enteredyay oesday otnay appearyay ootay ebay alidvay.',
			'field_trap_description' => 'Eavelay ankblay:',
			'field_trap_error' => 'Isthay ieldfay ouldshay ebay eftlay ankblay.',
			'field_name_description' => 'Ouryay amenay:',
			'field_name_error' => 'Ouyay ustmay enteryay ouryay amenay.',
			'field_subject_description' => 'Ubjectsay:',
			'field_subject_error' => 'Ouyay ustmay enteryay ayay ubjectsay.',
			'field_message_error' => 'Ouyay ustmay enteryay ayay essagemay.',
			'field_captcha_description' => 'Ovepray atthay ouyay areyay ayay umanhay:',
			'field_captcha_error' => 'Aptchacay oblempray',
			# Error messaging
			'error_get_post_only' => "Isthay ormfay ustmay ebay ubmittedsay iavay eitheryay 'GET' oryay 'POST'.",
			'error_bad_referrer' => 'Isthay ormfay annotcay ebay ubmittedsay romfay {referrer}.',
			'error_bad_recipient' => 'Oryay essagemay annotcay ebay entsay ootay ethey ecifiedspay ecipientray.',
			'error_generic_field' => "Ethay ielday '{field_key}' oesday otnay appearyay ootay ebay alidvay.",
			'error_correction_required' => 'Easeplay orrectcay ethay erroryay ootay ontinuecay.',
			'error_corrections_required' => 'Easeplay orrectcay allyay errorsyay ootay ontinuecay.',
			'error_disallow_html_formatted_links' => 'Ouyay appearyay ootay ebay yingtray ootay includeyay HTML ormattedfay inkslay.  Inkslay ouldshay otnay ebay ormattedfay ikelay isthay.',
			'error_disallow_board_formatted_links' => 'Ouyay appearyay ootay ebay yingtray ootay includeyay essagemay oardbay ormattedfay inkslay.  Inkslay ouldshay otnay ebay ormattedfay ikelay isthay.',
			'error_module_missing_title' => '{perl_module} Erlpay Odulemay Otnay Installedyay',
			'error_module_missing_no_config_file' => 'Installyay ethay {perl_module} odulemay oryay ooday otnay useyay ethay onfigurationcay ilefay eaturefay',
			'error_module_missing_no_captcha' => 'Installyay ethay {perl_module} odulemay oryay ooday otnay useyay ethay aptchacay eaturefay',
			'error_bad_config_file_title' => 'Ouldcay Otnay Eadray Onfigurationcay Ilefay',
			'error_bad_config_file' => 'Eckchay onfigurationcay ilefay existenceyay, ermissionspay, andyay alidityvay ofyay XML; oryay ooday otnay useyay ayay onfigurationcay ilefay.',
			'error_template_file_problem' => 'Ethay emplatetay ilefay ouldcay otnay ebay openedyay.',
			'field_captcha_error' => 'Aptchacay oblempray',
			'contact_administrator_name' => 'administratoryay',
			'field_email_default' => 'obodynay',
			# Configuration examples
			'contact_customer_support_name' => 'Ustomercay Upportsay',
			'contact_customer_support_email' => 'upportsay@ouyayrsite.tld',
			'contact_postmaster_name' => 'ostmasterpay',
			'field_onephay_error' => 'Ethay onephay umbernay ouyay enteredyay oesday otnay appearyayyay ootay ebay alidvay.',
			'field_onephay_description' => 'Onephay umbernay:',
			'field_fax_error' => 'Ethay axfay umbernay ouyay enteredyay oesday otnay appearyay ootay ebay alidvay.',
			'field_fax_description' => 'Axfay Umbernay:',
			'field_address_error' => 'Easeplay enteryay ouyayr addressyay.',
			'field_address_description' => 'Addressyay:',
			'field_city_error' => 'Ouryay itycay oesday otnay appearyay ootay ebay alidvay.',
			'field_city_description' => 'Itycay:',
			'field_state_error' => 'Easeplay oosechay ouyayr atestay.',
			'field_state_description' => 'Atestay:',
			'field_zip_error' => 'Ouryay ipcodezay oesday otnay appearyay ootay ebay alidvay.',
			'field_zip_description' => 'Ipcodezay:',
			'field_color_required' => '^(?:Edray|Orangeyay|Ellowyay|Eengray|Ueblay|Urplepay|Ackblay|Itewhay)$',
			'field_color_error' => 'Easeplay oosechay ayay olorcay.',
			'field_color_description' => 'Choose ayay olorcay:',
			'field_vegetable_required' => '^(?:|Orncay|Easpay|Eansbay|Arrotscay|Occolibray)$',
			'field_vegetable_error' => 'Easeplay oosechay ayay alidvay egetablevay.',
			'field_vegetable_description' => 'Ichwhay (ifyay anyay) isyay ouyayr avoritefay egetablevay:',
			'field_letter_required' => '^(?:Ayay|Byay|Cyay|Dyay)$',
			'field_letter_error' => 'Easeplay oosechay onyay ofyay ethay ourfay etterslay.',
			'field_letter_description' => 'Oosechay ayay etterlay (Cyay isyay electedsay ybay efaultday):',
			'field_letter_selected' => 'Cyay',
			'field_yes_no_required' => '^(?:esyay|onay)$',
			'field_yes_no_error' => 'Easeplay answeryay ethay esyay/onay estionquay',
			'field_yes_no_description' => 'Esyay or onay:',
			'field_true_false_required' => '^(?:uetray|alsefay)$',
			'field_true_false_error' => 'Easeplay answeryay ethay uetray/alsefay estionquay',
			'field_true_false_description' => 'Uetray or alsefay (alsefay isyay electedsay ybay efaultday):',
			'field_true_false_selected' => 'alsefay',
			'field_vegetable2_required' => '^(?:|Ettucelay|Omatotay|Usselbray Routspay)$',
			'field_about_error' => 'Easeplay enteryay atwhay isthay essagemay isyay aboutyay.',
			'field_about_description' => 'What isyay isthay essagemay aboutyay:',
			'field_about_default' => 'Emailyay',
		},
	};

	# These settings are here for backwards compatability
	# It is better to modify the translations directly
	$settings->{'input_page_title'} = 'input_page_title';
	$settings->{'sent_page_title'} = 'sent_page_title';
}

#=====================================================================
# You need to know Perl to and have a strong stomach to
# modify much of anything below this line

&initConstants();
&settings();
&loadConfiguration();
&loadTemplate();
&parseInput();
&createMaps();
&sanityCheck();
&composeEmail();
&previewMessage();
&sendEmail();
&sentPage();

sub initConstants {

	$settings = {};

	$translations = {};

	# initialize the path to something safe so we can later call sendmail
	$ENV{'PATH'} = '/bin:/usr/bin:/usr/local/bin';

	if (&safeHeader($ENV{'PATH_INFO'}) eq '/contactformicon.png'){
		&contactformicon();
	}

	# denotes that no description is desired.
	$NO_DESCRIPTION = "-";

	# Version number of this software.
	$VERSION = "4.03.01";

	# Reqular expression building blocks
	$LETTER = "[a-zA-Z]";
	$DIGIT = "[0-9]";
	$DOSEOL = "(?:[\r][\n])";
	$EOL = "(?:[\r\n]|$DOSEOL)";
	$LETTER_DIGIT = "[0-9a-zA-Z]";
	$LETTER_DIGIT_HYPHEN = "(?:[0-9a-zA-Z-])";
	$HEX_DIGIT = "(?:[0-9a-fA-F])";
	$QUOTEDSTRING = "(?:[\\\"](?:[^\\\"]|(?:[\\][\\\"]))*[\\\"])";
	$ATOM = "(?:[\\!\\#-\\\\\\'\\*\\+\\-\\/-9\\=\\?A-Z\\^-\\~]+)";
	$SUBDOMAIN = "(?:" . $LETTER_DIGIT . "(?:" . $LETTER_DIGIT_HYPHEN . "*" . $LETTER_DIGIT . ")?)";
	$WORD = "(?:" . $ATOM . "|" . $QUOTEDSTRING . ")";
	$DOMAIN = "(?:" . $SUBDOMAIN . "(?:[\\.]" . $SUBDOMAIN . ")+)";
	$LOCALPART = "(?:" . $WORD . "(?:[\\.]" . $WORD . ")*)";
	$EMAIL = "(?:" . $LOCALPART . "[\\@]" . $DOMAIN . ")";
	$PHONE_DIGIT = "[\\.\\-\\(\\)\\+\\ Xx]*";
	$PHONE = "(?:(?:" . $PHONE_DIGIT . $DIGIT . "){10,20})";
	$PHONE_NO_AREA_CODE = "(?:(?:" . $PHONE_DIGIT . $DIGIT . "){7,20})";
	$ZIPCODE = "(?:" . $DIGIT . "{5}(?:[\\-]" . $DIGIT . "{4})?)";
	$PRICE = "(?:" . $DIGIT . "+(?:[\\.]" . $DIGIT . "{2})?)|(?:[\\.]" . $DIGIT . "{2})";
	$FLOAT = "(?:" . $DIGIT . "+(?:[\\.]" . $DIGIT . "*)?)|(?:[\\.]" . $DIGIT . "+)";
	$INTEGER = "(?:" . $DIGIT . "+)";

	# Some recommended regular expressions
	$SOMETHING = ".+";
	$ANYTHING = ".*";
	$ONE_LINE_REQUIRED = "^(?:(?:[^\\n\\r])+)\$";
	$ONE_LINE_OPTIONAL = "^(?:(?:[^\\n\\r])*)\$";
	$ZIPCODE_REQUIRED = "^" . $ZIPCODE . "\$";
	$ZIPCODE_OPTIONAL = "^(?:" . $ZIPCODE . "?)\$";
	$PHONE_REQUIRED = "^" . $PHONE . "\$";
	$PHONE_OPTIONAL = "^(?:" . $PHONE . "?)\$";
	$PHONE_NO_AREA_CODE_REQUIRED = "^" . $PHONE_NO_AREA_CODE . "\$";
	$PHONE_NO_AREA_CODE_OPTIONAL = "^(?:" . $PHONE_NO_AREA_CODE . "?)\$";
	$EMAIL_REQUIRED = "^" . $EMAIL . "\$";
	$EMAIL_OPTIONAL = "^(?:" . $EMAIL . "?)\$";
	$PRICE_REQUIRED = "^" . $PRICE . "\$";
	$PRICE_OPTIONAL = "^(?:" . $PRICE . "?)\$";
	$FLOAT_REQUIRED = "^" . $FLOAT . "\$";
	$FLOAT_OPTIONAL = "^(?:" . $FLOAT . "?)\$";
	$INTEGER_REQUIRED = "^" . $INTEGER . "\$";
	$INTEGER_OPTIONAL = "^(?:" . $INTEGER . "?)\$";
	$BLANK = "^\$";
}

sub loadConfiguration(){
	return if (! defined $settings->{'configuration_file'} or $settings->{'configuration_file'} eq "");

	my $xmlmodule = "XML::Simple";
	eval "use $xmlmodule";
	if ($@) {
		&errorPage(
			&trans('error_module_missing_title',{'perl_module'=>$xmlmodule}),
			&trans('error_module_missing_no_config_file',{'perl_module'=>$xmlmodule})
		);
	}
	my $xmlsimple = $xmlmodule->new(forcearray => 1, keyattr => ['Aliases','FormFields','Translations']);
	my $xmlconf;
	eval {
		$xmlconf = $xmlsimple->XMLin($settings->{'configuration_file'});
	};
	if ($@) {
		&errorPage(
			&trans('error_bad_config_file_title'),
			&trans('error_bad_config_file')
		);
	}

	if ($xmlconf->{Aliases}){
		$Aliases = [];
		if ($xmlconf->{Aliases}->[0] and $xmlconf->{Aliases}->[0]->{Alias}){
			foreach my $alias(@{$xmlconf->{Aliases}->[0]->{Alias}}){
				my $name =  $alias->{name};
				my $email = $alias->{content};
				$email = &safeHeader($ENV{'SERVER_ADMIN'}) if ($email eq "SERVER_ADMIN");
				push(@$Aliases, $name);
				push(@$Aliases, $email);
			}
		}
	}

	if ($xmlconf->{Setting}){
		foreach my $setting(@{$xmlconf->{Setting}}){
			my $name = $setting->{name};
			if ($name){
				my $value = $setting->{content};
				$value='' if (!$value);
				if (defined $ENV{'SCRIPT_NAME'}){
					my $escapedScript = &escapeHTML($ENV{'SCRIPT_NAME'});
					$value =~ s/SCRIPT_NAME_ESCAPED/$escapedScript/g;
				}
				$value = &trimEachLine($value);
				$settings->{$name} = $value;
			}
		}
	}

	if ($xmlconf->{DisallowedText}){
		$disallowed_text = {};
		if ($xmlconf->{DisallowedText}->[0] and $xmlconf->{DisallowedText}->[0]->{Disallow}){
			foreach my $disallow(@{$xmlconf->{DisallowedText}->[0]->{Disallow}}){
				my $regex =  &trimEachLine($disallow->{content});
				my $message = $disallow->{message};
				$disallowed_text->{$regex} = $message;
			}
		}
	}

	if ($xmlconf->{Translations}){
		if ($xmlconf->{Translations}->[0] and $xmlconf->{Translations}->[0]->{Language}){
			foreach my $lang(@{$xmlconf->{Translations}->[0]->{Language}}){
				my $langname = $lang->{name};
				$translations->{$langname} = {} if (! exists $translations->{$langname});
				foreach my $translation (@{$lang->{Translation}}){
					my $content = "";
					$content = $translation->{'content'} if (exists $translation->{'content'});
					$translations->{$langname}->{$translation->{'key'}} = $content;
				}
			}
		}
	}

	if ($xmlconf->{FormFields}){
		$FormFields = [];
		if ($xmlconf->{FormFields}->[0] and $xmlconf->{FormFields}->[0]->{Field}){
			foreach my $field(@{$xmlconf->{FormFields}->[0]->{Field}}){
				my $name = $field->{name};
				my $required = &trimEachLine($field->{content});
				$required =~ s/\$SOMETHING/$SOMETHING/g if ($required);
				$required =~ s/\$ANYTHING/$ANYTHING/g if ($required);
				$required =~ s/\$ONE_LINE_REQUIRED/$ONE_LINE_REQUIRED/g if ($required);
				$required =~ s/\$ONE_LINE_OPTIONAL/$ONE_LINE_OPTIONAL/g if ($required);
				$required =~ s/\$ZIPCODE_REQUIRED/$ZIPCODE_REQUIRED/g if ($required);
				$required =~ s/\$ZIPCODE_OPTIONAL/$ZIPCODE_OPTIONAL/g if ($required);
				$required =~ s/\$PHONE_REQUIRED/$PHONE_REQUIRED/g if ($required);
				$required =~ s/\$PHONE_OPTIONAL/$PHONE_OPTIONAL/g if ($required);
				$required =~ s/\$PHONE_NO_AREA_CODE_REQUIRED/$PHONE_NO_AREA_CODE_REQUIRED/g if ($required);
				$required =~ s/\$PHONE_NO_AREA_CODE_OPTIONAL/$PHONE_NO_AREA_CODE_OPTIONAL/g if ($required);
				$required =~ s/\$EMAIL_REQUIRED/$EMAIL_REQUIRED/g if ($required);
				$required =~ s/\$EMAIL_OPTIONAL/$EMAIL_OPTIONAL/g if ($required);
				$required =~ s/\$PRICE_REQUIRED/$PRICE_REQUIRED/g if ($required);
				$required =~ s/\$PRICE_OPTIONAL/$PRICE_OPTIONAL/g if ($required);
				$required =~ s/\$FLOAT_REQUIRED/$FLOAT_REQUIRED/g if ($required);
				$required =~ s/\$FLOAT_OPTIONAL/$FLOAT_OPTIONAL/g if ($required);
				$required =~ s/\$INTEGER_REQUIRED/$INTEGER_REQUIRED/g if ($required);
				$required =~ s/\$INTEGER_OPTIONAL/$INTEGER_OPTIONAL/g if ($required);
				$required =~ s/\$BLANK/$BLANK/g if ($required);
				my $error = $field->{error};
				my $type = $field->{type};
				my $description = $field->{description};
				$description =~ s/\$NO_DESCRIPTION/$NO_DESCRIPTION/g if($description);
				my $enabled = $field->{enabled};
				my $default = $field->{default};
				my $selected = $field->{selected};
				my $special = $field->{special};
				my $show_in_message = $field->{show_in_message};
				push (@$FormFields, $name);
				push (@$FormFields, {
					'required' =>  $required,
					'error' =>  $error,
					'type' =>  $type,
					'description' =>  $description,
					'enabled' =>  $enabled,
					'default' =>  $default,
					'selected' =>  $selected,
					'special' =>  $special,
					'show_in_message' =>  $show_in_message,
				});
			}
		}
	}
}

sub trimEachLine(){
	my ($s) = @_;
	return '' if (!$s);
	$s =~ s/^[ \t\n\r]+//g;
	$s =~ s/[ \t\n\r]+$//g;
	$s =~ s/[\n \t\r]*\n[\n \t\r]*/\n/g;
	return $s;
}

sub loadTemplate(){
	$template_error = "";
	if (defined $settings->{'page_template_file'} and $settings->{'page_template_file'} ne ""){
		if (!open(TEMPLATE, &trans($settings->{'page_template_file'}))){
			$template_error = "<div class=\"contactform cf_error\">".&trans('error_template_file_problem')."</div>\n";
			return;
		}
		$settings->{'page_template'} = join("", <TEMPLATE>);
		close(TEMPLATE);
	}
}

sub createOrderedMap(){
	my ($arr, $keytransformfunction) = @_;
	my $orderarr = [];
	my $hash = {};
	my $key;
	foreach my $value (@$arr){
		if ($key){
			$hash->{$key} = $value;
			undef $key;
		} else {
			$key = $keytransformfunction->($value);
			push(@$orderarr, $key);
		}
	}
	return ($orderarr, $hash);
}

sub createMaps {
	# Since hash maps are not ordered, Aliases and Form_Fields
	# Are declared as arrays.  We need to create two data structures
	# from each.  The first is an ordered key list, the second is an
	# unordered map

	($AliasesOrdered,$AliasesMap) = &createOrderedMap($Aliases,\&trans);

	$field_name_to = '';
	$field_name_from_email = '';
	$field_name_from_name = '';
	$field_name_subject = '';
	$field_name_regarding = '';
	$field_name_referrer = '';

	$FieldMap = {};
	my $key;
	foreach my $value (@$FormFields){
		if ($key){
			my $field = $value;
			if (! defined $field->{"enabled"} or $field->{"enabled"} != 0){
				push(@Field_Order, $key);
				if (defined $field->{"special"}){
					my $special = $field->{"special"};
					if ($special eq "to"){
						$field_name_to = $key;
					} elsif ($special eq "from"){
						$field_name_from_email = $key;
					} elsif ($special eq "name"){
						$field_name_from_name = $key;
					} elsif ($special eq "subject"){
						$field_name_subject = $key;
					} elsif ($special eq "regarding"){
						$field_name_regarding = $key;
					} elsif ($special eq "referrer"){
						$field_name_referrer = $key;
					}
				}
				if (defined $field->{"default"}){
					# 'default' is a synonym for 'selected', just copy it over
					$field->{"selected"} = $field->{"default"};
				}
				$FieldMap->{$key} = $field;
			}
			undef $key;
		} else {
			$key = $value;
		}
	}

	# Put the referrer header into the map if it is not there already
	if ($field_name_referrer ne "" and $FieldMap->{$field_name_referrer} and ! exists $SubmittedData->{$field_name_referrer}){
		if (defined $ENV{'HTTP_REFERER'}){
			$SubmittedData->{$field_name_referrer} = $ENV{'HTTP_REFERER'};
		} else {
			$SubmittedData->{$field_name_referrer} = "-";
		}
	}
}

sub errorPage {
	my ($title, $body) =  @_;
	&outputPage(
		$title,
		"",
		"",
		"<span style=\"color:red\">$body</span>\n"
	);

}

sub parseInput {
	my ($pair, @pairs, $buffer);

	if ($settings->{'recaptcha_public_key'} and $settings->{'recaptcha_private_key'}){
		my $captchamodule = "Captcha::reCAPTCHA";
		eval "use $captchamodule";
		if ($@) {
			&errorPage(
				&trans('error_module_missing_title',{'perl_module'=>$captchamodule}),
				&trans('error_module_missing_no_captcha',{'perl_module'=>$captchamodule})
			);
		}
		$captcha = $captchamodule->new();
	}

	if (&safeHeader($ENV{'REQUEST_METHOD'}) eq 'GET'){
		@pairs = split(/&/, $ENV{'QUERY_STRING'});
	} elsif (&safeHeader($ENV{'REQUEST_METHOD'}) eq 'POST'){
		read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
		@pairs = split(/&/, $buffer);
	} elsif ($ENV{'SERVER_NAME'}){
		&inputPage(&trans('error_get_post_only'));
	}

	foreach $pair (@pairs){
		if ($pair =~ /([^\=]+)(?:\=(.*))?/){

			my $name = $1;
			$name =~ tr/+/ /;
			$name =~ s/%($HEX_DIGIT{2})/pack("C", hex($1))/eg;
			$name =~ tr/\0//d;

			my $value = "";
			if ($2){
				$value = $2;
				$value =~ tr/+/ /;
				$value =~ s/%($HEX_DIGIT{2})/pack("C", hex($1))/eg;
				$value =~ tr/\0//d;
			}

			$SubmittedData->{$name} = $value;
		}
	}
}

sub getRequired {
	my ($key) = @_;
	return &trans($FieldMap->{$key}->{"required"}) if (defined $FieldMap->{$key}->{"required"});
	return "" if (&getType($key) eq "select" || &getType($key) eq "radio");
	return $ANYTHING;
}

sub getError {
	my ($key) = @_;
	return &trans($FieldMap->{$key}->{"error"}) if (defined $FieldMap->{$key}->{"error"});
	return &trans('error_generic_field', {'field_key'=>$key});
}

sub getSpecial {
	my ($key) = @_;
	return $FieldMap->{$key}->{"special"} if (defined $FieldMap->{$key}->{"special"});
	return undef;
}

sub getShowInMessage {
	my ($key) = @_;
	return 1 if &isAffirmative($FieldMap->{$key}->{"show_in_message"});
	return undef;
}


sub getType {
	my ($key) = @_;
	if ($key eq $field_name_to){
		return "select" if (scalar(@$AliasesOrdered) > 1);
		return "hidden";
	}
	return $FieldMap->{$key}->{"type"} if (defined $FieldMap->{$key}->{"type"});
	return "text";
}

sub getSelected {
	my ($key) = @_;
	return &trans($FieldMap->{$key}->{"selected"}) if (defined $FieldMap->{$key}->{"selected"});
	return undef;
}

sub getDescription {
	my ($key) = @_;
	return &trans($FieldMap->{$key}->{"description"}) if (defined $FieldMap->{$key}->{"description"});
	return "$key:";
}

sub isDefined(){
	my ($key) = @_;
	return defined($SubmittedData->{$key});
}

sub getSelection {
	my ($key) = @_;
	return $SubmittedData->{$key} if (defined($SubmittedData->{$key}));
	return &getSelected($key) if (&getSelected($key));
	return "";
}

sub sanityCheck {

	# Check the referrer
	my $allowedReferers = $settings->{'allowedReferers'};
	if (&safeHeader($ENV{'HTTP_REFERER'}) && &safeHeader($ENV{'HTTP_REFERER'}) !~ /$allowedReferers/g){
		&inputPage(&trans('error_bad_referrer',{'referrer'=>&escapeHTML($ENV{'HTTP_REFERER'})}));
	}

	my $some_required_field_present = 0;
	my $errorCount = 0;
	my %errorHash = ();

	my @field_keys = &getOrderedFields();
	foreach my $key (@field_keys){
		my $required_value = &getRequired($key);
		my $data = &getSelection($key);
		my $form_type = &getType($key);
		$errorHash{$key} = "";
		if ($data !~ /$required_value/g){
			if(&isDefined($key)){
				$errorCount++;
				$errorHash{$key} = &getError($key);
			}
		} elsif (&isDefined($key) && $form_type ne 'hidden'){
			$some_required_field_present = 1;
		}

		foreach my $disallow_check (keys(%$disallowed_text)){
			if ($data =~ /$disallow_check/){
				$errorCount++;
				$errorHash{$key} .= &trans($disallowed_text->{$disallow_check});
			}
		}
	}
	if (!($some_required_field_present) or defined($SubmittedData->{"prefill"})){
		&inputPage('', &trans('input_page_instructions'));
	}

	foreach my $key (@field_keys){
		if (&getType($key) eq "trap" and "trap" and !&isDefined($key)){
			$errorCount++;
			$errorHash{$key} .=  &getError($key);
		}
	}
	if ($errorCount > 0){
		my $errorMessage = &getCorrectionsRequiredText($errorCount);
		&inputPage($errorMessage, "", "", \%errorHash);
	}

	if ($captcha and !&messagePreviewSubmitted()){
		$captchaResult = $captcha->check_answer(
			$settings->{'recaptcha_private_key'},
			$ENV{'REMOTE_ADDR'},
			$SubmittedData->{"recaptcha_challenge_field"},
			$SubmittedData->{"recaptcha_response_field"}
		);
		if (!$captchaResult->{is_valid}){
			$errorHash{"captcha"} = &trans('field_captcha_error');
			&inputPage(&getCorrectionsRequiredText(1), "", "", \%errorHash, 1);
		}
	}

	if ((!$SubmittedData->{$field_name_to}) || $SubmittedData->{$field_name_to} eq ""){
		&inputPage('', &trans('input_page_instructions'));
	} else {
		my $recipent = $SubmittedData->{$field_name_to};
		if ((!$AliasesMap->{$recipent})){
			&inputPage(&trans('error_bad_recipient'));
		}
	}
}

sub getCorrectionsRequiredText(){
	my ($errorCount) = @_;
	return &trans('error_correction_required') if ($errorCount == 1);
	return &trans('error_corrections_required');
}

sub getFromEmail(){
	if ($field_name_from_email and $FieldMap->{$field_name_from_email}){
		my $email = &getSelection($field_name_from_email);
		return $email if ($email);
	}
	return &trans('field_email_default');
}

sub getFromName(){
	return &getSelection($field_name_from_name) if ($field_name_from_name and $FieldMap->{$field_name_from_name});
	return undef;
}

sub getFrom(){
	my $email = &getFromEmail();
	my $name = &getFromName();
	return "$name <$email>" if ($name);
	return $email;
}

sub getFromSender(){
	my $email = &getSenderEmail();
	my $name = &getFromName();
	return "$name (via contact form) <$email>" if ($name);
	return $email;
}

sub getSenderEmail(){
	return &getToEmail() if ($settings->{'sender_email'} !~ /\@/);
	return $settings->{'sender_email'};
}

sub useSender(){
	return 1 if ($settings->{'sender_email'} eq "");
	return 1 if ($settings->{'sender_email'} =~ /\@/);
	return 0;
}

sub getTo(){
	my ($email) = @_;
	my $name = &getToName();
	return "$name <$email>" if ($name);
	return $email;
}

sub getToName(){
	return &getSelection($field_name_to) if ($field_name_to and $FieldMap->{$field_name_to});
	return undef;
}

sub getSubject(){
	my $subject = "";
	$subject .= &trans($settings->{'subject_prepend'})." " if ($settings->{'subject_prepend'});
	$subject .= &getSelection($field_name_subject) if ($field_name_subject and $FieldMap->{$field_name_subject});
	$subject .= &trans('field_subject_default') if (!$subject);
	return $subject;
}

sub getRegarding(){
	return &getSelection($field_name_regarding) if ($field_name_regarding and $FieldMap->{$field_name_regarding});
	return undef;
}

sub getSubjectAndRegarding(){
	my $subject = &getSubject();
	my $regarding = &getRegarding();
	return "$subject ($regarding)" if ($regarding);
	return $subject;
}

sub isAffirmative(){
	my ($s) = @_;
	return 0 if (!$s);
	return 1 if ($s =~ /^(?:1|true|t|yes|y)$/);
	return 0;
}

sub includeFieldInEmailBody(){
	my ($key) = @_;
	return 0 if (&getType($key) eq "trap");
	return &getShowToInMessage() if ($key eq $field_name_to);
	return &getShowInMessage($key) if (&getSpecial($key));
	return 1;
}

sub getShowToInMessage(){
	return 1 if (&getShowInMessage($field_name_to));
	return 1 if (&isAffirmative($settings->{'show_to_in_message'}));
	return 0 if ('multiple' ne $settings->{'show_to_in_message'});
	return 1 if (&getToEmail() =~ /,/);
	return 0;
}

sub composeEmail {
	my @field_keys = &getOrderedFields();
	my $needsnewline=-1;
	foreach my $key (@field_keys){
		if (&includeFieldInEmailBody($key)){
			my $surroundfieldwithnewlines = 0;
			my $value = &getSelection($key);
			my $mail_description = &getDescription($key);
			if ($mail_description eq $NO_DESCRIPTION){
				$mail_description = "";
				$surroundfieldwithnewlines = 1;
			} elsif ($value =~ /[\r\n]/){
				$mail_description .= "\n";
				$surroundfieldwithnewlines = 1;
			} else {
				$mail_description .= " ";
			}
			if ($needsnewline >= 0){
				$mail_message .= "\n" if ($needsnewline or $surroundfieldwithnewlines);
			}
			$mail_message .= $mail_description;
			$mail_message .= &getSelection($key)."\n";
			$needsnewline = $surroundfieldwithnewlines;
		}
	}
}

sub getToEmail(){
	return &trans($AliasesMap->{&getSelection($field_name_to)},{'server_admin'=>&safeHeader($ENV{'SERVER_ADMIN'})});
}

sub sendEmail {
	my @to_address_list = split(/,/,&getToEmail());
	foreach my $to_address (@to_address_list){
		open(MAIL,"|".$settings->{'sendmail'});
		print MAIL "To: ".&safeHeader(&getTo($to_address))."\n";
		if (&useSender()){
			print MAIL "From: ".&safeHeader(&getFromSender())."\n";
			print MAIL "Sender: ".&safeHeader(&getSenderEmail())."\n";
			print MAIL "Reply-To: ".&safeHeader(&getFrom())."\n";
		} else {
			print MAIL "From: ".&safeHeader(&getFrom())."\n";
		}
		print MAIL "Subject: ".&safeHeader(&getSubjectAndRegarding())."\n";
		print MAIL "Content-Type: text/plain; charset=".&safeHeader($settings->{'charset'})."\n";
		print MAIL "X-Mailer: ContactForm/".&safeHeader($VERSION)." (http://ostermiller.org/contactform/)\n";
		print MAIL "X-Server-Name: ".&safeHeader($ENV{'SERVER_NAME'})."\n";
		print MAIL "X-Server-Admin: ".&safeHeader($ENV{'SERVER_ADMIN'})."\n";
		print MAIL "X-Script-Name: ".&safeHeader($ENV{'SCRIPT_NAME'})."\n";
		print MAIL "X-Path-Info: ".&safeHeader($ENV{'PATH_INFO'})."\n";
		print MAIL "X-Remote-Host: ".&safeHeader($ENV{'REMOTE_HOST'})."\n";
		print MAIL "X-Remote-Addr: ".&safeHeader($ENV{'REMOTE_ADDR'})."\n";
		print MAIL "X-Remote-User: ".&safeHeader($ENV{'REMOTE_USER'})."\n";
		print MAIL "X-HTTP-User-Agent: ".&safeHeader($ENV{'HTTP_USER_AGENT'})."\n";
		print MAIL "X-HTTP-Referer: ".&safeHeader($ENV{'HTTP_REFERER'})."\n";
		if ($field_name_referrer ne ""){
			print MAIL "X-First-HTTP-Referer: ".&safeHeader(&getSelection($field_name_referrer))."\n";
		}
		print MAIL $mail_message;
		close (MAIL);
	}
}

sub previewRequired(){
	return 1 if ($settings->{'require_preview'} == 1);
	return 0;
}

sub previewAllowed(){
	return 1 if ($settings->{'require_preview'} != 0);
	return 0;
}

sub previewMessage(){
	return if (!&previewAllowed());
	return if (&messageSendSubmitted());
	&inputPage('',&trans('preview_page_instructions'),&getMessageForWebDisplay());
}

sub getMessageForWebDisplay(){
	my $s = "";
	$s .= &trans('email_header_to')." ".&getSelection($field_name_to)."\n" if (!getShowToInMessage());
	$s .= &trans('email_header_from')." ".&getFrom()."\n" if (!getShowInMessage($field_name_from_name) and !getShowInMessage($field_name_from_email));
	$s .= &trans('email_header_subject')." ".&getSubjectAndRegarding()."\n" if (!getShowInMessage($field_name_subject) and !getShowInMessage($field_name_regarding));
	$s .= "\n";
	$s .= $mail_message;
	return &textToHTML($s);
}

sub sentPage {
	my $javascript = ""; # No javascript

	if ($settings->{'redirect_url_sent'} ne ""){
		my $url = &trans($settings->{'redirect_url_sent'});
		if ($settings->{'redirect_delay_sent'} == 0){
			&redirect($url);
		} else {
			$javascript = "<meta http-equiv=\"refresh\" content=\"".$settings->{'redirect_delay_sent'}.";url=$url\">\n"
		}
	}

	my $sentthankyou = &trans('sent_page_thank_you');
	$sentthankyou = "<div class=\"contactform cf_thankyou\">$sentthankyou</div>" if ($sentthankyou);

	&outputPage(
		&trans($settings->{'sent_page_title'}),
		$settings->{'sent_page_css'},
		$javascript,
		$sentthankyou."<div class=\"contactform cf_sent\">".&getMessageForWebDisplay()."</div>"
	);
}

sub redirect {
	my ($url) = @_;
	print "Location: $url\n\n";
	exit 0;
}

sub inputPage {
	my ($error, $instructions, $preview, $fieldErrors, $allowSendAnyway) = @_;
	my $haserror = 1;
	if (!defined($error) or $error eq ""){
		$error = "";
		$haserror = 0;
	}
	my %FieldErrorsHash = ();
	if (defined($fieldErrors)){
		%FieldErrorsHash = %$fieldErrors;
	}

	if (!defined($instructions)){
		$instructions = "";
	} elsif ($instructions){
		$instructions="<div class=\"contactform cf_instructions\" id=\"cf_instructions\">$instructions</div>"
	}

	if (!defined($preview)){
		$preview = "";
	} elsif ($preview){
		$preview="<div class=\"contactform cf_preview\">$preview</div>"
	}

	my (@orderedKeys, $key, $form_html, $script_call, $alias_selected, $client_side_check_script);

	my $errorStyle=" style=\"display:none;\"";
	if ($error ne ""){
		$errorStyle="";
	}

	# Error div must always be present, even with no contents, for javascript output
	$error="<div id=\"cf_global_error\"$errorStyle class=\"contactform cf_error\">$error</div>";

	$script_call = '';
	if ($settings->{'use_client_side_verification'}){
		$script_call="onSubmit=\"return cfCheckForm(this);\"";
	}

	my $submit_method = "POST";
	if (defined $settings->{'submit_method'} and $settings->{'submit_method'} eq "GET"){
		$submit_method = "GET";
	}

	$form_html="<form class=\"contactform\" id=\"cf_form\" action=\"".&escapeHTML($ENV{'SCRIPT_NAME'})."\" method=".$settings->{'submit_method'}." $script_call>\n";
	my $lang = &escapeHTML(&getLanguageParamValue());
	$form_html.= "<input type=\"hidden\" name=\"".$settings->{language_param}."\" value=\"$lang\">\n" if ($lang);
	@orderedKeys = &getOrderedFields();
	foreach $key (@orderedKeys){
		my $html_description = &getDescription($key);
		if ($html_description eq $NO_DESCRIPTION){
			$html_description = '';
		} else {
			$html_description = "<label class=\"contactform cf_fieldlabel\" for=\"$key\">$html_description</label>";
		}
		my $fieldErrorMessage = "";
		my $errorStyle=" style=\"display:none;\"";
		if (defined $FieldErrorsHash{$key} and $FieldErrorsHash{$key} ne ""){
			$fieldErrorMessage = $FieldErrorsHash{$key};
			$errorStyle = "";
		}
		$fieldErrorMessage= "<span id=\"cf_error_$key\"$errorStyle class=\"contactform cf_error cf_fielderror\">".&escapeHTML($fieldErrorMessage)."</span>";
		if ($key eq $field_name_to){
			if (scalar(@$AliasesOrdered) == 1){
				my $alias = $AliasesOrdered->[0];
				$form_html.= "$fieldErrorMessage <input type=\"hidden\" name=\"$field_name_to\" value=\"$alias\">\n";
			} else {
				$form_html.= "<div class=\"contactform cf_field\">".&trans($settings->{'required_marker'})." $html_description $fieldErrorMessage\n<div class=\"contactform cf_userentry\"><select id=\"$key\" name=\"$field_name_to\">\n";
				$form_html.= "<option value\"\"></option>\n";
				foreach my $alias (@$AliasesOrdered){
					if (defined $SubmittedData->{$field_name_to} and $alias eq $SubmittedData->{$field_name_to}){
						$alias_selected = 'selected'
					} else {
						$alias_selected = '';
					}
						$form_html.= "<option value=\"$alias\" $alias_selected>$alias</option>\n";
				}
				$form_html.= "</select></div></div>\n";
			}
		} else {
			my $mark = '';
			my $required_value = &getRequired($key);
			my $data = &getSelection($key);
			my $fieldText = "";
			if (($data !~ /$required_value/g) && $html_description ne ''){
				if (length($fieldText) > 0){
					$fieldText .= " ";
				}
				$fieldText .= &trans($settings->{'required_marker'});
			}
			if (length($html_description) > 0){
				if (length($fieldText) > 0){
					$fieldText .= " ";
				}
				$fieldText .= $html_description;
			}
			if (length($fieldErrorMessage) > 0){
				if (length($fieldText) > 0){
					$fieldText .= " ";
				}
				$fieldText .= $fieldErrorMessage;
			}
			my $form_type=&getType($key);
			if ($form_type eq 'select'){
				$form_html.="<div class=\"contactform cf_field\">$fieldText<div class=\"contactform cf_userentry\"><select id=\"$key\" class=\"contactform cf_select\" name=\"$key\">";
				my $required = &getRequired($key);
				if ("" !~ /$required/ and !&getSelected($key)){
					$form_html.="<option value=\"\"></option>";
				}
				my $selectvalue = $required;
				$selectvalue =~ s/^[\^\(\?\:]+//g;
				$selectvalue =~ s/[\)\$]+$//g;
				my @selectvalues = split(/\|/, $selectvalue);
				foreach my $selectval (@selectvalues){
					$selectval =~ s/^[\(\?\:]+//g;
					$selectval =~ s/[\)]+$//g;
					$selectval = &escapeHTML($selectval);
					my $selected="";
					if ($selectval eq $data){
						$selected = " selected";
					}
					$form_html.="<option value=\"$selectval\"$selected>$selectval</option>";
				}
				$form_html.="</select></div></div>\n";
			} elsif ($form_type eq 'radio'){
				$form_html.="<div class=\"contactform cf_field\">$fieldText<div class=\"contactform cf_userentry\"><span id=\"$key\" class=\"contactform cf_radio\">";
  				my $selectvalue = &getRequired($key);
				$selectvalue =~ s/^[\^\(\?\:]+//g;
				$selectvalue =~ s/[\)\$]+$//g;
				my @selectvalues = split(/\|/, $selectvalue);
				my $radionum=0;
				foreach my $selectval (@selectvalues){
					$selectval =~ s/^[\(\?\:]+//g;
					$selectval =~ s/[\)]+$//g;
					$selectval = &escapeHTML($selectval);
					if ($selectval ne ""){
						my $selected="";
						if ($selectval eq $data){
							$selected = " checked";
						}
						$form_html.="<div class=\"contactform cf_radioselection\"><input type=\"radio\" name=\"$key\" id=\"$key$radionum\" value=\"$selectval\"$selected><label for=\"$key$radionum\">$selectval</label></div>";
						$radionum++;
					}
				}
				$form_html.="</span></div></div>\n";
			} elsif ($form_type eq 'textarea'){
				$form_html.="<div class=\"contactform cf_field\">$fieldText<div class=\"contactform cf_userentry\"><textarea id=\"$key\" class=\"contactform cf_textentry\" wrap=\"virtual\" name=\"$key\">".&escapeHTML($data)."</textarea></div></div>\n";
			} elsif ($form_type eq 'hidden'){
				$form_html.="$fieldErrorMessage <input type=\"hidden\" name=\"$key\" value=\"".&escapeHTML($data)."\">\n";
			} elsif ($form_type eq 'trap'){
				$form_html.="<div class=\"contactform cf_field cf_nt\">$fieldText<div class=\"contactform cf_userentry\"><input id=\"$key\" class=\"contactform cf_textentry\" type=\"text\" name=\"$key\" value=\"".&escapeHTML($data)."\"></div></div>\n";
			} else {
				$form_html.="<div class=\"contactform cf_field\">$fieldText<div class=\"contactform cf_userentry\"><input id=\"$key\" class=\"contactform cf_textentry\" type=\"text\" name=\"$key\" value=\"".&escapeHTML($data)."\"></div></div>\n";
			}
		}
	}
	my $hasSendButton = &hasSendButton($haserror);
	$hasSendButton = 1 if ($allowSendAnyway);
	if ($hasSendButton and $captcha){
		$form_html.="<div class=\"contactform cf_field\"><label class=\"contactform cf_fieldlabel\" for=\"recaptcha_response_field\">";
		$form_html.=&trans($settings->{'required_marker'})." ".&trans('field_captcha_description');
		if (defined $FieldErrorsHash{"captcha"} and $FieldErrorsHash{"captcha"} ne ""){
			$form_html.=" <span id=\"cf_error_captcha\" class=\"contactform cf_error cf_fielderror\">".$FieldErrorsHash{"captcha"}."</span> ";
		}
		$form_html.="</label>\n";
		my $captcha_error=undef;
		$captcha_error = $captchaResult->{error} if ($captchaResult and !$captchaResult->{is_valid});
		$form_html.=$captcha->get_html($settings->{'recaptcha_public_key'}, $captcha_error, undef, {lang=>&getUserLanguage()});
		$form_html.="</div>\n";
	}
	if ($settings->{'require_preview'} eq "1" or $settings->{'require_preview'} eq "2"){
		$form_html.="<input class=\"contactform\" id=\"cf_submit\" type=\"submit\" name=\"".$settings->{'field_name_submit'}."\" value=\"".&escapeHTML(&trans('preview_button'))."\">\n";
	}
	if ($hasSendButton){
		$form_html.="<input class=\"contactform\" id=\"cf_submit\" type=\"submit\" name=\"".$settings->{'field_name_submit'}."\" value=\"".&escapeHTML(&trans('send_button'))."\">\n";
	}
	my $requiredMarkerDescription = &trans('required_marker_description',{required_marker=>&trans($settings->{'required_marker'})});
	if ($requiredMarkerDescription){
		$form_html.="<p class=\"contactform\" id=\"cf_requiredexplain\">$requiredMarkerDescription</p>\n";
	}
	$form_html.="</form>";

	$client_side_check_script = "";
	if ($settings->{'use_client_side_verification'}){
		$client_side_check_script .= "<script language=\"javascript\" type=\"text/javascript\"><!--\n";
		$client_side_check_script .= "function cfRadioSelected(r){\n";
		$client_side_check_script .= "for (i=0;i<r.length;i++) {\n";
		$client_side_check_script .= "if (r[i].checked)return true;\n";
		$client_side_check_script .= "}\n";
		$client_side_check_script .= "return false;\n";
		$client_side_check_script .= "}\n";
		$client_side_check_script .= "function cfErrorOn(k,d,m,s,f,b){\n";
		$client_side_check_script .= "var df=document.getElementById(d);\n";
		$client_side_check_script .= "df.innerHTML=m;\n";
		$client_side_check_script .= "df.style.display=b;\n";
		$client_side_check_script .= "if(s)k.select();\n";
		$client_side_check_script .= "if(f)k.focus();\n";
		$client_side_check_script .= "}\n";
		$client_side_check_script .= "function cfErrorOff(d){\n";
		$client_side_check_script .= "var f=document.getElementById(d);\n";
		$client_side_check_script .= "f.innerHTML='';\n";
		$client_side_check_script .= "f.style.display='none';\n";
		$client_side_check_script .= "}\n";
		$client_side_check_script .= "function cfCheckForm(form){\n";
		$client_side_check_script .= "var major = parseInt(navigator.appVersion);\n";
		$client_side_check_script .= "var agent = navigator.userAgent.toLowerCase();\n";
		$client_side_check_script .= "if (agent.indexOf('msie')!=-1){\n";
		$client_side_check_script .= "major = parseFloat(agent.split('msie')[1]);\n";
		$client_side_check_script .= "}\n";
		$client_side_check_script .= "if (agent.indexOf('mozilla')==0 && major<=4){\n";
		$client_side_check_script .= "// Internet Explorer 4 or Netscape 4 and earlier.\n";
		$client_side_check_script .= "return true;\n";
		$client_side_check_script .= "} else if (agent.indexOf('opera')!=-1){\n";
		$client_side_check_script .= "// Opera doesn't seem to do regular expressions properly.\n";
		$client_side_check_script .= "return true;\n";
		$client_side_check_script .= "}\n";
		$client_side_check_script .= "var ec=0;\n";
		foreach $key (reverse(@orderedKeys)){
			my $formType = &getType($key);
			my $check = "";
			if($formType eq 'hidden'){
				$check = "";
			} elsif ($formType eq "select"){
				my $required = &getRequired($key);
				if ("" !~ /$required/ and !&getSelected($key)){
					$check = "form.$key.selectedIndex == 0";
				} else {
					$check = "";
				}
			} elsif ($formType eq "radio"){
				my $required = &getRequired($key);
				if ("" !~ /$required/ and !&getSelected($key)){
					$check = "!cfRadioSelected(form.$key)"
				} else {
					$check = "";
				}
			} else {
				$check = "!form.$key.value.match(new RegExp('".&escapeJavaScript(&getRequired($key))."', 'g'))";
			}
			if ($check ne ""){
				my $dofocus = "false";
				if ($formType ne "radio"){
					$dofocus = "true";
				}
				my $doselect = "false";
				if ($formType eq "text" or $formType eq "textarea"){
					$doselect = "true";
				}
				$client_side_check_script .= "if ($check){\n";
				$client_side_check_script .= "cfErrorOn(form.$key,'cf_error_$key','".&escapeJavaScript(&getError($key))."',$doselect,$dofocus,'inline');\n";
				$client_side_check_script .= "ec++;\n";
				$client_side_check_script .= "} else {\n";
				$client_side_check_script .= "cfErrorOff('cf_error_$key');\n";
				$client_side_check_script .= "}\n";
			} else {
				$client_side_check_script .= "cfErrorOff('cf_error_$key');\n";
			}
		}
		$client_side_check_script .= "\n";
		$client_side_check_script .= "if(ec>0){\n";
		$client_side_check_script .= "cfErrorOn('','cf_global_error',(ec==1?'".&escapeJavaScript(&getCorrectionsRequiredText(1))."':'".&escapeJavaScript(&getCorrectionsRequiredText(2))."'),false,false,'block');\n";
		$client_side_check_script .= "scroll(0,0);";
		$client_side_check_script .= "return false;\n";
		$client_side_check_script .= "} else {\n";
		$client_side_check_script .= "cfErrorOff('cf_global_error');\n";
		$client_side_check_script .= "return true;\n";
		$client_side_check_script .= "}\n";
		$client_side_check_script .= "}\n";
		$client_side_check_script .= "//--></script>\n";
	}

	&outputPage(
		&trans($settings->{'input_page_title'}),
		$settings->{'input_page_css'},
		$client_side_check_script,
		$instructions.$preview.$error.$form_html
	);
}


sub getUserLanguage(){
	return &getUserLanguages()->[0];
}

sub getLanguageParamValue(){
	return "" if (!$settings->{'language_param'});
	my $value = $SubmittedData->{$settings->{'language_param'}};
	return "" if (!$value);
	return "" if ($value !~ /^[a-zA-Z_]+$/);
	return $value;
}

sub getUserLanguages(){
	return $userLangs if ($userLangs);

	my $allowed;
	if ($settings->{'allowed_languages'}){
		$allowed = {};
		for my $lang (split(/[\,\; ]+/, $settings->{'allowed_languages'})){
			$allowed->{$lang} = 1;
		}
	}
	$userLangs = [];
	my $langSet = {};
	my $langs = "";
	my $byparam = &getLanguageParamValue();
	if ($byparam){
		if (!$allowed or $allowed->{$byparam}){
			push(@$userLangs, $byparam);
		}
	}
	$langs = $ENV{HTTP_ACCEPT_LANGUAGE} if (defined $ENV{HTTP_ACCEPT_LANGUAGE});
	for my $lang (split(/[\,\; ]+/, $langs)){
		if ($lang =~ /^([A-Za-z]{2})(?:[\-\_]([A-Za-z]{2}))?$/){
			my ($l, $c) = ($1, $2);
			$l = lc($l);
			if ($c){
				$c = uc($c);
				if (!$langSet->{"${l}_$c"}){
					if (!$allowed or $allowed->{"${l}_$c"}){
						push(@$userLangs, "${l}_$c");
						$langSet->{"${l}_$c"}=1;
					}
				}
			}
			if (!$langSet->{$l}){
				if (!$allowed or $allowed->{$l}){
					push(@$userLangs, $l);
					$langSet->{$l}=1;
				}
			}
		}
	}
	if (!$langSet->{$settings->{'default_language'}}){
		push(@$userLangs, $settings->{'default_language'});
	}
	return $userLangs;
}

sub trans(){
	my ($key, $vars) = @_;
	return $key if ($key !~ /^[a-z0-9]+_[a-z_0-9]+$/);
	for my $lang (@{&getUserLanguages()}){
		if (exists $translations->{$lang} and exists $translations->{$lang}->{$key}){
			return &messageFormat($translations->{$lang}->{$key}, $vars);
		}
	}
	return $key;
}

sub messageFormat(){
	my ($s, $vars) = @_;
	return $s if (!$vars);
	foreach my $name (keys(%$vars)){
		my $value = $vars->{$name};
		$s =~ s/\{$name\}/$value/g;
	}
	return $s;
}

sub hasSendButton(){
	my ($haserror) = @_;
	return 1 if ($settings->{'require_preview'} eq "0");
	return 1 if ($settings->{'require_preview'} eq "2" );
	return 1 if (!$haserror and &messagePreviewSubmitted());
	return 0;
}

sub messagePreviewSubmitted(){
	return 0 if (!defined $SubmittedData->{$settings->{'field_name_submit'}});
	return 1 if ($SubmittedData->{$settings->{'field_name_submit'}} eq &trans('preview_button'));
	return 0;
}

sub messageSendSubmitted(){
	return 1 if (!defined $SubmittedData->{$settings->{'field_name_submit'}});
	return 1 if ($SubmittedData->{$settings->{'field_name_submit'}} eq &trans('send_button'));
	return 0;
}

sub outputPage(){
	my ($title, $css, $javascript, $content) = @_;

	my $page = &trans($settings->{'page_template'});
	$page =~ s/\$title/$title/g;
	$page =~ s/\$css/$css/g;
	my $icon_link = $settings->{'icon_link'};
	my $copyright_link = $settings->{'copyright_link'};
	$page =~ s/\$javascript/$javascript$icon_link\n$copyright_link/g;
	my $contact_form_link = "<p class=\"contactform\" id=\"cf_version\"><a class=\"contactform cf_link\" href=\"http://ostermiller.org/contactform/\">".&trans('contact_form_version',{'version_number'=>$VERSION})."</a></p>";
	$contact_form_link = "" if (defined $settings->{'contact_form_link'} and "" eq $settings->{'contact_form_link'});
	$contact_form_link = "" if (!$settings->{'show_contact_form_link'});
	$template_error = "" if (!$template_error);
	$page =~ s/\$content/$template_error$content$contact_form_link/g;

	if ($ENV{'SERVER_NAME'}){
		print "Content-type: text/html; charset=",$settings->{'charset'},"\n";
		print "\n";
	}

	print $page;

	exit;
}

# Remove characters that would be unsafe in an email header.
sub safeHeader {
	my ($headerText) = @_;
	if (!defined($headerText)){
		$headerText="";
	}
	$headerText =~ s/[\0\n\r]+/ /g;
	return $headerText;
}

sub safeHeaderName {
	my ($headerText) = @_;
	if (!defined($headerText)){
		$headerText="";
	}
	$headerText =~ s/[\0\n\r\(\)\@\%\<\>]+/ /g;
	return $headerText;
}

# Convert <, >, & and " to their HTML equivalents.
sub escapeHTML {
	my ($value) = @_;
	if (!defined($value)){
		$value="";
	}
	$value =~ s/\&/\&amp;/g;
	$value =~ s/</\&lt;/g;
	$value =~ s/>/\&gt;/g;
	$value =~ s/"/\&quot;/g;
	$value =~ s/'/\&#39;/g;
	return $value;
}

# escape HTML and make text into HTML paragraphs.
sub textToHTML {
	my ($value) = @_;
	if (!defined($value)){
		$value="";
	}
	$value = escapeHTML($value);
	$value =~ s/(\n[\r\n]+)|(\r\n[\r\n]+)|(\r\r[\r\n]*)/<p>/g;
	$value =~ s/[\r\n]+/<br>/g;
	$value =~ s/\<p\>/\n<p>\n/g;
	$value =~ s/\<br\>/<br>\n/g;
	return $value;
}

# put in javascript escape sequences.
sub escapeJavaScript {
	my ($value) = @_;
	if (!defined($value)){
		$value="";
	}
	$value =~ s/\\/\\\\/g;
	$value =~ s/\'/\\'/g;
	$value =~ s/\n/\\n'/g;
	$value =~ s/\r/\\r'/g;
	$value =~ s/\t/\\t'/g;
	return $value;
}

sub getOrderedFields {
	return @Field_Order;
}

sub contactformicon {
	print "Content-type: image/png\n";
	print "\n";
	print "\x89\x50\x4e\x47\x0d\x0a\x1a\x0a\x00\x00\x00\x0d\x49\x48\x44\x52";
	print "\x00\x00\x00\x10\x00\x00\x00\x10\x08\x06\x00\x00\x00\x1f\xf3\xff";
	print "\x61\x00\x00\x01\xbc\x49\x44\x41\x54\x78\x9c\xa5\x92\x4d\x6e\x13";
	print "\x41\x10\x85\xbf\xea\xee\xb1\x31\x72\xe2\xbf\x90\xe4\x0a\x88\x25";
	print "\x87\x60\x83\x60\xc9\x6d\xb8\x0b\x6b\x96\x88\x15\x6b\x8e\x00\x6c";
	print "\xed\x28\x12\xc1\x7f\x33\x4e\x6c\xc7\xe3\xe9\xae\x62\xe1\x38\x8e";
	print "\x09\x28\x20\x6a\xd7\xaa\xf7\x5e\xd7\x7b\x55\xf0\x9f\x25\xef\xde";
	print "\x5f\xbc\xed\x1c\xda\x4b\xef\x39\xaf\xa2\x9c\x95\x6b\x06\x55\x64";
	print "\x20\x22\x83\x5a\x26\x67\xb5\x4c\xa6\xaf\x5f\x3c\x49\x7f\x14\xf8";
	print "\xf8\xe9\xfb\x57\xef\x79\x7a\xd2\x53\xbc\x03\x03\x52\x82\xaa\x12";
	print "\xd6\x11\x4b\x89\xcb\xa4\x72\x9e\x94\x41\x15\xe9\x97\x6b\x19\xac";
	print "\x4a\xfa\x49\xa5\x1f\xbc\x7c\x0b\xe2\x48\xa7\x3d\xe5\xc7\xd4\x71";
	print "\xda\x53\x44\x20\x78\x08\xde\x68\x80\x00\x2d\xb0\x16\xf0\x6c\xfb";
	print "\xab\x1a\xcc\x97\xc2\x70\x22\x9f\x1d\x46\x74\x0e\x8e\x3b\x1b\x11";
	print "\xb3\x87\x7d\xa7\x04\x31\x42\xaf\x6d\x3d\x67\x50\x01\x78\x0f\xbd";
	print "\x96\x32\xca\xe5\x41\x72\x71\x25\x74\x5b\x06\x20\xce\x8c\xb8\x6d";
	print "\x66\x01\xda\x07\xc6\xb8\xf8\xbd\x88\x19\x4c\x66\xc2\x51\xfb\x66";
	print "\x4c\xc1\x39\x90\x78\x17\x54\xcb\xa0\xd9\x30\x86\xd3\xfb\x22\xa3";
	print "\x7c\x43\x96\x5d\xcb\x39\x33\xab\x7e\x05\x2e\x4b\xc1\x7b\x98\xce";
	print "\x76\xc8\x49\x21\xa8\x71\x97\x0c\x86\x06\x33\xf6\x04\xae\x96\x42";
	print "\x70\x70\xd8\x34\xae\x4b\x61\x5c\x08\xde\x41\xe3\x11\x74\x6a\xb6";
	print "\x6f\x01\x2c\x98\xc9\x7a\xfb\x5a\xad\xa1\xaa\xd8\x06\x44\xa3\x6e";
	print "\x64\x1e\x92\x41\x3d\xdb\x60\x0e\x1e\x1b\xb3\xb9\xd0\x6a\xda\x26";
	print "\x03\x35\x16\x00\x55\x84\xd9\x2e\xdd\xdb\x0a\x61\x47\x06\xa8\xd7";
	print "\xc0\x39\x58\x95\xb7\x19\x10\x55\x61\x9c\x3b\x8e\xbb\x7f\x71\x04";
	print "\x37\x53\x5c\x97\x42\x4a\x48\x50\x65\x7d\x31\x71\x9c\x74\x75\x3f";
	print "\xa0\xad\x49\xdb\x5c\x9e\x2a\xa4\x24\x24\x85\xa4\x98\x08\xe5\x28";
	print "\x77\x5f\xc2\xe2\x5a\x3e\x64\xc1\x9e\x0f\x73\x37\x57\x25\x57\xa5";
	print "\x48\x4a\x1e\x93\xe4\x31\x51\xc4\x48\x9e\x94\xdc\x8c\x42\x44\x72";
	print "\xef\x28\x42\x90\x4b\xef\xdd\xe2\xcd\xab\xa3\x7b\x1b\xfc\xe7\xfa";
	print "\x09\xfd\xc8\xe6\x8e\x15\xeb\x74\x06\x00\x00\x00\x00\x49\x45\x4e";
	print "\x44\xae\x42\x60\x82\x00";
	exit;
}
