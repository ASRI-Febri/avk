<?php

namespace App\View\Components;

use Illuminate\View\Component;

class BtnDeleteDetail extends Component
{
    public $label;
    public $id;
    public $function;
    /**
     * Create a new component instance.
     *
     * @return void
     */
    public function __construct($label, $id, $function='deleteDetail')
    {
        $this->label = $label;
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
        return view('components.btn-delete-detail');
    }
}
