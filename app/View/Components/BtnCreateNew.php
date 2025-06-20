<?php

namespace App\View\Components;

use Illuminate\View\Component;

class BtnCreateNew extends Component
{
    public $label;
    public $url;
    /**
     * Create a new component instance.
     *
     * @return void
     */
    public function __construct($label, $url)
    {
        $this->label = $label;
        $this->url = $url;
    }

    /**
     * Get the view / contents that represent the component.
     *
     * @return \Illuminate\View\View|string
     */
    public function render()
    {
        return view('components.btn-create-new');
    }
}
