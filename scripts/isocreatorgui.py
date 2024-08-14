import os
import tkinter as tk
from tkinter import filedialog, messagebox, scrolledtext, ttk
import subprocess
import shutil  # For checking if ddrescue is installed

def select_output_path():
    """Open a file dialog for selecting the output path and update the entry widget."""
    iso_path = filedialog.asksaveasfilename(defaultextension=".iso", filetypes=[("ISO files", "*.iso")])
    if iso_path:
        output_path_var.set(iso_path)

def check_ddrescue_installed():
    """Check if ddrescue is installed on the system."""
    return shutil.which("ddrescue") is not None

def detect_dvd_devices():
    """Automatically detect available DVD drives and populate the dropdown."""
    dvd_devices = []
    # Check common device paths
    for device in ["/dev/sr0", "/dev/sr1", "/dev/cdrom", "/dev/dvd"]:
        if os.path.exists(device):
            dvd_devices.append(device)
    return dvd_devices or ["No DVD device found"]

def create_iso():
    """Create an ISO image using the selected method (dd or ddrescue)."""
    iso_path = output_path_var.get()
    if not iso_path:
        messagebox.showerror("Error", "Please specify an output path.")
        return

    dvd_device = dvd_device_var.get()
    if dvd_device == "No DVD device found":
        messagebox.showerror("Error", "No DVD device detected. Please check your hardware.")
        return

    method = method_var.get()

    # Check if ddrescue is selected and available
    if method == "ddrescue" and not check_ddrescue_installed():
        messagebox.showerror("Error", "ddrescue is not installed on this system. Please install it and try again.")
        return

    # Prepare the appropriate command
    if method == "dd":
        command = f"dd if={dvd_device} of={iso_path} bs=1M status=progress"
    elif method == "ddrescue":
        command = f"ddrescue {dvd_device} {iso_path} {iso_path}.log"

    try:
        # Run the command and capture the output
        process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)

        for line in process.stdout:
            log_text.insert(tk.END, line)
            log_text.see(tk.END)
            app.update_idletasks()

        process.wait()

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

# Initialize the main application window
app = tk.Tk()
app.title("ISO Image Creator")

# Set up the main frame of the GUI
frame = tk.Frame(app)
frame.pack(pady=10, padx=10)

# Add a label to guide the user
label = tk.Label(frame, text="Click the button below to create an ISO image from the CD/DVD.")
label.pack(pady=10)

# Dropdown to select DVD device
dvd_device_var = tk.StringVar(value="No DVD device found")
dvd_devices = detect_dvd_devices()
dvd_device_label = tk.Label(frame, text="Select DVD Device:")
dvd_device_label.pack(anchor=tk.W)

dvd_device_combobox = ttk.Combobox(frame, textvariable=dvd_device_var, values=dvd_devices)
dvd_device_combobox.pack(anchor=tk.W)
dvd_device_combobox.current(0)  # Set the default selection

# Add a dropdown (combobox) for selecting the method (dd or ddrescue)
method_var = tk.StringVar(value="ddrescue")  # Default to 'ddrescue'
method_label = tk.Label(frame, text="Select Method:")
method_label.pack(anchor=tk.W)

method_combobox = ttk.Combobox(frame, textvariable=method_var, values=["dd", "ddrescue"])
method_combobox.pack(anchor=tk.W)

# Add a label and entry for showing the current output path
output_path_var = tk.StringVar(value=os.path.expanduser("~/ddrescue.iso"))
output_path_label = tk.Label(frame, text="Output Path:")
output_path_label.pack(anchor=tk.W)

output_path_entry = tk.Entry(frame, textvariable=output_path_var, width=50)
output_path_entry.pack(anchor=tk.W)

# Add a button to allow the user to select a different output path
select_output_button = tk.Button(frame, text="Select Output Path", command=select_output_path)
select_output_button.pack(anchor=tk.W, pady=5)

# Add a button that triggers the ISO creation process
create_iso_button = tk.Button(frame, text="Create ISO", command=create_iso)
create_iso_button.pack(pady=10)

# Add a scrolled text widget to display the log output
log_frame = tk.Frame(app)
log_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

log_text = scrolledtext.ScrolledText(log_frame, wrap=tk.WORD, height=10)
log_text.pack(fill=tk.BOTH, expand=True)

# Start the Tkinter main loop to run the application
app.mainloop()
