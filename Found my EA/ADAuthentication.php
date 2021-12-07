// Copyright Tenic Inc 2016-18. All rights reserved.

<?php

$ds = ldap_connect("ldaps://192.168.1.20", 636);
ldap_set_option($ds, LDAP_OPT_NETWORK_TIMEOUT, 3.5);

// echo gethostbyname(php_uname('n'));

if (!$ds) {
	die("-1");
} else {
	
	$ldapbind = ldap_bind($ds, $argv[1] . "@bcis.cn", $argv[2]);
	
	if ($ldapbind) {
		echo "1";
	} else {
		echo "0";
    }
}

?>