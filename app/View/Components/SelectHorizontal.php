<?php

namespace App\View\Components;

use Illuminate\View\Component;

class SelectHorizontal extends Component
{
    public $label;
    public $id;
    public $class;
    public $value;
    public $array;
    public $flag;

    /**
     * Create a new component instance.
     *
     * @return void
     */
    public function __construct($label, $id, $class, $value, $array, $flag = '')
    {
        $this->label = $label;
        $this->id = $id;
        $this->class = $class;
        $this->value = $value;
        $this->array = $array;
        $this->flag = $flag;
    }

    /**
     * Get the view / contents that represent the component.
     *
     * @return \Illuminate\View\View|string
     */
    public function render()
    {
        return view('components.select-horizontal');
    }
}
