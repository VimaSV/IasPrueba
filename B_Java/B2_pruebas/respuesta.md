# B2. Verificacion de la correccion Java

## 1. Objetivo

Verificar que el metodo `consultar(Long id)` funcione correctamente cuando existen datos y controle adecuadamente los escenarios en los que falta informacion.

## 2. Casos de prueba

| Prueba | Datos de entrada | Resultado esperado |
|---|---|---|
| Solicitud existente con gestiones | Solicitud valida, cliente con nombre y varias gestiones | Devuelve el DTO con los datos correctos y la fecha de la gestion mas reciente |
| Solicitud inexistente | ID que no existe | Genera `IllegalArgumentException` |
| Solicitud sin gestiones | Solicitud existente y lista vacia | Genera `IllegalStateException` |
| Cliente inexistente | Solicitud sin cliente asociado | Genera `IllegalStateException` |
| Nombre del cliente nulo | Cliente existente sin nombre | Genera `IllegalStateException` |
| Gestiones sin fecha valida | Lista con gestiones cuyas fechas son nulas | Genera `IllegalStateException` |

## 3. Pseudopruebas

### Prueba 1. Solicitud existente con gestiones

**Entrada:**
- ID: 100.
- Cliente: Maria.
- Gestiones con fechas: 10/11/2026, 12/11/2026 y 09/11/2026.

**Resultado esperado:**
- El metodo devuelve un DTO correctamente.
- El nombre del cliente es Maria.
- La fecha de la ultima gestion corresponde al 12/11/2026.

### Prueba 2. Solicitud inexistente

**Entrada:**
- ID: 999999.

**Resultado esperado:**
- Se genera `IllegalArgumentException`.
- No se intenta acceder a los datos de una solicitud inexistente.

### Prueba 3. Solicitud sin gestiones

**Entrada:**
- Solicitud existente.
- Cliente valido.
- Lista de gestiones vacia.

**Resultado esperado:**
- Se genera `IllegalStateException`.
- No se intenta acceder a una posicion inexistente de la lista.

### Prueba 4. Cliente inexistente

**Entrada:**
- Solicitud existente.
- Cliente asociado igual a null.

**Resultado esperado:**
- Se genera `IllegalStateException`.
- Se informa que la solicitud no tiene un cliente valido.

### Prueba 5. Nombre del cliente nulo

**Entrada:**
- Solicitud existente.
- Cliente existente con nombre null.

**Resultado esperado:**
- Se genera `IllegalStateException`.
- Se evita ejecutar `trim()` sobre un valor nulo.

### Prueba 6. Gestiones sin fecha valida

**Entrada:**
- Solicitud existente.
- Cliente valido.
- Lista con gestiones, pero todas tienen fecha nula.

**Resultado esperado:**
- Se genera `IllegalStateException`.
- No se devuelve una fecha de gestion inexistente.

## 4. Conclusion

Los casos propuestos permiten verificar el funcionamiento normal del servicio y el manejo de situaciones que anteriormente podian provocar errores.

Se comprueba que el metodo:
- Devuelve la informacion correcta cuando los datos existen.
- Identifica solicitudes inexistentes.
- Controla la ausencia de gestiones y datos del cliente.
- Selecciona la gestion mas reciente sin depender del orden de la lista.

Las pruebas se presentan como pseudopruebas verificables, ya que no se proporciono un proyecto Java completo ni la configuracion necesaria para ejecutarlas automaticamente.