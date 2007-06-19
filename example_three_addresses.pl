#!/usr/bin/perl -T -w

use strict;

# Contact Form is a Perl script that you can run on your website that will
# allow others to send you email through a web interface.
# See: http://ostermiller.org/contactform/
# Copyright (C) 2002-2007 Stephen Ostermiller
# http://ostermiller.org/contact.pl?regarding=Contact+Form
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# See copying.txt for details.
my ($NO_DESCRIPTION, $version, $LETTER, $DIGIT, $DOSEOL, $EOL, $LETTER_DIGIT,
$LETTER_DIGIT_HYPHEN, $HEX_DIGIT, $QUOTEDSTRING, $ATOM, $SUBDOMAIN, $WORD,
$DOMAIN, $LOCALPART, $EMAIL, $PHONE_DIGIT, $PHONE, $ZIPCODE, $PRICE, $FLOAT,
$INTEGER, $SOMETHING, $ANYTHING, $ONE_LINE_REQUIRED, $ONE_LINE_OPTIONAL,
$ZIPCODE_REQUIRED, $ZIPCODE_OPTIONAL, $PHONE_REQUIRED, $PHONE_OPTIONAL,
$EMAIL_REQUIRED, $EMAIL_OPTIONAL, $PRICE_REQUIRED, $PRICE_OPTIONAL,
$FLOAT_REQUIRED, $FLOAT_OPTIONAL, $INTEGER_REQUIRED, $INTEGER_OPTIONAL);
&initConstants();

# List of email address to which mail can be sent.
# Mail cannot be sent to any email address which is not on this list.
# If a single address is listed, it will be a hidden value on the
# form, otherwise, the user will be presented with a pulldown menu
# of aliases to which email can be sent.
# The addresses listed here are never visible via served web pages.
my @Aliases = (
	'Mr. Duznut Exist','null@ostermiller.com',
	'Mrs. Fig Mint','null@ostermiller.com',
	'Nobody','null@ostermiller.com',
);

# Modify the following to control how the HTML pages look

# Page titles for the input and thank your pages
my $input_page_title = 'Contact Us';
my $sent_page_title = 'Message Sent';

# Extra text (may be html formatted) that will be placed on
# the page before the the form
my $input_page_text = '<p class="contactform cf_message" id="cf_filloutformmessage">Fill out the form below to test contact form.
<span style="color:red;">All messages submitted here will be discarded.</span>
Feel free to play with this form as much as you would like, it is here to
demonstrate how Contact Form works.
If you really need to contact Stephen (the Contact Form author) please use
the contact link at the bottom of the page.</p>
<p>This contact form has three customizations:</p>
<ol>
<li>The recipient list been sent to three email addresses that ignore all incoming messages.</li>
<li>Required preview has been disabled.</li>
<li>A <a href="form.html">template file</a> is used to make it look like the Contact Form web site.</li>
<li>This message is set in the $input_page_text variable.</li>
</ol>';
my $sent_page_text = '<p class="contactform cf_message" id="cf_thankyoumessage">The message you entered was correctly formatted and normally would
have been sent.  However, <span style="color:red;">your message was sent to nobody!</span>
This Contact Form was configured to send email to an address that does not exist so
that you could test Contact Form. If you really need to contact Stephen
(the Contact Form author) please use the contact link at the bottom of the page.</p>';
my $preview_page_text = '<p class="contactform cf_message" id="cf_previewmessage">Please review your message before sending it. Changes can be made below.</p>';

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
my $page_template =
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
# my $page_template_file = "mytemplate.html";
# or
# my $page_template_file = "/home/me/contact.template";
# If this file is set, the file will be read every time this script
# is called, not the most efficient, but very convenient.
# The temlate file must be in the same format as the page_template
# variable above
my $page_template_file = "form.html";

# Link back to contact form.
# You may remove the link by setting this variable to the empty string:
# my $contact_form_link = "";
# If you do remove it, please tell your friends about contact form,
# link to contact form somewhere else, write a blog entry about
# contact form, post in a forum about contact form, or otherwise
# spread the word.
my $contact_form_link = "<p class=\"contactform cf_message\" id=\"cf_version\"><a class=\"contactform cf_link\" href=\"http://ostermiller.org/contactform/\">Contact Form $version</a></p>";

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
# $INTEGER_REQUIRED, $INTEGER_OPTIONAL
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
my @FormFields = (
	'to', {
		'required' => $ONE_LINE_REQUIRED,
		'error' => 'You must specify a recipient.',
		'description' => 'To:',
		# Alias of the address put in the "To:" field of the email.
		'special' => 'to',
	},
	'email', {
		'required' => $EMAIL_REQUIRED,
		'error' => 'The email address you entered does not appear to be valid.',
		'type' => 'text',
		'description' => 'Your email address:',
		# Put in the "From:" field of the email as the email of the person it is from
		'special' => 'from',
	},
	'name', {
		'required' => $ONE_LINE_OPTIONAL,
		'error' => 'You must enter your name.',
		'type' => 'text',
		'description' => 'Your name:',
		# Put in the "From:" field of the email as the name of the person it is from
		'special' => 'name',
	},
	'subject', {
		'required' => $ONE_LINE_REQUIRED,
		'error' => 'You must enter a subject.',
		'type' => 'text',
		'description' => 'Subject:',
		# Put in the "Subject:" field of the email.
		'special' => 'subject',
	},
	'message', {
		'required' => $SOMETHING,
		'error' => 'You must enter a message.',
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
	},
	'referrer', {
		'required' => $ANYTHING,
		'error' => '',
		'type' => 'hidden',
		'description' => $NO_DESCRIPTION,
		# The original referring url.
		'special' => 'referrer',
	},
	# The following fields are disabled examples, remove the 'enabled' => 0 line to use them
	'phone', {
		'required' => $PHONE_OPTIONAL,
		'error' => 'The phone number you entered does not appear to be valid.',
		'type' => 'text',
		'description' => 'Phone Number:',
		'enabled' => 0,
	},
	'fax', {
		'required' => $PHONE_OPTIONAL,
		'error' => 'The fax number you entered does not appear to be valid.',
		'type' => 'text',
		'description' => 'Fax Number:',
		'enabled' => 0,
	},
	'address1', {
		'required' => $ONE_LINE_OPTIONAL,
		'error' => 'Please enter your address.',
		'type' => 'text',
		'description' => 'Address:',
		'enabled' => 0,
	},
	'address2', {
		'required' => $ONE_LINE_OPTIONAL,
		'error' => 'Please enter your address.',
		'type' => 'text',
		'description' => $NO_DESCRIPTION,
		'enabled' => 0,
	},
	'city', {
		'required' => '^(?:[a-zA-Z ]*)$',
		'error' => 'Your city does not appear to be valid.',
		'type' => 'text',
		'description' => 'City:',
		'enabled' => 0,
	},
	'state', {
		'required' => '^(?:AL|AK|AS|AZ|AR|CA|CO|CT|DE|DC|FL|GA|GU|HI|ID|IL|IN|IA|KS|KY|LA|ME|MD|MH|MA|MI|FM|MN|MS|MO|MT|NE|NV|NH|NJ|NM|NY|NC|ND|MP|OH|OK|OR|PW|PA|PR|RI|SC|SD|TN|TX|UT|VT|VA|VI|WA|WV|WI|WY)$',
		'error' => 'Please choose your state.',
		'type' => 'select',
		'description' => 'State:',
		'enabled' => 0,
	},
	'zip', {
		'required' => $ZIPCODE_OPTIONAL,
		'error' => 'Your zipcode does not appear to be valid.',
		'type' => 'text',
		'description' => 'Zipcode:',
		'enabled' => 0,
	},
	'most_basic_question', {
		# uses the default values for required, error, type, and description
		'enabled' => 0,
	},
	'color', {
		# A required select drop down
		'type' => 'select',
		'required' => '^(?:Red|Orange|Yellow|Green|Blue|Purple|Black|White)$',
		'error' => 'Please choose a color.',
		'description' => 'Choose a color:',
		'enabled' => 0,
	},
	'vegetable', {
		# An optional select drop down
		'type' => 'select',
		'required' => '^(?:|Corn|Peas|Beans|Carrots|Broccoli)$',
		'error' => 'Please choose a valid vegetable.',
		'description' => 'Which (if any) is your favorite vegetable:',
		'enabled' => 0,
	},
	'letter', {
		# A select drop down with a pre-filled option
		'type' => 'select',
		'required' => '^(?:A|B|C|D)$',
		'error' => 'Please choose on of the four letters.',
		'description' => 'Choose a letter (C is selected by default):',
		'selected' => 'C',
		'enabled' => 0,
	},
	'yes_no', {
		# required radio buttons
		'type' => 'radio',
		'required' => '^(?:yes|no)$',
		'error' => 'Please answer the yes/no question',
		'description' => 'Yes or no:',
		'enabled' => 0,
	},
	'true_false', {
		# radio buttons with a prefilled option
		'type' => 'radio',
		'required' => '^(?:true|false)$',
		'error' => 'Please answer the true/false question',
		'description' => 'True or false (false is selected by default):',
		'selected' => 'false',
		'enabled' => 0,
	},
	'vegetable2', {
		# optional radio buttons
		'type' => 'radio',
		'required' => '^(?:|Lettuce|Tomato|Brussel Sprouts)$',
		'error' => 'Please choose a valid vegetable.',
		'description' => 'Which (if any) is your favorite vegetable:',
		'enabled' => 0,
	},
);

# The name of the field for submit/preview action
my $field_name_submit = 'do';

# Regular expression describing urls which can host forms
# pointing to this program. The referral URL is generated on the
# client side by the browser. Therefore it useless to prevent
# unauthorized submission by mail software robots. You can
# prevent somebody from reliably hosting, on another server,
# a form pointing to this email software.
	# This form can be used from any site at all.
	my $allowedReferers = '.*';
	# This form can only be used from pages on yoursite.tld
	#my $allowedReferers = '^http[s]?\\:\\/\\/yoursite\\.tld\\/';
	# This form can only be used from pages on the domain or ip address
	#my $allowedReferers = '^http[s]?\\:\\/\\/((yoursite\\.tld)|(127\\.0\\.0\\.1))\\/';
	# This form can only be used from a specific page.
	#my $allowedReferers = '^http[s]?\\:\\/\\/yoursite\\.tld\\/directory\\/page\\.html\\$';

# Regular expressions for text that is not allowed in any fields
my %disallowed_text = (
	"\\<[ \\r\\n\\t]*[Aa][ \\r\\n\\t]","You appear to be trying to include HTML formatted links.  Links should not be formatted like this.",
	"\\[[ \\r\\n\\t]*[Uu][Rr][Ll][ \\r\\n\\t]*\\=","You appear to be trying to include message board formatted links.  Links should not be formatted like this.",
);

# Whether or not users are required to preview
# their message before sending.
# 0 -- preview disabled (allows users to send mail the fastest)
# 1 -- preview required (best for spam prevention)
# 2 -- preview available, but not required  (most choice for users)
my $require_preview = 1;

# The character set for the web site.
my $charset = 'ISO-8859-1';

# Command line program used to send email
# '/usr/lib/sendmail -i -t' almost always works fine
my $sendmail = '/usr/lib/sendmail -i -t';

# Whether or not to include javascript that checks the form
# before it is submitted.
# This is generally good, but it increases the page size, increases the
# complexity of the page, and could alert hackers to the
# regular expressions you are using for verification.
# Set to 0 to disable, 1 to enable.
my $use_client_side_verification = 1;

# This should be either 'POST' or 'GET'
my $submit_method = 'POST';

# Placed next to form elements that must be filled in
my $required_marker = '<span class="contactform cf_required">*</span>';
my $required_marker_note = "<p class=\"contactform cf_message\" id=\"cf_requiredexplain\">$required_marker denotes a required field.</p>";

# Style rules for the input page.
# to put question and answer on the same line use:
# .cf_userentry, .cf_radioselection { display:inline; margin-left:0.25cm; }
my $input_page_css =
'<style>
.cf_error { color:red; }
.cf_textentry { min-width:300px; width:100%; max-width:600px; width:expression(document.body.clientWidth>600?"600px":"auto");}
textarea.contactform { height:4in; }
.cf_required { color:green; }
#cf_version { text-align:right; }
.cf_field { margin-bottom:0.5cm; }
.cf_preview { border:thin black ridge; padding:1cm; max-width:600px; width:expression(document.body.clientWidth>600?"600px":"auto");margin-bottom:1cm;}
</style>';

# Style rules for thank you page
my $sent_page_css =
'<style>
.cf_sent { border:thin black ridge; padding:1cm; max-width:600px; width:expression(document.body.clientWidth>600?"600px":"auto");}
#cf_version { text-align:right; }
</style>';

# Link to favicon, placed in the head after the JavaScript
my $icon_link='<link rel="icon" href="'.&escapeHTML($ENV{'SCRIPT_NAME'}).'/contactformicon.png" type="image/png">';

# Form copyright header placed in the head after the JavaScript
my $copyright_link = '<link rel="copyright" href="http://ostermiller.org/contactform/" type="text/html">';

# Redirect to this url after the message has been sent
# By default there is no redirect.  The url must
# be fully qualified (must start with http://)
# Example: my $redirect_url_sent = "http://example.com/";
my $redirect_url_sent = "";

# Show the sent confirmation for this many seconds before redirecting
# after the message has been sent if the redirect_url_sent has been defined.
# If zero is specified, the message sent confirmation will not
# be shown at all (you can redirect to your own thank you)
my $redirect_delay_sent = 15;

#=====================================================================
# You need to know Perl to and have a strong stomach to
# modify much of anything below this line

my(%SubmittedData, $mail_message, %AliasesMap, @AliasesOrdered,
%FieldMap, @Field_Order, $template_error, $field_name_to,
$field_name_from_email, $field_name_from_name, $field_name_subject,
$field_name_regarding, $field_name_referrer);

&loadTemplate();
&parseInput();
&createMaps();
&sanityCheck();
&composeEmail();
&previewMessage();
&sendEmail();
&sentPage();

sub initConstants {

	# initialize the path to something safe so we can later call sendmail
	$ENV{'PATH'} = '/bin:/usr/bin:/usr/local/bin';

	if (&safeHeader($ENV{'PATH_INFO'}) eq '/contactformicon.png'){
		&contactformicon();
	}

	# denotes that no description is desired.
	$NO_DESCRIPTION = "-";

	# Version number of this software.
	$version = "2.00.02";

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
	$EMAIL_REQUIRED = "^" . $EMAIL . "\$";
	$EMAIL_OPTIONAL = "^(?:" . $EMAIL . "?)\$";
	$PRICE_REQUIRED = "^" . $PRICE . "\$";
	$PRICE_OPTIONAL = "^(?:" . $PRICE . "?)\$";
	$FLOAT_REQUIRED = "^" . $FLOAT . "\$";
	$FLOAT_OPTIONAL = "^(?:" . $FLOAT . "?)\$";
	$INTEGER_REQUIRED = "^" . $INTEGER . "\$";
	$INTEGER_OPTIONAL = "^(?:" . $INTEGER . "?)\$";
}

sub loadTemplate(){
	$template_error = "";
	if ($page_template_file ne ""){
		if (!open(TEMPLATE, "<$page_template_file")){
			$template_error = '<div class="contactform cf_error cf_message">The template file could not be opened.</div>\n';
			return;
		}
		$page_template = join("", <TEMPLATE>);
		close(TEMPLATE);
	}
}

sub createMaps {
	# Since hash maps are not ordered, Aliases and Form_Fields
	# Are declared as arrays.  We need to create two data structures
	# from each.  The first is an undered map, the second is an
	# ordered key set.
	%AliasesMap = @Aliases;
	my $useAlias = 1;
	foreach my $alias (@Aliases){
		if ($useAlias){
			push(@AliasesOrdered, $alias);
			$useAlias = 0;
		} else {
			$useAlias = 1;
		}
	}

	$field_name_to = '';
	$field_name_from_email = '';
	$field_name_from_name = '';
	$field_name_subject = '';
	$field_name_regarding = '';
	$field_name_referrer = '';

	%FieldMap = @FormFields;
	foreach my $key (@FormFields){
		if ($FieldMap{$key} and (! defined ${$FieldMap{$key}}{"enabled"} or ${$FieldMap{$key}}{"enabled"} != 0)){
			push(@Field_Order, $key);
			if (defined ${$FieldMap{$key}}{"special"}){
				my $special = ${$FieldMap{$key}}{"special"};
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
			if (defined ${$FieldMap{$key}}{"default"}){
                ${$FieldMap{$key}}{"selected"} = ${$FieldMap{$key}}{"default"};
			}
		}
	}

	# Put the referrer header into the map if it is not there already
	if ($field_name_referrer ne "" and $FieldMap{$field_name_referrer} and ! exists $SubmittedData{$field_name_referrer}){
		if (defined $ENV{'HTTP_REFERER'}){
			$SubmittedData{$field_name_referrer} = $ENV{'HTTP_REFERER'};
		} else {
			$SubmittedData{$field_name_referrer} = "-";
		}
	}
}

sub parseInput {
	my ($pair, @pairs, $buffer);

	if (&safeHeader($ENV{'REQUEST_METHOD'}) eq 'GET'){
		@pairs = split(/&/, $ENV{'QUERY_STRING'});
	} elsif (&safeHeader($ENV{'REQUEST_METHOD'}) eq 'POST'){
		read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
		@pairs = split(/&/, $buffer);
	} elsif ($ENV{'SERVER_NAME'}){
		&inputPage("This form must be submitted via either 'GET' or 'POST'.");
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

			$SubmittedData{$name} = $value;
		}
	}
}

sub getRequired {
	my ($key) = @_;
	if (defined ${$FieldMap{$key}}{"required"}){
		return ${$FieldMap{$key}}{"required"};
	} elsif (&getType($key) eq "select" || &getType($key) eq "radio"){
		return "";
	} else {
		return $ANYTHING;
	}
}

sub getError {
	my ($key) = @_;
	if (defined ${$FieldMap{$key}}{"error"}){
		return ${$FieldMap{$key}}{"error"};
	} else {
		return "The field '$key' does not appear to be valid.";
	}
}

sub getType {
	my ($key) = @_;
    if ($key eq $field_name_to){
		if ($#AliasesOrdered > 0){
			 return "select";
		} else {
			return "hidden";
		}
	}
	if (defined ${$FieldMap{$key}}{"type"}){
		return ${$FieldMap{$key}}{"type"};
	} else {
		return "text";
	}
}

sub getSelected {
	my ($key) = @_;
	if (defined ${$FieldMap{$key}}{"selected"}){
		return ${$FieldMap{$key}}{"selected"};
	} else {
		return undef;
	}
}

sub getDescription {
	my ($key) = @_;
	if (defined ${$FieldMap{$key}}{"description"}){
		return ${$FieldMap{$key}}{"description"};
	} else {
		"$key:";
	}
}

sub getSelection {
	my ($key) = @_;
	if (defined($SubmittedData{$key})){
		return $SubmittedData{$key};
	}
    if (&getSelected($key)){
        return &getSelected($key);
    }
    return "";
}

sub sanityCheck {

	# Check the referrer
	if (&safeHeader($ENV{'HTTP_REFERER'}) && &safeHeader($ENV{'HTTP_REFERER'}) !~ /$allowedReferers/g){
		&inputPage("This form cannot be submitted from".&escapeHTML($ENV{'HTTP_REFERER'}).".");
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
		    if($data ne "" or !defined($SubmittedData{"prefill"})){
                $errorCount++;
			    $errorHash{$key} = &getError($key);
            }
		} elsif ($SubmittedData{$key} && $form_type ne 'hidden'){
			$some_required_field_present = 1;
		}

		foreach my $disallow_check (keys(%disallowed_text)){
			if ($data =~ /$disallow_check/){
				$errorCount++;
				$errorHash{$key} .= $disallowed_text{$disallow_check};
			}
		}
	}
	if (!($some_required_field_present)){
		&inputPage('', $input_page_text);
	}

	if ($errorCount > 0){
		my $errorMessage = "";
		if ($errorCount == 1){
			$errorMessage = "<p>Please correct the error to continue.</p>";
		} else {
			$errorMessage = "<p>Please correct all errors to continue.</p>";
		}
		&inputPage($errorMessage, "", \%errorHash);
	}

	if ((!$SubmittedData{$field_name_to}) || $SubmittedData{$field_name_to} eq ""){
		&inputPage('', $input_page_text);
	} else {
		my $recipent = $SubmittedData{$field_name_to};
		if ((!$AliasesMap{$recipent})){
			&inputPage("Your message cannot be sent to the specified recipient.")
		}
	}
}

sub composeEmail {
	my ($subject, $from, @field_keys, $key);

	if ($field_name_from_email ne '' and $FieldMap{$field_name_from_email}){
		$from = &safeHeader(&getSelection($field_name_from_email));
	} else {
		$from = '';
	}
	if ($from !~ /$EMAIL_REQUIRED/g){
		$from = 'nobody';
	}
	if ($field_name_from_name ne "" and $FieldMap{$field_name_from_name} and &getSelection($field_name_from_name) ne ''){
		$from = &safeHeaderName(&getSelection($field_name_from_name))." <$from>";
	}

	if ($field_name_subject ne "" and $FieldMap{$field_name_subject} and &getSelection($field_name_subject)){
		$subject = &safeHeader(&getSelection($field_name_subject));
	} else {
		$subject = "Website Form Submission";
	}

	if ($field_name_regarding ne "" and $FieldMap{$field_name_regarding} and &getSelection($field_name_regarding) ne ''){
		$subject .= " (".&safeHeader(&getSelection($field_name_regarding)).")";
	}


	$mail_message	= "From: $from\n";
	$mail_message .= "Subject: $subject\n";
	$mail_message .= "\n";

	@field_keys = &getOrderedFields();
	foreach $key (@field_keys){
		if ($key ne $field_name_to && $key ne $field_name_subject &&
			$key ne $field_name_from_name && $key ne $field_name_from_email &&
			$key ne $field_name_regarding && $key ne $field_name_referrer){
			my $mail_description = &getDescription($key);
			if ($mail_description eq $NO_DESCRIPTION){
				$mail_description = "";
			} else {
				$mail_description .= "\n";
			}
			$mail_message .= $mail_description;
			$mail_message .= &getSelection($key)."\n";
			$mail_message .= "\n";
		}
	}
}

sub sendEmail {
	my @to_address_list = split(/,/,$AliasesMap{&getSelection($field_name_to)});
	foreach my $to_address (@to_address_list){
		open(MAIL,"|$sendmail");
		print MAIL "To: ".&safeHeader($to_address)."\n";
		print MAIL "Content-Type: text/plain; charset=".&safeHeader($charset)."\n";
		print MAIL "X-Mailer: ContactForm/".&safeHeader($version)." (http://ostermiller.org/contactform/)\n";
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

sub previewMessage() {
	if ($require_preview == 0){
		return;
	}
	if (defined $SubmittedData{$field_name_submit} and $SubmittedData{$field_name_submit} eq "Send"){
		return;
	}

	my ($message);
	$message = &textToHTML("To: ".&getSelection($field_name_to)."\n".$mail_message);

	&inputPage(
		'',
		"$preview_page_text<div class=\"contactform cf_preview\">$message</div>"
	);
}

sub sentPage {
	my ($message);
	$message = &textToHTML("To: ".&getSelection($field_name_to)."\n".$mail_message);

	my $javascript = ""; # No javascript

	if ($redirect_url_sent ne ""){
		if ($redirect_delay_sent == 0){
			&redirect($redirect_url_sent);
		} else {
			$javascript = "<meta http-equiv=\"refresh\" content=\"$redirect_delay_sent;url=$redirect_url_sent\">\n"
		}
	}

	&outputPage(
		$sent_page_title,
		$sent_page_css,
		$javascript,
		"$sent_page_text<div class=\"contactform cf_sent\">$message</div>"
	);
}

sub redirect {
	my ($url) = @_;
	print "Location: $url\n\n";
	exit 0;
}

sub inputPage {
	my ($error, $preview, $fieldErrors) = @_;
    my $haserror = 1;
	if (!defined($error)){
		$error = "";
        $haserror = 0;
	}
	my %FieldErrorsHash = ();
	if (defined($fieldErrors)){
		%FieldErrorsHash = %$fieldErrors;
	}
	if (!defined($preview)){
		$preview = "";
	}
	my (@orderedKeys, $key, $form_html, $script_call, $alias_selected, $client_side_check_script);

    my $errorStyle=" style=\"display:none;\"";
	if ($error ne ""){
        $errorStyle="";
	}
	$error = "<div id=cf_global_error$errorStyle class=\"contactform cf_error cf_message\">\n" . $error . "</div>\n";
	$script_call = '';
	if ($use_client_side_verification){
		$script_call="onSubmit='return cfCheckForm(this);'";
	}

	if ($submit_method ne "GET"){
		$submit_method = "POST";
	}

	$form_html="<form class=contactform id=cf_form action=\"".&escapeHTML($ENV{'SCRIPT_NAME'})."\" method=$submit_method $script_call>\n";
	@orderedKeys = &getOrderedFields();
	foreach $key (@orderedKeys){
		my $html_description = &getDescription($key);
		if ($html_description eq $NO_DESCRIPTION){
			$html_description = '';
		} else {
			$html_description = "<label class=\"contactform cf_fieldlabel\" for='$key'>$html_description</label>";
		}
		my $fieldErrorMessage = "";
        my $errorStyle=" style=\"display:none;\"";
		if (defined $FieldErrorsHash{$key} and $FieldErrorsHash{$key} ne ""){
			$fieldErrorMessage = $FieldErrorsHash{$key};
            $errorStyle = "";
		}
        $fieldErrorMessage= "<span id=cf_error_$key$errorStyle class=\"contactform cf_error cf_fielderror\">".&escapeHTML($fieldErrorMessage)."</span>";
		if ($key eq $field_name_to){
			if ($#AliasesOrdered == 0){
				my $alias = $AliasesOrdered[0];
				$form_html.= "$fieldErrorMessage <input type=hidden name='$field_name_to' value='$alias'>\n";
			} else {
				$form_html.= "<div class=\"contactform cf_field\">$required_marker $html_description $fieldErrorMessage\n<div class=\"contactform cf_userentry\"><select id='$key' name='$field_name_to'>\n";
				$form_html.= "<option value=''></option>\n";
				foreach my $alias (@AliasesOrdered){
					if (defined $SubmittedData{$field_name_to} and $alias eq $SubmittedData{$field_name_to}){
						$alias_selected = 'selected'
					} else {
						$alias_selected = '';
					}
						$form_html.= "<option value='$alias' $alias_selected>$alias</option>\n";
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
				$fieldText .= "$required_marker";
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
				$form_html.="<div class=\"contactform cf_field\">$fieldText<div class=\"contactform cf_userentry\"><select id='$key' class=\"contactform cf_select\" name='$key'>";
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
				$form_html.="<div class=\"contactform cf_field\">$fieldText<div class=\"contactform cf_userentry\"><span id='$key' class=\"contactform cf_radio\">";
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
				$form_html.="<div class=\"contactform cf_field\">$fieldText<div class=\"contactform cf_userentry\"><textarea id='$key' class=\"contactform cf_textentry\" wrap=virtual name='$key'>".&escapeHTML($data)."</textarea></div></div>\n";
			} elsif ($form_type eq 'hidden'){
				$form_html.="$fieldErrorMessage <input type=hidden name='$key' value='".&escapeHTML($data)."'>\n";
			} else {
				$form_html.="<div class=\"contactform cf_field\">$fieldText<div class=\"contactform cf_userentry\"><input id='$key' class=\"contactform cf_textentry\" type=text name='$key' value='".&escapeHTML($data)."'></div></div>\n";
			}
		}
	}
	if ($require_preview == 1 or $require_preview == 2){
		$form_html.="<input class=\"contactform\" id=cf_submit type=submit name=$field_name_submit value=Preview>\n";
	}
	if ($require_preview == 0 or $require_preview == 2 or (!$haserror eq "" and defined $SubmittedData{$field_name_submit} and $SubmittedData{$field_name_submit} eq "Preview")){
		$form_html.="<input class=\"contactform\" id=cf_submit type=submit name=$field_name_submit value=Send>\n";
	}
	$form_html.="$required_marker_note\n";
	$form_html.="</form>";

	$client_side_check_script = "";
	if ($use_client_side_verification){
		$client_side_check_script .= "<script language=javascript type='text/javascript'><!--\n";
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
		$client_side_check_script .= "var ec=0;\n";
		$client_side_check_script .= "if (agent.indexOf('mozilla')==0 && major<=4 && agent.indexOf('msie')!=-1){\n";
		$client_side_check_script .= "// Internet Explorer 4 and earlier.\n";
		$client_side_check_script .= "return true;\n";
		$client_side_check_script .= "} else if (agent.indexOf('mozilla')==0 && major<=4){\n";
		$client_side_check_script .= "// Netscape 4 and earlier.\n";
		$client_side_check_script .= "return true;\n";
		$client_side_check_script .= "} else if (agent.indexOf('opera')!=-1){\n";
		$client_side_check_script .= "// Opera doesn't seem to do regular expressions properly.\n";
		$client_side_check_script .= "return true;\n";
		$client_side_check_script .= "}\n";
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
        $client_side_check_script .= "cfErrorOn('','cf_global_error','Please correct '+(ec==1?'the error':'all errors')+' to continue.',false,false,'block');\n";
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
		$input_page_title,
		$input_page_css,
		$client_side_check_script,
		$preview.$error.$form_html
	);
}

sub outputPage {
	my ($title, $css, $javascript, $content) = @_;

	my $page = $page_template;
	$page =~ s/\$title/$title/g;
	$page =~ s/\$css/$css/g;
	$page =~ s/\$javascript/$javascript$icon_link\n$copyright_link/g;
	$page =~ s/\$content/$template_error$content$contact_form_link/g;

	if ($ENV{'SERVER_NAME'}){
		print "Content-type: text/html; charset=$charset\n";
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
	$value =~ s/'/\&apos;/g;
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
