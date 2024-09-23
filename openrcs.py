import time
import customtkinter, shutil
from tkinter.filedialog import askopenfile, asksaveasfilename
from customtkinter import ThemeManager
from tkinter import messagebox
from PIL import Image, ImageTk
import tkinter as tk
import os
from stl_module import *
from rcs_monostatic import *
from rcs_bistatic import *
from rcs_functions import getParamsFromFile,FREQUENCY,STANDART_DEVIATION,RESISTIVITY,MATERIALESPECIFICO,NTRIA
from thread_trace import thread_with_trace
from gif import ImageLabel
import warnings

customtkinter.set_appearance_mode("System")  # Modes: "System" (standard), "Dark", "Light"
customtkinter.set_default_color_theme("dark-blue")  # Themes: "blue" (standard), "green", "dark-blue"

class App(customtkinter.CTk):
    def __init__(self):
        super().__init__()
        self.model = None
        self.protocol("WM_DELETE_WINDOW", self.on_closing)
        self.defineInterfaceComponents()
        
    def defineInterfaceComponents(self):
        self.define_window_and_grid()
        self.define_sidebars()
        self.define_description_frame_and_tabview()
        self.define_monostatic_inputs()
        self.define_bistatic_inputs()
        self.define_results_frame()

    def define_window_and_grid(self):
        self.title("Open RCS")
        self.wm_iconbitmap()
        self.icon_image = ImageTk.PhotoImage(file="./img/logo_openrcs.png")
        self.iconphoto(True, self.icon_image)
        self.geometry(f"{1350}x{600}")
        self.resizable(True,True)
        self.grid_columnconfigure((0, 1), weight=0)
        self.grid_columnconfigure(2, weight=1)
        self.grid_rowconfigure((0, 1, 2), weight=1)
        self.minsize(1350, 600)

    def define_sidebars(self):
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
        self.appearance_mode_label = customtkinter.CTkLabel(self.sidebar_frame, text="Modo de Aparência:", anchor="s")
        self.appearance_mode_label.grid(row=5, column=0, padx=20, pady=(5, 5))
        self.appearance_mode_optionemenu = customtkinter.CTkOptionMenu(self.sidebar_frame, values=["Claro", "Escuro", "Sistema"], command=self.change_appearance_mode_event)
        self.appearance_mode_optionemenu.grid(row=6, column=0, padx=20, pady=(0, 20))
        self.appearance_mode_optionemenu.set("Claro")
        self.last_appearance_mode = "Claro"

    def define_description_frame_and_tabview(self):
        self.descriptionFrame = customtkinter.CTkFrame(self, width=140)
        self.descriptionFrame.grid(row=0, column=1, columnspan=1, padx=(20, 0), pady=(20,0), sticky="new")
        self.text = customtkinter.CTkLabel(self.descriptionFrame, text="\nO software Open-RCS foi desenvolvido para fins acadêmicos e de instrução\n referentes a diversos cenários de Guerra Eletrônica. A estimação do valor\nda RCS para as estruturas carregadas no programa é obitdo pelo método da\n Óptica Física e os resultados para os formatos clássicos (cubo, placa\nplana, esfera) foram validados contra o software externo POFacets.")
        self.text.grid(row=0, column=0, padx=(10,10), pady=(10,20), sticky="nsew")
        
        self.tabview = customtkinter.CTkTabview(self, width=140)
        self.tabview.grid(row=1, column=1, columnspan=1, padx=(20, 0), pady=(0, 0), sticky="nsew")
        self.tabview.add("Monoestático")
        self.tabview.add("Biestático")
        self.tabview.tab("Monoestático").grid_columnconfigure((0,1,2), weight=0)
        self.tabview.tab("Biestático").grid_columnconfigure((0,1,2), weight=0)

    def define_monostatic_inputs(self):
        self.monomodel_text = "\n⬆\nUpload Modelo (.stl)\n"
        self.monotext = customtkinter.CTkLabel(self.tabview.tab("Monoestático"), text="Insira os dados para o cálculo monoestático da RCS estimada")
        self.monotext.grid(row=0, column=0, columnspan=3, padx=5, pady=(5,5), sticky="ew")
        self.monomodel = customtkinter.CTkButton(self.tabview.tab("Monoestático"), text=self.monomodel_text, command=self.upload, fg_color=ThemeManager.theme['CTkEntry']['fg_color'], text_color=ThemeManager.theme['CTkEntry']['placeholder_text_color'])
        self.monomodel.grid(row=4, column=0, rowspan=2, padx=5, pady=(5, 5),sticky="ns")
        self.monomodel.bind("<Enter>", self.on_button_enter)
        self.monomodel.bind("<Leave>", self.on_button_leave)
        self.monofreq = customtkinter.CTkEntry(self.tabview.tab("Monoestático"), placeholder_text="Frequência (GHz)")
        self.monofreq.grid(row=1, column=0, padx=5, pady=(5, 5))
        self.monocorr = customtkinter.CTkEntry(self.tabview.tab("Monoestático"), placeholder_text="Distância (m)")
        self.monocorr.grid(row=1, column=1, padx=5, pady=(5, 5))
        self.monodelstd = customtkinter.CTkEntry(self.tabview.tab("Monoestático"), placeholder_text="Desvio Padrão (m)")
        self.monodelstd.grid(row=1, column=2, padx=5, pady=(5, 5))
        self.monoipol = customtkinter.CTkOptionMenu(self.tabview.tab("Monoestático"), values=["TM-Z","TE-Z"], fg_color=ThemeManager.theme['CTkEntry']['fg_color'], text_color=ThemeManager.theme['CTkEntry']['placeholder_text_color'])
        self.monoipol.grid(row=2, column=0, padx=5, pady=(5,5))
        self.monoipol.set("Polarização")
        self.monorest = customtkinter.CTkOptionMenu(self.tabview.tab("Monoestático"), values=["Material Específico","Condutor Perfeito"], fg_color=ThemeManager.theme['CTkEntry']['fg_color'], text_color=ThemeManager.theme['CTkEntry']['placeholder_text_color'])
        self.monorest.grid(row=3, column=0, padx=5, pady=(5,5))
        self.monorest.set("Resistividade")
        self.monopstart = customtkinter.CTkEntry(self.tabview.tab("Monoestático"), placeholder_text="Phi Inicial (º)")
        self.monopstart.grid(row=2, column=1, padx=5, pady=(5, 5))
        self.monopstop = customtkinter.CTkEntry(self.tabview.tab("Monoestático"), placeholder_text="Phi Final (º)")
        self.monopstop.grid(row=3, column=1, padx=5, pady=(5, 5))
        self.monodelp = customtkinter.CTkEntry(self.tabview.tab("Monoestático"), placeholder_text="Passo Phi (º)")
        self.monodelp.grid(row=4, column=1, padx=5, pady=(5, 5))
        self.monotstart = customtkinter.CTkEntry(self.tabview.tab("Monoestático"), placeholder_text="Teta Inicial (º)")
        self.monotstart.grid(row=2, column=2, padx=5, pady=(5, 5))
        self.monotstop = customtkinter.CTkEntry(self.tabview.tab("Monoestático"), placeholder_text="Teta Final (º)")
        self.monotstop.grid(row=3, column=2, padx=5, pady=(5, 5))
        self.monodelt = customtkinter.CTkEntry(self.tabview.tab("Monoestático"), placeholder_text="Passo Teta (º)")
        self.monodelt.grid(row=4, column=2, padx=5, pady=(5, 5))
        self.monoresult = customtkinter.CTkButton(self.tabview.tab("Monoestático"), text="Gerar Resultados", command=lambda: self.generate_and_show_results_event('monostatic','interface'))
        self.monoresult.grid(row=6, column=1, padx=5, pady=(40, 0), sticky="nsew")
        self.monoresultfile = customtkinter.CTkButton(self.tabview.tab("Monoestático"), text="Gerar Resultados do Input File", command=lambda:self.generate_and_show_results_event('monostatic','inputFile'), fg_color=ThemeManager.theme['CTkEntry']['fg_color'], text_color=ThemeManager.theme['CTkEntry']['placeholder_text_color'])
        self.monoresultfile.grid(row=7, column=0, columnspan=3, padx=5, pady=(10, 0))
        self.monoerror = customtkinter.CTkLabel(self.tabview.tab("Monoestático"), text="", font=customtkinter.CTkFont(size=10, weight="bold"))
        self.monoerror.grid(row=8, column=1, padx=5, pady=0, sticky="ew")

    def define_bistatic_inputs(self):  
        self.bitext = customtkinter.CTkLabel(self.tabview.tab("Biestático"), text="Insira os dados para o cálculo biestático da RCS estimada")
        self.bitext.grid(row=0, column=0, columnspan=3, padx=5, pady=(5,5), sticky="ew")
        self.bimodel = customtkinter.CTkButton(self.tabview.tab("Biestático"), text="\n⬆\nUpload Modelo (.stl)\n", command=self.upload, fg_color=ThemeManager.theme['CTkEntry']['fg_color'], text_color=ThemeManager.theme['CTkEntry']['placeholder_text_color'])
        self.bimodel.grid(row=4, column=0, rowspan=2, padx=5, pady=(5, 5))
        self.bifreq = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Frequência (GHz)")
        self.bifreq.grid(row=1, column=0, padx=5, pady=(5, 5))
        self.bicorr = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Distância (m)")
        self.bicorr.grid(row=1, column=1, padx=5, pady=(5, 5))
        self.bidelstd = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Desvio Padrão (m)")
        self.bidelstd.grid(row=1, column=2, padx=5, pady=(5, 5))
        self.biipol = customtkinter.CTkOptionMenu(self.tabview.tab("Biestático"), dynamic_resizing=False, values=["TM-Z","TE-Z"], fg_color=ThemeManager.theme['CTkEntry']['fg_color'], text_color=ThemeManager.theme['CTkEntry']['placeholder_text_color'])
        self.biipol.grid(row=2, column=0, padx=5, pady=(5,5))
        self.biipol.set("Polarização")
        self.birest = customtkinter.CTkOptionMenu(self.tabview.tab("Biestático"), values=["Material Específico","Condutor Perfeito"], fg_color=ThemeManager.theme['CTkEntry']['fg_color'], text_color=ThemeManager.theme['CTkEntry']['placeholder_text_color'])
        self.birest.grid(row=3, column=0, padx=5, pady=(5,5))
        self.birest.set("Resistividade")
        self.biphi = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Phi Incidente (º)")
        self.biphi.grid(row=2, column=1, padx=5, pady=(5, 5))
        self.bitheta = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Teta Incidente (º)")
        self.bitheta.grid(row=2, column=2, padx=5, pady=(5, 5))
        self.bipstart = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Phi Inicial (º)")
        self.bipstart.grid(row=3, column=1, padx=5, pady=(5, 5))
        self.bipstop = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Phi Final (º)")
        self.bipstop.grid(row=4, column=1, padx=5, pady=(5, 5))
        self.bidelp = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Passo Phi (º)")
        self.bidelp.grid(row=5, column=1, padx=5, pady=(5, 5))
        self.bitstart = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Teta Inicial (º)")
        self.bitstart.grid(row=3, column=2, padx=5, pady=(5, 5))
        self.bitstop = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Teta Final (º)")
        self.bitstop.grid(row=4, column=2, padx=5, pady=(5, 5))
        self.bidelt = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Passo Teta (º)")
        self.bidelt.grid(row=5, column=2, padx=5, pady=(5, 5))
        self.biresult = customtkinter.CTkButton(self.tabview.tab("Biestático"), text="Gerar Resultados", command=lambda: self.generate_and_show_results_event('bistatic','interface'))
        self.biresult.grid(row=7, column=1, padx=5, pady=(40, 0), sticky="nsew")
        self.biresultfile = customtkinter.CTkButton(self.tabview.tab("Biestático"), text="Gerar Resultados do Input File", command=lambda: self.generate_and_show_results_event('bistatic','inputFile'), fg_color=ThemeManager.theme['CTkEntry']['fg_color'], text_color=ThemeManager.theme['CTkEntry']['placeholder_text_color'])
        self.biresultfile.grid(row=8, column=0, columnspan=3, padx=5, pady=(10, 0))
        self.bierror = customtkinter.CTkLabel(self.tabview.tab("Biestático"), text="")
        self.bierror.grid(row=9, column=1, padx=5, pady=0, sticky="ew")

    def define_results_frame(self):
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

    def define_material_frame(self):
        self.material_window = customtkinter.CTkToplevel(self)
        self.material_window.withdraw()

        self.material_window.title("Características do Material")
        self.material_window.wm_iconbitmap()
        self.material_window.iconphoto(True, self.icon_image)
        self.material_window.resizable(True,True)
        self.material_window.grid_columnconfigure(0, weight=1)
        self.material_window.grid_columnconfigure(1, weight=1)
       
        self.material_text = customtkinter.CTkLabel(self.material_window, text="Selecione o Tipo de Material")
        self.material_text.grid(row=0, column=0,columnspan=2, padx=10, pady=10)

        self.material_type = customtkinter.CTkOptionMenu(self.material_window, values=["PEC","Composito", "Camada de Composito em PEC", "Multiplas Camadas", "Multiplas Camadas em PEC"], fg_color=ThemeManager.theme['CTkEntry']['fg_color'], text_color=ThemeManager.theme['CTkEntry']['placeholder_text_color'], command=self.on_select_material_type)
        self.material_type.grid(row=1, column=0, columnspan=2, padx=5, pady=(5,5))

        self.material_ffacet = customtkinter.CTkLabel(self.material_window, text="Primeira Faceta")
        self.material_ffacet.grid(row=2, column=0, padx=5, pady=(5,5))

        self.ffacet_entry = customtkinter.CTkEntry(self.material_window, placeholder_text="Todas")
        self.ffacet_entry.grid(row=3, column=0, padx=5, pady=(5, 5))

        self.material_lfacet = customtkinter.CTkLabel(self.material_window, text="Última Facetas")
        self.material_lfacet.grid(row=2, column=1, padx=5, pady=(5,5))

        self.lfacet_entry = customtkinter.CTkEntry(self.material_window, placeholder_text="Todas")
        self.lfacet_entry.grid(row=3, column=1, padx=5, pady=(5, 5))

        self.material_perms = customtkinter.CTkLabel(self.material_window, text="Permissividade")
        self.material_perms.grid(row=4, column=0, columnspan=2, padx=5, pady=(5,5))

        self.relperm_entry = customtkinter.CTkEntry(self.material_window, placeholder_text="Permissividade Rel.")
        self.relperm_entry.grid(row=6, column=0, padx=5, pady=(5, 5))

        self.losstang_entry = customtkinter.CTkEntry(self.material_window, placeholder_text="Tang. de Perdas")
        self.losstang_entry.grid(row=6, column=1, padx=5, pady=(5, 5))

        self.material_perm = customtkinter.CTkLabel(self.material_window, text="Permeabilidade")
        self.material_perm.grid(row=7, column=0, columnspan=3, padx=5, pady=(5,5), sticky="ew")

        self.real_entry = customtkinter.CTkEntry(self.material_window, placeholder_text="Parte Real")
        self.real_entry.grid(row=9, column=0, padx=5, pady=(5, 5))

        self.imag_entry = customtkinter.CTkEntry(self.material_window, placeholder_text="Parte Imaginária")
        self.imag_entry.grid(row=9, column=1, padx=5, pady=(5, 5))

        self.material_thick = customtkinter.CTkLabel(self.material_window, text="Espessura (mm)")
        self.material_thick.grid(row=10, column=0, columnspan=2, padx=5, pady=(5,5))

        self.thick_entry = customtkinter.CTkEntry(self.material_window, placeholder_text="Espessura")
        self.thick_entry.grid(row=11, column=0,columnspan=2, padx=5, pady=(5, 5))

        self.button_addlayer = customtkinter.CTkButton(self.material_window, text="Adicionar Camada", command=lambda: self.add_new_layer_event())

        self.button_removelayer = customtkinter.CTkButton(self.material_window, text="Remover Última Camada", command=lambda: self.remove_last_layer())
        
        self.material_message = customtkinter.CTkLabel(self.material_window, text="", font=customtkinter.CTkFont(size=10, weight="bold"))
        self.material_message.grid(row=13, column=0, columnspan=2, padx=5, pady=(5,5))

        self.button_openconfig = customtkinter.CTkButton(self.material_window, text="Calcular com Arquivo", command=lambda:self.define_material_properties_list_from_material_file_event())
        self.button_openconfig.grid(row=14, column=1, padx=5, pady=(5,5))

        self.button_actualconfig = customtkinter.CTkButton(self.material_window, text="Ver Configuração Atual", command=lambda: self.show_actual_material_config_event())
        self.button_actualconfig.grid(row=14, column=0, padx=5, pady=(5,5))

        self.button_saveconfig = customtkinter.CTkButton(self.material_window, text="Salvar", command=lambda: self.save_current_material_properties())
        self.button_saveconfig.grid(row=15, column=0, padx=5, pady=(5,5))

        self.button_continue = customtkinter.CTkButton(self.material_window, text="Calcular RCS",command=lambda: self.run_write_matrl_and_calculate_rcs_event())
        self.button_continue.grid(row=15, column=1,columnspan=2, padx=5, pady=(5,5))
        self.material_window.deiconify()
        
    def define_actual_material_frame(self):
        self.material_actual_configuration = customtkinter.CTkToplevel(self.material_window)
        self.material_actual_configuration.title("Características do Atual do Material")
        self.material_actual_configuration.wm_iconbitmap()
        self.material_actual_configuration.iconphoto(True, self.icon_image)
        self.material_actual_configuration.resizable(False, False)
        self.material_actual_configuration.grid_columnconfigure(0, weight=1)
        self.material_actual_configuration.grid_columnconfigure(1, weight=1)
       
        self.canvas = customtkinter.CTkCanvas(self.material_actual_configuration)
        self.canvas.grid(row=0, column=0, columnspan=2, padx=(10, 10), pady=(10, 10), sticky="nsew")

        # Scrollbar para o Canvas
        scrollbar = customtkinter.CTkScrollbar(self.material_actual_configuration, orientation="vertical", command=self.canvas.yview)
        scrollbar.grid(row=0, column=2, sticky="ns")

        self.canvas.configure(yscrollcommand=scrollbar.set)

        self.table_inner_frame = customtkinter.CTkFrame(self.canvas)

        self.load_header_of_material_table()
         
        self.load_lines_of_material_table() 
        
        self.table_inner_frame.grid(row=0, column=0, padx=5, pady=5, sticky="nsew")
        self.canvas.create_window((0, 0), window=self.table_inner_frame, anchor="nw")

        self.table_inner_frame.update_idletasks()
        self.canvas.config(scrollregion=self.canvas.bbox("all"))
        self.table_width = self.table_inner_frame.winfo_reqwidth()
        row_height = self.table_inner_frame.winfo_children()[0].winfo_reqheight()
        self.material_actual_configuration.geometry(f"{self.table_width+30}x{row_height*9+50}") 
        
    def generate_and_show_results_event(self,method,inputFont):
        try:
            self.reset_event()
        except:
            pass

        self.method = method # monostatic or bistatic
        self.inputFont = inputFont # interface or inputFile
        
        self.initiate_thread_for_function(self.generate_and_show_results)
    
    def initiate_thread_for_function(self, function):
        try:
            self.end_generate_attempt()
        except Exception as e:
            pass
        self.thread = thread_with_trace(target=function)
        self.thread.start()
        self.result_tab_loading()
    
    def generate_and_show_results(self):         
        try:
            self.update_all_data_and_run_rcs_simulation()

        except Exception as e:
            self.error_message_and_restore_tab(e)
    
    def update_all_data_and_run_rcs_simulation(self):
        self.update_simulation_params_list()
        
        self.verify_standart_deviation()

        self.now = datetime.now().strftime("%Y%m%d%H%M%S")
        
        self.coordinatesData = extractCoordinatesData(self.simulationParamsList[RESISTIVITY])
        
        self.define_action_for_each_resistivity_case()
              
    def update_simulation_params_list(self):
        if self.inputFont == 'interface':
            self.simulationParamsList = self.getParamsFromInterface()
        elif self.inputFont == 'inputFile':
            self.simulationParamsList = getParamsFromFile(self.method)

    def getParamsFromInterface(self) -> list:
        def get_common_params(prefix):
            return [
                float(getattr(self, f"{prefix}freq").get())*1e9,
                float(getattr(self, f"{prefix}corr").get()),
                float(getattr(self, f"{prefix}delstd").get()),
                convert_polarization(getattr(self, f"{prefix}ipol").get()),
                convert_reisivity(getattr(self, f"{prefix}rest").get()),
                float(getattr(self, f"{prefix}pstart").get()),
                float(getattr(self, f"{prefix}pstop").get()),
                float(getattr(self, f"{prefix}delp").get()),
                float(getattr(self, f"{prefix}tstart").get()),
                float(getattr(self, f"{prefix}tstop").get()),
                float(getattr(self, f"{prefix}delt").get()),
            ]

        def convert_polarization(pol):
            if pol == 'TM-Z': return 0
            elif pol == 'TE-Z': return 1

        def convert_reisivity(rest):
            if rest == 'Condutor Perfeito': return 0
            elif rest == 'Material Específico': return 1

        simulationParamsList = [self.model]
        
        if self.method == 'monostatic':
            simulationParamsList.extend(get_common_params('mono'))
        elif self.method == 'bistatic':
            simulationParamsList.extend(get_common_params('bi'))
            simulationParamsList.append(float(self.bitheta.get()))
            simulationParamsList.append(float(self.bipstart.get()))
        simulationParamsList.append('matrl.txt')
        
        return simulationParamsList

    def verify_standart_deviation(self):
        wave = 3e8/(self.simulationParamsList[FREQUENCY])

        if self.simulationParamsList[STANDART_DEVIATION] > 0.1*wave:
            messagebox.showerror("Desvio", "Desvio Padrão elevado")
            raise ValueError("Desvio padrão elevado")

    def define_action_for_each_resistivity_case(self):
        self.ntria = self.coordinatesData[NTRIA]
        self.reset_all_material_lists_and_define_type('PEC')
        
        if self.simulationParamsList[RESISTIVITY] == MATERIALESPECIFICO:
            self.especific_material_treatment()
        else:
            self.update_material_properties_list()
            save_list_in_file(self.material_properties_list,'matrl.txt')
            self.calculate_and_show_rcs_results()
            
    def especific_material_treatment(self):
        if self.inputFont == 'inputFile' and self.simulationParamsList[-1] != "configure":
            self.calculate_and_show_rcs_results()
        else:
            self.simulationParamsList[-1] = 'matrl.txt'
            self.open_material_especification_tab()
                
    def open_material_especification_tab(self): 
        self.define_material_frame()
        self.end_generate_attempt()
        
    def get_entrys_from_material_interface(self):
        try:
            self.get_facets_indexs()
            self.type = getattr(self, f"material_type").get()
            self.thickness = float(getattr(self, f"thick_entry").get())
            self.RelPermittivity = float(getattr(self, f"relperm_entry").get())
            self.lossTangent = float(getattr(self, f"losstang_entry").get())
            self.RelaPermeabilityReal = float(getattr(self, f"real_entry").get())
            self.RelaPermeabilityImaginary = float(getattr(self, f"imag_entry").get())
            print(self.facetBeginIndex,self.facetEndIndex,self.type,self.thickness,self.RelPermittivity,self.lossTangent,self.RelaPermeabilityReal,self.RelaPermeabilityImaginary)
            return True
        
        except Exception as e:
            print(e)
            return False
    
    def run_write_matrl_and_calculate_rcs_event(self):
        try:
            self.reset_event()
        except Exception as e:
            pass
        self.initiate_thread_for_function(self.run_write_matrl_and_calculate_rcs)
        
    def run_write_matrl_and_calculate_rcs(self):
        if self.get_entrys_from_material_interface():
            self.material_window.withdraw()
            self.add_current_layer()
            save_list_in_file(self.material_properties_list,'matrl.txt')
            self.remove_last_layer()
            self.calculate_and_show_rcs_results()
        
        else:
            if (self.type == 'Multiplas Camadas' or self.type == 'Multiplas Camadas em PEC') and self.material_properties_list != []:
                self.material_window.withdraw()       
                save_list_in_file(self.material_properties_list,'matrl.txt')
                self.calculate_and_show_rcs_results()

            else:
                self.material_message.configure(text="Preencha os campos corretamente.")

    def show_actual_material_config_event(self):
        if self.get_entrys_from_material_interface():
            self.add_current_layer()
            self.define_actual_material_frame()
            self.remove_last_layer()
            self.material_message.configure(text="")   
        else:
            if (self.type == 'Multiplas Camadas' or self.type == 'Multiplas Camadas em PEC') and self.material_properties_list != []:
                self.define_actual_material_frame()
            else:   
                self.material_message.configure(text="Termine de preencher os campos.")
    
    def define_material_properties_list_from_material_file_event(self):
        try:
            self.reset_event()
        except Exception as e:
            pass
        self.initiate_thread_for_function(self.define_material_properties_list_from_material_file)
    
    def define_material_properties_list_from_material_file(self):
        self.material_window.withdraw()
        
        materialFile = askopenfile(title="Selecionar um arquivo", filetypes=[("Text files", "*.txt")])
       
        self.material_properties_list = get_material_properties_from_file(materialFile)
            
        if len(self.material_properties_list) != self.ntria:
            self.material_message.configure(text="Número de facets divergentes.")
        else:
            save_list_in_file(self.material_properties_list,'matrl.txt')
            self.calculate_and_show_rcs_results()
                     
    def save_current_material_properties(self):
        if self.get_entrys_from_material_interface():
            self.add_current_layer()
            file_path = asksaveasfilename(defaultextension=".txt", 
                                             filetypes=[("Text files", "*.txt"), ("All files", "*.*")])
            save_list_in_file(self.material_properties_list,file_path)
            self.remove_last_layer()
            self.material_message.configure(text="")
        
        elif (self.type == "Multiplas Camadas" or self.type == "Multiplas Camadas em PEC") and len(self.material_properties_list) > 0:
            file_path = asksaveasfilename(defaultextension=".txt", 
                                             filetypes=[("Text files", "*.txt"), ("All files", "*.*")])
            save_list_in_file(self.material_properties_list,file_path)
        else:
            self.material_message.configure(text="Sem camadas incluídas.")
        
    def update_material_properties_list(self):
        self.material_properties_list = []
        
        for m in range(self.ntria):
            entry = [self.types[m],self.description[m]]
            
            if len(self.layers[m]) == 0:
               entry.append([0, 0, 0, 0, 0]) 
                        
            for layer in self.layers[m]:
                entry.append(layer)
                                 
            self.material_properties_list.append(entry)
      
    def update_material_types(self):
        for facetIndex in range(self.facetBeginIndex-1,self.facetEndIndex):
            self.types[facetIndex] = self.type
    
    def add_new_layer_event(self):
        if self.get_entrys_from_material_interface():
            self.add_current_layer()
            self.material_message.configure(text="Nova camada adicionada com sucesso")
        else:
            self.material_message.configure(text="Entradas inválidas")
        
    def add_current_layer(self):
        layerProperties = [self.RelPermittivity, self.lossTangent, self.RelaPermeabilityReal, self.RelaPermeabilityImaginary, self.thickness]
        for facetIndex in range(self.facetBeginIndex-1,self.facetEndIndex):
            self.types[facetIndex] = self.type
            self.layers[facetIndex].append(layerProperties)
        self.update_material_properties_list()
        
    def remove_last_layer(self):
        try :
            remove_some_layer = False
            for facetIndex in range(self.facetBeginIndex-1,self.facetEndIndex):
                tamanho = len(self.layers[facetIndex])
                if tamanho > 0:
                    self.layers[facetIndex].pop()
                    remove_some_layer = True
                    
                    if tamanho - 1 == 0:
                        self.material_properties_list[facetIndex][0] = "PEC"
                    
                    
            if remove_some_layer:
                self.material_message.configure(text="Remoção realizada com sucesso")
                self.update_material_properties_list()
            else:
                self.material_message.configure(text="Sem mais camadas a remover")
                
        except Exception as e:
            self.material_message.configure(text="Sem mais camadas a remover")
                  
    def get_facets_indexs(self):
        ffacet_value = getattr(self, "ffacet_entry").get()
        lfacet_value = getattr(self, "lfacet_entry").get()

        self.facetBeginIndex = int(ffacet_value) if ffacet_value.strip() else 1
        self.facetEndIndex = int(lfacet_value) if lfacet_value.strip() else self.ntria
 
    def reset_all_material_lists_and_define_type(self,type):
        self.material_properties_list = []
        self.types = [type for _ in range(self.ntria)]
        self.description = ['facet description' for _ in range(self.ntria)]
        self.layers = [[] for _ in range(self.ntria)]  
        
    def calculate_and_show_rcs_results(self):
        self.plotpath, self.figpath, self.filepath = self.calculate_RCS()
    
        self.restore_result_tab()

        self.show_results_on_interface()
               
    def calculate_RCS(self):
        if self.method == 'monostatic': return rcs_monostatic(self.simulationParamsList,self.coordinatesData)
        elif self.method == 'bistatic': return rcs_bistatic(self.simulationParamsList, self.coordinatesData)
  
    def error_message_and_restore_tab(self,e):
        print(f"An error occurred: {str(e)}")
        self.restore_result_tab()
        if self.method[:4] == 'mono': self.monoerror.configure(text="Entradas Inválidas!")
        elif self.method[:2] == 'bi': self.bierror.configure(text="Entradas Inválidas!")
        
    def show_results_on_interface(self):
        self.results_window()
        if self.method == 'monostatic': self.monoerror.configure(text="")
        elif self.method == 'bistatic': self.bierror.configure(text="")
            
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
        self.reset = customtkinter.CTkButton(self.results_frame, text="Limpar Área", command=self.reset_event, fg_color=ThemeManager.theme['CTkEntry']['fg_color'], text_color=ThemeManager.theme['CTkEntry']['placeholder_text_color'])
        self.reset.grid(row=6, column=1, columnspan=2, padx=5, pady=15)  
       
    def upload(self):
        file = askopenfile(title="Selecionar um arquivo",
                  filetypes=[("Arquivos STL", "*.stl")])
        if file:
            stl_converter(file.name)
            self.model = os.path.basename(file.name)
            self.monomodel_text = f"\n⬆\nUploaded: {self.model}\n"
            self.monomodel.configure(text=self.monomodel_text)
    
    def load_header_of_material_table(self): 
        columns = ["faceta", "Material", "Descrição", "Permis. Relat.", "Tang. de Perdas", "Permea. Rela. Real", "Permea. Rela. Img", "Espess."]
        for col_index, col_name in enumerate(columns):
            header_label = customtkinter.CTkLabel(self.table_inner_frame, text=col_name, font=customtkinter.CTkFont(weight="bold"))
            header_label.grid(row=0, column=col_index, padx=5, pady=5)
       
    def load_lines_of_material_table(self):

        new_data = convert_material_properties_list_format_to_table_format(self.material_properties_list)
            
        for row_index, row_data in enumerate(new_data):
            for col_index, cell_data in enumerate(row_data):
                cell_label = customtkinter.CTkLabel(self.table_inner_frame, text=str(cell_data))
                cell_label.grid(row=row_index + 1, column=col_index, padx=5, pady=5)
            
    def on_button_enter(self, event):
        if self.model:
            self.monomodel.configure(text="\n⬆\nUpload Modelo (.stl)\n")

    def on_button_leave(self, event):
        # Restore the button text if not uploaded on mouse leave
        if self.model:
            self.monomodel.configure(text=f"\n⬆\nUploaded: {self.model}\n")
            
    def on_select_material_type(self,choice):
        self.reset_all_material_lists_and_define_type("PEC")
        
        if choice == "PEC" or choice == "Composito" or choice == "Composito Layer on PEC":
            self.button_addlayer.grid_remove()
            self.button_removelayer.grid_remove()
            
        elif choice == "Multiplas Camadas" or choice == "Multiplas Camadas em PEC":
            self.button_addlayer.grid(row=12, column=0, padx=5, pady=(5,5))
            self.button_removelayer.grid(row=12, column=1, padx=5, pady=(5,5))
            
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
        try:
            self.cancel.grid_forget()
            self.active_buttons()
            self.gif.destroy()
        except Exception as e:
            pass

    def change_appearance_mode_event(self, new_appearance_mode: str):
        if self.gif.winfo_exists():
            self.appearance_mode_optionemenu.set(self.last_appearance_mode)
        else:
            if new_appearance_mode == "Claro": 
                self.last_appearance_mode = "Light"
            elif new_appearance_mode == "Escuro": 
                self.last_appearance_mode = "Dark"
            else: 
                self.last_appearance_mode = "System"
            
            self.withdraw()
            customtkinter.set_appearance_mode(self.last_appearance_mode)
            time.sleep(0.1)
            self.deiconify()
        
    def end_generate_attempt(self):
        self.restore_result_tab()
        if self.thread.isAlive():
            self.thread.kill()
        
    def loading_gif(self):
        self.gif = ImageLabel(self.results_frame)
        self.gif.set_background_color_for_appearence(customtkinter.get_appearance_mode())
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