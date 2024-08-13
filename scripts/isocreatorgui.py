import os
import tkinter as tk
from tkinter import filedialog, messagebox, scrolledtext
import subprocess

def create_iso():
    iso_path = filedialog.asksaveasfilename(defaultextension=".iso", filetypes=[("ISO files", "*.iso")])
    if not iso_path:
        return
    
    dvd_device = "/dev/sr0"  # Assuming /dev/sr0 is the DVD device
    
    # Command to create the ISO image
    command = f"dd if={dvd_device} of={iso_path} bs=1M status=progress"
    
    try:
        # Run the command and capture the output
        process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
        
        # Update the log window with real-time output
        for line in process.stdout:
            log_text.insert(tk.END, line)
            log_text.see(tk.END)
            app.update_idletasks()
        
        process.wait()  # Wait for the process to complete
        
        # Check if the command was successful
        if process.returncode == 0:
            messagebox.showinfo("Success", f"ISO image created successfully at {iso_path}")
        else:
            raise subprocess.CalledProcessError(process.returncode, command)
    
    except subprocess.CalledProcessError as e:
        log_text.insert(tk.END, f"Error: {e}\n")
        messagebox.showerror("Error", f"Failed to create ISO image. See log for details.")
    
    except Exception as e:
        log_text.insert(tk.END, f"Unexpected error: {e}\n")
        messagebox.showerror("Error", "An unexpected error occurred. See log for details.")

app = tk.Tk()
app.title("ISO Image Creator")

frame = tk.Frame(app)
frame.pack(pady=10, padx=10)

label = tk.Label(frame, text="Click the button below to create an ISO image from the DVD.")
label.pack(pady=10)

create_iso_button = tk.Button(frame, text="Create ISO", command=create_iso)
create_iso_button.pack()

# Log window to show output
log_frame = tk.Frame(app)
log_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

log_text = scrolledtext.ScrolledText(log_frame, wrap=tk.WORD, height=10)
log_text.pack(fill=tk.BOTH, expand=True)

app.mainloop()
