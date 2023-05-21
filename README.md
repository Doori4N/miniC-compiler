
# Projet compilation

Projet réalisé dans le cadre de l'UE Compilation de Licence 3 2022-2023 
- [Sujet du projet](https://github.com/Doori4N/projet_compilation/blob/main/Projet-Compilation-2023.pdf)
## Installation

Extraire l'archive du projet de la façon suivante :

```
  tar -xvf Projet-ESCOBAR-GIRARD.tar.gz
```
Une fois extrait placez-vous à l'intérieur du dossier et exécuter :

```
  make
```
## Utilisation/Examples

Vous pouvez maintenant compiler un fichier miniC :
```
  ./miniC < MonFichier.c
```
Le programme va alors créer un fichier ex.dot et ex.pdf qui correspond au programme donné.

Pour supprimer les fichiers indésirables vous pouvez utiliser :
```
  make clean
```
Cela supprimera les fichiers lex.yy.c y.tab.c y.tab.h ainsi que l'exécutable miniC.
De plus cela va vider les dossiers pdf/Tests/ et dot/Tests/ .

## Lancement des tests

Pour lancer les tests lancer la commande suivante :

```
  make test
```
Attention, les tests seront uniquement réalisés s'ils se trouvent dans le répertoire Tests.


## Remerciements
Merci à notre professeur de compilation Pr. Sid TOUATI.


## Réalisé par :

- [Quentin ESCOBAR](https://github.com/Moustik06)
- [Dorian GIRARD](https://github.com/Doori4N)



