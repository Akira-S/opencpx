use Test::More tests => 16;

use strict;
use XML::LibXML;

BEGIN { use_ok('VSAP::Server::G11N::Mail') };

my $default_encoding = 'UTF-8';
my $to_encoding = 'UTF-8'; # good
my $test_num = 1;

# ISO-2022-JP Subject
my $subject = "Attachments =?ISO-2022-JP?B?GyRCIUobKEJJU08tMjAyMi1KUCk=?=";

my $mail = new VSAP::Server::G11N::Mail;

my $foo = $mail->get_subject({default_encoding => $default_encoding,
			   to_encoding  => $to_encoding,
			   subject      => $subject});


ok($foo);

# ASCII Subject

$subject = "I am a regular ole subject line";

$foo = $mail->get_subject({default_encoding => $default_encoding,
                           to_encoding  => $to_encoding,
                           subject      => $subject});

ok($foo);

$subject = qq{=?EUC-JP?B?pLOk7KSsRVVDLUpQpail8w==?=
 =?EUC-JP?B?pbOhvKXJpLWk7KS/peGhvKXrpMekuQ==?=};

$foo = $mail->get_subject({default_encoding => $default_encoding,
                           to_encoding  => $to_encoding,
                           subject      => $subject});

ok($foo);
ok( test_dom($foo), "added to dom" );

# is($foo,"これがEUC-JPエンコードされたメールです");

# Shift_Jis

$subject = qq{=?SHIFT_JIS?B?grGC6oKqU2hpZnRfSklTg0c=?=
 =?SHIFT_JIS?B?g5ODUoFbg2iCs4Lqgr2DgYFbg4uCxQ==?= =?SHIFT_JIS?B?grc=?=};

$foo = $mail->get_subject({default_encoding => $default_encoding,
                           to_encoding  => $to_encoding,
                           subject      => $subject});

ok($foo);
ok( test_dom($foo), "added to dom" );

# Quoted-printable

$subject = qq{=?iso-2022-jp?Q?=34=56?=};

$foo = $mail->get_subject({default_encoding => $default_encoding,
                           to_encoding  => $to_encoding,
                           subject      => $subject});

ok($foo);
ok( test_dom($foo), "added to dom" );

## an unknown encoding
$subject = 'fozzie bear says =?unknown-8bit?B?w7g=?=';
$foo = $mail->get_subject({default_encoding => $default_encoding,
			   to_encoding      => $to_encoding,
			   subject          => $subject});

like( $foo, qr(fozzie bear says \x{F8}) );

##
## an unknown subject encoding (high-ascii-date) [ks_c_5601-1987]
##
$subject = q!������������ ��.ī.��.��.��.���� �ƴϴ�(���Ժ�+��ġ��+��û��(3����)+�ջ���ǰ@!;
$foo = $mail->get_subject( { default_encoding => $default_encoding,
			     to_encoding      => $to_encoding,
			     subject          => $subject } );
like( $foo, qr#\x{A3}\x{A8}\x{B1}\x{A4}\x{B0}#, "unencoded subject" );
ok( test_dom($foo), "added to dom" );

## kr subject (mail-badchar-1b1)
$subject = q#(����)����ΰ�����̼���?�������ؾ߻����������2878610@#;
$foo = $mail->get_subject( { default_encoding => $default_encoding,
			     to_encoding      => $to_encoding,
			     subject          => $subject } );
like( $foo, qr#����#, "decoded kr subject" );
ok( test_dom($foo), "added to dom" );

## ru subject
$subject = q#����� ��������!#;
$foo = $mail->get_subject( {default_encoding => $default_encoding,  ## try Windows-1291
			    to_encoding      => $to_encoding,
			    subject          => $subject} );
like( $foo, qr#��������#, "decoded subject" );
ok( test_dom($foo), "added to dom" );

exit;

sub test_dom {
    my $string = shift;
    my $dom = XML::LibXML::Document->createDocument('1.0', 'UTF8');
#    my $dom = XML::LibXML::Document->createDocument();
    $dom->setDocumentElement($dom->createElement('vsap'));
    my $root = $dom->createElement( 'vsap' );

    eval {
	$root->appendTextChild( body => $string );
	$dom->documentElement->appendChild($root);
	my $string = $dom->toString(1);
    };

    if( $@ ) {
#	return 1 if $@ =~ /no dtd found/i;

	warn "************************ERROR: $@\n";
	return;
	
    }

    1;
}
