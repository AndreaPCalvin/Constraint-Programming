% Andrea Peña Calvin

int: D; %dias duracion
int: T; %trabajadores totales
int: N; %trabajadores por turno
enum tTurno = {turno1, turno2, turno3, libra, pedido};%nuevo valor 
int: numTurnos = 5; %numero de turnos + opcion de librar
int: MaxDT;
int: MaxDL;
int: MinDT;
array[1..T] of set of 1..T: incompatibles;
array[1..T] of par bool: esSupervisor;

array[1..T, 1..D] of par bool: diasPedidos;
array[1..T, 1..D] of par tTurno: turnosPedidos;

array[1..T, 1..D] of var tTurno: solTrabajador; 
array[1..T] of var int: vecesIgnoradoDia;
array[1..T] of var int: vecesIgnoradoTurno;
%-------------------------------------------------------------------------------------------------------------
%optimizacion
%1. Añadid la posibilidad de que los trabajadores pidan días que no quieren trabajar
constraint forall(i in 1..T, j in 1..D)( if diasPedidos[i,j]=false then solTrabajador[i,j]!=pedido 
  else  solTrabajador[i,j]!=libra  endif );

%2. Añadid la posibilidad de que los trabajadores pidan qué turno no quieren 

%reparto
constraint forall(i in 1..T)(vecesIgnoradoDia[i] = sum(j in 1..D) (bool2int( diasPedidos[i,j]=true /\ solTrabajador[i,j]!=pedido)));
constraint forall(i in 1..T)(vecesIgnoradoTurno[i] = sum(j in 1..D) (bool2int( turnosPedidos[i,j]=solTrabajador[i,j])));
solve minimize max(x in 1..T)(vecesIgnoradoDia[x]+vecesIgnoradoTurno[x]);
%-------------------------------------------------------------------------------------------------------------

%1. Cada turno tiene N trabajadores
constraint forall(j in 1..D, k in 1..numTurnos where k!=libra /\ k!=pedido) ((sum(i in 1..T) (bool2int(solTrabajador[i,j]= k ))) = N);

%2. Un trabajador solo puede estar en un turno cada día. 
%por la forma de construir la solucion, esto siempre se cumple

%3. Dado un número MaxDT, garantizar que nadie trabaja MaxDT días consecutivos. 
constraint forall(i in 1..T, j in 1..D) ((sum(x in j..j+MaxDT where j+MaxDT<=D) 
  (bool2int(solTrabajador[i,x]!=libra /\ solTrabajador[i,x]!=pedido))) <= MaxDT);

%4. Dado un número MaxDL, garantizar que nadie tiene MaxDL días libres consecutivos. pedido no cuenta como dia libre
constraint forall(i in 1..T, j in 1..D) ((sum(x in j..j+MaxDL where j+MaxDL<=D) (bool2int(solTrabajador[i,x]=libra))) <= MaxDL);
 
%5. Dado un número MinDT, garantizar que todos trabajan como mínimo MinDT en los D días. 
constraint forall(i in 1..T) ((sum(j in 1..D) (bool2int(solTrabajador[i,j] != libra /\ solTrabajador[i,j]!=pedido))) >= MinDT);

%6. Un trabajador no puede hacer el último turno de un día y el primero del día siguiente.
constraint forall(i in 1..T, j in 1..D-1) (if solTrabajador[i,j]=turno3 then solTrabajador[i,j+1]!=turno1 endif);

%7. Dada una serie de parejas de trabajadores incompatibles, dos trabajadores incompatibles no pueden estar en el mismo turno. 
constraint forall(i in 1..T) (forall(i2 in incompatibles[i]) ( forall(j in 1..D)
    ( if solTrabajador[i, j] != libra then solTrabajador[i, j]!= solTrabajador[i2, j] endif)  ));

%8. Dados cuáles de los trabajadores son “supervisores”, garantizar que en cada turno hay un supervisor (suponemos al menos un supervisor)
constraint forall(j in 1..D, k in 1..numTurnos where k!=libra /\ k!=pedido)
    (( sum(i in 1..T) (bool2int(solTrabajador[i,j]= k /\ esSupervisor[i]))) >= 1);

