%-------------------------------------------------------------------
% SIST. REPR. CONHECIMENTO E RACIOCINIO - MiEI/3

% ~/prolog/bin/sicstus -l main.pl

:- [paragens].
:- [arcos].
:- [predAux].

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SICStus PROLOG: Declaracoes iniciais

:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( single_var_warnings,off ).
:- set_prolog_flag( unknown,fail ).

%--------------------------------------------------------- Algoritmos de Procura ----------------------------------------------

% [Pesquisa em Profundidade]

resolve_pp(NodoInicial, [NodoInicial|Caminho], NodoFinal, Amostra) :-
	profundidadeprimeiro(NodoInicial, Caminho, NodoFinal, Amostra).

profundidadeprimeiro(NodoInicial, [], NodoFinal, Amostra) :-
	(NodoInicial == NodoFinal), !.

profundidadeprimeiro(NodoInicial, [ProxNodo|Caminho], NodoFinal, Amostra) :-
	adjacenteProfundidade(NodoInicial, ProxNodo, Amostra),
	profundidadeprimeiro(ProxNodo, Caminho, NodoFinal, Amostra).	

adjacenteProfundidade(Nodo, ProxNodo, Amostra) :- 
	arco(Nodo,_,ProxNodo),
	membro(Nodo,Amostra),
	membro(ProxNodo,Amostra).

% [Pesquisa em Largura]

% findall(A, paragem(A,B,C,D,E,F,X), P1), resolve_lp(183, R, 499,P1). -----------------> [183,791,595,182,499]
resolve_lp(NodoInicial, Caminho, NodoFinal, Amostra) :-
    larguraprimeiro([[NodoInicial]], CaminhoInverso, NodoFinal, Amostra),
    inverso(CaminhoInverso, Caminho).

larguraprimeiro([[Node|Path]|_], [Node|Path], NodoFinal, Amostra) :-
    (Node == NodoFinal).

larguraprimeiro([[N|Path]|Paths], Caminho, NodoFinal, Amostra) :-
    bagof([M,N|Path],
    (arco(N,_,M), membro(N, Amostra), membro(M, Amostra), \+ member(M, [N | Path])), NewPaths),
    append(Paths, NewPaths, Pathsl), !,
    larguraprimeiro(Pathsl, Caminho, NodoFinal, Amostra);
    larguraprimeiro(Paths, Caminho, NodoFinal, Amostra).

% [Pesquisa A*]

% Calcula a distância euclidiana entre dois nodos
euristica(NodoInicio, NodoDestino, Distance) :- 
    paragem(NodoInicio, Lat1, Lon1, _, _, _, _),
    paragem(NodoDestino, Lat2, Lon2, _, _ , _, _),
    P is 0.017453292519943295,
    A is (0.5 - cos((Lat2 - Lat1) * P) / 2 + cos(Lat1 * P) * cos(Lat2 * P) * (1 - cos((Lon2 - Lon1) * P)) / 2),
    Distance is (12742 * asin(sqrt(A)))/1000.

% findall(A, paragem(A,B,C,D,E,F,X), P1), resolve_aestrela(183, Caminho/Tempo, 594, P1). -------------> [183,791,595,594]
resolve_aestrela(Nodo, Caminho/Custo, NodoFinal, Amostra) :-
	euristica(Nodo, NodoFinal, Estima),
	aestrela([[Nodo]/0/Estima], InvCaminho/Custo/_, NodoFinal, Amostra),
	inverso(InvCaminho, Caminho).

aestrela(Caminhos, Caminho, NodoFinal, Amostra) :-
	obtem_melhor(Caminhos, Caminho),
	Caminho = [Nodo|_]/_/_,(Nodo == NodoFinal).

aestrela(Caminhos, SolucaoCaminho, NodoFinal, Amostra) :-
	obtem_melhor(Caminhos, MelhorCaminho),
	seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
	expande_aestrela(MelhorCaminho, ExpCaminhos, NodoFinal, Amostra),
	append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
        aestrela(NovoCaminhos, SolucaoCaminho, NodoFinal, Amostra).		

obtem_melhor([Caminho], Caminho) :- !.

obtem_melhor([Caminho1/Custo1/Est1,_/Custo2/Est2|Caminhos], MelhorCaminho) :-
	Custo1 + Est1 =< Custo2 + Est2, !,
	obtem_melhor([Caminho1/Custo1/Est1|Caminhos], MelhorCaminho).
	
obtem_melhor([_|Caminhos], MelhorCaminho) :- 
	obtem_melhor(Caminhos, MelhorCaminho).

expande_aestrela(Caminho, ExpCaminhos, NodoFinal, Amostra) :-
	findall(NovoCaminho, adjacenteEstrela(Caminho,NovoCaminho,NodoFinal, Amostra), ExpCaminhos).

adjacenteEstrela([Nodo|Caminho]/Custo/_, [ProxNodo,Nodo|Caminho]/NovoCusto/Est, NodoFinal, Amostra) :-
	arco(Nodo,_,ProxNodo),\+ member(ProxNodo, Caminho),
	membro(Nodo, Amostra),
	membro(ProxNodo, Amostra),
	euristica(Nodo, ProxNodo, PassoCusto),
	NovoCusto is Custo + PassoCusto,
	euristica(ProxNodo, NodoFinal,Est).

% -----------------------------------------------------------------------------------------------------------------------
% [QUERY 1] Calcular um trajeto entre dois pontos 
% percurso(863,79,D).

% Profundidade
percurso(NodoInicial, NodoFinal, Caminho) :-
	findall(A, paragem(A,B,C,D,E,F,X), P1),
	resolve_pp(NodoInicial, Caminho, NodoFinal,P1).
	%resolve_lp(NodoInicial, Caminho, NodoFinal, P1).
	%resolve_aestrela(Nodo, Caminho/Custo, NodoFinal, P1).

% -----------------------------------------------------------------------------------------------------------------------
% [QUERY 2] Selecionar apenas algumas das operadoras de transporte para um determinado percurso

% comOperadoras(['Vimeca','LT'],863,79,C). -------> yes
% comOperadoras(['Carris'],863,79,C).      -------> no
comOperadorasParagens([], Acc, Acc).
comOperadorasParagens([X|Cauda], Acc, Paragens) :-
	findall(A, paragem(A,B,C,D,E,F,X), P1),
	append(P1, Acc, R),
	comOperadorasParagens(Cauda, R, Paragens).

comOperadoras(Operadoras,NodoInicial,NodoFinal, Caminho) :-
	comOperadorasParagens(Operadoras,[],Paragens),
	resolve_pp(NodoInicial, Caminho, NodoFinal,Paragens).

% -----------------------------------------------------------------------------------------------------------------------
% [QUERY 3] Excluir um ou mais operadores de transporte para o percurso

% noOperadoras(['Carris'],863,79,C).       -----> yes
% noOperadoras(['Vimeca','LT'],183,791,C). -----> no
noOperadorasParagens([],Acc,Acc).
noOperadorasParagens([X|Cauda],Acc,Paragens) :-
	findall(A,(paragem(A,B,C,D,E,F,Op), Op \= X), P1),
	inter(P1, Acc, Int),
	noOperadorasParagens(Cauda, Int, Paragens).

noOperadoras(Operadoras,NodoInicial,NodoFinal, Caminho) :-
	findall(A,paragem(A,B,C,D,E,F,G),P1),
	noOperadorasParagens(Operadoras,P1,Paragens),!,
	resolve_lp(NodoInicial, Caminho, NodoFinal,Paragens).

% -----------------------------------------------------------------------------------------------------------------------
% [QUERY 4] Identificar quais as paragens com o maior número de carreiras num determinado percurso

% maisCarreirasPercurso(183,595,C). ----------------> [(595,7),(183,6),(791,6)]
carreirasParagem([], Acc, Final) :-
	insertionSort(Acc,InvOrd),
	inverso(InvOrd,Final).

carreirasParagem([Nodo|Cauda], Acc, Final) :-
	findall(Nodo,arco(Nodo,_, _), ParagensCarreiras),
	comprimento(ParagensCarreiras,N),
	append([(Nodo,N)],Acc,Int),
	carreirasParagem(Cauda, Int, Final).

maisCarreirasPercurso(NodoInicial, NodoFinal, Ordenado) :-
	findall(A, paragem(A,B,C,D,E,F,X), P1),
	resolve_lp(NodoInicial, MaisCarreiras, NodoFinal,P1),
	carreirasParagem(MaisCarreiras,[],Ordenado),
	print(Ordenado).

% -----------------------------------------------------------------------------------------------------------------------
% [QUERY 5] Escolher o menor percurso (usando critério menor número de paragens)

% menorPercursoParagens(183,595,C).
menorPercursoParagens(NodoInicial, NodoFinal, Caminho) :-
	todosPercursos(NodoInicial, NodoFinal, Solucoes),
	headLista(Solucoes,Head),
	comprimento(Head,N),
	listaMenor(Solucoes, (Head,N), Caminho).

% -----------------------------------------------------------------------------------------------------------------------
% [QUERY 6] Escolher o percurso mais rápido (usando critério da distância)

% menorPercursoDistancia(354,79,C,D).
menorPercursoDistancia(NodoInicial, NodoFinal, Caminho, Custo) :-
	findall(A, paragem(A,B,C,D,E,F,X), P1),
	resolve_aestrela(NodoInicial, Caminho/Custo, NodoFinal, P1).

% -----------------------------------------------------------------------------------------------------------------------
% [QUERY 7] Escolher o percurso que passe apenas por abrigos com publicidade

% percursoPublicitado(353,333,C). ------> yes
% percursoPublicitado(353,846,C). ------> no
publicitadas(Paragens) :-
	findall(A, paragem(A,B,C,D,E,'Yes',G), Paragens).

percursoPublicitado(NodoInicial, NodoFinal, Caminho) :-
	publicitadas(Paragens),
	resolve_pp(NodoInicial, Caminho, NodoFinal,Paragens).

% -----------------------------------------------------------------------------------------------------------------------
% [QUERY 8] Escolher o percurso que passe apenas por paragens abrigadas

% percursoAbrigado(863,32,C). ------> yes 
% percursoAbrigado(863,60,C). ------> no
abrigadas(Paragens) :-
	findall(A,(paragem(A,B,C,D,E,F,G), E \= 'Sem Abrigo'), Paragens).

percursoAbrigado(NodoInicial, NodoFinal, Caminho) :-
	abrigadas(Paragens),
	resolve_lp(NodoInicial, Caminho, NodoFinal,Paragens).

% [QUERY 9] Escolher um ou mais pontos intermédios por onde o percurso deverá passar

% percursoComPontos([78,364,33,61,64,58],863,79).     -------> yes
% percursoComPontos([999],863,79).                    -------> no
percursoComPontos(Pontos,NodoInicial,NodoFinal) :-
	todosPercursos(NodoInicial, NodoFinal, Solucoes),
	temNaListaListas(Pontos,Solucoes).

% Dá todos os percursos possíveis para um nodo inicial e para um nodo final 
todosPercursos(NodoInicial, NodoFinal, Solucoes) :-
	findall(A, paragem(A,B,C,D,E,F,X), P1),
	findall(Caminho, resolve_pp(NodoInicial, Caminho, NodoFinal,P1), Solucoes).