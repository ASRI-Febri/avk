<table class="table table-bordered">
    <thead>
        <tr>
            <th scope="col">#</th>
            <th scope="col">Kategori</th>                     
            <th scope="col">Nama File</th>
            <th scope="col">Lokasi File</th>
            <th scope="col">Keterangan</th>

            @if(!isset($show_action) || $show_action == TRUE)
            <th scope="col" class="text-center">Action</th>
            @endif
        </tr>
    </thead>
    <tbody>
    @if($records_upload)

        @php 
            $seq = 0; 			
        @endphp

        @foreach($records_upload as $row)

            @php 
                $seq += 1;
            @endphp

            <tr>
                <td>{{ $seq }}</td>
                <td>{{ $row->UploadCategory }}</td>
                <td>{{ $row->FileName }}</td>
                <td>{{ $row->FilePath }}</td>
                <td>{{ $row->FileDescription }}</td>

                @if(!isset($show_action) || $show_action == TRUE)
                <td class="text-center">      
                    <a href="{{ url('/mc-sales-order-download?filepath='.$row->FilePath.'/'.$row->FileName) }}" target="_blank">																
                        <span class="text-info"><strong>Download :</strong> @php echo basename($row->FileName); @endphp</span>	
                    </a>
                    {{-- <br>    
                    <a href="#" onclick="deleteFile('test')">																
                        <span class="text-danger"><strong>Delete :</strong> @php echo basename($row->FileName); @endphp</span>	
                    </a>     --}}
                </td>
                @endif
            </tr>
        @endforeach       

    @endif
    </tbody>
</table>