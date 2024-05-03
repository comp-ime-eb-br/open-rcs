import threading
import time
import customtkinter, shutil
from tkinter.filedialog import askopenfile, asksaveasfile
from customtkinter import ThemeManager
from tkinter import messagebox
from PIL import Image, ImageTk
import tkinter as tk

import os
import platform

from stl_module import *
from rcs_monostatic import *
from rcs_bistatic import *
from thread_trace import thread_with_trace
from gif import ImageLabel

customtkinter.set_appearance_mode("System")  # Modes: "System" (standard), "Dark", "Light"
customtkinter.set_default_color_theme("dark-blue")  # Themes: "blue" (standard), "green", "dark-blue"
class App(customtkinter.CTk):
    def __init__(self):
        super().__init__()
        self.model = None
        
        self.protocol("WM_DELETE_WINDOW", self.on_closing)

        # window and grid
        self.title("Open RCS")
        self.wm_iconbitmap()
        self.iconphoto(True, ImageTk.PhotoImage(file="./img/logo_openrcs.png"))
        self.geometry(f"{1350}x{600}")
        self.resizable(True,True)
        self.grid_columnconfigure((0, 1), weight=0)
        self.grid_columnconfigure(2, weight=1)
        self.grid_rowconfigure((0, 1, 2), weight=1)
        self.minsize(1350, 600)

        # sidebar
        self.sidebar_frame = customtkinter.CTkFrame(self, width=140, corner_radius=0)
        self.sidebar_frame.grid(row=0, column=0, rowspan=4, sticky="nsew")
        self.sidebar_frame.grid_rowconfigure(4, weight=1)
        logopath="./img/logo_openrcs.png"
        logo= customtkinter.CTkImage(dark_image=Image.open(logopath), size=(100,100))
        self.logo = customtkinter.CTkLabel(self.sidebar_frame, image=logo, text="")
        self.logo.grid(row=0, column=0, padx=20, pady=(20,0))
        self.logo_label = customtkinter.CTkLabel(self.sidebar_frame, text="Open RCS", font=customtkinter.CTkFont(size=20, weight="bold"))
        self.logo_label.grid(row=1, column=0, padx=20, pady=(10, 10))
        # self.organization = customtkinter.CTkLabel(self.sidebar_frame, text="CIGE - Centro de Instrução\nde Guerra Eletrônica", anchor="w")
        # self.organization.grid(row=2, column=0, padx=20, pady=(0, 10),sticky="s")
        self.appearance_mode_label = customtkinter.CTkLabel(self.sidebar_frame, text="Appearance Mode:", anchor="s")
        self.appearance_mode_label.grid(row=5, column=0, padx=20, pady=(5, 5))
        self.appearance_mode_optionemenu = customtkinter.CTkOptionMenu(self.sidebar_frame, values=["Light", "Dark", "System"], command=self.change_appearance_mode_event)
        self.appearance_mode_optionemenu.grid(row=6, column=0, padx=20, pady=(0, 20))
        self.appearance_mode_optionemenu.set("Dark")
        
        # description frame
        self.description = customtkinter.CTkFrame(self, width=140)
        self.description.grid(row=0, column=1, columnspan=1, padx=(20, 0), pady=(20,0), sticky="new")
        self.text = customtkinter.CTkLabel(self.description, text="\nO software Open-RCS foi desenvolvido para fins acadêmicos e de instrução\n referentes a diversos cenários de Guerra Eletrônica. A estimação do valor\nda RCS para as estruturas carregadas no programa é obitdo pelo método da\n Óptica Física e os resultados para os formatos clássicos (cubo, placa\nplana, esfera) foram validados contra o software externo POFacets.")
        self.text.grid(row=0, column=0, padx=(10,10), pady=(10,20), sticky="nsew")
        
        # tabview
        self.tabview = customtkinter.CTkTabview(self, width=140)
        self.tabview.grid(row=1, column=1, columnspan=1, padx=(20, 0), pady=(0, 0), sticky="nsew")
        self.tabview.add("Monoestático")
        self.tabview.add("Biestático")
        self.tabview.tab("Monoestático").grid_columnconfigure((0,1,2), weight=0)
        self.tabview.tab("Biestático").grid_columnconfigure((0,1,2), weight=0)

        # monostatic input values
        self.monomodel_text = "\n⬆\nUpload Modelo (.stl)\n"
        self.monotext = customtkinter.CTkLabel(self.tabview.tab("Monoestático"), text="Insira os dados para o cálculo monoestático da RCS estimada")
        self.monotext.grid(row=0, column=0, columnspan=3, padx=5, pady=(5,5), sticky="ew")
        self.monomodel = customtkinter.CTkButton(self.tabview.tab("Monoestático"), text=self.monomodel_text, command=self.upload, fg_color=ThemeManager.theme['CTkEntry']['fg_color'], text_color=ThemeManager.theme['CTkEntry']['placeholder_text_color'])
        self.monomodel.grid(row=4, column=0, rowspan=2, padx=5, pady=(5, 5),sticky="ns")
        self.monomodel.bind("<Enter>", self.on_button_enter)
        self.monomodel.bind("<Leave>", self.on_button_leave)
        self.monofreq = customtkinter.CTkEntry(self.tabview.tab("Monoestático"), placeholder_text="Frequência (Hz)")
        self.monofreq.grid(row=1, column=0, padx=5, pady=(5, 5))
        self.monocorr = customtkinter.CTkEntry(self.tabview.tab("Monoestático"), placeholder_text="Distância (m)")
        self.monocorr.grid(row=1, column=1, padx=5, pady=(5, 5))
        self.monodelstd = customtkinter.CTkEntry(self.tabview.tab("Monoestático"), placeholder_text="Desvio Padrão (m)")
        self.monodelstd.grid(row=1, column=2, padx=5, pady=(5, 5))
        self.monoipol = customtkinter.CTkOptionMenu(self.tabview.tab("Monoestático"), values=["TM-Z","TE-Z"], fg_color=ThemeManager.theme['CTkEntry']['fg_color'], text_color=ThemeManager.theme['CTkEntry']['placeholder_text_color'])
        self.monoipol.grid(row=2, column=0, padx=5, pady=(5,5))
        self.monoipol.set("Polarização")
        self.monorest = customtkinter.CTkOptionMenu(self.tabview.tab("Monoestático"), values=["Transparente","Condutor Perfeito"], fg_color=ThemeManager.theme['CTkEntry']['fg_color'], text_color=ThemeManager.theme['CTkEntry']['placeholder_text_color'])
        self.monorest.grid(row=3, column=0, padx=5, pady=(5,5))
        self.monorest.set("Resistividade")
        self.monopstart = customtkinter.CTkEntry(self.tabview.tab("Monoestático"), placeholder_text="Phi Inicial (º)")
        self.monopstart.grid(row=2, column=1, padx=5, pady=(5, 5))
        self.monopstop = customtkinter.CTkEntry(self.tabview.tab("Monoestático"), placeholder_text="Phi Final (º)")
        self.monopstop.grid(row=3, column=1, padx=5, pady=(5, 5))
        self.monodelp = customtkinter.CTkEntry(self.tabview.tab("Monoestático"), placeholder_text="Passo Phi (º)")
        self.monodelp.grid(row=4, column=1, padx=5, pady=(5, 5))
        self.monotstart = customtkinter.CTkEntry(self.tabview.tab("Monoestático"), placeholder_text="Theta Inicial (º)")
        self.monotstart.grid(row=2, column=2, padx=5, pady=(5, 5))
        self.monotstop = customtkinter.CTkEntry(self.tabview.tab("Monoestático"), placeholder_text="Theta Final (º)")
        self.monotstop.grid(row=3, column=2, padx=5, pady=(5, 5))
        self.monodelt = customtkinter.CTkEntry(self.tabview.tab("Monoestático"), placeholder_text="Passo Phi (º)")
        self.monodelt.grid(row=4, column=2, padx=5, pady=(5, 5))
        self.monoresult = customtkinter.CTkButton(self.tabview.tab("Monoestático"), text="Gerar Resultados", command=lambda: self.generate_results(self.generate_monoresults_event))
        self.monoresult.grid(row=6, column=1, padx=5, pady=(40, 0), sticky="nsew")
        self.monoresultfile = customtkinter.CTkButton(self.tabview.tab("Monoestático"), text="Gerar Resultados do Input File", command=lambda:self.generate_results(self.generate_monoresultsfile_event), fg_color=ThemeManager.theme['CTkEntry']['fg_color'], text_color=ThemeManager.theme['CTkEntry']['placeholder_text_color'])
        self.monoresultfile.grid(row=7, column=0, columnspan=3, padx=5, pady=(10, 0))
        self.monoerror = customtkinter.CTkLabel(self.tabview.tab("Monoestático"), text="", font=customtkinter.CTkFont(size=10, weight="bold"))
        self.monoerror.grid(row=8, column=1, padx=5, pady=0, sticky="ew")

        # bistatic input values
        self.bitext = customtkinter.CTkLabel(self.tabview.tab("Biestático"), text="Insira os dados para o cálculo biestático da RCS estimada")
        self.bitext.grid(row=0, column=0, columnspan=3, padx=5, pady=(5,5), sticky="ew")
        self.bimodel = customtkinter.CTkButton(self.tabview.tab("Biestático"), text="\n⬆\nUpload Modelo (.stl)\n", command=self.upload, fg_color=ThemeManager.theme['CTkEntry']['fg_color'], text_color=ThemeManager.theme['CTkEntry']['placeholder_text_color'])
        self.bimodel.grid(row=4, column=0, rowspan=2, padx=5, pady=(5, 5))
        self.bifreq = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Frequência (Hz)")
        self.bifreq.grid(row=1, column=0, padx=5, pady=(5, 5))
        self.bicorr = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Distância (m)")
        self.bicorr.grid(row=1, column=1, padx=5, pady=(5, 5))
        self.bidelstd = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Desvio Padrão (m)")
        self.bidelstd.grid(row=1, column=2, padx=5, pady=(5, 5))
        self.biipol = customtkinter.CTkOptionMenu(self.tabview.tab("Biestático"), dynamic_resizing=False, values=["TM-Z","TE-Z"], fg_color=ThemeManager.theme['CTkEntry']['fg_color'], text_color=ThemeManager.theme['CTkEntry']['placeholder_text_color'])
        self.biipol.grid(row=2, column=0, padx=5, pady=(5,5))
        self.biipol.set("Polarização")
        self.birest = customtkinter.CTkOptionMenu(self.tabview.tab("Biestático"), values=["Transparente","Condutor Perfeito"], fg_color=ThemeManager.theme['CTkEntry']['fg_color'], text_color=ThemeManager.theme['CTkEntry']['placeholder_text_color'])
        self.birest.grid(row=3, column=0, padx=5, pady=(5,5))
        self.birest.set("Resistividade")
        self.biphi = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Phi Incidente (º)")
        self.biphi.grid(row=2, column=1, padx=5, pady=(5, 5))
        self.bitheta = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Theta Incidente (º)")
        self.bitheta.grid(row=2, column=2, padx=5, pady=(5, 5))
        self.bipstart = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Phi Inicial (º)")
        self.bipstart.grid(row=3, column=1, padx=5, pady=(5, 5))
        self.bipstop = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Phi Final (º)")
        self.bipstop.grid(row=4, column=1, padx=5, pady=(5, 5))
        self.bidelp = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Passo Phi (º)")
        self.bidelp.grid(row=5, column=1, padx=5, pady=(5, 5))
        self.bitstart = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Theta Inicial (º)")
        self.bitstart.grid(row=3, column=2, padx=5, pady=(5, 5))
        self.bitstop = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Theta Final (º)")
        self.bitstop.grid(row=4, column=2, padx=5, pady=(5, 5))
        self.bidelt = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Passo Phi (º)")
        self.bidelt.grid(row=5, column=2, padx=5, pady=(5, 5))
        self.biresult = customtkinter.CTkButton(self.tabview.tab("Biestático"), text="Gerar Resultados", command=lambda: self.generate_results(self.generate_biresults_event))
        self.biresult.grid(row=7, column=1, padx=5, pady=(40, 0), sticky="nsew")
        self.biresultfile = customtkinter.CTkButton(self.tabview.tab("Biestático"), text="Gerar Resultados do Input File", command=lambda: self.generate_results(self.generate_biresults_event), fg_color=ThemeManager.theme['CTkEntry']['fg_color'], text_color=ThemeManager.theme['CTkEntry']['placeholder_text_color'])
        self.biresultfile.grid(row=8, column=0, columnspan=3, padx=5, pady=(10, 0))
        self.bierror = customtkinter.CTkLabel(self.tabview.tab("Biestático"), text="")
        self.bierror.grid(row=9, column=1, padx=5, pady=0, sticky="ew")
        
        # results frame
        self.results_frame = customtkinter.CTkFrame(self, width=250)
        self.results_frame.grid(row=0, column=2, rowspan=2, columnspan=2, padx=(20, 20), pady=(20, 0), sticky="nsew")
        self.results_frame.grid_columnconfigure((0,1,2), weight=1)
        self.label_results = customtkinter.CTkLabel(self.results_frame, text="Resultados", font=customtkinter.CTkFont(size=13, weight="bold"))
        self.label_results.grid(row=0, column=0, columnspan=3, padx=10, pady=(10,0), sticky="nsew")
        adjustp="./img/empty.png"
        adjust= customtkinter.CTkImage(dark_image=Image.open(adjustp), size=(600,300))
        self.adjust = customtkinter.CTkLabel(self.results_frame, image=adjust, text="")
        self.adjust.grid(row=1, column=0, columnspan=4, rowspan=4, padx=(30,30), pady=(10,10))
        self.cancel = customtkinter.CTkButton(self.results_frame, text="Cancelar Carregamento", command=self.end_generate_attempt,fg_color=ThemeManager.theme['CTkEntry']['fg_color'], text_color=ThemeManager.theme['CTkEntry']['placeholder_text_color'])

    def generate_results(self,function):
        try:
            self.reset_event()
        except:
            print("")
        self.thread = thread_with_trace(target=function)
        self.thread.start()
        self.result_tab_loading()

    def generate_monoresults_event(self):
        generate_images = False
        try:
            freq = float(self.monofreq.get())
            corr = float(self.monocorr.get())
            delstd = float(self.monodelstd.get())
            pol = self.monoipol.get()
            if pol == 'TM-Z': ipol=0
            elif pol == 'TE-Z': ipol=1
            rest = self.monorest.get()
            if rest == 'Condutor Perfeito': rs=0
            elif rest == 'Transparente': rs=1
            pstart = float(self.monopstart.get())
            pstop = float(self.monopstop.get())
            delp = float(self.monodelp.get())
            tstart = float(self.monotstart.get())
            tstop = float(self.monotstop.get())
            delt = float(self.monodelt.get())
            
            self.now = datetime.now().strftime("%Y%m%d%H%M%S")
            
            self.plotpath, self.figpath, self.filepath = rcs_monostatic(self.model, freq, corr, delstd, ipol, pstart, pstop, delp, tstart, tstop, delt, rs)
            generate_images = True

        except Exception as e:
            print(f"An error occurred: {str(e)}")
            self.monoerror.configure(text="Entradas Inválidas!")

        self.restore_result_tab()

        if generate_images:
            self.results_window()
            self.monoerror.configure(text="")
        
    def generate_monoresultsfile_event(self):
        generate_images = False
        try:
            input_data_file = "./input_files/input_data_file_monostatic.dat"
            params = open(input_data_file, 'r')
            param_list = []
            for line in params:
                line=line.strip("\n")
                if not line.startswith("#"):
                    if line.isnumeric(): param_list.append(int(line))
                    else: param_list.append(line)
            input_model, freq, corr, delstd, ipol, rs, pstart, pstop, delp, tstart, tstop, delt = param_list
            params.close()
            
            stl_converter("./stl_models/"+input_model)
            self.model = os.path.basename(input_model)           
            self.now = datetime.now().strftime("%Y%m%d%H%M%S")
            self.plotpath, self.figpath, self.filepath = rcs_monostatic(self.model, freq, corr, delstd, ipol, pstart, pstop, delp, tstart, tstop, delt, rs)
            generate_images = True

        except Exception as e:
            print(f"An error occurred: {str(e)}")
            self.monoerror.configure(text="Entradas Inválidas!")
        
        #fim da thread sempre limpa a tela
        self.restore_result_tab()
        
        #caso tenham gerado com sucesso, vai colocar as imagens em resultados
        if generate_images:
            self.results_window()
            self.monoerror.configure(text="")
        
    def generate_biresults_event(self):
        generate_images = False
        try:
            freq = float(self.bifreq.get())
            corr = float(self.bicorr.get())
            delstd = float(self.bidelstd.get())
            pol = self.biipol.get()
            if pol == 'TM-Z': ipol=0
            elif pol == 'TE-Z': ipol=1
            rest = self.birest.get()
            if rest == 'Condutor Perfeito': rs=0
            elif rest == 'Transparente': rs=1
            phii = float(self.biphi.get())
            thetai = float(self.bitheta.get())
            pstart = float(self.bipstart.get())
            pstop = float(self.bipstop.get())
            delp = float(self.bidelp.get())
            tstart = float(self.bitstart.get())
            tstop = float(self.bitstop.get())
            delt = float(self.bidelt.get())
            
            self.now = datetime.now().strftime("%Y%m%d%H%M%S")
            self.plotpath, self.figpath, self.filepath = rcs_bistatic(self.model, freq, corr, delstd, ipol, pstart, pstop, delp, tstart, tstop, delt,phii,thetai, rs)
            generate_images = True
        except Exception as e:
            print(f"An error occurred: {str(e)}")
            self.bierror.configure(text="Entradas Inválidas!")

        #fim da thread sempre limpa a tela
        self.restore_result_tab()
        
        #caso tenham gerado com sucesso, vai colocar as imagens em resultados
        if generate_images:
            self.results_window()
            self.bierror.configure(text="")

    def generate_biresultsfile_event(self):
        generate_images = False
        try:
            input_data_file = "./input_files/input_data_file_bistatic.dat"
            params = open(input_data_file, 'r')
            param_list = []
            for line in params:
                line=line.strip("\n")
                if not line.startswith("#"):
                    if line.isnumeric(): param_list.append(int(line))
                    else: param_list.append(line)
            input_model, freq, corr, delstd, ipol, rs, pstart, pstop, delp, tstart, tstop, delt, thetai, phii = param_list
            params.close()
            
            stl_converter("./stl_models/"+input_model)
            self.model = os.path.basename(input_model)           
            self.now = datetime.now().strftime("%Y%m%d%H%M%S")
            self.plotpath, self.figpath, self.filepath = rcs_bistatic(self.model, freq, corr, delstd, ipol, pstart, pstop, delp, tstart, tstop, delt,phii,thetai, rs)
            
            generate_images = True
        except Exception as e:
            print(f"An error occurred: {str(e)}")
            self.bierror.configure(text="Entradas Inválidas!")
            
            #fim da thread sempre limpa a tela
        self.restore_result_tab()
        
        #caso tenham gerado com sucesso, vai colocar as imagens em resultados
        if generate_images:
            self.results_window()
            self.bierror.configure(text="")

    def results_window(self):
        w,h=Image.open(self.plotpath).size
        plot= customtkinter.CTkImage(dark_image=Image.open(self.plotpath), size=(400,400*h/w))
        self.plottext = customtkinter.CTkLabel(self.results_frame, text="Seção Reta Radar do Alvo Carregado")
        self.plottext.grid(row=1, column=1, columnspan=1, padx=0, pady=0, stick="nsew")
        self.plot = customtkinter.CTkLabel(self.results_frame, image=plot, text="")
        self.plot.grid(row=2, column=1, padx=(20, 5), pady=0, sticky="nsew")
        self.figtext = customtkinter.CTkLabel(self.results_frame, text="Modelo Triangular do Alvo Carregado (.stl)")
        self.figtext.grid(row=1, column=2, columnspan=1, padx=0, pady=0, stick="nsew")
        w,h=Image.open(self.figpath).size
        fig= customtkinter.CTkImage(dark_image=Image.open(self.figpath), size=(400,400*h/w))
        self.fig = customtkinter.CTkLabel(self.results_frame, image=fig, text="")
        self.fig.grid(row=2, column=2, columnspan=1, padx=(5, 10), pady=0, sticky="nsew")
        self.saveplot = customtkinter.CTkButton(self.results_frame, text="⬇ Download Gráfico ", command=self.save_plot, width=300)
        self.saveplot.grid(row=3, column=1, columnspan=2, padx=5, pady=(25, 5))
        self.savefile = customtkinter.CTkButton(self.results_frame, text="⬇ Download Modelo Triangular", command=self.save_fig, width=300)
        self.savefile.grid(row=4, column=1, columnspan=2, padx=5, pady=(5, 5))
        self.savefig = customtkinter.CTkButton(self.results_frame, text="⬇ Download Arquivo de Dados", command=self.save_file, width=300)
        self.savefig.grid(row=5, column=1, columnspan=2, padx=5, pady=(5, 5))
        self.reset = customtkinter.CTkButton(self.results_frame, text="Reset", command=self.reset_event, fg_color=ThemeManager.theme['CTkEntry']['fg_color'], text_color=ThemeManager.theme['CTkEntry']['placeholder_text_color'])
        self.reset.grid(row=6, column=1, columnspan=2, padx=5, pady=15)  
       
    def upload(self):
        file = askopenfile(title="Selecionar um arquivo",
                  filetypes=[("Arquivos STL", "*.stl")])
        if file:
            stl_converter(file.name)
            self.model = os.path.basename(file.name)
            self.monomodel_text = f"\n⬆\nUploaded: {self.model}\n"
            self.monomodel.configure(text=self.monomodel_text)
            
    def on_button_enter(self, event):
        if self.model:
            self.monomodel.configure(text="\n⬆\nUpload Modelo (.stl)\n")

    def on_button_leave(self, event):
        # Restore the button text if not uploaded on mouse leave
        if self.model:
            self.monomodel.configure(text=f"\n⬆\nUploaded: {self.model}\n")
            
    def save_plot(self):
        im= Image.open(self.plotpath)
        im.save("./results/"+"RCSSimulator"+"_"+self.now+".png")
        self.on_save()
        
    def save_fig(self):
        im= Image.open(self.figpath)
        im.save("./results/"+"RCSSimulator"+"_"+self.now+".jpg")
        self.on_save()
        
    def save_file(self):
        shutil.copy(self.filepath, "./results/"+"RCSSimulator"+"_"+self.now+".dat")
        self.on_save()

    def open_file(self, file_path):
        try:
            plt.close()
            image = Image.open(file_path)
            plt.imshow(image)
            plt.axis('off')  
            plt.show()
            image.close()
        except FileNotFoundError:
            print(f"The file '{file_path}' was not found.")
        except Exception as e:
            print(f"An error occurred: {str(e)}")
            
    def reset_event(self):    
        self.plot.destroy()
        self.saveplot.destroy()
        os.remove(self.plotpath)
        
        self.fig.destroy()
        self.plottext.destroy()
        self.figtext.destroy()
        self.savefig.destroy()
        os.remove(self.figpath)
        
        self.savefile.destroy()
        os.remove(self.filepath)
        
        self.reset.destroy()

    def restore_result_tab(self):
        self.cancel.grid_forget()
        self.gif.destroy()
        self.active_buttons()

    def change_appearance_mode_event(self, new_appearance_mode: str):
        customtkinter.set_appearance_mode(new_appearance_mode)

    def end_generate_attempt(self):
        self.restore_result_tab()
        if self.thread.isAlive():
            self.thread.kill()
        
    def loading_gif(self):
        self.gif = ImageLabel(self.results_frame)
        self.gif.grid(row=4, column=1, padx=5, pady=(25, 5))
        self.gif.load('img/load.gif')

    def active_buttons(self):
        self.monoresult.configure(state=tk.ACTIVE)
        self.monoresultfile.configure(state=tk.ACTIVE)
        self.biresult.configure(state=tk.ACTIVE)
        self.biresultfile.configure(state=tk.ACTIVE)

    def disable_buttons(self):
        self.monoresult.configure(state=tk.DISABLED)
        self.monoresultfile.configure(state=tk.DISABLED)
        self.biresult.configure(state=tk.DISABLED)
        self.biresultfile.configure(state=tk.DISABLED)

    def result_tab_loading(self):
        self.disable_buttons()
        self.cancel.grid(row=5, column=1, padx=5, pady=(40, 0), sticky="nsew")
        self.loading_gif()

    def on_closing(self):
        if messagebox.askokcancel("Sair", "Deseja sair do programa?"):
            try:
                self.reset_event()
                if self.thread.isAlive():
                    self.thread.kill()
                    self.thread.join()
            except:
                print("")
            self.quit()

    def on_save(self):
        messagebox.showinfo("Arquivo Salvo", f"Arquivo salvo na pasta results do diretório do OpenRCS")
        
if __name__ == "__main__":
    app = App()
    app.mainloop()