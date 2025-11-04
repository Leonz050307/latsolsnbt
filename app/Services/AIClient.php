<?php
namespace App\Services;

class AIClient
{
    private array $config;

    public function __construct(array $config)
    {
        $this->config = $config;
    }

    public function generate(array $messages): array
    {
        $payload = [
            'model' => $this->config['model'],
            'messages' => $messages,
            'response_format' => ['type' => 'json_object'],
        ];

        $ch = curl_init($this->config['endpoint']);
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => json_encode($payload),
            CURLOPT_HTTPHEADER => [
                'Content-Type: application/json',
                'Authorization: Bearer ' . $this->config['api_key'],
            ],
            CURLOPT_TIMEOUT => (int) $this->config['timeout'],
        ]);

        $response = curl_exec($ch);
        if ($response === false) {
            throw new \RuntimeException('AI request failed: ' . curl_error($ch));
        }
        $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        if ($code >= 400) {
            throw new \RuntimeException('AI request returned status ' . $code . ': ' . $response);
        }
        $data = json_decode($response, true);
        return $data;
    }
}
