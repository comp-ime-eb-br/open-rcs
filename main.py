from tkinter.filedialog import askopenfile 
from customtkinter import ThemeManager
import tkfontawesome 
import fontawesome as fa
import customtkinter
from PIL import Image

customtkinter.set_appearance_mode("System")  # Modes: "System" (standard), "Dark", "Light"
customtkinter.set_default_color_theme("blue")  # Themes: "blue" (standard), "green", "dark-blue"

class App(customtkinter.CTk):
    def __init__(self):
        super().__init__()

        # window and grid
        self.title("Open RCS")
        self.geometry(f"{1150}x{600}")
        self.grid_columnconfigure((1, 2, 3), weight=1)
        self.grid_rowconfigure((0, 1, 2), weight=1)

        # sidebar
        self.sidebar_frame = customtkinter.CTkFrame(self, width=140, corner_radius=0)
        self.sidebar_frame.grid(row=0, column=0, rowspan=4, sticky="nsew")
        self.sidebar_frame.grid_rowconfigure(4, weight=1)
        logopath="files/logo_openrcs.png"
        logo= customtkinter.CTkImage(dark_image=Image.open(logopath), size=(100,100))
        self.logo = customtkinter.CTkLabel(self.sidebar_frame, image=logo, text="")
        self.logo.grid(row=0, column=0, padx=20, pady=(20,0))
        self.logo_label = customtkinter.CTkLabel(self.sidebar_frame, text="Open RCS", font=customtkinter.CTkFont(size=20, weight="bold"))
        self.logo_label.grid(row=1, column=0, padx=20, pady=(10, 10))
        self.organization = customtkinter.CTkLabel(self.sidebar_frame, text="CIGE - Centro de Instrução\nde Guerra Eletrônica", anchor="w")
        self.organization.grid(row=2, column=0, padx=20, pady=(0, 10),sticky="s")
        self.appearance_mode_label = customtkinter.CTkLabel(self.sidebar_frame, text="Appearance Mode:", anchor="s")
        self.appearance_mode_label.grid(row=5, column=0, padx=20, pady=(5, 5))
        self.appearance_mode_optionemenu = customtkinter.CTkOptionMenu(self.sidebar_frame, values=["Light", "Dark", "System"], command=self.change_appearance_mode_event)
        self.appearance_mode_optionemenu.grid(row=6, column=0, padx=20, pady=(0, 5))
        self.appearance_mode_optionemenu.set("Dark")
        
        # description frame
        self.description = customtkinter.CTkFrame(self, width=140)
        self.description.grid(row=0, column=1, columnspan=1, padx=(20, 0), pady=(20, 0), sticky="nsew")
        self.label_description = customtkinter.CTkLabel(self.description, text="Informações sobre o Software", font=customtkinter.CTkFont(size=13, weight="bold"))
        self.label_description.grid(row=0, column=0, padx=(10,0), pady=(10,0), sticky="nsew")
        self.text = customtkinter.CTkLabel(self.description, text="Texto aqui")
        self.text.grid(row=1, column=0, padx=(10,0), pady=(10,0), sticky="nsew")
        
        # tabview
        self.tabview = customtkinter.CTkTabview(self, width=140)
        self.tabview.grid(row=1, column=1, columnspan=1, padx=(20, 0), pady=(20, 0), sticky="nsew")
        self.tabview.add("Monoestático")
        self.tabview.add("Biestático")
        self.tabview.tab("Monoestático").grid_columnconfigure((0,1,2), weight=0)
        self.tabview.tab("Biestático").grid_columnconfigure((0,1,2), weight=0)

        # monostatic input values
        self.monotext = customtkinter.CTkLabel(self.tabview.tab("Monoestático"), text="Insira os dados para o cálculo monoestático da RCS estimada")
        self.monotext.grid(row=0, column=0, columnspan=3, padx=5, pady=(5,5), sticky="ew")
        self.monoinput = customtkinter.CTkButton(self.tabview.tab("Monoestático"), text="⬆\nUpload Modelo .STL", command=askopenfile, fg_color=ThemeManager.theme['CTkEntry']['fg_color'], text_color=ThemeManager.theme['CTkEntry']['placeholder_text_color'])
        self.monoinput.grid(row=3, column=0, rowspan=2, padx=5, pady=(5, 5),sticky="ns")
        self.monofreq = customtkinter.CTkEntry(self.tabview.tab("Monoestático"), placeholder_text="Frequência (Hz)")
        self.monofreq.grid(row=1, column=0, padx=5, pady=(5, 5))
        self.monodist = customtkinter.CTkEntry(self.tabview.tab("Monoestático"), placeholder_text="Distância (m)")
        self.monodist.grid(row=1, column=1, padx=5, pady=(5, 5))
        self.monostdev = customtkinter.CTkEntry(self.tabview.tab("Monoestático"), placeholder_text="Desvio Padrão (m)")
        self.monostdev.grid(row=1, column=2, padx=5, pady=(5, 5))
        self.monopol = customtkinter.CTkOptionMenu(self.tabview.tab("Monoestático"), values=["TM-Z","TE-Z"], fg_color=ThemeManager.theme['CTkEntry']['fg_color'], text_color=ThemeManager.theme['CTkEntry']['placeholder_text_color'])
        self.monopol.grid(row=2, column=0, padx=5, pady=(5,5))
        self.monopol.set("Polarização")
        self.monostartphi = customtkinter.CTkEntry(self.tabview.tab("Monoestático"), placeholder_text="Phi Inicial (º)")
        self.monostartphi.grid(row=2, column=1, padx=5, pady=(5, 5))
        self.monoendphi = customtkinter.CTkEntry(self.tabview.tab("Monoestático"), placeholder_text="Phi Final (º)")
        self.monoendphi.grid(row=3, column=1, padx=5, pady=(5, 5))
        self.monoincphi = customtkinter.CTkEntry(self.tabview.tab("Monoestático"), placeholder_text="Passo Phi (º)")
        self.monoincphi.grid(row=4, column=1, padx=5, pady=(5, 5))
        self.monostarttheta = customtkinter.CTkEntry(self.tabview.tab("Monoestático"), placeholder_text="Theta Inicial (º)")
        self.monostarttheta.grid(row=2, column=2, padx=5, pady=(5, 5))
        self.monoendtheta = customtkinter.CTkEntry(self.tabview.tab("Monoestático"), placeholder_text="Theta Final (º)")
        self.monoendtheta.grid(row=3, column=2, padx=5, pady=(5, 5))
        self.monoinctheta = customtkinter.CTkEntry(self.tabview.tab("Monoestático"), placeholder_text="Passo Phi (º)")
        self.monoinctheta.grid(row=4, column=2, padx=5, pady=(5, 5))
        self.monoresult = customtkinter.CTkButton(self.tabview.tab("Monoestático"), text="Gerar Resultados", command=self.generate_results)
        self.monoresult.grid(row=5, column=1, padx=5, pady=(75, 5), sticky="nsew")

        # bistatic input values
        self.bitext = customtkinter.CTkLabel(self.tabview.tab("Biestático"), text="Insira os dados para o cálculo biestático da RCS estimada")
        self.bitext.grid(row=0, column=0, columnspan=3, padx=5, pady=(5,5), sticky="ew")
        self.biinput = customtkinter.CTkButton(self.tabview.tab("Biestático"), text="⬆\nUpload Modelo .STL", command=askopenfile, fg_color=ThemeManager.theme['CTkEntry']['fg_color'], text_color=ThemeManager.theme['CTkEntry']['placeholder_text_color'])
        self.biinput.grid(row=3, column=0, rowspan=2, padx=5, pady=(5, 5),sticky="ns")
        self.bifreq = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Frequência (Hz)")
        self.bifreq.grid(row=1, column=0, padx=5, pady=(5, 5))
        self.bidist = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Distância (m)")
        self.bidist.grid(row=1, column=1, padx=5, pady=(5, 5))
        self.bistdev = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Desvio Padrão (m)")
        self.bistdev.grid(row=1, column=2, padx=5, pady=(5, 5))
        self.bipol = customtkinter.CTkOptionMenu(self.tabview.tab("Biestático"), dynamic_resizing=False, values=["TM-Z","TE-Z"], fg_color=ThemeManager.theme['CTkEntry']['fg_color'], text_color=ThemeManager.theme['CTkEntry']['placeholder_text_color'])
        self.bipol.grid(row=2, column=0, padx=5, pady=(5,5))
        self.bipol.set("Polarização")
        self.biphi = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Phi Incidente (º)")
        self.biphi.grid(row=2, column=1, padx=5, pady=(5, 5))
        self.bitheta = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Theta Incidente (º)")
        self.bitheta.grid(row=2, column=2, padx=5, pady=(5, 5))
        self.bistartphi = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Phi Inicial (º)")
        self.bistartphi.grid(row=3, column=1, padx=5, pady=(5, 5))
        self.biendphi = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Phi Final (º)")
        self.biendphi.grid(row=4, column=1, padx=5, pady=(5, 5))
        self.biincphi = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Passo Phi (º)")
        self.biincphi.grid(row=5, column=1, padx=5, pady=(5, 5))
        self.bistarttheta = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Theta Inicial (º)")
        self.bistarttheta.grid(row=3, column=2, padx=5, pady=(5, 5))
        self.biendtheta = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Theta Final (º)")
        self.biendtheta.grid(row=4, column=2, padx=5, pady=(5, 5))
        self.biinctheta = customtkinter.CTkEntry(self.tabview.tab("Biestático"), placeholder_text="Passo Phi (º)")
        self.biinctheta.grid(row=5, column=2, padx=5, pady=(5, 5))
        self.biresult = customtkinter.CTkButton(self.tabview.tab("Biestático"), text="Gerar Resultados")
        self.biresult.grid(row=6, column=1, padx=5, pady=(40, 5), sticky="nsew")
        
        # results frame
        self.results_frame = customtkinter.CTkFrame(self, width=250)
        self.results_frame.grid(row=0, column=2, rowspan=2, columnspan=2, padx=(20, 20), pady=(20, 0), sticky="nsew")
        self.label_results = customtkinter.CTkLabel(self.results_frame, text="Resultados", font=customtkinter.CTkFont(size=13, weight="bold"))
        self.label_results.grid(row=0, column=0, columnspan=3, padx=10, pady=10, sticky="nsw")
        adjustp="files/empty.png"
        adjust= customtkinter.CTkImage(dark_image=Image.open(adjustp), size=(400,300))
        self.adjust = customtkinter.CTkLabel(self.results_frame, image=adjust, text="")
        self.adjust.grid(row=1, column=0, columnspan=3, padx=(30,30), pady=(10,10))
    
    def generate_results(self):
        plotpath ="files/RCSSimulator_Monostatic__20230721120855.png"
        plot= customtkinter.CTkImage(dark_image=Image.open(plotpath), size=(400,300))
        self.plot = customtkinter.CTkLabel(self.results_frame, image=plot, text="")
        self.plot.grid(row=1, column=0, columnspan=3, padx=(30,30), pady=(10,10))
        
        self.saveplot = customtkinter.CTkButton(self.results_frame, text="⬇ Download Gráfico")
        self.saveplot.grid(row=2, column=1, padx=5, pady=(15, 5), sticky="nsew")
        self.savefile = customtkinter.CTkButton(self.results_frame, text="⬇ Download Arquivo de Dados")
        self.savefile.grid(row=3, column=1, padx=5, pady=(5, 5), sticky="nsew")
        self.reset = customtkinter.CTkButton(self.results_frame, text="Reset", command=self.reset_command, fg_color=ThemeManager.theme['CTkEntry']['fg_color'], text_color=ThemeManager.theme['CTkEntry']['placeholder_text_color'])
        self.reset.grid(row=4, column=1, padx=5, pady=(15, 5), sticky="nsew")    
    
    def reset_command(self):    
        self.plot.destroy()
        self.saveplot.destroy()
        self.savefile.destroy()
        self.reset.destroy()
        
    def change_appearance_mode_event(self, new_appearance_mode: str):
        customtkinter.set_appearance_mode(new_appearance_mode)
        
if __name__ == "__main__":
    app = App()
    app.mainloop()