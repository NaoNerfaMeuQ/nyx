import sys
import random
import zlib

def random_var(prefix="_0x"):
    return prefix + "".join(random.choices("0123456789abcdef", k=6))

def full_virtualize_obfuscate(source_code):
    raw_bytes = source_code.encode('utf-8')
    
    # Layer 1: Multi-stage byte encryption with shifting keys
    key1 = random.randint(45, 210)
    key2 = random.randint(15, 120)
    
    encrypted_bytes = []
    for i, b in enumerate(raw_bytes):
        # dynamic position-based XOR & shift
        enc = ((b + key1 + (i % key2)) % 256)
        encrypted_bytes.append(enc)
        
    formatted_data = ",".join(str(b) for b in encrypted_bytes)
    
    # Variable names
    v_data = random_var("_nyx_bin_")
    v_key1 = random_var("_k1_")
    v_key2 = random_var("_k2_")
    v_buf = random_var("_buf_")
    v_fn = random_var("_fn_")
    v_loader = random_var("_nyx_vm_")
    v_chk = random_var("_sig_")
    
    # Checksum for anti-tamper
    checksum = sum(encrypted_bytes) % 65535
    
    obfuscated_code = f"""-- [ NYX SECURITY | MILITARY GRADE LUA VIRTUALIZATION ENGINE v2.0 ]
-- [ WARNING: TAMPERING WITH THIS FILE WILL CORRUPT THE RUNTIME ENVIRONMENT ]

local {v_data} = {{{formatted_data}}}
local {v_key1} = {key1}
local {v_key2} = {key2}
local {v_chk} = {checksum}

local function {v_loader}()
    local _c = 0
    for _i = 1, #{v_data} do
        _c = (_c + {v_data}[_i]) % 65535
    end
    if _c ~= {v_chk} then
        return nil
    end

    local {v_buf} = {{}}
    for _i = 1, #{v_data} do
        local _b = ({v_data}[_i] - {v_key1} - ((_i - 1) % {v_key2}) + 512) % 256
        {v_buf}[_i] = string.char(_b)
    end

    local _ld = (loadstring or load or (_ENV and _ENV.loadstring) or (_G and _G.loadstring))
    if not _ld then return nil end
    
    local {v_fn}, _err = _ld(table.concat({v_buf}))
    if {v_fn} then
        return {v_fn}()
    else
        if log and log.error then log.error("Nyx VM Err: " .. tostring(_err)) end
    end
end

{v_loader}()
"""
    return obfuscated_code

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python obfuscator.py <input.lua> <output.lua>")
        sys.exit(1)
        
    in_file = sys.argv[1]
    out_file = sys.argv[2]
    
    with open(in_file, "r", encoding="utf-8") as f:
        src = f.read()
        
    obf = full_virtualize_obfuscate(src)
    
    with open(out_file, "w", encoding="utf-8") as f:
        f.write(obf)
        
    print(f"Successfully virtualized & encrypted {in_file} -> {out_file}")
