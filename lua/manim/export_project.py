import os
from concurrent.futures import ThreadPoolExecutor, as_completed
import subprocess

# ---------- Read all configs from env ----------
RESOLUTION = (
    int(os.getenv("RESOLUTION_X", 3840)),
    int(os.getenv("RESOLUTION_Y", 2160)),
)
FPS = int(os.getenv("FPS", 60))
TRANSPARENT = bool(int(os.getenv("TRANSPARENT", 1)))
EXPORT_DIR = os.getenv("EXPORT_DIR", "./outputs")
MAX_WORKERS = int(os.getenv("MAX_WORKERS", 1))
IGNORE_FILES = set(os.getenv("IGNORE_FILES", "").split(",")) if os.getenv("IGNORE_FILES") else set()
FAILED_LIST_FILE = os.getenv("FAILED_LIST_FILE", "failed_files.txt")
MANIM_CMD = os.getenv("MANIM_CMD", "manim")

os.makedirs(EXPORT_DIR, exist_ok=True)

# ---------- Example rendering function ----------
def render_file(py_file, folder="."):
    file_path = os.path.join(folder, py_file)
    cmd = [
        MANIM_CMD,
        "render",
        file_path,
        "-a",
        f"--resolution={RESOLUTION[0]},{RESOLUTION[1]}",
        f"--fps={FPS}",
        f"--media_dir={EXPORT_DIR}",
    ]
    if TRANSPARENT:
        cmd += ["--transparent"]

    cmd_str = " ".join(cmd)
    print(f"[START] Rendering {py_file} → {EXPORT_DIR}")
    try:
        subprocess.run(cmd_str, shell=True, check=True)
        print(f"[DONE] {py_file}")
        return (py_file, None)
    except subprocess.CalledProcessError as e:
        return (py_file, str(e))

# ---------- Main export loop ----------
def export_all_scenes(folder="."):
    py_files = [
        f for f in os.listdir(folder)
        if f.endswith(".py") and f not in IGNORE_FILES
    ]

    failed = []

    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        futures = {executor.submit(render_file, f, folder): f for f in py_files}
        for future in as_completed(futures):
            py_file, error = future.result()
            if error:
                print(f"❌ Failed {py_file}: {error}")
                failed.append(py_file)
            else:
                print(f"✅ Finished {py_file}")

    # Write failed filenames
    with open(os.path.join(EXPORT_DIR, FAILED_LIST_FILE), "w") as f:
        for fn in failed:
            f.write(f"{fn}\n")

    if failed:
        print("\n--- Render Summary: FAILED FILES ---")
        for fn in failed:
            print(fn)
    else:
        print("\nAll files rendered successfully!")

if __name__ == "__main__":
    export_all_scenes()
