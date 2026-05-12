{{--
    Recursive node renderer for Profit & Loss report.

    Expects:
      $node  : ['title','level','sign','rows','children','subtotal']

    Renders the node header, then either its leaf rows or recurses into children.
--}}

@php
    $indent     = str_repeat('&nbsp;&nbsp;&nbsp;&nbsp;', $node['level']);
    $isLeaf     = empty($node['children']);
    $colspanAll = 5;
@endphp

{{-- Group header --}}
<tr class="{{ $node['level'] === 0 ? 'bg-info' : '' }}">
    <th class="text-left" colspan="{{ $colspanAll }}">
        {!! $indent !!}{{ $node['title'] }}
    </th>
</tr>

{{-- Leaf rows --}}
@if($isLeaf)
    @if(count($node['rows']) === 0)
        <tr>
            <td class="text-center">-</td>
            <td></td>
            <td>{!! $indent !!}<em>(tidak ada data)</em></td>
            <td class="text-right">0.00</td>
            <td></td>
        </tr>
    @else
        @foreach($node['rows'] as $i => $r)
            <tr>
                <td class="text-center">{{ $i + 1 }}</td>
                <td class="text-center">{{ $r['COA'] }}</td>
                <td>{!! $indent !!}{{ $r['COADesc'] }}</td>
                <td class="text-right">{{ number_format($r['amount'], 2, '.', ',') }}</td>
                <td></td>
            </tr>
        @endforeach
    @endif
@else
    {{-- Recurse into children — view does not need to know depth --}}
    @foreach($node['children'] as $child)
        @include('accounting.partials._pl_node', ['node' => $child])
    @endforeach
@endif

{{-- Group subtotal --}}
<tr>
    <td colspan="3" class="text-right">
        <span class="total">{!! $indent !!}Total {{ $node['title'] }}</span>
    </td>
    <td></td>
    <td class="text-right">
        <span class="total">{{ number_format($node['subtotal'], 2, '.', ',') }}</span>
    </td>
</tr>
