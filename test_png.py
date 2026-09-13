import os, struct, zlib

def scan_png(path):
    with open(path, 'rb') as f:
        sig = f.read(8)
        if sig != b'\x89PNG\r\n\x1a\n': return False
        while True:
            length_bytes = f.read(4)
            if not length_bytes: break
            length = struct.unpack('>I', length_bytes)[0]
            chunk_type = f.read(4)
            if chunk_type in (b'tEXt', b'zTXt', b'iTXt'):
                data = f.read(length)
                if chunk_type == b'tEXt':
                    text = data.decode('latin1', errors='ignore')
                    if 'heels' in text.lower(): return True
                elif chunk_type == b'zTXt':
                    null_idx = data.find(b'\0')
                    if null_idx != -1:
                        try:
                            text = zlib.decompress(data[null_idx+2:]).decode('latin1', errors='ignore')
                            if 'heels' in text.lower(): return True
                        except: pass
                elif chunk_type == b'iTXt':
                    null_idx = data.find(b'\0')
                    if null_idx != -1 and data[null_idx+1] == 1:
                        try:
                            text = zlib.decompress(data[null_idx+3:]).decode('latin1', errors='ignore')
                            if 'heels' in text.lower(): return True
                        except: pass
                    else:
                        text = data.decode('latin1', errors='ignore')
                        if 'heels' in text.lower(): return True
            else:
                f.seek(length, 1)
            f.seek(4, 1)
    return False

dir_path = '/Volumes/ai/ComfyUI/output'
found = []
for root, dirs, files in os.walk(dir_path):
    for f in files:
        if f.lower().endswith('.png'):
            if scan_png(os.path.join(root, f)):
                found.append(os.path.join(root, f))
                if len(found) >= 3: break
    if len(found) >= 3: break
print("Found in:", found)
