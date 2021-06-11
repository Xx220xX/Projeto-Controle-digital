//Programa de Controle de Posição de um sistema de levitação pneumática
clear; clc; 
global axes Gt t y u;
s = %s; 
//Configurações básicas para a simulação
m = 0.1;
C =  0.5; 
rho = 1; 
r = 0.1; 
A = %pi*r^2; 
alfa = C*rho*A/2*m;
//Calculando a velocidade do ar para o equilibrio
g = 9.81;
vo = sqrt(g/alfa) 
//FT do movimento da bolinha
Gb = syslin('c',(2*alfa*vo)/(s^2));
//Constantes da Ventoinha
k_v = 0.02;
tal = 0.01;
//FT da ventoinha
Gv = syslin('c',k_v/(tal*s+1));
//FT equivalente da malha direta
Gs = Gv * Gb;
[Gs_z Gs_p Gs_k] = tf2zp(Gs);
//Compensador com cancelamento de polos e zeros
Mp = 0.01;//Criterio Mp=5%
//Mp=exp(-pi*(zeta/sqrt(1-zeta^2)))
zetamf = abs(log(Mp/100))/((%pi^2)+(log(Mp/100))^2)^(1/2);
T5 = 0.4;//Criterio T5 = 400ms
//T5 = 3/(wn*zeta)
wnmf = 3/(T5*zetamf);//wn
//Polos malha fechada Smf = -(zeta*wn)+/- i(wn*sqrt(1-zeta^2))
wdmf = (wnmf*sqrt(1-zetamf^2));
sigmamf = zetamf*wnmf;
smf = -sigmamf + wdmf*%i;//Raizes de Malha Fechada
//Determinando os polos do compensador
C1 = 1;
for i=1:length(Gs_z)
    C1 = C1*(s-Gs_z(i));
end
C1=1/C1;
//Determinando os zeros do compensador
for i=1:length(Gs_p)
    C1 = C1*(s-Gs_p(i));
end
//Determinando Kc
ppid = -2*sigmamf;
kc = -(smf*(smf-ppid))/Gs_k;
//Controlador PID em S
Gc = (kc/(s*(s-ppid)))*C1;
//FT equivalente do sistema realimentado 
Gt = Gc * Gv * Gb/(1+Gc * Gv * Gb);//O mesmo que Gt = feedback(Gd, 1)

//Funções do Programa
function moveSeta 
    if(findobj('tag','fSeta') <> [] && findobj('tag','c1Frame') <> [] && findobj('tag','tMV') <> []) then
        dimensaoImagem = get('c1Frame','Position');
        valor = strtod(get('tMV','String'));
        valorMax = (251+(dimensaoImagem(4)/2))/dimensaoImagem(4);
        ValorMin = ((dimensaoImagem(4)/2)-83)/dimensaoImagem(4);
        set('fSeta','Data',[0.2 (valor*(valorMax-ValorMin)/100)+ValorMin]);//Movimenta a senta conforme necessário
    end
endfunction

function rsz
    set('main_fig','visible','off');
    moveSeta;
    set('main_fig','visible','on');
endfunction

function Auto
    global axes Gt t y u;
    set('bManual','Enable','on');
    set('bAuto','Enable','off'); 
    set('tSP','Enable','on');
    set('tMV','Enable','off');    
    tamJanela=100; 
    dT = 1e-1;//Tempo de amostragem da simulação

    //Simulação
    while(get('bAuto','Enable') == 'off')
        t = [t t($)+dT];//tempo de simulação
        u = [u strtod(get('tSP','String'))];
        y = csim(u,t,Gt);//lsim
        set('tMV','String',msprintf("%d",y($)));
        moveSeta;        
        if (length(t) > tamJanela) then
            axes.children(1).children(2).data = [t($-tamJanela:$)', u($-tamJanela:$)'];// plot sem mover a janela
            axes.children(1).children(1).data = [t($-tamJanela:$)', y($-tamJanela:$)'];// plot sem mover a janela
        else
            axes.children(1).children(2).data = [t', u']; // plot sem mover a janela
            axes.children(1).children(1).data = [t', y']; // plot sem mover a janela
        end
        try
            replot(axes);
        catch
        end    
        sleep(dT);                                                                              
     end
endfunction

function Manual
    set('bManual','Enable','off');
    set('bAuto','Enable','on');  
    set('tSP','Enable','off');
    set('tMV','Enable','on');       
endfunction

// Construção Gráfica
dimensaoTela = get(0, "screensize_px");
main_fig = figure('layout', 'gridbag',...//plotGraph = createWindow();
       'toolbar', 'none',...
       'menubar', 'none',...
       'backgroundcolor', [1 1 1],...
       'visible','off',..
       'resizefcn', 'rsz',..
       'tag','main_fig');
set('main_fig','axes_size',[620,600]);
dimensaoFig = get('main_fig','figure_size');
set('main_fig','figure_position',..
               [((dimensaoTela(1)+dimensaoTela(3)-dimensaoFig(1))/2);...
                ((dimensaoTela(2)+dimensaoTela(4)-dimensaoFig(2))/2)]);//Coloca o tela no centro do monitor
//A tela terá 3 frames sendo cada um uma linha onde a informação será apresentada
//Organização dos Frames
l1Frame = uicontrol(main_fig,...
              'layout', 'gridbag', ...
              'style', 'frame', ...
              'constraints', createConstraints("gridbag", [1, 2, 1, 1], [1, 0.01], "both"));             
l2Frame = uicontrol(main_fig,...
              'layout', 'gridbag', ...
              'style', 'frame', ...
              'constraints', createConstraints("gridbag", [1, 4, 1, 1], [1, 1], "both"));
c1Frame = uicontrol(l2Frame,...
              'layout', 'gridbag', ...
              'style', 'frame', ...
              'tag','c1Frame',..
              'constraints', createConstraints("gridbag", [1, 1, 1, 1], [0.001, 1], "both", "center", [0, 0], [239 554]));
c2Frame = uicontrol(l2Frame,...
              'layout', 'gridbag', ...
              'style', 'frame', ...
              'constraints', createConstraints("gridbag", [2, 1, 1, 1], [1, 1], "both"));
//Inserção das imagens
axesImage = newaxes(c1Frame);
axesImage.margins = [0 0 0 0];
strPath = part(get_absolute_file_path("grafLevit.sce"),1:$-7)+'Imagens\';
//strPath = get_absolute_file_path("Figura.sce");// Caso a imagem estiver na mesma pasta do programa
r = xstringl(0, 0, "$\includegraphics{"+strPath+"fotoLevitador3.png}$");
xstringb(0,0,"$\includegraphics{"+strPath+"fotoLevitador3.png}$",1,1);
xstring(0.2,0.35,"$\includegraphics{"+strPath+"fotoSeta.png}$");
gce().tag = 'fSeta';//Seta o tag para o handle corrente
//Inserção dos Objetos Graficos  
uicontrol(l1Frame,...
           'HorizontalAlignment','right',..//Orientação do texto deste encapsulamento
           'Style','text',..
           'Margins', [10 10 10 10],..//Cria um espaço em branco [top esquerda abaixo direita]
           'constraints', createConstraints("gridbag", [1, 1, 1, 1], [0.01, 1], "horizontal", "right"), ..
           'String','PV:');                  
uicontrol(l1Frame,...
           'Tag','tPV',..
           'HorizontalAlignment','left',..//Orientação do texto deste encapsulamento
           'Style','edit',..
           'String','0',..
           'Enable','off',..
           'Margins', [10 0 10 0],..//Cria um espaço em branco [top esquerda abaixo direita]
           'constraints', createConstraints("gridbag", [2, 1, 1, 1], [0.1, 1], "none", "left", [0, 0], [80 25])); 
uicontrol(l1Frame,...
           'HorizontalAlignment','right',..//Orientação do texto deste encapsulamento
           'Style','text',..
           'Margins', [10 0 10 10],..//Cria um espaço em branco [top esquerda abaixo direita]
           'constraints', createConstraints("gridbag", [3, 1, 1, 1], [0.01, 1], "horizontal", "right"), ..
           'String','SP:');                  
uicontrol(l1Frame,...
           'Tag','tSP',..
           'HorizontalAlignment','left',..//Orientação do texto deste encapsulamento
           'Style','edit',..
           'String','50',..
           'Enable','off',..
           'Margins', [10 0 10 0],..//Cria um espaço em branco [top esquerda abaixo direita]
           'constraints', createConstraints("gridbag", [4, 1, 1, 1], [0.1, 1], "none", "left", [0, 0], [80 25])); 
uicontrol(l1Frame,...
           'HorizontalAlignment','right',..//Orientação do texto deste encapsulamento
           'Style','text',..
           'Margins', [10 0 10 10],..//Cria um espaço em branco [top esquerda abaixo direita]
           'constraints', createConstraints("gridbag", [5, 1, 1, 1], [0.01, 1], "horizontal", "right"), ..
           'String','MV:');                  
uicontrol(l1Frame,...
           'Tag','tMV',..
           'HorizontalAlignment','left',..//Orientação do texto deste encapsulamento
           'Style','edit',..
           'String','0',..
           'Margins', [10 0 10 0],..//Cria um espaço em branco [top esquerda abaixo direita]
           'Callback','moveSeta',...
           'callback_type', 10,..
           'constraints', createConstraints("gridbag", [6, 1, 1, 1], [0.1, 1], "none", "left", [0, 0], [80 25])); 
uicontrol(l1Frame,...
           'Style','text',..
           'constraints', createConstraints("gridbag", [7, 1, 1, 1], [1, 1], "none", "center"), ..
           'String',' ');
uicontrol(l1Frame,...
           'Tag','bAuto',..
           'Style', 'pushbutton',...
           'String','Auto',...
           'Callback','Auto',...   
           'constraints', createConstraints("gridbag", [8, 1, 1, 1], [0.01, 1], "none", "center", [0, 0], [80 25]), ..
           'BackgroundColor',[0.00,1.00,0.00]);
uicontrol(l1Frame,...
           'Tag','bManual',..
           'Style', 'pushbutton',...
           'Enable','off',..
           'String','Manual',...
           'Callback','Manual',...
           'callback_type', 10,...                   
           'constraints', createConstraints("gridbag", [9, 1, 1, 1], [0.01, 1], "none", "center", [0, 0], [80 25]), ..
           'BackgroundColor',[0.00,0.00,1.0]);
axesFrame = uicontrol(c2Frame,..
           'layout', 'gridbag', ...
           'style', 'frame', ...
           'constraints', createConstraints("gridbag", [1, 2, 1, 1], [1, 1], "both"));
axes = newaxes(axesFrame);
axes.auto_clear = "on"; //Se "on" uma chamada a um gráfico reinicializa os eixos correntes apagando tudo que ja tinha antes.
t = [0];u = [0];y = [0];// Inicialização das variaveis
plot(axes, t, u,'-r', t, y,'-b');  // Every AnalogRead needs to be on its own Plotgraph
title('Controle de posição vertical');
xlabel('Tempo [s]');
ylabel('Altura [m]');
main_fig.visible = 'on';
disp('Programa Inicializado!!!');
