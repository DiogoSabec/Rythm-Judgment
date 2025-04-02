# Rythm Judgement - MIDI Encoder to Godot

This guide will show you how to create MIDI music and convert it so that the player’s attacks are timed perfectly with the music.

## Introduction

### MIDI File

First off, get any MIDI file. For this guide, we will use the [Bloody Tears](RythmJudgement/Audio/Musica/Bloody_Tears_DoS.mid) MIDI file.

If you want to use another MIDI, please ensure it has the following structure:  
![alt text](/docs/img/MIDI%201.png)

The full music of the level must have all instruments on separated layers. Each instrument will trigger an attack only when its note (highlighted in blue) plays. So, make sure that the layers are balanced, or else the character might attack 1000 times in 5 seconds.

### Installs

You will need FluidSynth, SDL, ffmpeg, and certain Python packages for this setup.

---

#### Python Dependencies

Install the required Python packages using pip:
```bash
pip install pretty_midi midi2audio
```
*Note:* The code now uses ffmpeg directly via the subprocess module, so there is no dependency on pydub.

---

#### FluidSynth

1. Go to [FluidSynth Releases](https://github.com/FluidSynth/fluidsynth/releases) and download the latest version.
2. Extract the folders to `C:\Program Files\` and rename the extracted folder to **FluidSynth**.
3. The structure should be something like this: 
    - `C:\Program Files\FluidSynth`
        - `bin`
        - `include`
        - `lib`
4. Press **Windows + S** and search for "environment variables".
5. In "Edit the system environment variables", click on **Environment Variables**.
6. Under **User variables**, find `PATH` and click **Edit**. Then click **New** and paste the location of the `bin` folder (e.g., `C:\Program Files\FluidSynth\bin`).
7. Save all settings.

---

#### SDL

1. Go to [SDL Releases](https://github.com/libsdl-org/SDL/releases) and download the latest zip.
2. Open the zip file.
3. Copy the `SDL3.dll` from the zip.
4. Paste the `SDL3.dll` into the `bin` folder located at `C:\Program Files\FluidSynth\bin`.

---

#### SoundFont File

Your script requires a SoundFont file (e.g., `FluidR3_GM.sf2`) for FluidSynth to generate audio. You can obtain a SoundFont file from sources such as:
- [FluidR3_GM.sf2 from Musical Artifacts](https://musical-artifacts.com/)
- Other free SoundFont libraries available online.

Once you have the SoundFont file, update the `SOUND_FONT_PATH` variable in your script to point to its location:
```python
SOUND_FONT_PATH = "C:\\path\\to\\your\\FluidR3_GM.sf2"  # Update this to your SoundFont file path
```

---

#### FFmpeg

Since pydub is no longer used, ffmpeg will be called directly via Python’s subprocess module.

1. Download ffmpeg from [ffmpeg.org](https://ffmpeg.org/download.html) (or use a build like [gyan.dev](https://www.gyan.dev/ffmpeg/builds/)).
2. Extract ffmpeg and locate the `ffmpeg.exe` file.
3. It is recommended to use the absolute path to `ffmpeg.exe` in your script. For example:
   ```python
   ffmpeg_path = r"C:\path\to\ffmpeg.exe"  # Update this path to your ffmpeg.exe location
   command = [ffmpeg_path, "-y", "-i", wav_temp_path, mp3_out_path]
   ```
4. Alternatively, you can add the folder containing `ffmpeg.exe` to your system’s PATH environment variable so that it can be called directly.

---

## How It Works

- **MIDI Processing:**  
  The script extracts each instrument from the full MIDI file, saving them as individual MIDI files. It also records note start times in JSON files.
  
- **MIDI to Audio Conversion:**  
  FluidSynth (via the midi2audio package) uses the provided SoundFont to convert each MIDI file to a temporary WAV file.
  
- **Audio Conversion with ffmpeg:**  
  The script then uses ffmpeg (called via Python’s subprocess with an absolute path) to convert the temporary WAV file into an MP3 file.
  
- **Folder Structure:**  
  The output is organized into separate folders for MIDI files, JSON files, and MP3 files.

# Sync with the engine
For this, we will need the code to be re-written. Will be done in the next week.