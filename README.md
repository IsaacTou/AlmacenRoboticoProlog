# Proyecto #2 – Prolog Almacén Robótico Lógico

**Universidad Central de Venezuela**
**Facultad de Ciencias**
**Escuela de Computación**
**Asignatura: Lenguajes de Programación**
**Semestre I-2026**

**Docentes:**

- Eugenio Scalise
- José Yvimas

**Integrantes:**

- Isaac Pérez C.I. 31.065.844
- Carmen Medina C.I. 32.061.534

---

## 1. Representación del Problema

- **El Tablero:** Representado como una matriz lógica de 6x6 con coordenadas desde `(0,0)` hasta `(5,5)`.
- **Estados (`state/3`):** `state(RobotCoord, TargetCoord, ListaBloqueos)`. El estado del sistema se modeló utilizando dicha estructura. Esta almacena de forma compacta un término para la posición del robot, un término para la posición de la caja objetivo y una lista de términos para las posiciones de los bloqueos. Esta representación permite al predicado `moveRobot/3` recibir la configuración actual del tablero y generar limpiamente el siguiente estado tras un movimiento, facilitando la expansión de nodos en el algoritmo de búsqueda BFS sin destruir los estados anteriores."
- **Movimientos:** Representados por los átomos `'u'`, `'d'`, `'l'` y `'r'`.

## 2. Hechos y Predicados Definidos

**Predicados Dinámicos:**

- `robot(Row, Col)`: Guarda la posición actual inicial del robot.
- `caja_objetivo(Row, Col)`: Guarda la posición inicial de la caja objetivo.
- `caja_bloqueo(Row, Col)`: Guarda las posiciones de los obstáculos.

**Predicados Principales:**

- `initialBoard/3`: Valida los límites y solapamientos, limpiando la base previa y haciendo `assertz` de las nuevas entidades.
- `isValidMove/2`: Lógica para comprobar choques con paredes, empujes válidos y la prohibición de empuje múltiple.
- `moveRobot/3`: Transición de estados generando el `NewState`.
- `solveWarehouse/2`: Ejecuta el algoritmo de búsqueda para encontrar la `Solution`.

**Predicados Auxiliares:**

- `enTablero/1`: Verifica que una coordenada esté dentro de los límites del tablero.
- `verificacionLista/3`: Comprueba que no haya solapamientos entre el robot, la caja objetivo y los bloqueos.
- `cargarObstaculos/1`: Predicado para agregar a la base de conocimientos la lista de cajas de bloqueo si la misma es válida.
- `posicionNueva/3`: Calcula la nueva posición del robot o la caja tras un movimiento dado.
- `modificarObstaculos/4`: Actualiza la lista de bloqueos si la caja objetivo es empujada a una nueva posición.
- `expandir/3`: Genera los nuevos estados a partir del estado actual para cada movimiento posible, verificando su validez.
- `esEstadoFinal/1`: Verifica si la caja objetivo ha llegado a la posición `(5,5)`.
- `bfs/3`: Implementación del algoritmo de búsqueda en anchura, utilizando una cola para gestionar los estados a explorar y una lista de visitados para evitar ciclos.

**Predicados Incorporados (built-in predicates):**

- `assertz/1`: Para agregar hechos dinámicos a la base de conocimientos. Utilizado en `initialBoard/3` para establecer el estado inicial del tablero.
- `retractall/1`: Para limpiar la base de conocimientos antes de establecer un nuevo estado inicial. Utilizado en `initialBoard/3` para eliminar hechos previos de robot, caja objetivo y bloqueos.
- `member/2`: Para verificar la presencia de un elemento en una lista, utilizado en la verificación de bloqueos y estados visitados. Se utilizo en los predicados `verificacionLista/3`, `isValidMove/2`, `MoveRobot/3`y `expandir/3`.
- `append/3`: Para concatenar listas, utilizado en la generación de nuevas secuencias de movimientos.
- `select/3`: Selecciona un elemento de una lista, lo elimina y devuelve la lista resultante sin el elemento seleccionado, utilizado para quitar una caja obstaculo con posicion obsoleta para ser modificada por la nueva posicion de la misma caja despues de ser empujada.
- `findall/3`: Para generar una lista de todos los estados hijos a partir del estado actual, utilizado en la expansión de nodos en el algoritmo BFS. Ya que este predicado funciona como un generador de soluciones, recibe un patrón de búsqueda, una consulta que genera soluciones y una variable para almacenar la lista de soluciones generadas. Esto permite que el algoritmo BFS explore eficientemente todos los estados alcanzables desde el estado inicial sin necesidad de escribir manualmente la lógica para cada movimiento posible.

## 3. Estrategia Utilizada

- **Algoritmo:** Búsqueda en Anchura (BFS).
- **Justificación:** Se utilizó BFS porque garantiza encontrar la secuencia _mínima_ de movimientos (el camino más corto) para llevar la Caja Objetivo a `(5,5)`, explorando todos los estados a distancia $n$ antes de pasar a $n+1$. En este caso se exploran primero los movimientos que llevan a estados más cercanos al estado inicial, lo que es crucial para evitar caminos largos e ineficientes en un espacio de búsqueda con obstaculos, manejando una lista de visitados para evitar ciclos y estados repetidos, con una cola que nos permite gestionar eficientemente los estados a explorar, ademaás de que al visitar cada estado se verifica si es estado final, lo que garantiza que la primera solución encontrada sea la óptima.

## 4. Referencias y Herramientas Consultadas

- **Libro - Learn Prolog Now!:**
  - _Autores:_ Patrick Blackburn, Johan Bos, y Kristina Striegnitz.
  - _Uso:_ Material de apoyo consultado para repasar la sintaxis de los predicados incorporados, la estructura de los árboles de búsqueda y el uso del corte lógico (`!`) en la optimización de predicados.
