<?php
require 'vendor/autoload.php';
$app = require 'bootstrap/app.php';
$kernel = $app->make(\Illuminate\Contracts\Http\Kernel::class);
$response = $kernel->handle(
    $request = \Illuminate\Http\Request::create('/api/dashboard', 'GET')
);
echo $response->getContent();
