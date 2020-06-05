%-------------------------------------------------------------------
% Extensões de Predicados

:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( single_var_warnings,off ).
:- set_prolog_flag( unknown,fail ).

% Verifica se a primeira lista contém todos os seus elementos em pelo menos uma lista da lista de listas
temNaListaListas(Pontos,[X|Cauda]) :-
	temTodos(Pontos,X);
	temNaListaListas(Pontos,Cauda).

% Verifica se a primeira lista contém todos os seus elementos na segunda
temTodos([],Lista).
temTodos([X|Cauda],Lista) :-
	member(X,Lista),
	temTodos(Cauda, Lista).

% Retorna a lista inversa à dada como argumento
inverso(Xs, Ys):-
	inverso(Xs, [], Ys).

inverso([], Xs, Xs).
inverso([X|Xs],Ys, Zs):-
	inverso(Xs, [X|Ys], Zs).

seleciona(E, [E|Xs], Xs).
seleciona(E, [X|Xs], [X|Ys]) :- seleciona(E, Xs, Ys).

% Escreve todos os nodos de um caminho
escreverCaminho([]).
escreverCaminho([X|L]):- write(X), nl, escreverCaminho(L).

% Retorna o comprimento de uma lista
comprimento( S,N ) :-
    length( S,N ).

% Insere um elemento de forma ordenada numa lista 
insert(X, [], [X]):- !.
insert((X,Y), [(X1,Y1)|L1], [(X,Y), (X1,Y1)|L1]):- Y =< Y1, !.
insert(X, [X1|L1], [X1|L]):- insert(X, L1, L).

% Retorna a lista dada como argumento ordenada
insertionSort([], []):- !.
insertionSort([X|L], S):- insertionSort(L, S1), insert(X, S1, S).

% Interseção de duas listas 
inter([], _, []).

inter([H1|T1], L2, [H1|Res]) :-
    member(H1, L2),
    inter(T1, L2, Res).

inter([_|T1], L2, Res) :-
    inter(T1, L2, Res).

% Verificação da existência de um elemento numa lista
membro(X, [X|_]).
membro(X, [_|Xs]):-
        membro(X,Xs).

% Retorna o primeiro elemento de uma lista
headLista([X|Cauda],X).

% Numa lista de listas retorna aquela com o menor comprimento(número de elementos)
listaMenor([],(Acc,N1), Acc).

listaMenor([X|Cauda], (Acc,N1), ListaMenor) :-
	comprimento(X,N),
	(N < N1) -> listaMenor(Cauda,(X,N),ListaMenor);
				listaMenor(Cauda,(Acc,N1),ListaMenor).