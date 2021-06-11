from threading import Thread
import tkinter as tk
from tkinter import ttk
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import struct
from math import floor
import numpy as np
def run(root,obj):
    frame_velocidaAngular = tk.Frame(root,bg='#0f0')
    frame_saidaCompensador = tk.Frame(root,bg='#00f')
    frameBotoes = tk.Frame(root)

    root.title('Speed Control')


    uiBotoes(frameBotoes,obj)
    frame_velocidaAngular.place(x=1,y=35,width= obj['scdim'][0],height= obj['scdim'][1]/2-20)
    frame_saidaCompensador.place(x=1,y=obj['scdim'][1]/2+20,width= obj['scdim'][0],height= obj['scdim'][1]/2-20)
    frameBotoes.place(x=1,y=1,width= obj['scdim'][0],height= 40)
    pltW = putGraphics(frame_velocidaAngular,obj['scdim'][0],obj['scdim'][1]/2-20,'Velocidade angular',2,legend=['Velocidade do rotor rad/s','Velocidade Alvo rad/s'])
    pltVa = putGraphics(frame_saidaCompensador,obj['scdim'][0],obj['scdim'][1]/2-20,'Tensão de armadura')

    def loop():
        w,st,va,x= [0],[0],[0],[0]
        obj['len'] = 10000
        #obj['serial'].readline()
        last_bytes = b''
        while True:
            n = floor(obj['serial'].in_waiting/3)*3
            if n<=30: continue
            b =  obj['serial'].read(30)
            b = list(b)           
            w_ = np.array(b[::3])/255*40-20
            tg_ = np.array(b[1::3])/255*40-20
            va_ = np.array(b[2::3])/255*20-10
            w = w + list(w_)
            Ts = 10e-3
            x = x + list(x[-1]+Ts + np.arange(0,np.size(w_))*Ts)
            
            st = st + list(tg_)
            va = va + list(va_)
            
            if len(w)> obj['len']:
                w = w[len(w)-obj['len']:]
                x = x[len(x)-obj['len']:]
                st = st[len(st)-obj['len']:]
                va = va[len(va)-obj['len']:]
            pltW(x,w,x,st)
            pltVa(x,va)

    Thread(target=loop,daemon=True).start()


def putGraphics(frame,x=100,y=100,title='',data=1,legend = ['Tensão(V)']):
    figure = plt.Figure(figsize=(6,6), dpi=100)
    ax = figure.add_subplot(111)
    cv = FigureCanvasTkAgg(figure, frame)
    cv.get_tk_widget().place(x=0,y=0,width = x,height=y)
    if data == 1:
        gp, = ax.plot([0],[0])
    else:
        gp,gp2 = ax.plot([0],[0],[0],[0])
    ax.set_title(title)
    ax.set_ylim(-15,15)
    ax.grid()
    ax.legend(legend)
    if data ==1:
        def plot(x,y):
            gp.set_data(x,y)
            ax.set_xlim(x[0],x[-1])
            cv.draw()
    else:
        def plot(x,y,w,z):
            gp.set_data(x,y)
            gp2.set_data(w,z)
            ax.set_xlim(x[0],x[-1])
            cv.draw()
        
    return plot
def uiBotoes(frame,obj):
    tk.Label(frame,text='Velocidade').place(x=1,y=10,width=100)
    value = tk.DoubleVar(frame)
    valueStr = tk.StringVar(frame)
    valueStr.set('0')
    value.set(0)
    def chose_event(event):
        v = value.get()
        v = floor((v+10)/20*255)/255.0*20-10
        value.set(v)
        valueStr.set('%.2f'%(value.get(),))

    tk.Label(frame,textvariable=valueStr).place(x=280,y=10,width=100)
    slider = ttk.Scale(frame,from_=-10,to=10,orient='horizontal',command=chose_event,variable=value)
    slider.place(x=105,y=10,width=170)
    def send(event):
        obj['setpoint'] = value.get()
        num = floor((obj['setpoint']+10)/20*255)
        obj['serial'].write(num.to_bytes(length=1, byteorder='big', signed=False))
    slider.bind("<ButtonRelease-1>", send)

def binary(num):
    return [c for c in struct.pack('d',num)]
