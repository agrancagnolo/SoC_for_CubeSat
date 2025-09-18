import re

# Ruta al archivo original
ruta_original = "/home/agrancagnolo/Prueba_PI_Lore/SoC_for_CubeSat/dependencies/pdks/sky130A/libs.ref/sky130_fd_pr/spice/sky130_fd_pr__nfet_01v8__tt.pm3.spice"
ruta_xyce = "/home/agrancagnolo/Prueba_PI_Lore/SoC_for_CubeSat/dependencies/pdks/sky130A/libs.ref/sky130_fd_pr/spice/sky130_fd_pr__nfet_01v8__tt.xyce.spice"

# Expresiones que Xyce no soporta
expresiones = [
    r"\{.*?AGAUSS\(.*?\).*?\}",       # funciones estadísticas
    r"\{.*?MC_MM_SWITCH.*?\}",        # variables de Monte Carlo
    r"\{.*?sky130_fd_pr__.*?\}",      # variables internas del PDK
    r"\{.*?\}",                       # cualquier expresión entre llaves
]

# Parámetros que suelen causar problemas
parametros_conflictivos = [
    "toxe", "vth0", "voff", "nfactor", "vsat", "ua", "ub", "u0", "a0", "keta", "ags", "b0", "b1"
]

# Valor por defecto para reemplazar
valor_por_defecto = {
    "toxe": "4.148e-09",
    "vth0": "0.49439",
    "voff": "-0.20753",
    "nfactor": "2.015",
    "vsat": "176320",
    "ua": "-1.1926e-09",
    "ub": "2.1846e-18",
    "u0": "0.030197",
    "a0": "1.5",
    "keta": "0",
    "ags": "1.25",
    "b0": "0",
    "b1": "0"
}

def limpiar_linea(linea):
    for expr in expresiones:
        linea = re.sub(expr, "", linea)
    for param in parametros_conflictivos:
        if param in linea:
            linea = re.sub(rf"{param}\s*=\s*\S+", f"{param} = {valor_por_defecto[param]}", linea)
    return linea

# Leer y limpiar
with open(ruta_original, "r") as f_in:
    lineas = f_in.readlines()

lineas_limpias = [limpiar_linea(linea) for linea in lineas]

# Guardar archivo limpio
with open(ruta_xyce, "w") as f_out:
    f_out.writelines(lineas_limpias)

print(f"Archivo limpio generado: {ruta_xyce}")
