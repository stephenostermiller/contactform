#!/usr/bin/perl -T -w

use strict;

# Contact Form is a Perl script that you can run on your website that will
# allow others to send you email through a web interface.
# See: http://ostermiller.org/contactform/
# Copyright (C) 2002-2004 Stephen Ostermiller
# http://ostermiller.org/contact.pl?regarding=Contact+Form
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
# GNU General Public License for more details.
#
# See copying.txt for details.
my ($NO_DESCRIPTION, $version, $LETTER, $DIGIT, $DOSEOL, $EOL, $LETTER_DIGIT,
$LETTER_DIGIT_HYPHEN, $HEX_DIGIT, $QUOTEDSTRING, $ATOM, $SUBDOMAIN, $WORD,
$DOMAIN, $LOCALPART, $EMAIL, $PHONE_DIGIT, $PHONE, $ZIPCODE, $PRICE, $FLOAT,
$INTEGER, $SOMETHING, $ANYTHING, $ONE_LINE_REQUIRED, $ONE_LINE_OPTIONAL,
$ZIPCODE_REQUIRED, $ZIPCODE_OPTIONAL, $PHONE_REQUIRED, $PHONE_OPTIONAL,
$EMAIL_REQUIRED, $EMAIL_OPTIONAL, $PRICE_REQUIRED, $PRICE_OPTIONAL,
$FLOAT_REQUIRED, $FLOAT_OPTIONAL, $INTEGER_REQUIRED, $INTEGER_OPTIONAL,
$page_head);
&initConstants();

# List of email address to which mail can be sent.
# Mail cannot be sent to any email address which is not on this list.
# If a single address is listed, it will be a hidden value on the
# form, otherwise, the user will be presented with a pulldown menu
# of aliases to which email can be sent.
# The addresses listed here are never visible via served web pages.
my %Aliases = (
	'administrator',&safeHeader($ENV{'SERVER_ADMIN'}),
	#'webmaster','webmaster@yoursite.tld',
	#'postmaster','postmaster@yoursite.tld',
);

# Modify the following to control how the HTML pages look
my $required_marker =
"<span class=required>*</span>";

my $input_page_head =
"<title>Contact Us</title>
<style>
.error { color:red; }
.textentry { min-width:300px; width:100%; max-width:600px; width:expression(document.body.clientWidth>600?'600px':'auto');}
textarea { height:4in; }
.required { color:green }
</style>";

my $input_page_body_start =
"<h1>Contact Us</h1>";

my $input_page_body_end =
"<p>$required_marker denotes a required field.</p>
<p align=right><a href='http://ostermiller.org/contactform/'>Contact Form $version</a></p>";

my $sent_page_head =
"<title>Message Sent</title>
<style>
.sent { border:thin black ridge; padding:1cm;  max-width:600px; width:expression(document.body.clientWidth>600?'600px':'auto');}
</style>";

my $sent_page_body_start =
"<h1>Message Sent</h1>
<div class=sent>";

my $sent_page_body_end =
"</div>
<p align=right><a href='http://ostermiller.org/contactform/'>Contact Form $version</a></p>";

# A list of required form variables, along with a regular
# expression that describes what a valid submission looks like.
# If a field is not in this list, it will not be put in email.
# Consider using the following pre-defined regular expressions:
# $SOMETHING, $ANYTHING, $ONE_LINE_REQUIRED, $ONE_LINE_OPTIONAL,
# $ZIPCODE_REQUIRED, $ZIPCODE_OPTIONAL, $PHONE_REQUIRED,
# $PHONE_OPTIONAL, $EMAIL_REQUIRED, $EMAIL_OPTIONAL, $PRICE_REQUIRED,
# $PRICE_OPTIONAL, $FLOAT_REQUIRED, $FLOAT_OPTIONAL,
# $INTEGER_REQUIRED, $INTEGER_OPTIONAL
# You may safely remove the subject, email, name, and message
# from the form.	The to field should not be removed.

my %Form_Fields = (
	'to',$ONE_LINE_REQUIRED,
	'email',$EMAIL_REQUIRED,
	'name',$ONE_LINE_OPTIONAL,
	'subject',$ONE_LINE_REQUIRED,
	'message',$SOMETHING,
	'regarding',$ANYTHING,
	#'phone',$PHONE_OPTIONAL,
	#'fax',$PHONE_OPTIONAL,
	#'address1', $ONE_LINE_OPTIONAL,
	#'address2', $ONE_LINE_OPTIONAL,
	#'city', "^(?:[a-zA-Z ]*)\$",
	#'state', "^(?:(?:[A-Z][A-Z])?)\$",
	#'zip',$ZIPCODE_OPTIONAL,
);

# The order that fields will appear in web pages and email
# Just because a field name is present here, it is not
# nessecarily allowed.	Make sure it is also in %Form_Fields
# If field order is not important, this list may be empty.
my @Field_Order = (
	'to',
	'email',
	'name',
	'subject',
	'message',
	'regarding',
	#'phone',
	#'fax',
	#'address1',
	#'address2',
	#'city',
	#'state',
	#'zip',
);

# A user friendly error message for each required
# element that a user gets wrong.
# Just because a field name is present here, it is not
# nessecarily allowed.	Make sure it is also in %Form_Fields
# If there is no error message, a default is used.
my %Error_Messages = (
	'to','You must specify a recipient.',
	'email','The email address you entered does not appear to be valid.',
	'name','You must enter your name.',
	'subject','You must enter a subject.',
	'message','You must enter a message.',
	'regarding','',
	#'phone','The phone number you entered does not appear to be valid.',
	#'fax','The fax number you entered	does not appear to be valid.',
	#'address1','Please enter your address.',
	#'address2','Please enter your address.',
	#'city','Your city does not appear to be valid.',
	#'state','Please use the two digit abbreviation for your state.',
	#'zip','Your zipcode does not appear to be valid.',
);

# Type of input in web pages for each field.
# Currently supported are 'text', 'hidden', and 'textarea'
# Just because a field name is present here, it is not
# nessecarily allowed.	Make sure it is also in %Form_Fields
# If there is no type, 'text' is assumed.
# Setting this for the to field will have no effect since
# the to field is handled specially.
my %Form_Type = (
	'email','text',
	'name','text',
	'message','textarea',
	'subject','text',
	'regarding', 'hidden',
	#'phone','text',
	#'fax','text',
	#'address1','text',
	#'address2','text',
	#'city','text',
	#'state','text',
	#'zip','text',
);

# Description to appear next to entry forms and in
# the email or $NO_DESCRIPTION for none
# Just because a field name is present here, it is not
# nessecarily allowed.	Make sure it is also in %Form_Fields
# If no description is given the field name followed
# by a colon is used.
my %Field_Descriptions = (
	'to','To:',
	'email','Your email address:',
	'name','Your name:',
	'subject','Subject:',
	'message',$NO_DESCRIPTION,
	'regarding',$NO_DESCRIPTION,
	#'phone','Phone Number:',
	#'fax','Fax Number:',
	#'address1','Address:',
	#'address2',$NO_DESCRIPTION,
	#'city','City:',
	#'state','State:',
	#'zip','Zipcode:',
);

# The names of the fields that are inserted into special places
# in the email can be changed by changing these values.
	# Alias of the address put in the "To:" field of the email.
	my $field_name_to = 'to';
	# Put in the "From:" field of the email.
	my $field_name_from_email = 'email';
	# Put in the "From:" field of the email in parenthesis.
	my $field_name_from_name = 'name';
	# Put in the "Subject:" field of the email.
	my $field_name_subject = 'subject';
	# Put in the "Subject:" field of the email in parenthesis.
	my $field_name_regarding = 'regarding';

# Regular expression describing urls which can host forms
# pointing to this program.	The referral URL is generated on the
# client side by the browser.	Therefore it useless to prevent
# unauthorized submission by mail software.	You can, however,
# prevent somebody from reliably hosting on another server,
# a form pointing to this email software.
	# This form can be used from any site at all.
	my $allowedReferers = '.*';
	# This form can only be used from pages on yoursite.tld
	#my $allowedReferers = '^http[s]?\\:\\/\\/yoursite\\.tld\\/';
	# This form can only be used from pages on the domain or ip address
	#my $allowedReferers = '^http[s]?\\:\\/\\/((yoursite\\.tld)|(127\\.0\\.0\\.1))\\/';
	# This form can only be used from a specific page.
	#my $allowedReferers = '^http[s]?\\:\\/\\/yoursite\\.tld\\/directory\\/page\\.html\\$';

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

#=====================================================================
# You need to know Perl to and have a strong stomach to
# modify much of anything below this line

my(%SubmittedData, $mail_message);

&parseInput();
&sanityCheck();
&composeEmail();
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
	$version = "1.1.9";

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

	$page_head='<link rel="icon" href="'.&escapeHTML($ENV{'SCRIPT_NAME'}).'/contactformicon.png" type="image/png">
<link rel="copyright" href="http://ostermiller.org/contactform/" type="text/html">';

}

sub parseInput {
	my ($pair, @pairs, $buffer);

	if (&safeHeader($ENV{'REQUEST_METHOD'}) eq 'GET'){
		@pairs = split(/&/, $ENV{'QUERY_STRING'});
	} elsif (&safeHeader($ENV{'REQUEST_METHOD'}) eq 'POST'){
		read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
		@pairs = split(/&/, $buffer);
	} else {
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

sub sanityCheck {

	# Check the referrer
	if (&safeHeader($ENV{'HTTP_REFERER'}) && &safeHeader($ENV{'HTTP_REFERER'}) !~ /$allowedReferers/g){
		&inputPage("This form cannot be submitted from".&escapeHTML($ENV{'HTTP_REFERER'}).".");
	}

	my $missing_field_list_html = "";
	my $some_required_field_present = 0;

	my @field_keys = &getOrderedFields();
	foreach my $key (@field_keys){
		my $required_value = "";
		if (defined($Form_Fields{$key})){
			$required_value = $Form_Fields{$key};
		}
		my $data = "";
		if (defined($SubmittedData{$key})){
			$data = $SubmittedData{$key};
		}
		my $form_type = "";
		if (defined($Form_Type{$key})){
			$form_type = $Form_Type{$key};
		}
		if ($data !~ /$required_value/g){
			if ($Error_Messages{$key}){
				$missing_field_list_html .= "<li>" . &escapeHTML($Error_Messages{$key}) . "</li>\n";
			} else {
				$missing_field_list_html .= "<li>The field '" . &escapeHTML($key) . "' does not appear to be valid.</li>\n";
			}
		} elsif ($SubmittedData{$key} && $form_type ne 'hidden'){
			$some_required_field_present = 1;
		}
	}
	if (!($some_required_field_present)){
		&inputPage();
	}
	if ($missing_field_list_html ne ''){
		if (!defined($SubmittedData{"prefill"})){
			$missing_field_list_html = "<p>The following problems prevented your message from being sent:<br>" . $missing_field_list_html . "</p>";
		} else {
			$missing_field_list_html = "";
		}
		&inputPage($missing_field_list_html);
	}

	if ((!$SubmittedData{$field_name_to}) || $SubmittedData{$field_name_to} eq ""){
		&inputPage('');
	} else {
		my $recipent = $SubmittedData{$field_name_to};
		if ((!$Aliases{$recipent})){
			&inputPage("Your message cannot be sent to the specified recipient.")
		}
	}
}

sub composeEmail {
	my ($subject, $from, @field_keys, $key);

	if ($Form_Fields{$field_name_from_email}){
		$from = &safeHeader($SubmittedData{$field_name_from_email});
	} else {
		$from = '';
	}
	if ($from !~ /$EMAIL_REQUIRED/g){
		$from = 'nobody';
	}
	if ($Form_Fields{$field_name_from_name} && $SubmittedData{$field_name_from_name} ne ''){
		$from .= " (".&safeHeaderName($SubmittedData{$field_name_from_name}).")";
	}

	if ($Form_Fields{$field_name_subject} && $SubmittedData{$field_name_subject}){
		$subject = &safeHeader($SubmittedData{$field_name_subject});
	} else {
		$subject = "Website Form Submission";
	}

	if ($Form_Fields{$field_name_regarding} && $SubmittedData{$field_name_regarding} ne ''){
		$subject .= " (".&safeHeader($SubmittedData{$field_name_regarding}).")";
	}


	$mail_message	= "From: $from\n";
	$mail_message .= "Subject: $subject\n";
	$mail_message .= "\n";

	@field_keys = &getOrderedFields();
	foreach $key (@field_keys){
		if ($key ne $field_name_to && $key ne $field_name_subject &&
			$key ne $field_name_from_name && $key ne $field_name_from_email &&
			$key ne $field_name_regarding){
			my $mail_description = $Field_Descriptions{$key};
			if ($mail_description eq ''){
				$mail_description = $key.":"
			}
			if ($mail_description eq $NO_DESCRIPTION){
				$mail_description = "";
			} else {
				$mail_description .= "\n";
			}
			$mail_message .= $mail_description;
			$mail_message .= "$SubmittedData{$key}\n";
			$mail_message .= "\n";
		}
	}
}

sub sendEmail {
	open(MAIL,"|$sendmail");
	print MAIL "To: ".&safeHeader($Aliases{$SubmittedData{$field_name_to}})."\n";
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
	print MAIL $mail_message;
	close (MAIL);
}

sub sentPage {
	my ($message);
	$message = &textToHTML("To: $SubmittedData{$field_name_to}\n".$mail_message);

	print "Content-type: text/html; charset=$charset\n";
	print "\n";
	print "<html>\n";
	print "<head>\n";
	print "$sent_page_head\n";
	print "$page_head\n";
	print "</head>\n";
	print "<body>\n";
	print "$sent_page_body_start\n";
	print "$message\n";
	print "$sent_page_body_end\n";
	print "</body>\n";
	print "</html>\n";
}

sub inputPage {
	my ($error) = @_;
	if (!defined($error)){
		$error = "";
	}
	my (@orderedKeys, $key, $form_html, @alias_keys, $alias_key, $script_call, $alias_selected, $client_side_check_script);

	if ($error ne ""){
		$error = "<div class=error>\n" . $error . "</div>\n";
	}
	$script_call = '';
	if ($use_client_side_verification){
		$script_call="onSubmit='return checkForm(this);'";
	}

	if ($submit_method ne "GET"){
		$submit_method = "POST";
	}

	$form_html="<form method=$submit_method $script_call>\n";
	@orderedKeys = &getOrderedFields();
	foreach $key (@orderedKeys){
		my $html_description = $Field_Descriptions{$key};
		if ($html_description eq ''){
			$html_description = $key.":"
		}
		if ($html_description eq $NO_DESCRIPTION){
			$html_description = '';
		} else {
			$html_description = "<label for='$key'>$html_description</label><br>";
		}
		if ($key eq $field_name_to){
			@alias_keys = keys(%Aliases);
			if ($#alias_keys == 0){
				$alias_key = $alias_keys[0];
				$form_html.= "<input type=hidden name='$field_name_to' value='$alias_key'>\n";
			} else {
				$form_html.= "<p>$required_marker $html_description<select id='$key' name='$field_name_to'>\n";
				$form_html.= "<option value=''></option>\n";
				foreach $alias_key (@alias_keys){
					if ($alias_key eq $SubmittedData{$field_name_to}){
						$alias_selected = 'selected'
					} else {
						$alias_selected = '';
					}
						$form_html.= "<option value='$alias_key' $alias_selected>$alias_key</option>\n";
				}
				$form_html.= "</select></p>\n";
			}
		} else {
			my $mark = '';
			my $required_value = $Form_Fields{$key};
			my $data = "";
			if (defined($SubmittedData{$key})){
				$data = $SubmittedData{$key};
			}
			if (($data !~ /$required_value/g) && $html_description ne ''){
				$mark = "$required_marker ";
			}
			if ($Form_Type{$key} eq 'textarea'){
				$form_html.="<p>$mark$html_description<textarea id='$key' class=textentry wrap=virtual name='$key'>".&escapeHTML($SubmittedData{$key})."</textarea></p>\n";
			} elsif ($Form_Type{$key} eq 'hidden'){
				$form_html.="<input type=hidden name='$key' value='".&escapeHTML($SubmittedData{$key})."'>\n";
			} else {
				$form_html.="<p>$mark$html_description<input id='$key' class=textentry type=text name='$key' value='".&escapeHTML($SubmittedData{$key})."'></p>\n";
			}
		}
	}

	$form_html.="<input type=submit value=Send>\n";
	$form_html.="</form>\n";

	$client_side_check_script = "";
	if ($use_client_side_verification){
		$client_side_check_script .= "<script language=javascript type='text/javascript'><!--\n";
		$client_side_check_script .= "function checkForm(form){\n";
		$client_side_check_script .= "var major = parseInt(navigator.appVersion);\n";
		$client_side_check_script .= "var agent = navigator.userAgent.toLowerCase();\n";
		$client_side_check_script .= "if (agent.indexOf('mozilla')==0 && major<=4 && agent.indexOf('msie')!=-1){\n";
		$client_side_check_script .= "// Internet Explorer 4 and earlier.\n";
		$client_side_check_script .= "return true;\n";
		$client_side_check_script .= "} else if (agent.indexOf('mozilla')==0 && major<=4){\n";
		$client_side_check_script .= "// Netscape 4 and earlier.\n";
		$client_side_check_script .= "return true;\n";
		$client_side_check_script .= "} else if (agent.indexOf('opera')!=-1){\n";
		$client_side_check_script .= "// Opera doesn't seem to do regular expressions properly.\n";
		$client_side_check_script .= "return true;\n";
		$client_side_check_script .= "}";
		foreach $key (@orderedKeys){
			if(!defined($Form_Type{$key}) || $Form_Type{$key} ne 'hidden'){
				if ($key eq $field_name_to){
					$client_side_check_script .= " else if (form.$key.value.length == 0){\n";
				} else {
					$client_side_check_script .= " else if (!form.$key.value.match(new RegExp('".&escapeJavaScript($Form_Fields{$key})."', 'g'))){\n";
				}
				if ($Error_Messages{$key}){
					$client_side_check_script .= "alert('".&escapeJavaScript($Error_Messages{$key})."');\n";
				} else {
					$client_side_check_script .= "alert(The field '".$key."' does not appear to be valid.);\n";
				}
				$client_side_check_script .= "form.$key.select();\n";
				$client_side_check_script .= "form.$key.focus();\n";
				$client_side_check_script .= "return false;\n";
				$client_side_check_script .= "}";
			}
		}
		$client_side_check_script .= " else {\n";
		$client_side_check_script .= "return true;\n";
		$client_side_check_script .= "}\n";
		$client_side_check_script .= "}\n";
		$client_side_check_script .= "//--></script>";
	}

	print "Content-type: text/html; charset=$charset\n";
	print "\n";
	print "<html>\n";
	print "<head>\n";
	print "$input_page_head\n";
	print "$client_side_check_script\n";
	print "$page_head\n";
	print "</head>\n";
	print "<body>\n";
	print "$input_page_body_start\n";
	print "$error\n";
	print "$form_html\n";
	print "$input_page_body_end\n";
	print "</body>\n";
	print "</html>\n";

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
	my ($key, @field_keys, %done);
	foreach $key (@Field_Order){
		if (!$done{$key} && $Form_Fields{$key}){
			push(@field_keys,$key);
			$done{$key} = 1;
		}
	}
	foreach $key (keys %Form_Fields){
		if (!$done{$key}){
			push(@field_keys,$key);
			$done{$key} = 1;
		}
	}
	return @field_keys;
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
