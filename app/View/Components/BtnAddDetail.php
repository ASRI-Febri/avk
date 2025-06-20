<?php

namespace App\View\Components;

use Illuminate\View\Component;

class BtnAddDetail extends Component
{
    public $id;
    public $label;

    /**
     * Create a new component instance.
     *
     * @return void
     */
    public function __construct($id, $label='Add New')
    {
        $this->id = $id;
        $this->label = $label;
    }

    /**
     * Get the view / contents that represent the component.
     *
     * @return \Illuminate\View\View|string
     */
    public function render()
    {
        return view('components.btn-add-detail');
    }
}
