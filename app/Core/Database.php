<?php
namespace App\Core;

use PDO;
use PDOException;

class Database
{
    private static ?PDO $pdo = null;

    public static function pdo(): PDO
    {
        if (!self::$pdo) {
            $config = require __DIR__ . '/../Config/config.php';
            $dsn = sprintf('mysql:host=%s;dbname=%s;charset=utf8mb4', $config['db_host'], $config['db_name']);
            try {
                self::$pdo = new PDO($dsn, $config['db_user'], $config['db_pass'], [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false,
                ]);
                self::$pdo->exec("SET time_zone='+07:00'");
            } catch (PDOException $e) {
                throw new PDOException('Database connection failed: ' . $e->getMessage(), (int)$e->getCode());
            }
        }

        return self::$pdo;
    }
}
