<table class="table table-bordered">
    <thead>
        <tr>
            <th scope="col">#</th>
            <th scope="col">Address Type</th>
            <th scope="col">Address</th>
            {{-- <th scope="col">City</th>
            <th scope="col">Zip</th> --}}
            <th scope="col">Default ?</th> 
            
            @if(!isset($show_action) || $show_action == TRUE)
            <th scope="col" class="text-center">Action</th>
            @endif
        </tr>
    </thead>
    <tbody>
    @if($records_address)   
        @php
            $seqno = 0;
        @endphp     

        @foreach($records_address as $row)
        @php
            $seqno += 1;
        @endphp
        <tr>
            <td>{{ $seqno }}</td>
            <td>{{ $row->AddressTypeName }}</td>
            <td>
                <span style="display:block">{{ $row->Street }}</span>
                <span style="display:block">{{ $row->CityDescription }}</span>
                <span style="display:block">{{ $row->Zip }}</span>
            </td>
            {{-- <td>{{ $row->CityDescription }}</td>
            <td>{{ $row->Zip }}</td> --}}

            <td class="text-center">
                @if($row->IsDefault == 'Y')
                <i class="fas fa-check"></i>
                @else 
                
                @endif
            </td> 

            <td class="text-center">                
                <div class="input-group-prepend text-center">
                    <x-btn-edit-detail :id="$row->IDX_M_PartnerAddress" function="editAddress" />
                    <x-btn-delete-detail :id="$row->IDX_M_PartnerAddress" :label="$row->Street" function="deleteAddress" />                    
                </div>                
            </td>
        </tr>
        @endforeach
    @endif
    </tbody>
</table>
