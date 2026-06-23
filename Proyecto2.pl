% ======================================================================================================
% Parte 1: Inicialización del Tablero 
% ======================================================================================================

% Predicados dinámicos.
:- dynamic robot/2.
:- dynamic caja_objetivo/2.
:- dynamic caja_bloqueo/2.

% Para evaluar si una entidad se encuentra en los límites del tablero.
enTablero((Fila, Columna)) :-
    Fila >= 0, 
    Fila =< 5,
    Columna >= 0,
    Columna =< 5. 

% Para verificar que la lista de cajas de bloqueo se encuentre en el tablero y no haya solapamientos.
verificacionLista(_, _, []).
verificacionLista((FilaRobot, ColumnaRobot), (FilaObjetivo, ColumnaObjetivo), [(FilaObstaculo, ColumnaObstaculo) | T]) :-
    enTablero((FilaObstaculo, ColumnaObstaculo)),
    \+ member((FilaObstaculo, ColumnaObstaculo), T),
    (FilaRobot, ColumnaRobot) \= (FilaObstaculo, ColumnaObstaculo),
    (FilaObjetivo, ColumnaObjetivo) \= (FilaObstaculo, ColumnaObstaculo),
    verificacionLista((FilaRobot, ColumnaRobot), (FilaObjetivo, ColumnaObjetivo), T).

% Para agregar a la base de conocimientos la lista de cajas de bloqueo si la misma es válida.
cargarObstaculos([]).
cargarObstaculos([(FilaObstaculo, ColumnaObstaculo) | T]) :-
    assertz(caja_bloqueo(FilaObstaculo, ColumnaObstaculo)),
    cargarObstaculos(T).

% Para garantizar el correcto estado inicial de las entidades.
initialBoard((FilaRobot, ColumnaRobot), (FilaObjetivo, ColumnaObjetivo), BlockingBoxes) :- 

    enTablero((FilaRobot, ColumnaRobot)),
    enTablero((FilaObjetivo, ColumnaObjetivo)),
    (FilaRobot, ColumnaRobot) \= (FilaObjetivo, ColumnaObjetivo),
    verificacionLista((FilaRobot, ColumnaRobot), (FilaObjetivo, ColumnaObjetivo), BlockingBoxes),

    % para garantizar la limpieza de ejecuciones previas.
    retractall(robot(_, _)),
    retractall(caja_objetivo(_, _)),
    retractall(caja_bloqueo(_, _)),

    % Si todo es válido se carga la base de conocimientos con los hechos correspondientes.
    assertz(robot(FilaRobot, ColumnaRobot)),
    assertz(caja_objetivo(FilaObjetivo, ColumnaObjetivo)),
    cargarObstaculos(BlockingBoxes).

% ======================================================================================================
% Parte 2: Validación de movimientos 
% ======================================================================================================

% Definiendo los tipos de movimientos posibles.
posicionNueva((FilaActual, ColumnaActual), 'u', (FilaNueva, ColumnaActual)) :- FilaNueva is FilaActual-1.
posicionNueva((FilaActual, ColumnaActual), 'd', (FilaNueva, ColumnaActual)) :- FilaNueva is FilaActual+1.
posicionNueva((FilaActual, ColumnaActual), 'l', (FilaActual, ColumnaNueva)) :- ColumnaNueva is ColumnaActual-1.
posicionNueva((FilaActual, ColumnaActual), 'r', (FilaActual, ColumnaNueva)) :- ColumnaNueva is ColumnaActual+1.

% Caso 1: El robot puede moverse libremente porque su nueva posición no choca con la caja objetivo, ni con ninguna caja de bloqueo.
isValidMove(state(Robot, Objetivo, Obstaculos), Move) :-
    posicionNueva(Robot, Move, NewPosicionRobot),
    enTablero(NewPosicionRobot),
    NewPosicionRobot \= Objetivo,
    \+ member(NewPosicionRobot, Obstaculos).

% Caso 2: La nueva posición del robot choca con la caja objetivo.
isValidMove(state(Robot, Objetivo, Obstaculos), Move) :-
    posicionNueva(Robot, Move, NewPosicionRobot),
    enTablero(NewPosicionRobot),
    NewPosicionRobot == Objetivo,
    posicionNueva(Objetivo, Move, NewPosicionObjetivo),
    enTablero(NewPosicionObjetivo),
    \+ member(NewPosicionObjetivo, Obstaculos).

% Caso 3: La nueva posición del robot choca con una caja de bloqueo.
isValidMove(state(Robot, Objetivo, Obstaculos), Move) :-
    posicionNueva(Robot, Move, NewPosicionRobot),
    enTablero(NewPosicionRobot),
    NewPosicionRobot \= Objetivo,
    member(NewPosicionRobot, Obstaculos),
    posicionNueva(NewPosicionRobot, Move, NewPosicionObstaculo),
    enTablero(NewPosicionObstaculo),
    \+ member(NewPosicionObstaculo, Obstaculos),
    NewPosicionObstaculo \= Objetivo.

% =====================================================================================================
% Parte 3: Ejecución de movimiento
% =====================================================================================================

% Predicado para actualizar la lista de cajas de bloqueo con las nuevas posiciones de las cajas de bloqueo 
% después de ejecutar un movimiento, si es que el movimiento implica empujar una caja de bloqueo.
modificarObstaculos(ObstaculoSinModificar, ObstaculoModificado, Obstaculos, [ObstaculoModificado | ObstaculosModificados]) :-
    select(ObstaculoSinModificar, Obstaculos, ObstaculosModificados).

% Caso 1: el robot se mueve a una casilla libre.
moveRobot(state(Robot, Objetivo, Obstaculos), Move, state(NewRobot, Objetivo, Obstaculos)) :-
    isValidMove(state(Robot, Objetivo, Obstaculos), Move),
    posicionNueva(Robot, Move, NewRobot),
    NewRobot \= Objetivo,
    \+ member(NewRobot, Obstaculos).

% Caso 2: el robot se mueve a la posicion donde se encontraba la caja objetivo.
moveRobot(state(Robot, Objetivo, Obstaculos), Move, state(NewRobot, NewObjetivo, Obstaculos)) :-
    isValidMove(state(Robot, Objetivo, Obstaculos), Move),
    posicionNueva(Robot, Move, NewRobot),
    NewRobot == Objetivo, 
    posicionNueva(Objetivo, Move, NewObjetivo).

% Caso 3: el robot se mueve a la posición donde se encontraba una caja de bloqueo.
moveRobot(state(Robot,Objetivo,Obstaculos), Move, state(NewRobot, Objetivo, NewObstaculos)) :-
    isValidMove(state(Robot, Objetivo, Obstaculos), Move),
    posicionNueva(Robot, Move, NewRobot),
    posicionNueva(NewRobot, Move, NewObstaculo),
    NewObstaculo \= Objetivo,
    modificarObstaculos(NewRobot, NewObstaculo, Obstaculos, NewObstaculos).

% =====================================================================================================
%Parte 4: Solución 
% =====================================================================================================

% Para buscar los hijos de cada nodo.
expandir(nodo(Estado, Camino), Visitados, HijosValidos) :-
    findall(
        nodo(NuevoEstado, NuevoCamino),
        (
            moveRobot(Estado, Move, NuevoEstado), % evaluamos si se puede realizar el movimiento.
            \+ member(NuevoEstado, Visitados),    % verificamos que el estado que estoy consultando no
                                                  % esté ya en la lista de visitados, porque si ya está no lo agregamos.
            append(Camino, [Move], NuevoCamino)   % Si efectivamente es un estado nuevo, actualizo el 
                                                  % camino del mismo agregándole el movimiento que puede ejecutar a partir de allí.
        ),
        HijosValidos % se generan todos los hijos que el estado actual tiene.
    ).

% Verifica si ya la caja objetivo llegó al estado final.
esEstadoFinal(state(_, (5, 5), _)).

% Caso base: Si el estado actual en el que estoy es un estado final, se acabó el backtracking y la solución
% es el camino que haya recorrido ese estado.
bfs([nodo(EstadoActual, CaminoActual) | _], _, SolucionFinal) :-
    esEstadoFinal(EstadoActual),
    SolucionFinal = CaminoActual,
    !.

% Caso general: Si la caja objetivo no ha llegado al estado final.
bfs([nodo(EstadoActual, CaminoActual) | RestoCola], Visitados, SolucionFinal) :-
    NuevosVisitados = [EstadoActual | Visitados], % agrego el estado actual a la lista de visitados.
    expandir(nodo(EstadoActual, CaminoActual), NuevosVisitados, HijosValidos), % evalúo si me puedo mover (tengo hijos).
    append(RestoCola, HijosValidos, NuevaCola), % si tengo hijos entonces los agego a la cola.
    bfs(NuevaCola, NuevosVisitados, SolucionFinal). % continúa la recursión.

% Devuelme el camino (secuencia de movimientos) más corto desde el estado inicial hasta que la 
% caja objetivo llega al estado final.
solveWarehouse(StartState, Solution) :-
    bfs([nodo(StartState, [])],[],Solution).
    