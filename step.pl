#!/usr/bin/perl -X
require HTTP::Request;
use HTTP::Request 6.07;
use LWP::UserAgent ();
use Image::OCR::Tesseract 'get_ocr';

##########
$user = 'login'; # Enter your username here
$pass = 'password'; # Enter your password here
###########

# Server settings (no need to modify)
$home = "http://website.com";
$url  = "$home/c/test.cgi?u=$user&p=$pass";

# Get HTML code
$ua = LWP::UserAgent->new;
$html = $ua->get($url);

# Grab img from HTML code
$html->decoded_content =~ m/<img/;
$img = "$'\n";
$img =~ m/src="/;
$imgNext  = "$'\n";
$imgNext =~ m/"/;
$imgPath = "$`\n";

#########
$captcha = "captcha.png";
$request = HTTP::Request->new(GET => "$home$imgPath");
$resCaptcha = $ua->simple_request( $request, $captcha );
$text = get_ocr( $captcha);

$resForm = $ua->put( $url, "u" => $user, "p" => $pass, "text" => $text );

1;
