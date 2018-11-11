#!IT/Perl
use strict;
use warnings;
require HTTP::Request;
require HTTP::Response;
use LWP::UserAgent ();
use Image::OCR::Tesseract 'get_ocr';

my $user = 'user';
my $pass = 'pass';

my $home = "http://task.com";
my $url  = "$home/c/test.cgi?u=$user&p=$pass";

my $ua   = LWP::UserAgent->new;
my $html = $ua->get($url);

$html->decoded_content =~ /<img src="(\/\w+\/(\w+\.\w{3}))"/;
my $imgPath  = $1;
my $fileName = $2;

my $myCaptcha      = "captcha.png";
my $reqCaptcha     = HTTP::Request->new( GET => "$home$imgPath" );
my $requestCaptcha = $ua->simple_request( $reqCaptcha, $myCaptcha );

die "captcha.png not found\n" if ( !-e "captcha.png" );
my $text = get_ocr($myCaptcha);

$text =~ s/(\n|\s)//gi;

die "ocr result not found\n" if ( !$text );

my $responseForm = $ua->post(
    $url,
    [
        'u'    => $user,
        'p'    => $pass,
        'file' => $fileName,
        'text' => $text
    ]
);

if ( $responseForm->is_success ) {
    print $responseForm->decoded_content;
}

die "$url error: ", $responseForm->status_line
  unless $responseForm->is_success;
die "Weird content type at $url -- ", $responseForm->content_type
  unless $responseForm->content_type eq 'text/html';

1;
