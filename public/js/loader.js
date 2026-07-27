// Loader halaman untuk proses yang berjalan di server (upload file, baca Excel,
// simpan massal). Dipakai pada form post biasa: overlay tetap tampil sampai
// halaman hasil dimuat, sehingga tidak perlu unblock manual.
function showPageLoader(message)
{
	var target = $('#div-main-content');

	var options = {
		message: '<span class="text-semibold"><i class="fa fa-spinner fa-spin"></i>&nbsp; ' + (message || 'Loading...') + '</span>',
		overlayCSS: {
			backgroundColor: '#fff',
			opacity: 0.8,
			cursor: 'wait'
		},
		css: {
			border: 0,
			padding: '10px 15px',
			color: '#fff',
			width: 'auto',
			'-webkit-border-radius': 2,
			'-moz-border-radius': 2,
			backgroundColor: '#333'
		}
	};

	if (target.length) {
		target.block(options);
	} else {
		$.blockUI(options);
	}
}

function hidePageLoader()
{
	if ($('#div-main-content').length) {
		$('#div-main-content').unblock();
	}

	$.unblockUI();
}

// Pasang loader otomatis pada form ber-atribut data-loader="pesan".
// Loader hanya tampil bila validasi bawaan browser lolos, agar tidak
// tersangkut saat ada field wajib yang belum diisi.
$(document).ready(function ()
{
	$('form[data-loader]').on('submit', function (e)
	{
		// Handler halaman terpasang lebih dulu (@yield('script') dirender sebelum
		// file ini), jadi hormati bila submit sudah dibatalkan oleh validasi sendiri.
		if (e.isDefaultPrevented()) {
			return;
		}

		if (this.checkValidity && !this.checkValidity()) {
			return;
		}

		var btn = $(this).find('button[type="submit"]');
		var busyText = btn.data('loader-text');

		if (btn.length) {
			btn.prop('disabled', true);

			if (busyText) {
				btn.html('<i class="fa fa-spinner fa-spin me-1"></i> ' + busyText);
			}
		}

		showPageLoader($(this).data('loader'));
	});
});
