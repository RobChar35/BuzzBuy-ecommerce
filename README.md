# Proyecto final: BuzzBuy
BuzzBuy es el nombre del proyecto final del curso de Programación en Móviles Avanzado (iOS). 

## Desarrollo
Cada integrante del grupo que quiera apoyar en el desarrollo del proyecto deberá crear una rama en donde aplique los cambios que quiera realizar. Es importante no subir cambios directamente a la rama `main`. Si no se encuentra ningún problema, entonces se puede hacer un Pull Request.

### Comando para el desarrollo
Para crear una rama:
```
git branch <nombre-de-rama>
```
Para guardar cambios:
```
git add .
git commit -m "nombre-directorio: mensaje" 
```
Para cambiar de rama:
```
git checkout <nombre-de-rama>
```
Para publicar una rama al repositorio:
```
git push origin <nombre-de-rama>
```
Para actualizar su entorno local (afectando los cambios actuales de su rama):
```
git pull origin <nombre-de-rama>
```
Para traerse los últimos cambios sin afectar los cambios de su rama:
```
git merge origin/<nombre-de-rama>
```
Para actualizar todo el proyecto con los cambios del respositorio remoto:
```
git fetch
```
### Comado para Cocoapods
En el archivo `.gitignore` se encuentra el directorio de `/Pods`. Esto se hace para evitar problemas de compatibilidad de versiones entre diferentes proyectos al momento de usarlo. Si se clona el proyecto y se usa sin instalar las dependencias, este no funcionará correctamente. Para solucionar esto, se debe aplicar el siguiente comando dentro del directorio del proyecto clonado:
```
pod install
```