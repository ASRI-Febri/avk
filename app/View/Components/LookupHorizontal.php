<?php

namespace App\View\Components;

use Illuminate\View\Component;

class LookupHorizontal extends Component
{
    public $label;
    public $id;
    public $class;
    public $value;
    public $button;

    /**
     * Create a new component instance.
     *
     * @return void
     */
    public function __construct($label, $id, $class, $value, $button)
    {
        $this->label = $label;
        $this->id = $id;
        $this->class = $class;
        $this->value = $value;
        $this->button = $button;
    }

    /**
     * Get the view / contents that represent the component.
     *
     * @return \Illuminate\View\View|string
     */
    public function render()
    {
        return view('components.lookup-horizontal');
    }
}
