# Declarator

Éste es un script de Ruby para generar y subir declaraciones sin valor a pagar
al (sistema del SRI)[https://declaraciones.sri.gob.ec/]. Actualmente, sirve
sólo con el formulario 104A (IVA mensual, no obligados a llevar contabilidad).

## Uso

- Clonar el repo
- `bundle install`
- `cp config.yml.example config.yml`
- Llenar el archivo `config.yml` con los datos adecuados
- `./declarator.rb`
- Repetir el siguiente mes

## ¿Por qué?

Porque tengo RUC y casi todos los meses declaro en cero y me da pereza abrir el
DIMM, generar una nueva declaración, iniciar sesión en la página del SRI y
subir el archivo.
