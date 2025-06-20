<?php

namespace App\View\Components;

use Illuminate\View\Component;

class SwitchHorizontal extends Component
{
    public $label;
    public $id;
    public $name;
    public $value;
    public $checked;

    /**
     * Create a new component instance.
     *
     * @return void
     */
    public function __construct($label, $id, $name, $checked)
    {
        $this->label = $label;
        $this->id = $id;
        $this->name = $name;
        $this->checked = $checked;
    }

    /**
     * Get the view / contents that represent the component.
     *
     * @return \Illuminate\View\View|string
     */
    public function render()
    {
        return view('components.switch-horizontal');
    }
}
