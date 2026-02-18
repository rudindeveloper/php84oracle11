<?php
header('Content-Type: text/plain; charset=utf-8');

echo "=== PHP Version ===\n";
echo phpversion() . "\n\n";

echo "=== Extensions Status ===\n";
$extensions = [
    'oci8' => 'Oracle OCI8',
    'pdo_oci' => 'Oracle PDO',
    'pdo_mysql' => 'MySQL PDO',
    'mysqli' => 'MySQLi',
    'pdo_pgsql' => 'PostgreSQL PDO',
    'pgsql' => 'PostgreSQL',
];

foreach ($extensions as $ext => $label) {
    $status = extension_loaded($ext) ? '✓ OK' : '✗ MISSING';
    echo sprintf("%-20s : %s\n", $label, $status);
}

echo "\n=== PDO Drivers ===\n";
print_r(PDO::getAvailableDrivers());

echo "\n=== Test Connections (Commented) ===\n";
/*
// MySQL
try {
    $pdo = new PDO('mysql:host=localhost;dbname=test', 'user', 'pass');
    echo "MySQL: Connected\n";
} catch (PDOException $e) { echo "MySQL: " . $e->getMessage() . "\n"; }

// PostgreSQL
try {
    $pdo = new PDO('pgsql:host=localhost;dbname=test', 'user', 'pass');
    echo "PostgreSQL: Connected\n";
} catch (PDOException $e) { echo "PostgreSQL: " . $e->getMessage() . "\n"; }

// Oracle
try {
    $pdo = new PDO('oci:dbname=//host:1521/XE', 'user', 'pass');
    echo "Oracle: Connected\n";
} catch (PDOException $e) { echo "Oracle: " . $e->getMessage() . "\n"; }
*/