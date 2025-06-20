<?php

namespace App\Providers;

use Illuminate\Foundation\Support\Providers\RouteServiceProvider as ServiceProvider;
use Illuminate\Support\Facades\Route;

class RouteServiceProvider extends ServiceProvider
{
    /**
     * This namespace is applied to your controller routes.
     *
     * In addition, it is set as the URL generator's root namespace.
     *
     * @var string
     */
    protected $namespace = 'App\Http\Controllers';

    /**
     * The path to the "home" route for your application.
     *
     * @var string
     */
    public const HOME = '/home';

    /**
     * Define your route model bindings, pattern filters, etc.
     *
     * @return void
     */
    public function boot()
    {
        //

        parent::boot();
    }

    /**
     * Define the routes for the application.
     *
     * @return void
     */
    public function map()
    {
        $this->mapApiRoutes();

        $this->mapWebRoutes();

        //
    }

    /**
     * Define the "web" routes for the application.
     *
     * These routes all receive session state, CSRF protection, etc.
     *
     * @return void
     */
    protected function mapWebRoutes()
    {
        Route::group([
            'middleware' => 'web',
            'namespace' => $this->namespace,
        ], function ($router) {      
            require base_path('routes/web.php');      
            require base_path('routes/web/security.php');
            require base_path('routes/web/parking.php');
            require base_path('routes/web/inventory.php');
            require base_path('routes/web/general.php');
            require base_path('routes/web/finance.php');
            require base_path('routes/web/accounting.php');
            // require base_path('routes/web/retail.php'); 
            require base_path('routes/web/procurement.php'); 
            // require base_path('routes/web/property_sales.php'); 
            // require base_path('routes/web/property_management.php');   
            require base_path('routes/web/pawn.php'); 
            require base_path('routes/web/loan.php');    
            require base_path('routes/web/moneychanger.php');       
        });
    }

    /**
     * Define the "api" routes for the application.
     *
     * These routes are typically stateless.
     *
     * @return void
     */
    protected function mapApiRoutes()
    {
        Route::prefix('api')
            ->middleware('api')
            ->namespace($this->namespace)
            ->group(base_path('routes/api.php'));
    }
}
