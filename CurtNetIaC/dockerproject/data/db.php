<?php // error_reporting(0);
			// DB Connection
			$dbhost = $_SERVER['RDS_HOSTNAME'];
			$dbport = $_SERVER['RDS_PORT'];
			$dbname = $_SERVER['RDS_DB_NAME'];
			$charset = 'utf8' ;

			$dsn = "mysql:host={$dbhost};port={$dbport};dbname={$dbname};charset={$charset}";
			$username = $_SERVER['RDS_USERNAME'];
			$password = $_SERVER['RDS_PASSWORD'];
         
         try {
    $conn = new PDO($dsn, $username, $password);
} catch (PDOException $e) {
    print "Error: " . $e->getMessage();
}
?>