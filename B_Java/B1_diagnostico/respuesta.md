# B1. Diagnostico y correccion del servicio Java
## 1. Analisis del metodo original

El metodo `consultar(Long id)` busca una solicitud por su identificador, obtiene el nombre del cliente, consulta las gestiones asociadas y construye un DTO con la informacion encontrada.

El error reportado ocurre porque `repository.findById(id).orElse(null)` devuelve `null` cuando la solicitud no existe. Posteriormente, el codigo intenta acceder a `solicitud.getCliente()`, provocando un `NullPointerException`.

## 2. Problemas identificados

1. solicitud inexistente: no se valida si el repositorio devuelve un resultado.
2. Cliente nulo: puede provocar un `NullPointerException`.
3. Nombre nulo: la llamada a `trim()` falla si el nombre no existe.
4. Lista de gestiones vacia: `get(0)` provoca un `IndexOutOfBoundsException`.
5. Orden de las gestiones: no se garantiza que el primer elemento sea la gestion mas reciente.

## 3. Correccion propuesta

Se propone corregir el metodo en la capa de servicio, manteniendo su estructura original y agregando validaciones para evitar errores por ausencia de datos.

Se eligio obtener la lista de gestiones y buscar la mas reciente desde Java mediante `stream()` y `max()`.

Esta alternativa se selecciono porque es sencilla, facil de entender y no requiere modificar el repositorio 

### Codigo corregido

```java
public SolicitudDto consultar(Long id) {

    Solicitud solicitud = repository.findById(id)
        .orElseThrow(() ->
            new IllegalArgumentException("Solicitud no encontrada: " + id)
        );

    if (solicitud.getCliente() == null ||
        solicitud.getCliente().getNombre() == null) {
        throw new IllegalStateException(
            "La solicitud no tiene un cliente valido"
        );
    }

    String nombreCliente = solicitud.getCliente()
        .getNombre()
        .trim();

    List<Gestion> gestiones =
        gestionRepository.findBySolicitudId(id);

    if (gestiones == null || gestiones.isEmpty()) {
        throw new IllegalStateException(
            "La solicitud no tiene gestiones"
        );
    }

    Gestion ultima = gestiones.stream()
        .filter(g -> g.getFechaGestion() != null)
        .max(Comparator.comparing(Gestion::getFechaGestion))
        .orElseThrow(() ->
            new IllegalStateException(
                "No existen gestiones con fecha valida"
            )
        );

    return new SolicitudDto(
        solicitud.getId(),
        nombreCliente,
        solicitud.getEstado(),
        ultima.getFechaGestion()
    );
}
```

## 4. Manejo de logs

Se recomienda registrar:

- Identificador de la solicitud.
- Fecha y hora del error.
- Operacion que estaba ejecutandose.
- Tipo de excepcion y stack trace.

No se deben registrar nombres completos, documentos, datos personales, contraseñas ni tokens.

Ejemplo:

```java
log.error("Error consultando solicitud id={}", id, exception);
```

## Conclusion

La correccion permite manejar explicitamente la ausencia de solicitudes, clientes y gestiones, evitando errores poco claros y mejorando el diagnostico para soporte.

Se conserva la estructura original del servicio y se incorpora una validacion mas segura y mantenible.