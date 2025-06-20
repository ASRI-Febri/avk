<?php

namespace App\View\Components;

use Illuminate\View\Component;

class BtnDuplicateDetail extends Component
{
    public $id;
    public $function;

    /**
     * Create a new component instance.
     *
     * @return void
     */
    public function __construct($id, $function='duplicateDetail')
    {
        $this->id = $id;
        $this->function = $function;
    }

    /**
     * Get the view / contents that represent the component.
     *
     * @return \Illuminate\View\View|string
     */
    public function render()
    {
        return view('components.btn-duplicate-detail');
    }
}
