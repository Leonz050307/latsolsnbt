<?php
namespace App\Core;

class RateLimiter
{
    public static function check(string $key, int $max, int $window): bool
    {
        if (session_status() !== PHP_SESSION_ACTIVE) {
            session_start();
        }
        $bucketKey = 'rate_' . sha1($key);
        $now = time();
        if (!isset($_SESSION[$bucketKey])) {
            $_SESSION[$bucketKey] = ['reset' => $now + $window, 'count' => 0];
        }
        $bucket = &$_SESSION[$bucketKey];
        if ($bucket['reset'] < $now) {
            $bucket = ['reset' => $now + $window, 'count' => 0];
        }
        if ($bucket['count'] >= $max) {
            return false;
        }
        $bucket['count']++;
        return true;
    }
}
