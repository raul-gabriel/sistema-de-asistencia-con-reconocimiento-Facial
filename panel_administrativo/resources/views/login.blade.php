<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Iniciar Sesión</title>

    <link rel="stylesheet" href="{{ asset('recursos/plugins/fontawesome-free/css/all.min.css') }}">
    <link rel="stylesheet" href="{{ asset('recursos/plugins/icheck-bootstrap/icheck-bootstrap.min.css') }}">
    <link rel="stylesheet" href="{{ asset('recursos/dist/css/adminlte.min.css') }}">
</head>
</head>


<style>
    .img-thumbnail {
        padding: 0.25rem;
        background-color: #fff;
        max-width: 100%;
        height: auto;
        border: 0px solid #F35B3F !important;
        border-radius: 0.25rem !important;
        box-shadow: 0 1px 2px rgb(0 0 0 / 0%) !important;
    }

    .card-primary.card-outline {
        border-top: 3px solid #32A56A !important;
    }


    .btn-primary {
        color: #fff !important;
        background-color: #32A56A !important;
        border-color: #32A56A !important;
        box-shadow: none !important;
    }

    .link {
        font-weight: bold;
        color: #155634;
    }
</style>

<body class="hold-transition login-page">
    <div class="login-box">
        <!-- /.login-logo -->
        <div class="card card-outline card-primary">
            <div class="card-header text-center">

                <div class="col-12">

                    <img class="img-thumbnail" src="{{ asset('recursos/recursos/imagenes/cuscocode.png') }}"
                        width="200">
                </div>


            </div>
            <div class="card-body">
                <form id="formulario" autocomplete="off" method="POST" action="{{ url('/login') }}">
                    @csrf
                    <div class="input-group mb-3">
                        <input type="text" class="form-control" placeholder="Usuario / Correo" type="email" name="email"
                            id="email" required>
                        @error('email')
                            <span class="text-danger d-block">{{ $message }}</span>
                        @enderror

                        <div class="input-group-append">
                            <div class="input-group-text">
                                <span class="fas fa-user"></span>
                            </div>
                        </div>
                    </div>
                    <div class="input-group mb-3">
                        <input class="form-control" placeholder="Contraseña" type="password" name="password"
                            id="password" required>
                        @error('password')
                            <span class="text-danger d-block">{{ $message }}</span>
                        @enderror

                        <div class="input-group-append">
                            <div class="input-group-text">
                                <span class="fas fa-lock"></span>
                            </div>
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary btn-block" id="btnAccion">Login</button>
                </form>

                <div class="row mt-5">


                    @if (session('error'))

                        <div class="alert alert-danger alert-dismissible col-12">
                            <button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>
                            <h5><i class="icon fas fa-ban"></i>
                                ¡Alerta!
                            </h5>
                            {{ session('error') }}
                        </div>




                    @endif




                </div>

                <!-- 
                <p class="mt-4">
                    <a href="#" class="link">Olvidaste tu contraseña</a>
                </p>
                -->
            </div>
            <!-- /.card-body -->
        </div>
        <!-- /.card -->
    </div>
    <!-- /.login-box -->

    <script src="{{ asset('recursos/plugins/jquery/jquery.min.js') }}"></script>
    <script src="{{ asset('recursos/plugins/bootstrap/js/bootstrap.bundle.min.js') }}"></script>
    <script src="{{ asset('recursos/dist/js/adminlte.min.js') }}"></script>


</body>

</html>