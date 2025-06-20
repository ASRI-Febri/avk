<?php

namespace App\View\Components;

use Illuminate\View\Component;

class BtnEditDetail extends Component
{
    public $id;
    public $function;

    /**
     * Create a new component instance.
     *
     * @return void
     */
    public function __construct($id, $function='editDetail')
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
        return view('components.btn-edit-detail');
    }
}
