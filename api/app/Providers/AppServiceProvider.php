<?php

namespace App\Providers;

use Dedoc\Scramble\Scramble;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        Scramble::ignoreDefaultRoutes();
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Scramble::registerUiRoute('api/documentation')->name('scramble.docs.ui');
        Scramble::registerJsonSpecificationRoute('api/documentation.json')->name('scramble.docs.document');
    }
}
