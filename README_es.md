# Logger

Logger es una pequeña librería utilitaria para registros en Lua que puedes de forma similar a la función `assert()` and te permite escribir registros en ficheros y/o en la consola. Logger es fácil de usar, aquí un ejemplo:

```lua
local Logger = require("Logger")
local log = Logger("MyScript", os.getenv("HOME"), true)

-- algo de código aquí...

local userConf = load_user_config() -- función de ejemplo...
log(userConf, "error", "la configuración de usuario no pudo ser cargada")

-- más código aquí
```

Tendrás una salida como esta:

![Capture 1](cap1.png)

Y un fichero en tu carpeta `$HOME` llamado `MyScript_DATE.log` (donde `DATE` es el resultado de `os.date("%Y-%m-%d")`) con un contenido como este:

```
17:15:58 [MyScript ERROR] MyScript.lua@3: la configuración de usuario no pudo ser cargada
```

### Documentación

Logger provee solamente 2 funciones/métodos:

  * `new([name, dir, console])`: Constructor. Igual que `Logger()`. Esta función es principalmente para un uso más cómodo y básicamente prepara algunos elementos para ser usados por la función `log()`. Argumentos:
    * (__string__) `name` El nombre de tu aplicación/proyecto/script, entre otros. Básicamente un nombre con el que puedas identificar algo en particular, es útil si piensas usar varias instancias de Logger.
    * (__string__) `dir` Un directorio existente donde Logger guardará los ficheros de registro. Si no existe, tendrás un error.
    * (__boolean__) `console` Por defecto, Logger solo escribe ficheros de registro, pero si este argumento es `true`, entonces también escribirá registros en la terminal/consola.

  * `log(exp, lvl, msg, ...)`: Pues... Escribe registros... En lugar de llamar esta función con `log:log()`, simplemente hazlo con `log()`. Argumentos:
    * (__any__) `exp` Al igual que `assert()`, si este argumento es `nil` o `false`, entonces Logger escribe el mensaje de registro y, si el nivel de registro es 5, 6 o 7, Logger detiene la ejecución del script.
    * (__number__ or __string__) `lvl` El nivel de registro (ver la tabla más abajo)
    * (__string__) `msg` El mensaje de registro.
    * (__any__) `...` Argumentos variadicos, usado con `string.format()` para colocar valores en `msg`.

La función `log()` acepta los siguientes valores en el argumento `lvl` (refiriéndose al "nivel de importancia"):

| Número\* | Texto\*\* |
| :----- | :----- |
| `1` | `"trace"` |
| `2` | `"debug"` |
| `3` | `"info"`  |
| `4` | `"warn"`  |
| `5` | `"error"` |
| `6` | `"fatal"` |
| `7` | `"other"` |

__\*__: de preferencia, este valor númerico.

__\*\*__: el equivalente en texto a los valores numéricos.

Para los números en la función `log()`, si es diferente de uno de los que están en la tabla, entonces tendrás un error. Para el texto, si es diferente de los que están en la table, entonces Logger lo ignora y escribe el registro como si fuese de nivel 7.