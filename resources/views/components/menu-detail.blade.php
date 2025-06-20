<div data-kt-menu-trigger="click" data-kt-menu-placement="bottom-start"
    class="menu-item {{ $class }} menu-lg-down-accordion me-lg-1">
    <span class="menu-link py-3">
        <span class="menu-title">{{ $label }}</span>
        <span class="menu-arrow d-lg-none"></span>
    </span>
    <div class="menu-sub menu-sub-lg-down-accordion menu-sub-lg-dropdown menu-rounded-0 py-lg-4 w-lg-225px">
        {{ $slot }}
    </div>
</div>