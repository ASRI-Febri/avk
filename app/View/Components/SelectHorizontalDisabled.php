<?php

namespace App\View\Components;

use Illuminate\View\Component;

class SelectHorizontalDisabled extends Component
{
    public $label;
    public $id;
    public $class;
    public $value;
    public $array;

    /**
     * Create a new component instance.
     *
     * @return void
     */
    public function __construct($label, $id, $class, $value, $array)
    {
        $this->label = $label;
        $this->id = $id;
        $this->class = $class;
        $this->value = $value;
        $this->array = $array;
    }

    /**
     * Get the view / contents that represent the component.
     *
     * @return \Illuminate\View\View|string
     */
    public function render()
    {
        return view('components.select-horizontal-disabled');
    }
}
