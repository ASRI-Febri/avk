<?php

namespace App\View\Components;

use Illuminate\View\Component;

class CheckboxHorizontal extends Component
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
    public function __construct($label, $id, $name, $value, $checked)
    {
        $this->label = $label;
        $this->id = $id;
        $this->name = $name;
        $this->value = $value;
        $this->checked = $checked;
    }

    /**
     * Get the view / contents that represent the component.
     *
     * @return \Illuminate\View\View|string
     */
    public function render()
    {
        return view('components.checkbox-horizontal');
    }
}
