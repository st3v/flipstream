#! /usr/bin/perl

use URI::Escape;
use HTML::Entities;
use Mac::Tie::PList;
use DBI;
use DBD::mysql;
use Data::Dumper;

# db config
$platform = "mysql";
$host = "localhost";
$port = "3306";
$database = "youpod";
$tablename = "itunes_podcasts";
$user = "root";
$pw = "";

# db connect
$dsn = "dbi:$platform:$database:$host:$port";
$db = DBI->connect($dsn, $user, $pw) or die "Unable to connect: $DBI::errstr\n";

# url to browse itunes store
$endpoint = "http://itunes.apple.com/WebObjects/MZStore.woa/wa/browse?path=";

# worldwide stores and their IDs
%stores = ();
$stores{'United States'} = 143441;
$stores{'Argentina'} = 143505;
$stores{'Australia'} = 143460;
$stores{'Belgium'} = 143446;
$stores{'Brazil'} = 143503;
$stores{'Canada'} = 143455;
$stores{'Chile'} = 143483;
$stores{'China'} = 143465;
$stores{'Colombia'} = 143501;
$stores{'Costa Rica'} = 143495;
$stores{'Croatia'} = 143494;
$stores{'Czech Republic'} = 143489;
$stores{'Denmark'} = 143458;
#$stores{'Germany'} = 143443;
$stores{'El Salvador'} = 143506;
$stores{'Spain'} = 143454;
$stores{'Finland'} = 143447;
$stores{'France'} = 143442;
$stores{'Greece'} = 143448;
$stores{'Guatemala'} = 143504;
$stores{'Hong Kong'} = 143463;
$stores{'Hungary'} = 143482;
$stores{'India'} = 143467;
$stores{'Indonesia'} = 143476;
$stores{'Ireland'} = 143449;
$stores{'Israel'} = 143491;
$stores{'Italy'} = 143450;
$stores{'Korea'} = 143466;
$stores{'Kuwait'} = 143493;
$stores{'Lebanon'} = 143497;
$stores{'Luxembourg'} = 143451;
$stores{'Malaysia'} = 143473;
$stores{'Mexico'} = 143468;
$stores{'Nederlands'} = 143452;
$stores{'New Zealand'} = 143461;
$stores{'Norway'} = 143457;
$stores{'Austria'} = 143445;
$stores{'Pakistan'} = 143477;
$stores{'Panama'} = 143485;
$stores{'Peru'} = 143507;
$stores{'Phillipines'} = 143474;
$stores{'Poland'} = 143478;
$stores{'Portugal'} = 143453;
$stores{'Qatar'} = 143498;
$stores{'Romania'} = 143487;
$stores{'Russia'} = 143469;
$stores{'Saudi Arabia'} = 143479;
$stores{'Switzerland'} = 143459;
$stores{'Singapore'} = 143464;
$stores{'Slovakia'} = 143496;
$stores{'Slovenia'} = 143499;
$stores{'South Africa'} = 143472;
$stores{'Sri Lanka'} = 143486;
$stores{'Sweden'} = 143456;
$stores{'Taiwan'} = 143470;
$stores{'Thailand'} = 143475;
$stores{'Turkey'} = 143480;
$stores{'United Arab Emirates'} = 143481;
$stores{'United Kingdom'} = 143444;
$stores{'Venezuela'} = 143502;
$stores{'Vietnam'} = 143471;
$stores{'Japan'} = 143462;
$stores{'Dominican Republic'} = 143508;
$stores{'Ecuador'} = 143509;
$stores{'Egypt'} = 143516;
$stores{'Estonia'} = 143518;
$stores{'Honduras'} = 143510;
$stores{'Jamaica'} = 143511;
$stores{'Kazakhstan'} = 143517;
$stores{'Latvia'} = 143519;
#$stores{'Lithuania'} = 143520;
$stores{'Macau'} = 143515;
$stores{'Malta'} = 143521;
$stores{'Moldova'} = 143523;
$stores{'Nicaragua'} = 143512;
$stores{'Paraguay'} = 143513;
$stores{'Uruguay'} = 143514;

@stores_excluded = (143520,
					143443,
					143514,
					143456,
					143482,
					143477,
					143463,
					143486,
					143465,
					143518,
					143472,
					143504,
					143507,
					143476,
					143450,
					143479,
					143505,
					143510,
					143449,
					143453,
					143452,
					143512,
					143498,
					143519,
					143489,
					143508,
					143480,
					143468,
					143503,
					143462,
					143513,
					143506,
					143509,
					143496,
					143494,
					143511,
					143478,
					143499,
					143491,
					143467,
					143521,
					143523,
					143454,
					143516,
					143460,
					143470,
					143459,
					143444,
					143515,
					143457,
					143455,
					143497,
					143474,
					143451,
					143475,
					143481,
					143464,
					143471,
					143466,
					143469,
					143447,
					143487,
					143445,
					143517,
					143448);

my %hash;
@hash{@stores_excluded}=();

print "Fetching Podcasts for ...\n";

while (($store_country, $store_id) = each(%stores)) {
	if (exists $hash{$store_id}) {
		next;
	}
	
	print "  - " . $store_country . ": ";
	%categories = fetchCategories($store_id);
	print scalar(keys(%categories)) . " categories\n";
	
	while (($cat_name, $cat_id) = each(%categories)) {
		%subcategories = fetchSubCategories($store_id, $cat_id);
		print "    - " . $cat_name . ': ' . scalar(keys(%subcategories)) . " subcategories\n"; 
	
		while (($sub_name, $sub_id) = each(%subcategories)) {
			$count = fetchPodcasts($store_id, $cat_id, $sub_id);
			print "      - " . $sub_name . ": " . $count . " feeds\n";
		}
	}
}


sub fetchCategories {
	my $store = shift;
	
	%categories = ();
	
	my $url = $endpoint . uri_escape('/26');
	my $payload = fetchXML($store, $url);
   	my %hash = %{Mac::Tie::PList->new($payload)};
	
	foreach $item (@{$hash{'items'}}) {
		$categories{$item->{'itemName'}} = $item->{'itemId'};
	}
	
	return %categories;
}

sub fetchSubCategories {
	my $store = shift;
	my $category = shift;
	
	%subcategories = ();
	
	my $url = $endpoint . uri_escape('/26/' . $category);
	my $payload = fetchXML($store, $url);
   	my %hash = %{Mac::Tie::PList->new($payload)};
	
	foreach $item (@{$hash{'items'}}) {
		$subcategories{$item->{'itemName'}} = $item->{'itemId'};
	}
	
	return %subcategories;
}

sub fetchPodcasts {
   my $store = shift;
   my $category = shift;
   my $subcategory = shift;
   
   %podcasts = ();
   
   my $url = $endpoint . uri_escape('/26/' . $category . '/' . $subcategory);
   my $payload = fetchXML($store, $url);
   my %hash = %{Mac::Tie::PList->new($payload)};
   
   $count=0;
   foreach $item (@{$hash{'items'}}) {
   		$count++;
   		#print "        - " . $item->{'itemName'} . " (" . $item->{'itemId'} . ")\n";
   		
   		$query = "INSERT INTO $tablename ( feed_url, subscribe_url, item_id, item_name, artist_id, artist_name, keywords, description, long_description, url, playlist_id, playlist_name, release_date, kind, category, genre_id, genre, is_video, explicit, popularity, episode_guid, store, cat_id, sub_id, crawl_date) VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";
   		$db->do($query, 
				undef, 
				$item->{'feedURL'},
				$item->{'subscribeURL'},
				$item->{'itemId'}, 
				$item->{'itemName'},
				$item->{'artistId'},
				$item->{'artistName'},
				$item->{'keywords'},
				$item->{'description'},
				$item->{'longDescription'},
				$item->{'url'}, 
				$item->{'playlistId'},
				$item->{'playlistName'},
				$item->{'releaseDate'}, 
				$item->{'kind'},
				$item->{'category'},
				$item->{'genreId'}, 
				$item->{'genre'},
				$item->{'is-video'},
				$item->{'explicit'}, 
				$item->{'popularity'},
				$item->{'episodeGUID'},
				$store,
				$category,
				$subcategory);
   			
   		#print "\n" . $query . "\n";
   		#$podcasts{$item->{'itemName'}} = $item->{'itemId'};
	}
   
   return $count;
}

sub fetchXML {
	my $store = shift;
	my $url = shift;
	my $curl = qq{curl -s -H 'Host: itunes.apple.com' -H 'Accept-Language: en-us, en;q=0.50' -H 'X-Apple-Tz: 3600' --user-agent 'iTunes/9.2.1 (Macintosh; Intel Mac OS X 10.5.8) AppleWebKit/533.16' -H "X-Apple-Store-Front: $store-1,12" '$url' | xmllint --nowarning --format - };
	return `$curl 2>/dev/null`;
}