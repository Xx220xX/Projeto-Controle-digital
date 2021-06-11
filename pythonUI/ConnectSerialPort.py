from serial import Serial
import tkinter as tk
import ConfigurarPorta as tela0
import show as tela1

def run(root, obj):
    root.title("Connectando")

    try:
        obj['serial'] = Serial(obj['porta'],obj['speed'])
    except Exception as e:
        tela0.run(root,obj['scdim'],str(e))
        return
    tela1.run(root,obj)

