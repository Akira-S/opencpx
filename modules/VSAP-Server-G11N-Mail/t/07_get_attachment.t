use Test::More tests => 3;

use strict;
use XML::LibXML;

BEGIN { use_ok('VSAP::Server::G11N::Mail') };

my $default_encoding = 'UTF-8';
my $to_encoding = 'UTF-8'; # good

my $filename = q#�́�Ɂ����������ȁˁ��쁵������ ����ԁ쁣���с��ρ��Ёׁ́�ց� �������������Ɂ��Á����Ɂ����ǁ�1.doc#;

my $mail = new VSAP::Server::G11N::Mail();

my $foo = $mail->get_attachment_name( { default_encoding => $default_encoding,
					to_encoding      => $to_encoding,
					from_encoding    => 'GB2312',
					attachments      => [ $filename ] } )->[0];

ok( $foo, "filename encoded" );
ok( test_dom($foo), "added to dom" );

exit;

sub test_dom {
    my $string = shift;
    my $dom = XML::LibXML::Document->createDocument('1.0', 'UTF8');
    $dom->setDocumentElement($dom->createElement('vsap'));
    my $root = $dom->createElement( 'vsap' );

    eval {
	$root->appendTextChild( body => $string );
	$dom->documentElement->appendChild($root);
	my $string2 = $dom->toString(1);
    };

    if( $@ ) {
#	return 1 if $@ =~ /no dtd found/i;

	warn "************************ERROR: $@\n";
	return;
	
    }

    1;
}
