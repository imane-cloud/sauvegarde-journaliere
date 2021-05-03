/*
Ce script décrit comment implémenter une stratégie de sauvegarde flexible pour une base de données dans SQL server. 
la bases de donnée est sauvegardée complètement ou différentiellement à l'aide d'un caractère de contrôle de stratégie de sauvegarde en fonction
du nom du jour de la semaine. Le caractère de contrôle indiquera un "C" pour une sauvegarde complète ou un "D" pour une sauvegarde différentielle.
Chaque caractère du mot représente un jour de la semaine,donc la sauvegarde complète le lundi avec un différentiel le reste de la semaine ressembleraient à "DCDDDDD".Chaque sauvegarde de base de données sera nommée avec le nom de la base de données, le mode de sauvegarde et la date actuelle.

La sauvegarde complète est le point de départ de toutes les autres sauvegardes et contient toutes les données des dossiers et fichiers sélectionnés pour la sauvegarde.
Une sauvegarde différentielle est une sauvegarde cumulative de toutes les modifications effectuées depuis la dernière sauvegarde complète, c'est-à-dire les différences depuis la dernière sauvegarde complète.

En resumons,cette procédure prend en paramétre le nom d'une base de donnée trouve la colonne de caractères de contrôle de la stratégie de sauvegarde et décide pour le jour en cours de la semaine quoi faire.

*/ 


create  procedure backup_database (@DbName  varchar(30))
as
--déclaration des variables
DECLARE @BackupFile       varchar(255)                                                     
Declare @BackupName       varchar(30)                            
Declare @BackupMode        char(1)                                
Declare @BackupStrategy         char(7)                           
Declare @BackupDir varchar(255)  
--@Backupdir est la destination de sauvegarde
set @BackupDir='D:\sauvegarde'
set  @BackupStrategy ='DCDDDDD'

       set @BackupMode = Substring (@BackupStrategy, DatePart(dw, CURRENT_TIMESTAMP),1)
       /*SUBSTRING(chaine,debut, longueur) : retourne la chaîne de caractère “chaine” 
         en partant de la position définie par “debut” et sur la longueur définie par “longueur”

		 DATEPART(interval, date) Renvoie une partie spécifiée d'une date,dans ce cas 
		 elle revoie dw (day of the week) par exemple si c'est mardi DatePart(dw, CURRENT_TIMESTAMP) 
		 renvoie 3, car dimanche est considérer comme premier.*/

         
         set @BackupName = @DbName + '-Complète Base de données Sauvegarde' 
         set @BackupFile = @BackupDir + '\'  + @DbName + 
         CASE @BackupMode 
              WHEN 'C' THEN 'Full' 
				  ELSE 'Diff' 
		   END +   '_' + CONVERT(varchar, CURRENT_TIMESTAMP , 112) +   REPLACE(LEFT(CONVERT(varchar,CURRENT_TIMESTAMP,108),5),':','') + '.BAK' 
     /*LEFT(CONVERT(varchar,CURRENT_TIMESTAMP,108),5) permet de retourner 5 caractères parmi les premiers
      caractères de la date actuelle de type hh:mm:ss

       REPLACE() remplace ':' par ''  */
 
 IF @BackupMode = 'C' 
                  BEGIN
      BACKUP DATABASE @DbName TO  DISK = @BackupFile WITH NOFORMAT, NOINIT, 
      NAME = @BackupName , SKIP, NOREWIND, NOUNLOAD,  STATS = 10 

                  END
 IF @BackupMode = 'D' 
                  BEGIN
	  BACKUP DATABASE @DbName TO  DISK = @BackupFile WITH  DIFFERENTIAL , NOFORMAT, NOINIT,  
      NAME = @BackupName , SKIP, NOREWIND, NOUNLOAD,  STATS = 10 
				  END
				
   
go

--Tout le travail est fait en une seule procédure qui devrait être programmé pour travailler chaque jour par un seul travail.



EXEC  backup_database
  @DbName='AdventureWorks2019'
go
