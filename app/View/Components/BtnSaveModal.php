<?php

namespace App\View\Components;

use Illuminate\View\Component;

class BtnSaveModal extends Component
{
    public $id;    
    public $label;
    public $url;

    /**
     * Create a new component instance.
     *
     * @return void
     */
    public function __construct($id, $label, $url)
    {
        $this->id = $id;        
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
        return view('components.btn-save-modal');
    }
}
