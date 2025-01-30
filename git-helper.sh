#!/bin/bash

# Ruta al repositorio
REPO_PATH="/home/david/Tep/"
file_path=""

echo "Bienvenido al script de commits de TEP V 1.0"

# pide carpeta de project
echo "Elige el nombre de carpeta en: $REPO_PATH"
echo "1. carrier-api"
echo "2. order-api"
echo "3. shipment-api"
echo "4. tms-client"
echo "5. tms-core-api"
read selected_option

case $selected_option in
  1)
    file_path="carrier-api"
    ;;
  2)
    file_path="order-api"
    ;;
  3)
    file_path="shipment-api"
    ;;
  4)
    file_path="tms-client"
    ;;
  5)
    file_path="tms-core-api"
    ;;
  *)
    echo "Opción no válida."
    exit 1
    ;;
esac

REPO_PATH="$REPO_PATH$file_path"
if [ ! -d "$REPO_PATH" ]; then
  echo "La ruta $REPO_PATH no existe. Verifica el directorio."
  exit 1
fi

cd $REPO_PATH
echo "Estas en el directorio: $REPO_PATH"

echo "Nombre del stash: "
read stash_name
if [ -z "$stash_name" ]; then
  echo "El nombre del stash no puede estar vacío."
  exit 1
fi
stash_output=$(git stash save $stash_name 2>&1)
if [ $? -eq 0 ]; then
  echo "⚠️ Resultado de stash."
  echo "--------------------------------------------"
  echo "$stash_output"
  echo "--------------------------------------------"
else
  echo "❌ Ocurrió un error al realizar el stash."
  echo "--------------------------------------------"
  echo "$stash_output"
  echo "--------------------------------------------"
  exit 1
fi

echo "Nombre de la rama remota, elija una: "
echo "1. develop"
echo "2. release"
echo "3. master"
read selected_option_branch

case $selected_option_branch in
  1)
    branch_name="develop"
    ;;
  2)
    branch_name="release"
    ;;
  3)
    branch_name="master"
    ;;
  *)
    echo "Opción no válida."
    exit 1
    ;;
esac

echo "Validando y realizando pull en la rama remota $branch_name..."

if git branch -r | grep -q "upstream/$branch_name"; then
  pull_output=$(git pull upstream $branch_name --no-edit 2>&1)
  if [ $? -ne 0 ]; then
    echo "❌ Error al realizar git pull:"
    echo "$pull_output"
    exit 1
  else
    echo "✅ Pull realizado con éxito."
  fi
else
  echo "La rama remota $branch_name no existe. Verifica el nombre."
  exit 1
fi

echo "Clave de Jira (solo la parte numérica): "
read jira_key
if [[ -z "$jira_key" || ! "$jira_key" =~ ^[0-9]+$ ]]; then
  echo "❌ La clave de Jira debe ser un número válido."
  exit 1
fi
jira_key="TEP-$jira_key"
echo "$jira_key"

localBranch=$(git rev-parse --abbrev-ref HEAD)

if [ "$localBranch" == "$jira_key" ]; then
  echo "Estas en la rama correcta: $jira_key"
else
  # creando rama
  echo "Creando rama $jira_key..."

  case $localBranch in
    develop)
      git switch -c $jira_key
      ;;
    release)
      git switch -c "${jira_key}_release"
      ;;
    master)
      git switch -c "${jira_key}_master"
      ;;
    *)
      echo "El nombre de la rama no es válido: $localBranch"
      ;;
  esac
  localBranch=$jira_key
fi

if git stash list | grep -q "$stash_name"; then
  git stash apply
else
  echo "No se encontró un stash con el nombre $stash_name."
  exit 1
fi

echo "Tipo de commit seleccione uno: "
echo "1. feat"
echo "2. fix"
echo "3. improvement"
read selected_option_commit_type

case $selected_option_commit_type in
  1)
    commit_type="feat"
    ;;
  2)
    commit_type="fix"
    ;;
  3)
    commit_type="imp"
    ;;
  *)
    echo "Opción no válida."
    exit 1
    ;;
esac
echo $commit_type

echo "Modulo o archivo afectado: "
read module
echo $module

echo "Mensaje de commit: "
read commit_message
echo $commit_message

echo "Elige la carpeta raiz del proyecto:"
echo "1. src"
echo "2. app"
read selected_option_folder

case $selected_option_folder in
  1)
    git add src -- ':!src/environments/env.js' || { echo "Error al agregar archivos."; exit 1; }
    ;;
  2)
    git add app || { echo "Error al agregar archivos."; exit 1; }
    ;;
  *)
    echo "Opción no válida."
    exit 1
    ;;
esac

git commit -m "$commit_type($jira_key): $module. $commit_message"
echo "Commit creado"
echo "nombre del commit: $commit_type($jira_key): $module. $commit_message"

echo "Subiendo cambios al repositorio rama $localBranch"
push_output=$(git push origin $localBranch 2>&1)

if [ $? -eq 0 ]; then
  echo "✅ Push realizado exitosamente."
  echo "--------------------------------------------"
  echo "$push_output"
  echo "--------------------------------------------"
else
  echo "❌ Ocurrió un error al realizar el push."
  echo "--------------------------------------------"
  echo "$push_output"
  echo "--------------------------------------------"
  exit 1
fi
