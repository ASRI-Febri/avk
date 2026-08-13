@php
    // KOLOM DOKUMEN SUMBER (Document Type / IDX Document No / Document No) HANYA
    // DITAMPILKAN KALAU PEMBAYARAN SUDAH APPROVED. STATUS DIAMBIL DARI BARIS
    // PERTAMA KARENA SEMUA DETAIL MILIK SATU HEADER YANG SAMA.
    $show_document = false;

    if($records_detail)
    {
        foreach($records_detail as $row_first)
        {
            $show_document = (trim($row_first->PaymentStatus) == 'A');
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

            <th scope="col" class="text-end">Payment Amount</th>

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
                $url_delete = url('fm-financial-payment-detail/delete/'.$row->IDX_T_FinancialPaymentDetail);       
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

                        // PMC = Purchase Order Money Changer. Prefiks nomor dokumen dipakai
                        // sebagai cadangan kalau IDX_M_DocumentType data lama tidak konsisten.
                        $document_url = '';

                        if($document_no !== '' && ($document_type_id == 'PMC' || strpos($document_no, 'PMC-') === 0))
                        {
                            $document_url = url('mc-purchase-order/update/'.$row->IDX_DocumentNo);
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
                                title="Link pembayaran ini ke transaksi pembelian"
                                onclick="linkDocument('{{ $row->IDX_T_FinancialPaymentDetail }}')">
                                <i class="fa fa-link me-1"></i> Link Dokumen
                            </a>
                        @endif
                    </td>
                @endif

                <td class="text-end">
                    <span>{{ number_format($row->PaymentAmount, 2, '.', ',') }}</span>
                </td>
                
                @if(!isset($show_action) || $show_action == TRUE)
                <td class="text-center">
                    <div class="input-group-prepend text-center">

                        <a id="btn-allocate" class="btn btn-outline-success btn-sm" href="#" title="Allocate payment with invoice"
                            onclick="allocateDetail('{{ $row->IDX_T_FinancialPaymentDetail }}')">
                            <i class="fa fa-link"></i>
                        </a>

                        @if($row->PaymentStatus == 'D')
                            <x-btn-edit-detail :id="$row->IDX_T_FinancialPaymentDetail" />
                            <x-btn-delete-detail :id="$row->IDX_T_FinancialPaymentDetail" :label="$row->PaymentID" />
                        @endif                                            
                    </div>                    
                </td>
                @endif
            </tr>

            @if($allocation_detail)
                @foreach($allocation_detail as $row1)
                    @if($row1->IDX_T_FinancialPaymentDetail == $row->IDX_T_FinancialPaymentDetail)
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

                            <td class="text-right">
                                <span>({{ number_format($row1->AllocationAmount, 2, '.', ',') }})</span>
                            </td>
                            
                            @if(!isset($show_action) || $show_action == TRUE)
                            <td class="text-center">
                                @if($row1->AllocationStatus == 'D')
                                <div class="input-group-prepend text-center">
                                    <a id="btn-approve" class="btn btn-outline-success btn-sm" href="#" title="Approve"
                                        onclick="approveAllocation('{{ $row1->IDX_T_PaymentAllocation }}')">
                                        <i class="fa fa-check"></i>
                                    </a>
                                    <a id="btn-edit" class="btn btn-outline-secondary btn-sm" href="#" title="Edit"
                                        onclick="editAllocation('{{ $row1->IDX_T_PaymentAllocation }}')">
                                        <i class="fa fa-edit"></i>
                                    </a>
                                    <a id="btn-delete" class="btn btn-outline-danger btn-sm" href="#" title="Delete"
                                        onclick="deleteAllocation('{{ $row1->IDX_T_PaymentAllocation }}')">
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