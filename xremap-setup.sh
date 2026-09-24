#!/usr/bin/env bash
# Setup de una sola vez para xremap sin sudo en el día a día.
# Otorga a tu usuario acceso a uinput (teclado virtual de salida) y al grupo
# input (leer los teclados físicos en /dev/input/event*).
#
# Permite que el remapeador de teclado xremap corra como servicio de usuario
# (systemctl --user) sin necesidad de password después de este setup.
#
# Uso: sudo -E bash xremap-setup.sh
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "ERROR: ejecutar con sudo." >&2
  exit 1
fi

USER="${SUDO_USER:-$(logname 2>/dev/null || echo david)}"
echo "== 1/4 Grupo 'input' (leer teclados) -> $USER =="
getent group input >/dev/null || groupadd input
usermod -aG input "$USER"

echo "== 2/4 Regla udev para /dev/uinput (escribir teclado virtual) =="
mkdir -p /etc/udev/rules.d
printf '%s\n' 'KERNEL=="uinput", GROUP="input", TAG+="uaccess", MODE:="0660", OPTIONS+="static_node=uinput"' > /etc/udev/rules.d/99-input.rules
cat /etc/udev/rules.d/99-input.rules

echo "== 3/4 Modulo uinput (carga + persistencia) =="
modprobe uinput || true
printf 'uinput\n' > /etc/modules-load.d/uinput.conf

echo "== 4/4 Recargar udev =="
udevadm control --reload-rules
udevadm trigger

echo
echo "LISTO. Los permisos de grupo se aplican en la NUEVA sesion:"
echo "     -> cierra sesion y vuelve a entrar (logout/login). No hace falta reiniciar la maquina."
echo
echo "Confirmacion rapida (tras el login): id | grep input"
echo
echo "Siguiente paso (sin sudo):"
echo "     systemctl --user enable --now xremap"