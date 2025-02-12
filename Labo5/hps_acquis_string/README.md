<img src="https://storage.googleapis.com/visual-identity/logo/2020-slim.svg" style="height:80px;"><br><br>

<br>

# Laboratoire 05 - Conception d’une interface fiable
<br><br><br>

**Cours : ARE : Architecture des systèmes embarqués**<br>
**Labo 5 : Conception d’une interface fiable**<br>
**Professeur :** Etienne Messerli <br>
**Assistant :** Convers Anthony <br>
**Étudiants :** Lucas Lattion & Rafael Dousse

<!-- pagebreak -->

## Table des matières

<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=3 orderedList=false} -->

<!-- code_chunk_output -->

- [Laboratoire 05 - Conception d’une interface fiable](#laboratoire-05---conception-dune-interface-fiable)
  - [Table des matières](#table-des-matières)
  - [Introduction](#introduction)
  - [Plan d'adressage](#plan-dadressage)
  - [Spécification du programme](#spécification-du-programme)
  - [erreur à débug.](#erreur-à-débug)
  - [Conclusion](#conclusion)

<!-- /code_chunk_output -->

## Introduction


## Plan d'adressage

Zone d'adressage pour l'interface: 0x010000 - 0x01FFFF

| Adresse (offset) | Read | Write |
|-----------------|------|--------|
| 0x00 | [31..0] Interface user ID | reserved |
| 0x04 | [31..4] "0..0" ; [3..0] buttons | reserved |
| 0x08 | [31..10] "0..0" ; [9..0] switchs | reserved |
| 0x0C | [31..10] "0..0" ; [9..0] leds | [31..10] reserved ; [9..0] leds |
| 0x10 | [31..2] "0..0" ; [1-0] status | [31..5] reserved ; [4] new_char<br>[3..1] reserved ; [0] init_char |
| 0x14 | [31..5] "0..0" ; [4] mode_gen<br>[3-2] "0..0" ; [1-0] delay_gen | [31..5] reserved ; [4] mode_gen<br>[3-2] reserved ; [1-0] delay_gen |
| 0x18 | [31..1] reserved; | [31..1] reserved; [0] ack |
| 0x1C | available for news functionality | available for news functionality |
| 0x20 | [31..24] char_1 [23..16] char_2<br>[15..8] char_3 [7..0] char_4 | reserved |
| 0x24 | [31..24] char_5 [23..16] char_6<br>[15..8] char_7 [7..0] char_8 | reserved |
| 0x28 | [31..24] char_9 [23..16] char_10<br>[15..8] char_11 [7..0] char_12 | reserved |
| 0x2C | [31..24] char_13 [23..16] char_14<br>[15..8] char_15 [7..0] char_16 | reserved |
| 0x30 | [31..8] "0...0"<br>[7..0] checksum | reserved |
| 0x34 ... 0x3C | reserved | reserved |
| 0x40 ... 0xFFFC | not used | not used |


Explications sur le plan d’adressage : 
- status : Deux bits de statut, placés aux bits [1..0] (Ils seront utilisés lors de la 
seconde partie du laboratoire) :  
  - status[1] :  indique  si  l'interface  dispose  d'un  système  de  capture  des caractères (photo instantanée). Si status[1] = '1' système capture 
disponible. 
  - status[0] : indique qu'une photo a été prise lorsque le système de capture est actif. Ce bit est valide uniquement si status[1] = '1'. 
- init_char : Commande pour initialiser la chaine de caractères et son checksum au point de départ (prioritaire). 
- new_char :  Commande  pour  générer  une  nouvel  chaine  de 16  caractères  et 
son checksum (mode manuel) 
- mode_gen :Sélection du mode automatique ou manuel pour la génération des chaines de caractères. 
- delay_gen : Sélection de la fréquence de génération des chaines de caractères (mode automatique). 
- char_x : lecture du caractère sur 8 bits en codage ASCII. 
- checksum : lecture du checksum de la chaine de caractères.

## Spécification du programme

Le but est de contrôler le générateur de chaines de caractères selon l’états des
boutons et interrupteurs de la DE1-SoC, et de lire les valeurs des 16 caractères et son
checksum. Il faudra également vérifier l’intégrité de la chaine lues. La spécification du
fonctionnement est la suivante :
Au démarrage, le programme doit remplir les conditions suivantes :
- Les 10 leds DE1-SoC sont éteintes.
- Afficher la constante design standard ID du bus AXI lightweight HPS-to-FPGA
au format hexadécimal dans la console de ARM-DS.
- Afficher la constante interface user ID du bus Avalon au format hexadécimal
dans la console de ARM-DS.
Ensuite pendant l’exécution du programme, à tout instant les actions suivantes doivent
être respectées :
- Copie de la valeur des 10 interrupteurs (SW) sur les 10 leds de la DE1-SoC.
- Une pression sur KEY0 permet l’initialisation des 16 caractères et son
checksum.
- Une pression sur KEY1 permet de générer une nouvelle chaine de 16
caractères et son checksum, cela fonctionne seulement lorsque le mode
manuel est sélectionné.
- Tant que KEY2 est actif, lecture successive des 16 caractères et son checksum,
puis calcul de l’intégrité de la chaine pour vérifier la cohérence, et affichage
dans la console :
o Si la chaine de caractères est cohérente, donc l’intégrité est correcte,
affichage du message :
- OK : status: X , checksum: X, calcul integrity: X, string: X
o Si la chaine de caractères n’est pas cohérente, donc l’intégrité est
incorrecte, incrémentation d’un compteur du nombre d’erreur cumulée et
affichage du message :
- ER : status: X , checksum: X, calcul integrity: X, string: X
- ER : nombre d’erreur cumulée : X
- L’état de SW9-8 permet de sélectionner la fréquence de génération des chaines
de caractères :
o SW9-8 = 00 : 1 Hz
o SW9-8 = 01 : 1 KHz
o SW9-8 = 10 : 100 KHz
o SW9-8 = 11 : 1 MHz
- L’état de SW7 permet de sélectionner le mode de génération des chaines de
caractères :
o SW7 = 0 : mode manuel
o SW7 = 1 : mode automatique
- L’état de SW0 permet de sélectionner une acquisition fiable (implémenter
seulement dans la partie 2) :
o SW0 = 0 : acquisition non fiable
o SW0 = 1 : acquisition fiable garantie

## erreur à débug.

Error (10344): VHDL expression error at avl_user_interface.vhd(114): expression has 33 elements, but must have 32 elements
Error (12152): Can't elaborate user hierarchy "avl_user_interface:avl_user_interface_inst"
Info (144001): Generated suppressed messages file /home/reds/are/hps_acquis_string/hard/eda/output_files/DE1_SoC_top.map.smsg
Error: Quartus Prime Analysis & Synthesis was unsuccessful. 2 errors, 50 warnings
	Error: Peak virtual memory: 1193 megabytes
	Error: Processing ended: Fri Nov 29 15:39:11 2024
	Error: Elapsed time: 00:01:02
	Error: Total CPU time (on all processors): 00:01:54
Error (293001): Quartus Prime Full Compilation was unsuccessful. 4 errors, 50 warnings


## Conclusion

