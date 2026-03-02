<div>
    <aside class="main-sidebar sidebar-dark-primary elevation-4">

        <div
            class="sidebar os-host os-theme-light os-host-overflow os-host-overflow-y os-host-resize-disabled os-host-scrollbar-horizontal-hidden os-host-transition">
            <div class="os-viewport os-viewport-native-scrollbars-invisible">
                <!-- Brand Logo -->
                <a href="#" class="brand-link">
                    <img src="{{ asset('recursos/recursos/imagenes/cuscocode.png') }}" alt="logo cuscocode"
                        class="brand-image img-circle" style="width: 250ox;">
                    <span class="brand-text font-weight-light">.</span>
                </a>

                <!-- Sidebar -->
                <div class="sidebar">
                    <!-- Sidebar user panel (optional) -->
                    <div class="user-panel mt-3 pb-3 mb-3 d-flex">
                        <div class="image">
                            <img src="{{ asset('recursos/recursos/imagenes/avatar.png') }}" class="img-circle elevation-2"
                                alt="User Image">
                        </div>
                        <div class="info">
                            <a href="#" class="d-block">{{ explode(' ', auth()->user()->nombres)[0] }}</a>

                            <a href="#" class="d-block">{{ auth()->user()->rol }}</a>

                        </div>
                    </div>

                    <!-- SidebarSearch Form -->
                    <div class="form-inline">
                        <div class="input-group" data-widget="sidebar-search">
                            <input class="form-control form-control-sidebar" type="search" placeholder="Buscar"
                                aria-label="Search">
                            <div class="input-group-append">
                                <button class="btn btn-sidebar">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16"
                                        fill="currentColor" class="bi bi-search" viewBox="0 0 16 16">
                                        <path
                                            d="M11.742 10.344a6.5 6.5 0 1 0-1.397 1.398h-.001c.03.04.062.078.098.115l3.85 3.85a1 1 0 0 0 1.415-1.414l-3.85-3.85a1.007 1.007 0 0 0-.115-.1zM12 6.5a5.5 5.5 0 1 1-11 0 5.5 5.5 0 0 1 11 0z" />
                                    </svg>
                                </button>
                            </div>
                        </div>
                    </div>



                    <!-- Sidebar Menu -->

                    <nav class="mt-2">
                        <ul class="nav nav-pills nav-sidebar flex-column" data-widget="treeview" role="menu"
                            data-accordion="false">










                            @if(auth()->user()->rol == 'admin' )
                            
                       
                            <li class="nav-item">
                                <a href="{{ url('/usuarios') }}" class="nav-link">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16"
                                        fill="currentColor" class="bi bi-person-heart" viewBox="0 0 16 16">
                                        <path
                                            d="M9 5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Zm-9 8c0 1 1 1 1 1h10s1 0 1-1-1-4-6-4-6 3-6 4Zm13.5-8.09c1.387-1.425 4.855 1.07 0 4.277-4.854-3.207-1.387-5.702 0-4.276Z" />
                                    </svg>
                                    <p>
                                        Usuarios
                                    </p>
                                </a>
                            </li>


                            <li class="nav-item">
                                <a href="{{ url('/horarios') }}" class="nav-link">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16"
                                        fill="currentColor" class="bi bi-person-heart" viewBox="0 0 16 16">
                                        <path
                                            d="M9 5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Zm-9 8c0 1 1 1 1 1h10s1 0 1-1-1-4-6-4-6 3-6 4Zm13.5-8.09c1.387-1.425 4.855 1.07 0 4.277-4.854-3.207-1.387-5.702 0-4.276Z" />
                                    </svg>
                                    <p>
                                        Horarios
                                    </p>
                                </a>
                            </li>


                            <li class="nav-item">
                                <a href="{{ url('/alumnos') }}" class="nav-link">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16"
                                        fill="currentColor" class="bi bi-person-heart" viewBox="0 0 16 16">
                                        <path
                                            d="M9 5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Zm-9 8c0 1 1 1 1 1h10s1 0 1-1-1-4-6-4-6 3-6 4Zm13.5-8.09c1.387-1.425 4.855 1.07 0 4.277-4.854-3.207-1.387-5.702 0-4.276Z" />
                                    </svg>
                                    <p>
                                        Alumnos
                                    </p>
                                </a>
                            </li>

                            <li class="nav-item">
                                <a href="{{ url('/embedding') }}" class="nav-link">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16"
                                        fill="currentColor" class="bi bi-person-heart" viewBox="0 0 16 16">
                                        <path
                                            d="M9 5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Zm-9 8c0 1 1 1 1 1h10s1 0 1-1-1-4-6-4-6 3-6 4Zm13.5-8.09c1.387-1.425 4.855 1.07 0 4.277-4.854-3.207-1.387-5.702 0-4.276Z" />
                                    </svg>
                                    <p>
                                        Embedding
                                    </p>
                                </a>
                            </li>

                            

                            @endif

                            <li class="nav-item">
                                <a href="{{ url('/asistencias') }}" class="nav-link">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16"
                                        fill="currentColor" class="bi bi-person-heart" viewBox="0 0 16 16">
                                        <path
                                            d="M9 5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Zm-9 8c0 1 1 1 1 1h10s1 0 1-1-1-4-6-4-6 3-6 4Zm13.5-8.09c1.387-1.425 4.855 1.07 0 4.277-4.854-3.207-1.387-5.702 0-4.276Z" />
                                    </svg>
                                    <p>
                                        Asistencias
                                    </p>
                                </a>
                            </li>

                          




                        </ul>

                    </nav>



                    <!-- /.sidebar-menu -->
                </div>
                <!-- /.sidebar -->
            </div>
        </div>

    </aside>


    <!-- MODAL SOPORTE -->
    <div class="modal fade" id="soporteModal" tabindex="-1" role="dialog" aria-labelledby="soporteModal"
        aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="createDataModalLabel">Sistema de Catalogo
                    </h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true close-btn">×</span>
                    </button>
                </div>



                <div class="modal-body">

                    <div class="row">
                        <div class="col">

                            <!-- Profile Image -->
                            <div class="card card-success card-outline">
                                <div class="card-body box-profile">
                                    <div class="text-center">
                                        <img class="profile-user-img img-fluid img-circle"
                                            src="{{ asset('recursos/recursos/imagenes/cuscocode.png') }}"
                                            alt="User profile picture" _mstalt="391326">
                                    </div>

                                    <h3 class="profile-username text-center">Ing. Raul Gabriel Hacho Cutipa</h3>

                                    <p class="text-muted text-center">Desarrollador de Software</p>

                                    <ul class="list-group list-group-unbordered mb-3">
                                        <li class="list-group-item">
                                            <b>Telefono:</b> <a class="float-right">+51 940 500 006</a>
                                        </li>
                                        <li class="list-group-item">
                                            <b>Facebook</b> <a class="float-right"
                                                href="https://www.facebook.com/el.hacker.griss">@el.hacker.griss</a>
                                        </li>
                                        <li class="list-group-item">
                                            <b>Direccion</b> <a class="float-right">Oropesa - Cusco</a>
                                        </li>
                                    </ul>

                                    <a href="tel:+51940500006" class="btn btn-danger btn-block"><b>Llamar</b></a>


                                    <br><br>
                                    <div class="alert " role="alert" style="background-color: #F8D7DA">
                                        La mayoría de los buenos programadores programan, no porque esperan que se les
                                        pague o por adulación por parte del público, sino porque programar es divertido
                                        o simplemente es nuestra pasion
                                    </div>
                                </div>
                                <!-- /.card-body -->
                            </div>

                        </div>
                    </div>

                </div>

            </div>
        </div>
    </div>



</div>