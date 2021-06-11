import  tkinter as tk

from serial.tools.list_ports import comports
import pickle as pk
import ConnectSerialPort as tela
def run(root:tk.Tk,dimensao,msg = ''):
    frame = tk.Frame(bg="#aaa")
    root.title("Select Serial Port: "+msg)
    obj = {}
    # verifica se tem arquivo salvo
    portas = [d.device for d in comports()]
    speed = [9600,19200,38400,57600,74880,115200,230400,250000]
    try:
        with open(".pyuisession","rb") as f:
            obj = pk.load(f)
    except Exception as e:
        obj['porta'] = portas[0]
        obj['speed'] = speed[0]
        obj['setpoint'] = 0
        obj['len'] = 100

    variable = tk.StringVar(frame)
    variable.set(obj['porta']) # default value
    tk.Label(frame,text="Serial Port:").place(x=dimensao[0]*0.1,y=1,width= dimensao[0]*0.4,height= 25)
    tk.OptionMenu(frame, variable, *portas).place(x=dimensao[0]*0.1,y=30,width= dimensao[0]*0.4,height= 30)

    variable2 = tk.StringVar(frame)
    variable2.set(obj['speed']) # default value
    tk.Label(frame,text="Serial Speed:").place(x=dimensao[0]*0.5,y=1,width= dimensao[0]*0.4,height= 25)
    tk.OptionMenu(frame, variable2, *speed).place(x=dimensao[0]*0.5,y=30,width= dimensao[0]*0.4,height= 30)

    def next():
        obj['porta'] = variable.get()
        obj['speed'] = variable2.get()
        with open(".pyuisession","wb") as f:
            pk.dump(obj,f)
        frame.destroy()
        tela.run(root,obj)
    obj['scdim'] = dimensao
    tk.Button(frame,text="next",command=next).place(x=dimensao[0]*0.1,y=65,width= dimensao[0]*0.8,height= 30)
    frame.place(x=0,y=0,width= dimensao[0],height= dimensao[1])


