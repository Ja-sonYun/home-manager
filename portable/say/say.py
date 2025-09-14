import argparse
import os
import subprocess
import sys
import tempfile
from shutil import which

import numpy as np
import sounddevice as sd
import soundfile as sf
import warnings
import torch
from kokoro import KPipeline

SUPPORTED_VOICES = {
    # en-us, female
    "af_alloy",
    "af_aoede",
    "af_bella",
    "af_heart",
    "af_jessica",
    "af_kore",
    "af_nicole",
    "af_nova",
    "af_river",
    "af_sarah",
    "af_sky",
    # en-us, male
    "am_adam",
    "am_echo",
    "am_eric",
    "am_fenrir",
    "am_liam",
    "am_michael",
    "am_onyx",
    "am_puck",
    # en-gb
    "bf_alice",
    "bf_emma",
    "bf_isabella",
    "bf_lily",
    "bm_daniel",
    "bm_fable",
    "bm_george",
    "bm_lewis",
    # fr-fr
    "ff_siwis",
    # it
    "if_sara",
    "im_nicola",
    # ja
    "jf_alpha",
    "jf_gongitsune",
    "jf_nezumi",
    "jf_tebukuro",
    "jm_kumo",
    # cmn
    "zf_xiaobei",
    "zf_xiaoni",
    "zf_xiaoxiao",
    "zf_xiaoyi",
    "zm_yunjian",
    "zm_yunxi",
    "zm_yunxia",
    "zm_yunyang",
}

PREFIX_TO_LANG = {
    "af": "a",
    "am": "a",
    "bf": "b",
    "bm": "b",
    "ff": "f",
    "if": "i",
    "im": "i",
    "jf": "j",
    "jm": "j",
    "zf": "z",
    "zm": "z",
}

SR = 24000


def detect_lang_code(voice: str) -> str:
    if voice not in SUPPORTED_VOICES:
        raise ValueError(f"Unsupported voice: {voice}")
    prefix = voice.split("_", 1)[0]
    lc = PREFIX_TO_LANG.get(prefix)
    if not lc:
        raise ValueError(f"Cannot infer lang_code for voice: {voice}")
    return lc


def print_voice_list() -> None:
    groups = {
        "af": "English (US) – female",
        "am": "English (US) – male",
        "bf": "English (UK) – female",
        "bm": "English (UK) – male",
        "ff": "French (FR)",
        "if": "Italian – female",
        "im": "Italian – male",
        "jf": "Japanese – female",
        "jm": "Japanese – male",
        "zf": "Chinese (Mandarin) – female",
        "zm": "Chinese (Mandarin) – male",
    }
    order = [
        "af",
        "am",
        "bf",
        "bm",
        "ff",
        "if",
        "im",
        "jf",
        "jm",
        "zf",
        "zm",
    ]
    bucket = {k: [] for k in groups}
    for v in sorted(SUPPORTED_VOICES):
        p = v.split("_", 1)[0]
        if p in bucket:
            bucket[p].append(v)
    print("Available voices:")
    for k in order:
        if bucket.get(k):
            print(f"- {groups[k]}:")
            line = ", ".join(bucket[k])
            print(f"  {line}")


def build_pipeline(voice: str) -> KPipeline:
    lang_code = detect_lang_code(voice)
    return KPipeline(lang_code=lang_code, repo_id="hexgrad/Kokoro-82M")


def tts_joined_audio(pipeline: KPipeline, text: str, voice: str) -> np.ndarray:
    segs = []
    with torch.inference_mode():
        gen = pipeline(text, voice=voice, speed=1, split_pattern=r"\n+")
        for _, _, audio in gen:
            segs.append(audio)
    if not segs:
        return np.zeros((0,), dtype=np.float32)
    return np.concatenate(segs, axis=0)


def play_audio_pcm(wave: np.ndarray, sr: int = SR) -> None:
    try:
        sd.play(wave, sr)
        sd.wait()
        return
    except Exception:
        pass
    if which("afplay"):
        with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
            sf.write(tmp.name, wave, sr)
            tmp.flush()
            try:
                subprocess.run(["afplay", tmp.name], check=False)
            finally:
                try:
                    os.unlink(tmp.name)
                except OSError:
                    pass
        return
    raise RuntimeError(
        "No playback available. Install 'sounddevice' or use -o to write a file."
    )


def read_text_from_stdin_if_any() -> str:
    if not sys.stdin.isatty():
        return sys.stdin.read()
    return ""


def main():
    warnings.filterwarnings(
        "ignore",
        category=UserWarning,
        module=r"torch\.nn\.modules\.rnn",
    )
    warnings.filterwarnings(
        "ignore",
        category=FutureWarning,
        module=r"torch\.nn\.utils\.weight_norm",
    )
    parser = argparse.ArgumentParser(
        description="CLI TTS for kokoro. Positional text supported."
    )
    parser.add_argument("-f", "--file", type=str, help="Input text file (UTF-8).")
    parser.add_argument(
        "-v",
        "--voice",
        type=str,
        default="am_michael",
        help="Voice id. Use --list-voices to see all.",
    )
    parser.add_argument(
        "--list-voices",
        action="store_true",
        help="List available voices and exit.",
    )
    parser.add_argument(
        "-o", "--output", type=str, help="Output WAV path. If omitted, play to device."
    )
    parser.add_argument(
        "-i", "--interactive", action="store_true", help="Interactive mode."
    )
    parser.add_argument("text", nargs="*", help="Text to speak.")
    # If no CLI args and interactive TTY stdin, show help.
    if len(sys.argv) == 1 and sys.stdin.isatty():
        parser.print_help()
        return

    args = parser.parse_args()

    if args.list_voices:
        print_voice_list()
        return

    # Resolve input text priority: positional > -f > stdin
    text = " ".join(args.text).strip()

    try:
        pipeline = build_pipeline(args.voice)
    except Exception as e:
        print(f"error: {e}", file=sys.stderr)
        sys.exit(2)

    if args.interactive and not text:
        if args.output:
            buf = []
            try:
                while True:
                    line = input("> ")
                    if not line.strip():
                        continue
                    wave = tts_joined_audio(pipeline, line, args.voice)
                    buf.append(wave)
            except (EOFError, KeyboardInterrupt):
                pass
            if buf:
                wave = np.concatenate(buf, axis=0)
                sf.write(args.output, wave, SR)
            return
        try:
            while True:
                line = input("> ")
                if not line.strip():
                    continue
                wave = tts_joined_audio(pipeline, line, args.voice)
                play_audio_pcm(wave, SR)
        except (EOFError, KeyboardInterrupt):
            return

    if not text:
        if args.file:
            try:
                with open(args.file, "r", encoding="utf-8") as f:
                    text = f.read()
            except Exception as e:
                print(f"error: cannot read file: {e}", file=sys.stderr)
                sys.exit(2)
        else:
            text = read_text_from_stdin_if_any()
            if not text.strip():
                print(
                    "error: provide text, -f, -i, or pipe text via stdin.",
                    file=sys.stderr,
                )
                sys.exit(2)

    wave = tts_joined_audio(pipeline, text, args.voice)

    if args.output:
        sf.write(args.output, wave, SR)
    else:
        play_audio_pcm(wave, SR)


if __name__ == "__main__":
    main()
