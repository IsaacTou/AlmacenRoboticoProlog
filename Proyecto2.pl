% Universidad Central de Venezuela
% Facultad de Ciencias 
% Escuela de Computación 
% Asignatura: Lenguajes de Programación
% Semestre I-2026

% Docentes:
% Eugenio Scalise
% José Yvimas

% Integrantes:
% Isaac Pérez C.I. 31.065.844
% Carmen Medina C.I. 32.061.534

% ======================================================================================================
% Parte 1: Inicialización del Tablero 
% ======================================================================================================

% Predicados dinámicos
:- dynamic robot/2.
:- dynamic caja_objetivo/2.
:- dynamic caja_bloqueo/2.

% Para evaluar si una entidad se encuentra en los límites del tablero
enTablero((Fila, Columna)) :-
    Fila >= 0, 
    Fila =< 5,
    Columna >= 0,
    Columna =< 5. 

% Para verificar que la lista de cajas de bloqueo se encuentre en el tablero y no haya solapamientos
verificacionLista(_, _, []).
verificacionLista((FilaRobot, ColumnaRobot), (FilaObjetivo, ColumnaObjetivo), [(FilaObstaculo, ColumnaObstaculo) | T]) :-
    enTablero((FilaObstaculo, ColumnaObstaculo)),
    \+ member((FilaObstaculo, ColumnaObstaculo), T),
    (FilaRobot, ColumnaRobot) \= (FilaObstaculo, ColumnaObstaculo),
    (FilaObjetivo, ColumnaObjetivo) \= (FilaObstaculo, ColumnaObstaculo),
    verificacionLista((FilaRobot, ColumnaRobot), (FilaObjetivo, ColumnaObjetivo), T).

% Para agregar a la base de conocimientos la lista de cajas de bloqueo si la misma es válida
cargarObstaculos([]).
cargarObstaculos([(FilaObstaculo, ColumnaObstaculo) | T]) :-
    assertz(caja_bloqueo(FilaObstaculo, ColumnaObstaculo)),
    cargarObstaculos(T).

% Para garantizar el correcto estado inicial de las entidades
initialBoard((FilaRobot, ColumnaRobot), (FilaObjetivo, ColumnaObjetivo), BlockingBoxes) :- 
    % para garantizar la limpieza de ejecuciones previas
    %retractall(robot(_, _)),
    %retractall(caja_objetivo(_, _)),
    %retractall(caja_bloqueo(_, _)),

    enTablero((FilaRobot, ColumnaRobot)),
    enTablero((FilaObjetivo, ColumnaObjetivo)),
    (FilaRobot, ColumnaRobot) \= (FilaObjetivo, ColumnaObjetivo),
    verificacionLista((FilaRobot, ColumnaRobot), (FilaObjetivo, ColumnaObjetivo), BlockingBoxes),

    % para garantizar la limpieza de ejecuciones previas
    retractall(robot(_, _)),
    retractall(caja_objetivo(_, _)),
    retractall(caja_bloqueo(_, _)),

    % Si todo es válido se carga la base de conocimientos con los hechos correspondientes
    assertz(robot(FilaRobot, ColumnaRobot)),
    assertz(caja_objetivo(FilaObjetivo, ColumnaObjetivo)),
    cargarObstaculos(BlockingBoxes).

% ======================================================================================================
% Parte 2: Validación de movimientos 
% ======================================================================================================

% Definiendo los tipos de movimientos posibles
posicionNueva((FilaActual, ColumnaActual), 'u', (FilaNueva, ColumnaActual)) :- FilaNueva is FilaActual-1.
posicionNueva((FilaActual, ColumnaActual), 'd', (FilaNueva, ColumnaActual)) :- FilaNueva is FilaActual+1.
posicionNueva((FilaActual, ColumnaActual), 'l', (FilaActual, ColumnaNueva)) :- ColumnaNueva is ColumnaActual-1.
posicionNueva((FilaActual, ColumnaActual), 'r', (FilaActual, ColumnaNueva)) :- ColumnaNueva is ColumnaActual+1.

% Caso 1: El robot puede moverse libremente porque su nueva posición no choca con la caja objetivo, ni con ninguna caja de bloqueo
isValidMove(state(Robot, Objetivo, Obstaculos), Move) :-
    posicionNueva(Robot, Move, NewPosicionRobot),
    enTablero(NewPosicionRobot),
    NewPosicionRobot \= Objetivo,
    \+ member(NewPosicionRobot, Obstaculos).

% Caso 2: La nueva posición del robot choca con la caja objetivo
isValidMove(state(Robot, Objetivo, Obstaculos), Move) :-
    posicionNueva(Robot, Move, NewPosicionRobot),
    enTablero(NewPosicionRobot),
    NewPosicionRobot == Objetivo,
    posicionNueva(Objetivo, Move, NewPosicionObjetivo),
    enTablero(NewPosicionObjetivo),
    \+ member(NewPosicionObjetivo, Obstaculos).

% Caso 3: La nueva posición del robot choca con una caja de bloqueo
isValidMove(state(Robot, Objetivo, Obstaculos), Move) :-
    posicionNueva(Robot, Move, NewPosicionRobot),
    enTablero(NewPosicionRobot),
    NewPosicionRobot \= Objetivo,
    member(NewPosicionRobot, Obstaculos),
    posicionNueva(NewPosicionRobot, Move, NewPosicionObstaculo),
    enTablero(NewPosicionObstaculo),
    \+ member(NewPosicionObstaculo, Obstaculos),
    NewPosicionObstaculo \= Objetivo.



% Seccion 3

modificarObstaculos(ObstaculoSinModificar, ObstaculoModificado, Obstaculos, [ObstaculoModificado | ObstaculosModificados]) :-
    select(ObstaculoSinModificar, Obstaculos, ObstaculosModificados).

moveRobot(state(Robot, Objetivo, Obstaculos), Move, state(NewRobot, Objetivo, Obstaculos)) :-
    posicionNueva(Robot, Move, NewRobot),
    enTablero(NewRobot),
    NewRobot \= Objetivo,
    \+ member(NewRobot, Obstaculos).

moveRobot(state(Robot,Objetivo,Obstaculos), Move, state(NewRobot, NewObjetivo, Obstaculos)) :-
    posicionNueva(Robot, Move, NewRobot),
    enTablero(NewRobot),
    NewRobot == Objetivo,
    posicionNueva(Objetivo, Move, NewObjetivo),
    enTablero(NewObjetivo),
    \+ member(NewObjetivo, Obstaculos).

moveRobot(state(Robot,Objetivo,Obstaculos), Move, state(NewRobot, Objetivo, NewObstaculos)) :-
    posicionNueva(Robot, Move, NewRobot),
    enTablero(NewRobot),
    member(NewRobot, Obstaculos),
    posicionNueva(NewRobot, Move, NewObstaculo),
    enTablero(NewObstaculo),
    \+ member(NewObstaculo, Obstaculos),
    NewObstaculo \= Objetivo,
    modificarObstaculos(NewRobot, NewObstaculo, Obstaculos, NewObstaculos).


%Parte 4

agregarNodos(state(Robot,Objetivo,Obstaculos,[Camino]), [state(Robot,Objetivo,Obstaculos,[Camino]])


esEstadoFinal(state(Robot,(FilaObjetivo, ColumnaObjetivo),Obstaculos)) :-
    FilaObjetivo == 5,
    FilaColummna == 5.


