import os
from tkinter import Tk, Label, Button, Entry, StringVar, filedialog, messagebox, Frame
from tkinter.ttk import Progressbar, Style
from pytube import YouTube
import ffmpeg
import librosa
import threading

# Función para calcular los BPM de un archivo MP3
def calcular_bpm(ruta_archivo):
    resultado_label.config(text="Cargando y analizando...")
    progress_bar.grid(row=3, column=0, pady=20)
    progress_bar.start(interval=10)
    
    def proceso_bpm():
        try:
            y, sr = librosa.load(ruta_archivo)
            tempo, _ = librosa.beat.beat_track(y=y, sr=sr)
            resultado.set(f"El BPM de la canción es: {tempo}")
            resultado_label.config(fg='#19EB55')
        except Exception as e:
            messagebox.showerror("Error", f"Ocurrió un error al calcular el BPM:\n{str(e)}")
        finally:
            progress_bar.stop()
            progress_bar.grid_remove()
    
    thread = threading.Thread(target=proceso_bpm)
    thread.start()

# Función para descargar y convertir el video a MP3 y luego calcular su BPM
def descargar_y_convertir():
    url = url_entry.get()
    if url:
        try:
            yt = YouTube(url)
            destino = filedialog.asksaveasfilename(defaultextension=".mp3",
                                                   filetypes=[("Archivos MP3", "*.mp3"), ("Todos los archivos", "*.*")])
            if destino:
                resultado_label.config(text="Descargando y convirtiendo...")
                progress_bar.grid(row=3, column=0, pady=20)
                progress_bar.start(interval=10)
                
                def proceso_descarga():
                    try:
                        # Descargar solo el audio usando pytube
                        audio_stream = yt.streams.filter(only_audio=True).first()
                        audio_stream.download(filename=os.path.join(os.getcwd(), 'temp_audio.mp4'))

                        # Convertir el audio descargado a MP3 usando ffmpeg-python
                        input_file = os.path.join(os.getcwd(), 'temp_audio.mp4')
                        output_file = destino
                        ffmpeg.input(input_file).output(output_file).run()

                        # Eliminar archivo temporal
                        os.remove(input_file)

                        # Calcular BPM del archivo descargado
                        calcular_bpm(output_file)

                        # Mostrar mensaje de éxito
                        messagebox.showinfo("Éxito", "Descarga y conversión completadas.")
                    except Exception as e:
                        messagebox.showerror("Error", f"Ocurrió un error:\n{str(e)}")
                        print("Error:", f"\n{str(e)}")
                
                thread = threading.Thread(target=proceso_descarga)
                thread.start()
        except Exception as e:
            messagebox.showerror("Error", f"Ocurrió un error:\n{str(e)}")
    else:
        messagebox.showwarning("Advertencia", "Por favor ingresa una URL válida.")

# Función para seleccionar y calcular BPM de un archivo MP3
def seleccionar_archivo():
    ruta_archivo = filedialog.askopenfilename(
        title="Selecciona el archivo de audio",
        filetypes=[("Archivos MP3", "*.mp3"), ("Todos los archivos", "*.*")]
    )
    if ruta_archivo:
        calcular_bpm(ruta_archivo)

# Función para mostrar la ventana de descarga y conversión
def mostrar_descargar_convertir():
    limpiar_interfaz()
    
    url_label.grid(row=0, column=0, pady=10)
    url_entry.grid(row=1, column=0, padx=10, pady=10)
    descargar_button.grid(row=2, column=0, pady=10)
    volver_button.grid(row=3, column=0, pady=10)
    resultado_label.grid(row=4, column=0, pady=20)

# Función para mostrar la ventana de selección de archivo MP3
def mostrar_seleccionar_archivo():
    limpiar_interfaz()
    
    seleccionar_button.grid(row=0, column=0, pady=10)
    volver_button.grid(row=1, column=0, pady=10)
    resultado_label.grid(row=2, column=0, pady=20)

# Función para limpiar la interfaz
def limpiar_interfaz():
    for widget in frame.winfo_children():
        widget.grid_remove()
    progress_bar.grid_remove()

# Función para volver al menú principal
def volver_al_menu():
    limpiar_interfaz()
    menu_label.grid(row=0, column=0, pady=10)
    descargar_convertir_button.grid(row=1, column=0, pady=10)
    seleccionar_archivo_button.grid(row=2, column=0, pady=10)

# Configuración de la interfaz gráfica
root = Tk()
root.title("Descargador, Convertidor y Analizador de BPM")

# Obtener las dimensiones de la pantalla
window_width = 630
window_height = 300
screen_width = root.winfo_screenwidth()
screen_height = root.winfo_screenheight()

# Calcular la posición para centrar la ventana
x = (screen_width // 2) - (window_width // 2)
y = (screen_height // 2) - (window_height // 2)

# Establecer la geometría de la ventana
root.geometry(f"{window_width}x{window_height}+{x}+{y}")
root.configure(bg='#363a41')

# Crear el marco principal
frame = Frame(root, bg='#363a41')
frame.pack(expand=True)

# Variable para almacenar el resultado
resultado = StringVar()
resultado.set("El BPM de la canción aparecerá aquí")

# Crear y colocar los widgets para el menú principal
menu_label = Label(frame, text="Selecciona una opción:", font=("Bold 2", 16), bg='#363a41', fg='#19EB55')
menu_label.grid(row=0, column=0, pady=10)
descargar_convertir_button = Button(frame, text="Descargar y Convertir a MP3 y Calcular BPM", command=mostrar_descargar_convertir, bg='#389eff', fg='black', padx=10, pady=5, font=("Bold 2", 14))
descargar_convertir_button.grid(row=1, column=0, pady=10)
seleccionar_archivo_button = Button(frame, text="Calcular BPM de un archivo MP3", command=mostrar_seleccionar_archivo, bg='#389eff', fg='black', padx=10, pady=5, font=("Bold 2", 14))
seleccionar_archivo_button.grid(row=2, column=0, pady=10)

# Crear y colocar los widgets para la descarga y conversión
url_label = Label(frame, text="Ingresa la URL del video:", font=("Bold 2", 14), bg='#363a41', fg='#19EB55')
url_entry = Entry(frame, width=60, font=("Helvetica", 12))
descargar_button = Button(frame, text="Descargar y Convertir a MP3", command=descargar_y_convertir, bg='#389eff', fg='black', padx=10, pady=5, font=("Bold 2", 14))
volver_button = Button(frame, text="Volver al Menú", command=volver_al_menu, bg='#389eff', fg='black', padx=10, pady=5, font=("Bold 2", 14))

# Crear y colocar los widgets para la selección de archivo
seleccionar_button = Button(frame, text="Seleccionar archivo de audio", command=seleccionar_archivo, bg='#389eff', fg='black', padx=10, pady=5, font=("Bold 2", 14))

# Barra de progreso
style = Style()
style.configure("TProgressbar", thickness=10, troughcolor='#363a41', background='#2F83B1')

progress_bar = Progressbar(frame, style="TProgressbar", mode='indeterminate', length=300)

# Resultado del BPM
resultado_label = Label(frame, textvariable=resultado, bg='#363a41', fg='#19EB55', font=("Bold 2", 14))

# Mostrar el menú principal al iniciar
volver_al_menu()

# Iniciar el bucle de la interfaz
root.mainloop()
