<div wire:ignore.self class="modal fade" id="registrarModal" data-backdrop="static" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">{{ $regis_update }} Usuario</h5>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body p-4">
                <form>
                    <div class="form-group">
                        <label for="username">Usuario / Correo</label>
                        <input wire:model.defer="username" class="form-control" placeholder="Ingrese nombre de usuario">
                        <x-validacion_input for="username" />
                    </div>

                    <div class="form-group">
                        <label for="password">Contraseña</label>
                        <input wire:model.defer="password" type="password" class="form-control" placeholder="Ingrese contraseña">
                        <x-validacion_input for="password" />
                        @if($regis_update === 'Actualizar')
                            <small class="text-muted">Deje en blanco para mantener la contraseña actual</small>
                        @endif
                    </div>

                    <div class="form-group">
                        <label for="nombres">Nombres</label>
                        <input wire:model.defer="nombres" class="form-control" placeholder="Ingrese nombres">
                        <x-validacion_input for="nombres" />
                    </div>

                    <div class="form-group">
                        <label for="apellidos">Apellidos</label>
                        <input wire:model.defer="apellidos" class="form-control" placeholder="Ingrese apellidos">
                        <x-validacion_input for="apellidos" />
                    </div>

                    <div class="form-group">
                        <label for="rol">Rol</label>
                        <select wire:model.defer="rol" class="form-control">
                            <option value="">--- SELECCIONA ROL ---</option>
                            <option value="admin">ADMINISTRADOR</option>
                            <option value="docente">DOCENTE</option>
                            <option value="auxiliar">AUXILIAR</option>
                        </select>
                        <x-validacion_input for="rol" />
                    </div>

                    <div class="form-group">
                        <label for="estado">Estado</label>
                        <select wire:model.defer="estado" class="form-control">
                            <option value="">--- SELECCIONA ESTADO ---</option>
                            <option value="activo">ACTIVO</option>
                            <option value="inactivo">INACTIVO</option>
                        </select>
                        <x-validacion_input for="estado" />
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                <button class="btn btn-primary" wire:click.prevent="registrar()">{{ $regis_update }}</button>
            </div>
        </div>
    </div>
</div>