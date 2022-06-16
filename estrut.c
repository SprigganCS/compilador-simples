/*+−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−
  | UNIFAL − Universidade Federal de Alfenas .
  | BACHARELADO EM CIENCIA DA COMPUTACAO.
  | Trabalho . . : Vetor e verificacao de tipos
  | Disciplina . : Teoria de Linguagens e Compiladores
  | Professor . .: Luiz Eduardo da Silva
  | Aluno . . . .: Andre Neves Medeiros
  | Data . . . . : 24/03/2022
  +−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−*/


#define TAM_TAB 100
#define TAM_PIL 100

//Pilha semantica
int Pilha[TAM_PIL];
int topo = -1;

//Tabela de simbolos
struct elem_tab_simbolos {
    char id[100];
    int endereco;
    char tipo;
    int cat;
    int tam;

} TabSimb[TAM_TAB], elem_tab;
int pos_tab = 0;


// Rotinas da pilha semantica
void empilha (int valor) {
    if(topo == TAM_PIL)
        erro("Pilha cheia!");
    Pilha[++topo] = valor;
}

int desempilha (){
    if (topo == -1)
        erro("Pilha vazia!");
    return Pilha[topo--];
}

//Rotinas da Tabela de simbolos
//retorna -1 se nao encontra o id
int busca_simbolo (char *id) {
    int i = pos_tab - 1;
    for(; strcmp(TabSimb[i].id, id) && i >= 0; i--)
       ;
    return i;
}

void insere_simbolo (struct elem_tab_simbolos elem){
    int i;
    if (pos_tab ==TAM_TAB)
        erro("Tabela de simbolos cheia!");
    i = busca_simbolo(elem.id);
    if(i != -1){
        erro("Identificador duplicado");
        }
    TabSimb[pos_tab++] = elem;
    
}

void mostra_tabela()
{
    int i;
    char* aux;
    puts("Tabela de Simbolos");
    printf("\n%3s | %30s | %s | %s |  %s  | %s |\n", "#", "ID", "END", "TIP", "CAT", "TAM");
    for (i = 0; i < 100; i++)
        printf("-");

    for (i = 0; i < pos_tab; i++){
        if(TabSimb[i].cat==1){
            aux = "VET";
        }else{ //se nao for 1, vai ser 0
            aux="VAR";
        }
        printf("\n%3d | %30s | %3d |%3c  |  %3s  |  %d  |", i, TabSimb[i].id, TabSimb[i].endereco, TabSimb[i].tipo, aux, TabSimb[i].tam);
    }
    puts("\n");
}



//modificações
void chegada(){ //testa se o programa chega no lugar que a função é chamada
    printf("Chegou\n");
}
//imprime a pilha de execução completa
void imprime_pilha(){
    int i;
    printf("\nPilha Semantica\n");
    if(topo == -1){
        printf("Vazia\n");
    }
    else{
        for(i=0; i<=topo; i++){
            printf("%d\n", Pilha[i]);
        }
    }
    
}



