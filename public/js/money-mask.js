/*
 * money-mask.js
 *
 * Masking angka untuk textbox nominal: pemisah ribuan koma, pemisah desimal
 * titik, dan hanya menerima angka. Dipakai di form input cepat valas.
 *
 * Cara pakai: beri class "inp-money" pada input, dan data-decimal untuk jumlah
 * angka di belakang koma (default 2). Contoh:
 *
 *   <input type="text" class="form-control inp-money" data-decimal="4">
 *
 * Semua penanganan memakai event delegation di document, jadi baris tabel yang
 * dibuat javascript sesudah halaman siap ikut ter-masking tanpa perlu dipasang
 * ulang.
 *
 * Nilai yang dikirim ke server tetap harus dibersihkan dari koma memakai
 * cleanNumber() seperti sebelumnya.
 */
(function ($) {
    'use strict';

    function jumlahDesimal($el) {
        var d = parseInt($el.attr('data-decimal'), 10);
        return isNaN(d) ? 2 : d;
    }

    /**
     * Buang semua yang bukan angka atau titik, sisakan satu titik saja, dan
     * potong angka di belakang titik sesuai batas desimalnya.
     */
    function bersihkanKetikan(nilai, desimal) {
        var teks = String(nilai).replace(/[^0-9.]/g, '');

        var titik = teks.indexOf('.');
        if (titik !== -1) {
            teks = teks.slice(0, titik + 1) + teks.slice(titik + 1).replace(/\./g, '');
        }

        if (desimal === 0) {
            return teks.split('.')[0];
        }

        var bagian = teks.split('.');
        if (bagian.length > 1) {
            bagian[1] = bagian[1].slice(0, desimal);
            return bagian[0] + '.' + bagian[1];
        }

        return teks;
    }

    /** Sisipkan koma tiap tiga digit di bagian bulatnya saja */
    function beriPemisahRibuan(teks) {
        var bagian = teks.split('.');
        var bulat = bagian[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');

        // Titik yang baru diketik dipertahankan supaya user bisa lanjut mengetik desimal
        return bagian.length > 1 ? bulat + '.' + bagian[1] : bulat;
    }

    /** Bentuk akhir saat input ditinggalkan: desimal dilengkapi */
    function rapikan(teks, desimal) {
        var angka = parseFloat(String(teks).replace(/,/g, ''));
        if (isNaN(angka)) {
            return '';
        }

        return angka.toLocaleString('en-US', {
            minimumFractionDigits: desimal,
            maximumFractionDigits: desimal
        });
    }

    $(document).on('keypress', '.inp-money', function (e) {
        // Biarkan tombol kendali (backspace, tab, panah, dan sejenisnya)
        if (e.which === 0 || e.which === 8 || e.ctrlKey || e.metaKey) {
            return;
        }

        var karakter = String.fromCharCode(e.which);

        if (/[0-9]/.test(karakter)) {
            return;
        }

        // Titik hanya boleh satu, dan hanya kalau desimalnya memang dipakai
        if (karakter === '.' && jumlahDesimal($(this)) > 0 && this.value.indexOf('.') === -1) {
            return;
        }

        e.preventDefault();
    });

    $(document).on('input', '.inp-money', function () {
        var $el = $(this);
        var desimal = jumlahDesimal($el);

        // Jarak caret dihitung dari kanan supaya posisinya tidak melompat
        // ketika koma bertambah atau berkurang di sebelah kirinya.
        var dariKanan = this.value.length - (this.selectionEnd || 0);

        var bersih = bersihkanKetikan(this.value, desimal);
        this.value = beriPemisahRibuan(bersih);

        if (this.setSelectionRange) {
            var posisi = Math.max(0, this.value.length - dariKanan);
            try {
                this.setSelectionRange(posisi, posisi);
            } catch (abaikan) {
                // input type tertentu tidak mendukung setSelectionRange
            }
        }
    });

    $(document).on('blur', '.inp-money', function () {
        var $el = $(this);
        var rapi = rapikan(this.value, jumlahDesimal($el));

        if (rapi !== this.value) {
            this.value = rapi;
            // Beri tahu penghitung total bahwa nilainya berubah
            $el.trigger('change');
        }
    });

    $(document).on('focus', '.inp-money', function () {
        var input = this;
        window.setTimeout(function () {
            if (input.select) {
                input.select();
            }
        }, 0);
    });

    // Angka yang sudah tercetak di halaman saat pertama kali dibuka
    $(function () {
        $('.inp-money').each(function () {
            this.value = rapikan(this.value, jumlahDesimal($(this)));
        });
    });
})(jQuery);
