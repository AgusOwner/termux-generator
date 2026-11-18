#!/data/data/com.agus.termux/files/usr/bin/bash
# ArgentSS - menu de inicio para KellerSS
set -u

V=$'\e[92m'; A=$'\e[93m'; R=$'\e[91m'; C=$'\e[96m'; Z=$'\e[0m'; B=$'\e[1m'

abrir() {
  # Abre una pantalla de Ajustes de Android. Devuelve 0 si lo logro.
  command -v am >/dev/null 2>&1 || return 1
  am start "$@" >/dev/null 2>&1
}

estado_adb() {
  local n
  n=$(adb devices 2>/dev/null | awk 'NR>1 && $2=="device"' | wc -l)
  if [ "${n:-0}" -gt 0 ]; then
    echo "  ADB: ${V}conectado${Z}"
  else
    echo "  ADB: ${R}sin dispositivo${Z}"
  fi
}

banner() {
  clear 2>/dev/null || true
  echo "${C}${B}  ==============================${Z}"
  echo "${C}${B}        ArgentSS  -  Menu${Z}"
  echo "${C}${B}  ==============================${Z}"
  estado_adb
  echo
}

pausa() { echo; read -r -p "  Enter para volver al menu..." _; }

modo_desarrollador() {
  echo "${A}${B}Activar Modo desarrollador${Z}"
  echo
  echo "  Android no permite activarlo por comando. Una sola vez:"
  echo "   1) En 'Acerca del telefono' toca 7 veces 'Numero de compilacion'"
  echo "   2) Pon tu PIN/patron si te lo pide"
  echo
  if abrir -a android.settings.DEVICE_INFO_SETTINGS; then
    echo "  ${V}Te abri 'Acerca del telefono'. Cuando termines vuelve a esta app.${Z}"
  else
    echo "  ${R}No pude abrirlo. Entra a Ajustes > Acerca del telefono.${Z}"
  fi
  pausa
}

depuracion_inalambrica() {
  echo "${A}${B}Depuracion inalambrica${Z}"
  echo
  echo "  Activala en: Opciones de desarrollador > Depuracion inalambrica."
  echo "  (Android no deja encenderla por comando; yo te llevo hasta ahi.)"
  echo
  if abrir -a android.settings.APPLICATION_DEVELOPMENT_SETTINGS; then
    echo "  ${V}Te abri 'Opciones de desarrollador'.${Z}"
  elif abrir -a android.settings.SETTINGS; then
    echo "  ${A}Abri Ajustes; busca 'Opciones de desarrollador'.${Z}"
  else
    echo "  ${R}No pude abrirlo. Entra a mano.${Z}"
  fi
  echo
  echo "  Cuando la tengas activada, usa la opcion [V] para vincular."
  pausa
}

vincular_adb() {
  echo "${A}${B}Vincular ADB${Z}"
  echo
  echo "  Como Termux esta en este mismo celular, no necesitas la IP:"
  echo "  solo los puertos y el codigo."
  echo
  echo "  ${A}Tip:${Z} usa pantalla dividida o ventana flotante para ver Ajustes"
  echo "  y esta app a la vez (el codigo desaparece si sales de Ajustes)."
  echo
  adb start-server >/dev/null 2>&1

  echo "  1) Ajustes > Depuracion inalambrica > 'Vincular dispositivo con codigo'"
  read -r -p "  Puerto de vinculacion (los digitos despues de los dos puntos): " PPORT
  [ -z "$PPORT" ] && { echo "  ${R}No escribiste nada.${Z}"; pausa; return; }
  read -r -p "  Codigo de 6 digitos: " CODE
  echo
  if ! adb pair "localhost:${PPORT}" "$CODE"; then
    echo
    echo "  ${R}No se pudo vincular. Revisa puerto y codigo (cambian cada vez).${Z}"
    pausa; return
  fi
  echo
  echo "  2) Cierra esa ventana. En la pantalla principal de Depuracion"
  echo "     inalambrica mira 'Direccion IP y puerto' (puerto DISTINTO al anterior)."
  read -r -p "  Puerto de conexion: " CPORT
  [ -z "$CPORT" ] && { echo "  ${R}No escribiste nada.${Z}"; pausa; return; }
  adb connect "localhost:${CPORT}"
  echo
  sleep 1
  if adb devices | awk 'NR>1 && $2=="device"' | grep -q .; then
    echo "  ${V}${B}ADB conectado.${Z} Ya puedes usar KellerSS (otra sesion o [K])."
  else
    echo "  ${R}No quedo conectado. Prueba de nuevo.${Z}"
  fi
  pausa
}

ejecutar_kellerss() {
  if command -v kellerss >/dev/null 2>&1; then
    kellerss
  else
    echo "  ${R}No encontre KellerSS.${Z}"
    pausa
  fi
}

while true; do
  banner
  echo "  ${V}[D]${Z} Activar Modo desarrollador"
  echo "  ${V}[W]${Z} Depuracion inalambrica (abrir ajustes)"
  echo "  ${V}[V]${Z} Vincular ADB"
  echo "  ${V}[K]${Z} Ejecutar KellerSS"
  echo "  ${R}[Q]${Z} Salir a la terminal"
  echo
  echo "  ${A}Tip:${Z} escribe 'kellerss' para el scanner o 'menu' para este menu."
  echo
  read -r -p "  Elige una opcion: " OP
  case "${OP,,}" in
    d) modo_desarrollador ;;
    w) depuracion_inalambrica ;;
    v) vincular_adb ;;
    k) ejecutar_kellerss ;;
    q) clear 2>/dev/null; exit 0 ;;
    *) echo "  ${R}Opcion no valida.${Z}"; sleep 1 ;;
  esac
done
