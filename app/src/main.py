

import subprocess
import sys
import os
import shutil
import json # For potential future use with --dump-json

# --- Configuration ---
# Try to find the yt-dlp executable.
# You might need to adjust this if yt-dlp is not in your PATH
# or if you installed it via pip in a virtual environment.
YT_DLP_EXECUTABLE = shutil.which("yt-dlp")

if not YT_DLP_EXECUTABLE:
    print("Error: 'yt-dlp' command not found in PATH.")
    print("Please ensure yt-dlp is installed and accessible.")
    # Common install commands:
    # pip install -U yt-dlp
    # brew install yt-dlp (macOS Homebrew)
    # sudo apt install yt-dlp (Debian/Ubuntu - check version, might be old)
    sys.exit(1)

# --- Core Function ---

def run_yt_dlp(urls, options=None, verbose=True):
    """
    Runs the yt-dlp command with the given URLs and options.

    Args:
        urls (list or str): A list of URLs or a single URL string to download/process.
        options (dict, optional): A dictionary where keys are yt-dlp option names
                                  (long form preferred, without leading '--')
                                  and values are the option arguments.
                                  For flags (options without arguments), use True as the value.
                                  Example: {'format': 'bestvideo+bestaudio/best', 'output': '~/Downloads/%(title)s.%(ext)s', 'ignore-errors': True}
                                  Defaults to None (no extra options).
        verbose (bool): If True, prints the command being executed and yt-dlp's output.

    Returns:
        subprocess.CompletedProcess: The result object from subprocess.run.
                                      Contains attributes like 'returncode', 'stdout', 'stderr'.
                                      Returns None if execution fails before calling subprocess.

    Raises:
        FileNotFoundError: If the YT_DLP_EXECUTABLE is not found.
        subprocess.CalledProcessError: If yt-dlp returns a non-zero exit code.
    """
    if not YT_DLP_EXECUTABLE:
        raise FileNotFoundError(f"yt-dlp executable not found.")

    if isinstance(urls, str):
        urls = [urls]
    if not isinstance(urls, list):
        raise TypeError("urls must be a string or a list of strings.")
    if not urls:
        print("Warning: No URLs provided.")
        return None

    command = [YT_DLP_EXECUTABLE]

    # --- Build command list from options dictionary ---
    if options:
        for key, value in options.items():
            option_key = f"--{key.replace('_', '-')}" # Convert pythonic_name to --cli-name

            if isinstance(value, bool):
                if value:
                    command.append(option_key)
                # Optional: Handle --no- prefixed options if needed
                # elif key.startswith("no_"): # e.g. options = {'no_playlist': True} -> --no-playlist
                #     command.append(f"--{key.replace('_', '-')}")
                # else: # If value is False, we often just omit the flag
                #     pass
            elif isinstance(value, list):
                # Handle options that can be specified multiple times
                for item in value:
                   command.append(option_key)
                   command.append(str(item)) # Ensure value is string
            else:
                # Handle options with arguments
                command.append(option_key)
                command.append(str(value)) # Ensure value is string

    # Add URLs at the end
    command.extend(urls)

    if verbose:
        # Print the command in a readable format (be careful with quoting if copying)
        print("--- Executing Command ---")
        print(" ".join(f'"{arg}"' if " " in arg else arg for arg in command))
        print("-------------------------")
        print("--- yt-dlp Output -----")

    try:
        # Run the command
        # Using capture_output=False to stream output directly to terminal
        # Use capture_output=True if you need to process stdout/stderr in Python
        result = subprocess.run(command, check=True, text=True, encoding='utf-8')
        if verbose:
            print("-------------------------")
            print("yt-dlp finished successfully.")
        return result
    except subprocess.CalledProcessError as e:
        print(f"--- yt-dlp Error (Exit Code: {e.returncode}) ---", file=sys.stderr)
        # stderr and stdout might be None if capture_output=False,
        # as output goes directly to terminal
        # print(f"Stderr:\n{e.stderr}", file=sys.stderr)
        # print(f"Stdout:\n{e.stdout}", file=sys.stderr)
        print("-------------------------", file=sys.stderr)
        # Re-raise the exception so the caller knows it failed
        raise e
    except Exception as e:
        print(f"An unexpected error occurred: {e}", file=sys.stderr)
        raise e


# --- Helper Functions for Common Tasks ---

def download_best(urls, output_path=None, extra_options=None):
    """Downloads the best available video+audio format."""
    options = {'format': 'bestvideo+bestaudio/best'}
    if output_path:
        # Use -P for path, -o for template within that path
        options['paths'] = os.path.dirname(output_path) or '.' # Use '.' if only filename given
        options['output'] = os.path.basename(output_path) or '%(title)s [%(id)s].%(ext)s'
    else:
         # Default yt-dlp naming if no path specified
         pass
    if extra_options:
        options.update(extra_options)
    return run_yt_dlp(urls, options)

def download_audio_only(urls, audio_format='mp3', audio_quality=5, output_path=None, extra_options=None):
    """Downloads and extracts audio."""
    options = {
        'extract-audio': True,
        'audio-format': audio_format,
        'audio-quality': audio_quality, # 0 (best) to 10 (worst), 5 is default VBR
        # Use 'best' format selection initially, let ffmpeg handle conversion
        'format': 'bestaudio/best',
        # Keep intermediate video file? Set 'keep-video': True if needed
        'keep-video': False,
    }
    if output_path:
        options['paths'] = os.path.dirname(output_path) or '.'
        # Ensure the extension matches the audio format if possible in the template
        base, _ = os.path.splitext(os.path.basename(output_path))
        options['output'] = f"{base or '%(title)s [%(id)s]'}.%(ext)s" # Let yt-dlp set final extension
    else:
        # Default naming, yt-dlp usually sets correct audio extension with -x
        pass

    if extra_options:
        options.update(extra_options)
    return run_yt_dlp(urls, options)

def list_formats(url):
    """Lists available formats for a given URL."""
    options = {'list-formats': True}
    # Use verbose=False often for just listing, but keep True to see command
    return run_yt_dlp(url, options, verbose=True)

def download_specific_format(urls, format_code, output_path=None, extra_options=None):
    """Downloads a specific format code (use list_formats first)."""
    options = {'format': format_code}
    if output_path:
        options['paths'] = os.path.dirname(output_path) or '.'
        options['output'] = os.path.basename(output_path) or '%(title)s [%(id)s].%(ext)s'
    else:
        pass
    if extra_options:
        options.update(extra_options)
    return run_yt_dlp(urls, options)

def update_yt_dlp():
    """Runs yt-dlp --update."""
    print("Attempting to update yt-dlp...")
    # No URLs needed, just the update option
    return run_yt_dlp([], options={'update': True})


# --- Example Usage ---

if __name__ == "__main__":
    # Make sure you replace these with actual URLs you want to test
    test_video_url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ" # Example video
    test_playlist_url = "https://www.youtube.com/playlist?list=PLMC9KNkIncKtPzgY-5rmhvj7fax8fdxoj" # Example playlist (yt-dlp test)

    # --- Choose which examples to run ---
    run_example = None # Set to 'list', 'best', 'audio', 'specific', 'custom', 'update', 'playlist_items'

    try:
        # Example 1: List formats
        if run_example == 'list':
            print("\n--- Example: Listing Formats ---")
            list_formats(test_video_url)

        # Example 2: Download best quality video + audio
        elif run_example == 'best':
            print("\n--- Example: Downloading Best Quality ---")
            # Saves to current directory with default name template
            # download_best(test_video_url)
            # Saves to a specific directory and filename template
            download_best(test_video_url, output_path="~/Downloads/MyVideo_%(title)s.%(ext)s")


        # Example 3: Download audio only as MP3
        elif run_example == 'audio':
            print("\n--- Example: Downloading Audio Only (MP3) ---")
            download_audio_only(
                test_video_url,
                audio_format='mp3',
                audio_quality=2, # Better quality VBR
                output_path="~/Downloads/MyAudio_%(title)s.%(ext)s"
            )
            # Example: Download best quality audio (opus or webm usually) without converting
            # print("\n--- Example: Downloading Best Audio (No Conversion) ---")
            # download_specific_format(test_video_url, format_code='bestaudio/best', output_path="~/Downloads/BestAudio_%(title)s.%(ext)s")


        # Example 4: Download a specific format (find code using 'list' example first)
        elif run_example == 'specific':
             print("\n--- Example: Downloading Specific Format (e.g., '22' for 720p MP4) ---")
             # Note: Format codes can change! Use list_formats to check.
             # Format '22' is often a 720p mp4 direct download.
             download_specific_format(test_video_url, format_code='22', output_path="~/Downloads/SpecificFormat_%(title)s_720p.%(ext)s")
             # Example downloading best 1080p video only (no audio) - requires merging later or separate audio download
             # print("\n--- Example: Downloading Specific Format (1080p video only) ---")
             # download_specific_format(test_video_url, format_code='bv[height<=1080]', output_path="~/Downloads/VideoOnly_%(title)s_1080p.%(ext)s")


        # Example 5: Using custom options dictionary
        elif run_example == 'custom':
            print("\n--- Example: Using Custom Options ---")
            custom_opts = {
                'output': '~/Downloads/Custom_%(uploader)s_%(title)s.%(ext)s',
                'format': 'bestvideo[height<=?720]+bestaudio/best[height<=?720]', # Max 720p
                'write-thumbnail': True,
                'write-info-json': True,
                'ignore-errors': True,       # Continue on errors in playlist
                'download-archive': 'mydownload_archive.txt', # Keep track of downloaded videos
                'limit-rate': '1M',          # Limit download speed to 1MB/s
                # 'cookies-from-browser': 'firefox', # Example: Use Firefox cookies
            }
            # You can download multiple URLs at once
            run_yt_dlp([test_video_url, "https://vimeo.com/563647289"], options=custom_opts) # Example Vimeo URL

        # Example 6: Update yt-dlp
        elif run_example == 'update':
            print("\n--- Example: Updating yt-dlp ---")
            update_yt_dlp()

        # Example 7: Download specific playlist items
        elif run_example == 'playlist_items':
            print("\n--- Example: Downloading Playlist Items 1, 3 through 5 ---")
            playlist_options = {
                'playlist-items': '1,3-5', # Download items 1, 3, 4, 5
                'output': '~/Downloads/PlaylistTest/%(playlist_index)s - %(title)s.%(ext)s',
                'format': 'bestvideo[height<=?720]+bestaudio/best[height<=?720]', # Max 720p
            }
            run_yt_dlp(test_playlist_url, options=playlist_options)

        else:
            print("No example selected. Edit the 'run_example' variable in the script.")
            print("Available examples: 'list', 'best', 'audio', 'specific', 'custom', 'update', 'playlist_items'")

    except FileNotFoundError as e:
        print(f"Error: {e}", file=sys.stderr)
        # Specific message already printed by YT_DLP_EXECUTABLE check
    except subprocess.CalledProcessError as e:
        print(f"\nError: yt-dlp exited with code {e.returncode}", file=sys.stderr)
        # Output was likely already printed to stderr by run_yt_dlp
    except Exception as e:
        print(f"\nAn unexpected Python error occurred: {e}", file=sys.stderr)

