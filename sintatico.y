/*+−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−
  | UNIFAL − Universidade Federal de Alfenas .
  | BACHARELADO EM CIENCIA DA COMPUTACAO.
  | Trabalho . . : Vetor e verificacao de tipos
  | Disciplina . : Teoria de Linguagens e Compiladores
  | Professor . .: Luiz Eduardo da Silva
  | Aluno . . . .: Andre Neves Medeiros
  | Data . . . . : 24/03/2022
  +−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−*/


%{ 
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "lexico.c"
    #include "estrut.c"

    void erro(char *);
    int yyerror(char *);
    int conta = 0;
    int rotulo = 0;
    char tipo;
%}

%start programa
%token T_PROGRAMA
%token T_INICIO
%token T_FIM
%token T_IDENTIF
%token T_LEIA
%token T_ESCREVA
%token T_ENQTO
%token T_FACA
%token T_FIMENQTO
%token T_SE
%token T_ENTAO
%token T_SENAO
%token T_FIMSE
%token T_ATRIB
%token T_VEZES
%token T_DIV
%token T_MAIS
%token T_MENOS
%token T_IGUAL
%token T_MAIOR
%token T_MENOR
%token T_E
%token T_OU
%token T_V
%token T_F
%token T_NUMERO
%token T_NAO
%token T_ABRE
%token T_FECHA

%token T_ABREC
%token T_FECHAC

%token T_INTEIRO
%token T_LOGICO


%left T_E T_OU
%left T_IGUAL
%left T_MAIOR T_MENOR
%left T_MAIS T_MENOS
%left T_VEZES T_DIV


%%

programa
    : cabecalho variaveis
        { 
            mostra_tabela(); 
            fprintf(yyout, "\tAMEM\t%d\n", conta);
            empilha(conta);
            }
      T_INICIO lista_comandos T_FIM
        { 
            fprintf(yyout, "\tDMEM\t%d\n", desempilha()); 
            fprintf(yyout, "\tFIMP\n"); 
            }
    ;

cabecalho
    : T_PROGRAMA T_IDENTIF
        { fprintf(yyout, "\tINPP\n"); }
    ;

variaveis
    :
    | declaracao_variaveis
    ;

declaracao_variaveis
    : tipo lista_variaveis declaracao_variaveis
    | tipo lista_variaveis
    ;

tipo
    : T_INTEIRO { tipo = 'i'; }
    | T_LOGICO  { tipo = 'l'; }
    ;

lista_variaveis
    : lista_variaveis variavel
    | variavel
    ;

variavel
    : T_IDENTIF 
    {
        strcpy(elem_tab.id, atomo);
    }
    tamanho
    ;

tamanho
    : 
       {
            elem_tab.endereco = conta++;
            elem_tab.tipo = tipo;
            elem_tab.cat=0;
            elem_tab.tam = 1;
            insere_simbolo(elem_tab);

        }
    | T_ABREC T_NUMERO { 
            //chegada();
            elem_tab.endereco = conta;
            elem_tab.tipo = tipo;
            elem_tab.cat=1;
            elem_tab.tam = atoi(atomo);
            //printf("%d\n", atoi(atomo));
            insere_simbolo(elem_tab);
            conta += atoi(atomo);
        } T_FECHAC
    ;

lista_comandos
    :
    | comando lista_comandos
    ;

comando
    : leitura
    | escrita
    | repeticao
    | selecao
    | atribuicao
    ;

leitura
    : T_LEIA T_IDENTIF
        {  
            int pos = busca_simbolo(atomo);
            empilha(pos);
        }
        posicao
    ;

posicao
    :   {                                                               //se nao encontra nada prossegue para variavel simples
            fprintf(yyout, "\tLEIA\n");  
            int pos = desempilha();
            if (pos == -1)
                erro ("Variavel nao declarada!");
            fprintf(yyout, "\tARZG\t%d\n", TabSimb[pos].endereco);
        }
    | T_ABREC expr T_FECHAC                                             //caso de leitura para vetor, encontra colchete
        {
            //chegada();                             //a pilha chega com o topo sendo o tipo, seguido pela posicao base do variavel vetor
            //imprime_pilha();
            char t = desempilha();
            char pos = desempilha();

            if (pos == -1)
                erro ("Variavel nao declarada!");

            if (t != TabSimb[pos].tipo)
                erro ("Tipos diferentes!");
                
            fprintf(yyout, "\tLEIA\n");
            fprintf(yyout, "\tARZV\t%d\n", TabSimb[pos].endereco);     
        }
    ;

escrita
    : T_ESCREVA expr
        { 
            desempilha();
            fprintf(yyout, "\tESCR\n");  
        }
    ;

repeticao
    : T_ENQTO
        { 
            rotulo++;
            fprintf(yyout, "L%d\tNADA\n", rotulo);
            empilha(rotulo);
        }
    expr T_FACA
        { 
            char t = desempilha();
            if(t != 'l'){
                erro("Incompatibilidade de tipos");
            }
            rotulo++;
            fprintf(yyout, "\tDSVF\tL%d\n", rotulo);  
            empilha(rotulo);
            }
    lista_comandos T_FIMENQTO
        { 
            int r1 = desempilha();
            int r2 = desempilha();
            fprintf(yyout, "\tDSVS\tL%d\n", r2);  
            fprintf(yyout, "L%d\tNADA\n", r1);  
            }
    ;

selecao
    : T_SE expr T_ENTAO
        { 
            char t = desempilha();
            if(t != 'l'){
                erro("Incompatibilidade de tipos");
            }
            rotulo++;
            fprintf(yyout, "\tDSVF\tL%d\n", rotulo);  
            empilha(rotulo);
        }
    lista_comandos T_SENAO 
        { 
            int r = desempilha();
            rotulo++;
            fprintf(yyout, "\tDSVS\tL%d\n", rotulo); 
            empilha(rotulo) ;
            fprintf(yyout, "L%d\tNADA\n", r);  
         }
    lista_comandos T_FIMSE
        { 
            int r = desempilha();
            fprintf(yyout, "L%d\tNADA\n", r);  
        }
    ;



    

atribuicao
    :T_IDENTIF
    {
        int pos = busca_simbolo(atomo);  //posicao NA TABELA de simbolos
        if (pos == -1)
            erro ("Variavel nao declarada!");
        empilha(pos); //poe na pilha a posicao do atomo c na tabela de simbolos
    }
    indexador T_ATRIB expr
        { 
            //imprime_pilha();
            int tipo = desempilha();
            int pos = desempilha ();
            
           

            if(TabSimb[pos].cat == 0){ // se for variavel comum
                if(tipo != TabSimb[pos].tipo){
                    erro("Tipos diferentes!");
                }else{
                    fprintf(yyout, "\tARZG\t%d\n", TabSimb[pos].endereco);
                }
            }
            else{                       //se for vetor
                if(tipo != TabSimb[pos].tipo){
                    erro("Tipos diferentes!");
                }else{
                    fprintf(yyout, "\tARZV\t%d\n", TabSimb[pos].endereco); 
                }
            }
        }
    ;

indexador
    :   /*vazio*/
    |T_ABREC expr
        {
            int t = desempilha();
            int p = desempilha();
            if (t == 'l')
                erro ("tipo do indice deve ser inteiro");
            if (TabSimb[p].cat != 1)
                erro ("variavel nao eh vetor.");
            empilha (p);
        }
        T_FECHAC
    ;




expr
    : expr T_VEZES expr
        { 
            char t1 = desempilha();
            char t2 = desempilha();
            if(t1 != 'i' || t2 != 'i'){
                erro("Incompatibilidade de tipos!");
            }
            empilha('i');
            fprintf(yyout, "\tMULT\n");  
            
        }
    | expr T_DIV expr
        { 
            char t1 = desempilha();
            char t2 = desempilha();
            if(t1 != 'i' || t2 != 'i'){
                erro("Incompatibilidade de tipos!");
            }
            empilha('i');
            fprintf(yyout, "\tDIVI\n");  
        }
    | expr T_MAIS expr
        { 
            char t1 = desempilha();
            char t2 = desempilha();
            if(t1 != 'i' || t2 != 'i'){
                erro("Incompatibilidade de tipos!");
            }
            empilha('i');
            fprintf(yyout, "\tSOMA\n"); 
        }
    | expr T_MENOS expr
        { 
            fprintf(yyout, "\tSUBT\n");
            char t1 = desempilha();
            char t2 = desempilha();
            if(t1 != 'i' || t2 != 'i'){
                erro("Incompatibilidade de tipos!");
            }
            empilha('i');  
        }

    | expr T_MAIOR expr
        { 
            char t1 = desempilha();
            char t2 = desempilha();
            if(t1 != 'i' || t2 != 'i'){
                erro("Incompatibilidade de tipos!");
            }
            empilha('l');
            fprintf(yyout, "\tCMMA\n");  
        }
    | expr T_MENOR expr
        { 
            char t1 = desempilha();
            char t2 = desempilha();
            if(t1 != 'i' || t2 != 'i'){
                erro("Incompatibilidade de tipos!");
            }
            empilha('l');
            fprintf(yyout, "\tCMME\n");  
        }
    | expr T_IGUAL expr
        { 
            char t1 = desempilha();
            char t2 = desempilha();
            if(t1 != 'i' || t2 != 'i'){
                erro("Incompatibilidade de tipos!");
            }
            empilha('l');
            fprintf(yyout, "\tCMIG\n");  
        }

    | expr T_E expr
        { 
            char t1 = desempilha();
            char t2 = desempilha();
            if(t1 != 'l' || t2 != 'l'){
                erro("Incompatibilidade de tipos!");
            }
            empilha('l');
            fprintf(yyout, "\tCONJ\n");  
        }
    | expr T_OU expr
        { 
            char t1 = desempilha();
            char t2 = desempilha();
            if(t1 != 'l' || t2 != 'l'){
                erro("Incompatibilidade de tipos!");
            }
            empilha('l');
            fprintf(yyout, "\tDISJ\n");  
        }
    | termo
    ;

termo
    :T_IDENTIF  //caso simples ou vetor (precisa da posicao do identificador)
        { 
            int pos = busca_simbolo(atomo); //(corrigido)para b<-a esse busca atomo pega a variavel da linha de baixo na atribuicao
            if (pos == -1)
                erro ("Variavel nao declarada!");
            empilha(pos);
            empilha(TabSimb[pos].tipo); 
        } 
        indice                                           
        ;
    | T_NUMERO
        { 
            fprintf(yyout, "\tCRCT\t%s\n", atomo);
            empilha('i');
        }
    | T_V
        { 
            fprintf(yyout, "\tCRCT\t1\n");
            empilha('l') ;
        }
    | T_F
        { 
            fprintf(yyout, "\tCRCT\t0\n");
            empilha('l');
        }
    | T_NAO termo
        { 
            char t = desempilha();
            if(t !='l'){
                erro("Incompatibilidade de tipos");
            }
            empilha('l');
            fprintf(yyout, "\tNEGA\n");  

        }
    | T_ABRE expr T_FECHA
    
    ;

indice
    : /*vazio*/
    {
        int t = desempilha();
        int pos = desempilha(); //essa posicao vem de termo quando encontra T_IDENTIF
        if (pos == -1)
            erro ("Variavel nao declarada!");
        fprintf(yyout, "\tCRVG\t%d\n", TabSimb[pos].endereco); 
        empilha(TabSimb[pos].tipo); 
    }
    |T_ABREC expr T_FECHAC
    {
        int t1 = desempilha();
        int t2 = desempilha();
        int pos = desempilha();

        //empilha(atoi(atomo)); // empilha o index do vetor //nao precisa pois sabe a posicao pela pilha de execucao
        
        if (pos == -1)
            erro ("Variavel nao declarada!");
        fprintf(yyout, "\tCRVV\t%d\n", TabSimb[pos].endereco); 
        empilha(TabSimb[pos].tipo); 
    }
    ;


%%

void erro (char *s) {
    printf("ERRO na linha %d: %s\n", numLinha, s);
    exit(10);
}

int yyerror (char *s){
    erro ("Erro sintatico");
}

int main (int argc, char *argv[]) {
    char *p, nameIn[100], nameOut[100];
    argv++;
    if(argc < 2){
        puts("\n Compilador simples");
        puts("   USO: ./simples <nomefonte>[.simples]\n\n");
        exit (10);
    }
p = strstr(argv[0], ".simples");
    if(p) *p = 0;
    strcpy(nameIn, argv[0]);
    strcat(nameIn, ".simples");
    strcpy(nameOut, argv[0]);
    strcat(nameOut, ".mvs");

    yyin = fopen (nameIn, "rt");
    if(!yyin){
        puts("Programa fonte nao encontrado");
        exit(10);
    }

    yyout = fopen (nameOut, "wt");

    if (!yyparse())
        puts ("Programa ok!");

}