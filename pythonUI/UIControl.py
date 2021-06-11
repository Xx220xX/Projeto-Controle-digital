import tkinter as tk
import ConfigurarPorta as tela
root = tk.Tk()
dimensao = (720,540)
root.geometry("%dx%d"%dimensao)
tela.run(root,dimensao)



root.mainloop()