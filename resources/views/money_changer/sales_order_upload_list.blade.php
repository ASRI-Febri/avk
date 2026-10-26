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
                    @if(in_array(strtolower(pathinfo($row->FileName, PATHINFO_EXTENSION)), ['jpg', 'jpeg', 'png', 'gif']))
                    <br>
                    <a href="#" onclick="viewUploadImage(this); return false;"
                        data-src="{{ url('/mc-sales-order-view-file?filepath='.urlencode($row->FilePath.'/'.$row->FileName)) }}"
                        data-title="{{ basename($row->FileName) }}">
                        <span class="text-success"><i class="fa fa-eye"></i> <strong>View Gambar</strong></span>
                    </a>
                    @endif
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

<div class="modal fade" id="modal-view-upload-image" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"></h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body text-center">
                <img src="" alt="" class="img-fluid" style="max-height: 75vh;">
            </div>
        </div>
    </div>
</div>

<script>
    function viewUploadImage(link)
    {
        // PINDAHKAN MODAL KE BODY AGAR TIDAK TERPOTONG/TERTUTUP OLEH .table-responsive
        var inner = $(link).closest('table').nextAll('#modal-view-upload-image');
        if (inner.length) {
            $('body > #modal-view-upload-image').remove();
            inner.appendTo('body');
        }

        var modal = $('body > #modal-view-upload-image');
        modal.find('.modal-title').text($(link).data('title'));
        modal.find('img').attr('src', $(link).data('src'));
        bootstrap.Modal.getOrCreateInstance(modal[0]).show();
    }
</script>
