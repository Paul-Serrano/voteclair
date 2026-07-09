<?php

use Illuminate\Contracts\Http\Kernel;
use Illuminate\Http\Request;

require 'vendor/autoload.php';
$app = require 'bootstrap/app.php';
$kernel = $app->make(Kernel::class);
$response = $kernel->handle(
    $request = Request::create('/api/dashboard', 'GET')
);
echo $response->getContent();
