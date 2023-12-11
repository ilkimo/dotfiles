[22:54, 3/12/2023] Kim Marco Viberti: io invece sono al PC che sto facendo robe con i metadati di file jpg e png ahah
[22:55, 3/12/2023] Kim Marco Viberti: Sai che ho fatto un programma che ti cicla gli sfondi, no?
[22:56, 3/12/2023] Kim Marco Viberti: Ora sto facendo una roba che aggiunge un metadato ai file, metadato che ho chiamato "Rating" e in cui metto un numero intero da 1 a 100
[22:56, 3/12/2023] Kim Marco Viberti: Praticamente voglio fare in modo che posso scegliere la soglia minima per la selezione casuale degli sfondi, tra i file presenti nel percorso indicato
[22:56, 3/12/2023] Kim Marco Viberti: quindi se voglio solo sfondi bellissimissimi, anche a condizione di vedere sempre gli stessi, metto una soglia alta
[22:57, 3/12/2023] Kim Marco Viberti: se invece voglio un po' piu' di varianza, abbasso la soglia
[22:57, 3/12/2023] Kim Marco Viberti: Ovviamente perche' questo funzioni devo dare un rating ai wallpaper
[22:57, 3/12/2023] Kim Marco Viberti: pero' posso anche farmi uno strumento di supporto che quando c'e' un wallpaper clicco un tasto e poi clicco sullo schermo e metto il voto
[22:57, 3/12/2023] Kim Marco Viberti: Boh sto un po' sfasando ahaah
[22:58, 3/12/2023] Kim Marco Viberti: sta roba e' abbastanza partita a caso, non so bene come mai hahaa
[22:58, 3/12/2023] Kim Marco Viberti: pero' mi sta gasando
[22:59, 3/12/2023] Kim Marco Viberti: Piu' avanti sarebbe figo se il mio programma dicesse a qualche AI di generare uno sfondo da una certa descrizione ahhaha
[22:59, 3/12/2023] Kim Marco Viberti: Cosi mentre programmo con il terminale trasparente, ogni tot minuti mi arriva uno sfondo generato da una AI e io do i voti

```/shell
exiftool -Rating=50 image.png
```


```/shell
exiftool -UserComment="Rating:90 Contrast:50 Brightness: 40" /var/tmp/images/ant_mi3.jpg
```
