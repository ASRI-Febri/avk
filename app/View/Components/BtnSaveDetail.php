<?php

namespace App\View\Components;

use Illuminate\View\Component;

class BtnSaveDetail extends Component
{
    public $id;
    public $table;
    public $label;
    public $url;

    /**
     * Create a new component instance.
     *
     * @return void
     */
    
    public function __construct($id, $table, $label, $url)
    {
        $this->id = $id;
        $this->table = $table;
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
        return view('components.btn-save-detail');
    }
}
