@php
    // KOLOM DOKUMEN SUMBER (Document Type / IDX Document No / Document No) HANYA
    // DITAMPILKAN KALAU PENERIMAAN SUDAH APPROVED. STATUS DIAMBIL DARI BARIS
    // PERTAMA KARENA SEMUA DETAIL MILIK SATU HEADER YANG SAMA.
    $show_document = false;

    if($records_detail)
    {
        foreach($records_detail as $row_first)
        {
            $show_document = (trim($row_first->ReceiveStatus) == 'A');
            break;
        }
    }
@endphp

<table class="table table-bordered">
    <thead>
        <tr>
            <th scope="col">#</th>
            <th scope="col">Project</th>
            <th scope="col">COA</th>          
            <th scope="col">Notes</th>

            @if($show_document)
            <th scope="col">Document No</th>
            @endif

            <th scope="col">Receive Amount</th>

            @if(!isset($show_action) || $show_action == TRUE)
            <th scope="col" class="text-center">Action</th>
            @endif
        </tr>
    </thead>
    <tbody>
    @if($records_detail)

        @php
            $seq = 0;
        @endphp

        @foreach($records_detail as $row)

            @php 
                $seq += 1;
                $url_delete = url('fm-financial-receive-detail/delete/'.$row->IDX_T_FinancialReceiveDetail);       
            @endphp

            <tr>
                <td>{{ $seq }}</td>
                <td>{{ $row->ProjectName }}</td>
                
                <td>                    
                    <span>{{ $row->COAID . ' - ' . $row->COADesc }}</span>
                </td>

                <td>
                    <span>{{ $row->RemarkDetail }}</span>
                </td>

                @if($show_document)
                    @php
                        $document_no = trim($row->DocumentNo ?? '');
                        $document_type_id = trim($row->DocumentTypeID ?? '');

                        // SMC = Sales Order Money Changer. Sebagian data lama tersimpan
                        // dengan IDX_M_DocumentType yang salah (SI), padahal IDX_DocumentNo
                        // menunjuk ke MC_T_SalesOrder, jadi prefiks nomor dokumen dipakai
                        // sebagai cadangan supaya link tetap benar.
                        $document_url = '';

                        if($document_no !== '' && ($document_type_id == 'SMC' || strpos($document_no, 'SMC-') === 0))
                        {
                            $document_url = url('mc-sales-order/update/'.$row->IDX_DocumentNo);
                        }
                    @endphp

                    <td>
                        @if($document_no !== '')
                            @if($document_url !== '')
                                <a href="{{ $document_url }}" target="_blank" rel="noopener noreferrer">
                                    {{ $document_no }}
                                </a>
                            @else
                                <span>{{ $document_no }}</span>
                            @endif

                            {{-- JENIS DOKUMEN & INDEXNYA DITARUH SEBARIS DI BAWAH NOMOR --}}
                            <br>
                            <small class="text-muted">
                                {{ $row->DocumentTypeDesc ?? '-' }} &middot; IDX {{ $row->IDX_DocumentNo }}
                            </small>
                        @else
                            <a id="btn-link-document" class="btn btn-outline-primary btn-sm" href="#"
                                title="Link penerimaan ini ke transaksi penjualan"
                                onclick="linkDocument('{{ $row->IDX_T_FinancialReceiveDetail }}')">
                                <i class="fa fa-link me-1"></i> Link Dokumen
                            </a>
                        @endif
                    </td>
                @endif

                <td class="text-end">
                    <span>{{ number_format($row->ReceiveAmount, 2, '.', ',') }}</span>
                </td>
                
                @if(!isset($show_action) || $show_action == TRUE)
                <td class="text-center">
                    @if($row->ReceiveStatus == 'D')
                    <div class="input-group-prepend text-center">
                        <a id="btn-allocate" class="btn btn-outline-success btn-sm" href="#" title="Allocate"
                            onclick="allocateDetail('{{ $row->IDX_T_FinancialReceiveDetail }}')">
                            <i class="fa fa-link"></i>
                        </a>
                        <x-btn-edit-detail :id="$row->IDX_T_FinancialReceiveDetail" />
                        <x-btn-delete-detail :id="$row->IDX_T_FinancialReceiveDetail" :label="$row->ReceiveID" />                    
                    </div>
                    @endif
                </td>
                @endif
            </tr>

            @if($allocation_detail)
                @foreach($allocation_detail as $row1)
                    @if($row1->IDX_T_FinancialReceiveDetail == $row->IDX_T_FinancialReceiveDetail)
                        <tr>
                            <td></td>
                            <td></td>
                            
                            <td>                    
                                <span>Allocate To :</span>
                            </td>
            
                            <td>                    
                                <span>{{ $row1->AllocationDate }}</span>
                                <br>
                                <span>{{ $row1->DocumentTypeDesc }}</span>
                                <br>
                                <span>
                                    <a href="{{ url($row1->URLDocument) }}" target="_blank">{{ $row1->DocumentNo }}</a>                                    
                                </span>
                                <br>
                                <span>{{ $row1->PartnerName }}</span>
                            </td>

                            {{-- PENYELARAS KOLOM DOKUMEN SUMBER DI BARIS ALOKASI --}}
                            @if($show_document)
                            <td></td>
                            @endif

                            <td class="text-end">
                                <span>({{ number_format($row1->AllocationAmount, 2, '.', ',') }})</span>
                            </td>
                            
                            @if(!isset($show_action) || $show_action == TRUE)
                            <td class="text-center">
                                @if($row1->AllocationStatus == 'D')
                                <div class="input-group-prepend text-center">
                                    <a id="btn-approve" class="btn btn-outline-success btn-sm" href="#" title="Approve"
                                        onclick="approveAllocation('{{ $row1->IDX_T_ReceiveAllocation }}')">
                                        <i class="fa fa-check"></i>
                                    </a>
                                    <a id="btn-edit" class="btn btn-outline-secondary btn-sm" href="#" title="Edit"
                                        onclick="editAllocation('{{ $row1->IDX_T_ReceiveAllocation }}')">
                                        <i class="fa fa-edit"></i>
                                    </a>
                                    <a id="btn-delete" class="btn btn-outline-danger btn-sm" href="#" title="Delete"
                                        onclick="deleteAllocation('{{ $row1->IDX_T_ReceiveAllocation }}')">
                                        <i class="fa fa-trash"></i>
                                    </a>                  
                                </div>
                                @endif
                            </td>
                            @endif
                        </tr>
                    @endif
                @endforeach
            @endif

        @endforeach
       

    @endif
    </tbody>
</table>