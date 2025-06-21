<table class="table table-bordered">
    <thead>
        <tr>
            <th scope="col">#</th>
            <th scope="col">Bank Name</th>
            <th scope="col">Bank Account No</th>
            <th scope="col">Name on Account</th> 
            <th class="text-center">Default ?</th>           
            
            @if(!isset($show_action) || $show_action == TRUE)
            <th scope="col" class="text-center">Action</th>
            @endif
        </tr>
    </thead>
    <tbody>
    @if($records_bank)   
        @php
            $seqno = 0;
        @endphp     

        @foreach($records_bank as $row)
        @php
            $seqno += 1;
        @endphp
        <tr>
            <td>{{ $seqno }}</td>
            <td>{{ $row->BankName }}</td>
            <td>{{ $row->BankAccountNo }}</td>
            <td>{{ $row->BankAccountName }}</td>   
            <td class="text-center">
                @if($row->IsDefault == 'Y')
                <i class="fas fa-check"></i>
                @else 
                
                @endif
            </td>         
            <td class="text-center">                
                <div class="input-group-prepend text-center">
                    <x-btn-edit-detail :id="$row->IDX_M_PartnerBank" function="editBank"/>
                    <x-btn-delete-detail :id="$row->IDX_M_PartnerBank" :label="$row->BankAccountNo" function="deleteBank"/>                    
                </div>                
            </td>
        </tr>
        @endforeach
    @endif
    </tbody>
</table>
