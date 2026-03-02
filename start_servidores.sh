#!/bin/bash

# Iniciar Laravel (ubicado en panel_administrativo)
cd panel_administrativo
gnome-terminal -- bash -c "php artisan serve --host=0.0.0.0 --port=9000; exec bash"
cd ..

# Iniciar el script Python (ubicado en apibuscar)
cd apibuscar
gnome-terminal -- bash -c "python3 main.py; exec bash"
cd ..

