{{--
    Render satu section Balance Sheet (Aset / Liabilitas / Ekuitas).
    Expects:
      $section    : ['title','groups','total']  — subtotal/total = ['prior','current','ending']
      $totalLabel : string

    Kolom: NO | COA | URAIAN | SALDO M-1 | MUTASI | SALDO AKHIR
--}}

<tr style="background:#d9edf7;">
    <th class="text-left" colspan="6">{{ $section['title'] }}</th>
</tr>

@if(count($section['groups']) === 0)
    <tr>
        <td class="text-center">-</td>
        <td></td>
        <td><em>(tidak ada saldo)</em></td>
        <td class="text-right">0.00</td>
        <td class="text-right">0.00</td>
        <td class="text-right">0.00</td>
    </tr>
@else
    @foreach($section['groups'] as $group)

        {{-- Group header --}}
        <tr style="background:#f5f5f5;">
            <th class="text-left" colspan="6">&nbsp;&nbsp;{{ $group['title'] }}</th>
        </tr>

        {{-- Leaf COA rows --}}
        @foreach($group['rows'] as $i => $row)
            <tr>
                <td class="text-center">{{ $i + 1 }}</td>
                <td class="text-center">{{ $row['COA'] }}</td>
                <td>&nbsp;&nbsp;&nbsp;&nbsp;{{ $row['COADesc'] }}</td>
                <td class="text-right">{{ number_format($row['amount_prior'], 2, '.', ',') }}</td>
                <td class="text-right">{{ number_format($row['amount_current'], 2, '.', ',') }}</td>
                <td class="text-right">{{ number_format($row['amount'], 2, '.', ',') }}</td>
            </tr>
        @endforeach

        {{-- Group subtotal --}}
        <tr>
            <td colspan="3" class="text-right">
                <span class="total">Subtotal {{ $group['title'] }}</span>
            </td>
            <td class="text-right">
                <span class="total">{{ number_format($group['subtotal']['prior'], 2, '.', ',') }}</span>
            </td>
            <td class="text-right">
                <span class="total">{{ number_format($group['subtotal']['current'], 2, '.', ',') }}</span>
            </td>
            <td class="text-right">
                <span class="total">{{ number_format($group['subtotal']['ending'], 2, '.', ',') }}</span>
            </td>
        </tr>
    @endforeach
@endif

{{-- Section total --}}
<tr>
    <td colspan="3" class="text-right"><strong>{{ $totalLabel }}</strong></td>
    <td class="text-right">
        <strong>{{ number_format($section['total']['prior'], 2, '.', ',') }}</strong>
    </td>
    <td class="text-right">
        <strong>{{ number_format($section['total']['current'], 2, '.', ',') }}</strong>
    </td>
    <td class="text-right">
        <strong>{{ number_format($section['total']['ending'], 2, '.', ',') }}</strong>
    </td>
</tr>
