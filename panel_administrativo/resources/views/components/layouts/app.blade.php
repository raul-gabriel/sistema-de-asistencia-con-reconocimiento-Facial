<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Sistema de entradas</title>

 
    <x-header />

</head>

<body class="hold-transition sidebar-mini">
    @livewireStyles
    @stack('css')

    <div class="wrapper">

        <!-- cabecera -->
        <x-navar />
        <!-- /.navbar -->
        <!-- menu lateral -->
        <x-menu_lateral />

        <!-- contenedor -->
        <div class="content-wrapper">

            <!-- Main content -->
            <div class="content">
                <div class="container-fluid">
                    @isset($slot)
                        {{ $slot }}
                    @endisset
                </div>
            </div>
        </div>

        <x-pie_pagina />
    </div>

    <x-footer />




    @livewireScripts

</body>


<script>
    document.addEventListener('livewire:init', function () {
        console.log('Livewire cargado');

        Livewire.on('alerta', (data) => {
            console.log(data)
            const { type, message } = data[0];

            // Interpretar cod: 1 → success, 0 → error, cualquier otro → warning
            let icon, timer;
            if (type == 1 || type == 'ok') {
                icon = 'success';
                timer = 1500;
            } else if (type == 0 || type == 'error') {
            icon = 'error';
            timer = 10000;
        } else {
            icon = 'warning';
            timer = 5000;
        }

        Swal.fire({
            position: 'top-end',
            icon,
            title: message,
            showConfirmButton: false,
            timer
        });
    });

    Livewire.on('alerta_stop', (data) => {
        const { type, message } = data[0];

        let icon, timer;
        if (type == 1 || type == 'ok') {
            icon = 'success';
            timer = 1500;
        } else if (type == 0 || type == 'error') {
        icon = 'error';
        timer = 10000;
    } else {
        icon = 'warning';
        timer = 5000;
    }

    Swal.fire({
        icon,
        title: message,
        timer
    });
        });
    });



    Livewire.on('cerrarModal', () => {
        // Asegurarse de que el modal se cierre correctamente
        $('#registrarModal').modal('hide'); // Usar Bootstrap 4 para ocultar el modal

        // Cuando el modal se haya ocultado, eliminar aria-hidden y quitar enfoque
        $('#registrarModal').on('hidden.bs.modal', function () {
            // Eliminar aria-hidden de los elementos de contenedor que están bloqueando el enfoque
            $('body').removeAttr('aria-hidden');
            $('.main-wrapper').removeAttr('aria-hidden');

            // Desenfocar cualquier elemento que tenga el enfoque activo
            document.activeElement.blur();
        });
    });



    // Cerrar modal específico
    Livewire.on('cerrarModalEspecifico', (nombre) => {
        console.log('Cerrando el modal: ', nombre);
        $('#' + nombre).modal('hide');
    });


    Livewire.on('abrirPagina', (data) => {
        const { url} = data[0];
        window.open(url, '_blank');
    });

    Livewire.on('mostrar_pdf', (data) => {
    const { url } = data[0];
    const width = 800;
    const height = 600;
    const left = (screen.width / 2) - (width / 2);
    const top = (screen.height / 2) - (height / 2);

    window.open(
        url,
        'PDF',
        `width=${width},height=${height},top=${top},left=${left},resizable=yes,scrollbars=yes`
    );
});



</script>
@stack('js')


<!-- ver mas y menos -->
<script>
    document.querySelectorAll('.ver-mas').forEach(function (link) {
        link.addEventListener('click', function () {
            var descripcionLimita = this.previousElementSibling.previousElementSibling; // El div de texto truncado
            var descripcionCompleta = this.previousElementSibling; // El div de texto completo
            var textoLink = this; // El enlace "Ver más / Ver menos"

            if (descripcionLimita.style.display === 'none') {
                // Mostrar el texto truncado y ocultar el completo
                descripcionLimita.style.display = 'block';
                descripcionCompleta.style.display = 'none';
                textoLink.textContent = 'Ver más'; // Cambiar el enlace a "Ver más"
            } else {
                // Mostrar el texto completo y ocultar el truncado
                descripcionLimita.style.display = 'none';
                descripcionCompleta.style.display = 'block';
                textoLink.textContent = 'Ver menos'; // Cambiar el enlace a "Ver menos"
            }
        });
    });
</script>




<style>
    .custom-select-container {
        width: 100%;
        max-width: 400px;
        position: relative;
        font-family: Arial, sans-serif;
    }
  
    .custom-select {
        background-color: #fff;
        border: 1px solid #ccc;
        padding: 10px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        cursor: pointer;
        border-radius: 5px;
        font-size: 14px;
        width: 100%;
        color: #000000;
    font-weight: 500;
    }
  
    .custom-select.open {
        border-color: #007bff;
    }
  
    .custom-arrow {
        width: 0;
        height: 0;
        border-left: 5px solid transparent;
        border-right: 5px solid transparent;
        border-top: 5px solid #666;
    }
  
    .custom-dropdown {
        margin-top: 5px;
        position: absolute;
        top: 100%;
        left: 0;
        right: 0;
        background-color: #fff;
        border: 1px solid #ccc;
        border-top: none;
        max-height: 300px;
        overflow-y: auto;
        box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
        z-index: 10;
        width: 100%;
        border-radius: 5px;
    }
  
    .custom-input {
        width: 95%;
        padding: 8px;
        border: 1px solid #155634;
        border-radius: 5px;
        margin-bottom: 10px;
        font-size: 14px;
        margin-top: 5px;
        margin: 5px
    }
  
    .custom-item {
        padding: 10px;
        cursor: pointer;
        transition: background-color 0.3s;
    }
  
    .custom-item:hover {
        background-color: #f1f1f1;
    }
  
    .no-results {
        padding: 10px;
        color: #999;
        font-size: 14px;
    }
  
    /* Responsive */
    @media (max-width: 768px) {
        .custom-select-container {
            max-width: 100%;
        }
    }
  </style>
<!--<script defer src="https://unpkg.com/alpinejs@3.x.x/dist/cdn.min.js"></script> -->  

</html>