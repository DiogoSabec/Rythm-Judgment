import os
import pretty_midi
import json
import tkinter as tk
from tkinter import filedialog
from midi2audio import FluidSynth
import subprocess

def select_midi_file():
    root = tk.Tk()
    root.withdraw()
    midi_path = filedialog.askopenfilename(
        title="Select a MIDI file",
        filetypes=[("MIDI Files", "*.mid *.midi")]
    )
    return midi_path

def process_midi(input_midi_path, sound_font_path):
    if not os.path.exists(input_midi_path):
        print("❌ MIDI file not found.")
        return

    # Prepare folder structure
    midi_name = os.path.splitext(os.path.basename(input_midi_path))[0]
    base_folder = os.path.join("RythmJudgement", "Audio", "Music", midi_name)
    midi_folder = os.path.join(base_folder, "instrumentos_midi")
    json_folder = os.path.join(base_folder, "instrumentos_json")
    mp3_folder = os.path.join(base_folder, "instrumentos_mp3")

    os.makedirs(midi_folder, exist_ok=True)
    os.makedirs(json_folder, exist_ok=True)
    os.makedirs(mp3_folder, exist_ok=True)

    # Load the MIDI file
    midi_data = pretty_midi.PrettyMIDI(input_midi_path)

    # Initialize FluidSynth with the given SoundFont
    fs = FluidSynth(sound_font=sound_font_path)

    # Process each instrument in the MIDI file
    for idx, instrument in enumerate(midi_data.instruments):
        instrument_name = instrument.name.strip().replace(" ", "_") or f"Instrument_{idx}"

        midi_out_path = os.path.join(midi_folder, f"{instrument_name}.mid")
        json_out_path = os.path.join(json_folder, f"{instrument_name}.json")
        mp3_out_path = os.path.join(mp3_folder, f"{instrument_name}.mp3")

        # Save the instrument as a separate MIDI file
        single = pretty_midi.PrettyMIDI()
        single.instruments.append(instrument)
        single.write(midi_out_path)

        # Extract note start times and save to JSON
        note_times = sorted(set(note.start for note in instrument.notes))
        with open(json_out_path, "w") as f:
            json.dump(note_times, f)

        # Convert MIDI to WAV using FluidSynth
        wav_temp_path = midi_out_path.replace(".mid", ".wav")
        fs.midi_to_audio(midi_out_path, wav_temp_path)
        
        # Convert WAV to MP3 using ffmpeg via subprocess
        ffmpeg_path = r"C:\Program Files\ffmpeg\bin\ffmpeg.exe"  # Update this to your ffmpeg location
        command = [ffmpeg_path, "-y", "-i", wav_temp_path, mp3_out_path]
        subprocess.run(command, check=True)
        try:
            subprocess.run(command, check=True)
            print(f"✅ Processed: {instrument_name}")
        except subprocess.CalledProcessError as e:
            print(f"❌ Failed to convert {wav_temp_path} to MP3: {e}")
        
        # Clean up the temporary WAV file
        os.remove(wav_temp_path)

    print(f"\n🎉 Done! All files are saved under:\n{base_folder}")

if __name__ == "__main__":
    print("🎵 MIDI Encoder for RythmJudgement 🎵\n")
    midi_file = select_midi_file()
    if midi_file:
        # Update the path below to point to your SoundFont file
        SOUND_FONT_PATH = "FluidR3_GM.sf2"
        if not os.path.exists(SOUND_FONT_PATH):
            print(f"❌ SoundFont file not found at {SOUND_FONT_PATH}. Please update the path to your SoundFont file.")
        else:
            process_midi(midi_file, SOUND_FONT_PATH)
    else:
        print("❌ No MIDI file selected.")
