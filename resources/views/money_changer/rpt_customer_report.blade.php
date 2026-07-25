@extends('layouts.report_data')

@section('title')
    {{ $title }}
@endsection

@section('pagetitle')
    {{ $page_title }}
@endsection

@section('content')

    <!-- BEGIN REPORT PARAMETER -->
    <div style="width:100%;">
        <div style="float:left;width:70%;">
            <table>
                <tr>
                    <td class="param-key">IDPJK</td>
                    <td class="param-value">: {{ $IDPJK }}</td>
                </tr>
                <tr>
                    <td class="param-key">TANGGAL PENDAFTARAN</td>
                    <td class="param-value">: {{ date('d M Y',strtotime($fields['start_date'])) . ' - ' .date('d M Y',strtotime($fields['end_date'])) }}</td>
                </tr>
            </table>
        </div>
    </div>
    <br/>
    <hr>
    <br/>
    <!-- END REPORT PARAMETER -->

    <!-- BEGIN REPORT DATA -->
    <table id="table-report" class="minimalistBlack">
        <thead>
            <tr>
                <th>IDPJK</th>
                <th>Kode Nasabah</th>
                <th>Nama Nasabah</th>
                <th>Tempat Lahir</th>
                <th>Tanggal Lahir</th>
                <th>Alamat</th>
                <th>No KTP</th>
                <th>No.Idlain</th>
                <th>No.CIF</th>
                <th>No.NPWP</th>
            </tr>
        </thead>
        <tbody>
        @if($records)
        @foreach ($records as $row)
            <tr>
                <td style="mso-number-format:'\@';">{{ $IDPJK }}</td>
                <td style="mso-number-format:'\@';">{{ $row->PartnerID }}</td>
                <td>{{ strtoupper($row->PartnerName) }}</td>
                <td>{{ strtoupper($row->PlaceOfBirth) }}</td>
                <td style="mso-number-format:'\@';">{{ $row->DateOfBirth ? date('d/m/Y',strtotime($row->DateOfBirth)) : '' }}</td>
                <td>{{ strtoupper($row->Street) }}</td>
                <td style="mso-number-format:'\@';">{{ $row->SingleIdentityNumber }}</td>
                <td style="mso-number-format:'\@';"></td>
                <td style="mso-number-format:'\@';"></td>
                <td style="mso-number-format:'\@';">{{ $row->TaxIdentityNumber }}</td>
            </tr>
        @endforeach
        @endif
        </tbody>
    </table>
    <!-- END REPORT DATA -->

@endsection
