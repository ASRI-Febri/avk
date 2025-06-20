<?php

namespace App\View\Components;

use Illuminate\View\Component;

class MenuDetail extends Component
{
    public $label;
    public $class;

    /**
     * Create a new component instance.
     *
     * @return void
     */
    public function __construct(string $label, string $class)
    {
        $this->label = $label;
        $this->class = $class;
    }

    /**
     * Get the view / contents that represent the component.
     *
     * @return \Illuminate\View\View|string
     */
    public function render()
    {
        return view('components.menu-detail');
    }
}
