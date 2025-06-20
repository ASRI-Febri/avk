<?php

namespace App\View\Components;

use Illuminate\View\Component;

class MenuItem extends Component
{
    public $label;
    public $id;
    public $class;
    public $href;
    
    /**
     * Create a new component instance.
     *
     * @return void
     */
    public function __construct(string $label, string $id, string $class, string $href)
    {
        $this->label = $label;
        $this->id = $id;
        $this->class = $class;
        $this->href = $href;        
    }

    /**
     * Get the view / contents that represent the component.
     *
     * @return \Illuminate\View\View|string
     */
    public function render()
    {
        return view('components.menu-item');
    }
}
