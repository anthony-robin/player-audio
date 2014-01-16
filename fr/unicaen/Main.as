package fr.unicaen {

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.media.ID3Info;
	import flash.external.ExternalInterface;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;

	public class Main extends MovieClip{

		private var controleur:Controller;
		var sonMp3:Sound;
		var id3Info:ID3Info;
		var regexp:RegExp;
		var newtitre:String;
		var titre;
		var percent:Number;
		var enChargement:Boolean = false;
		var pourcentageEnCours:Number;


		public function Main() {
			this.addEventListener(Event.ADDED_TO_STAGE, initialisation);
		}


		/*
		|--------------------------------------------------------------------------
		| Fonction Initialisation
		|--------------------------------------------------------------------------
		|
		*/
		public function initialisation(e:Event):void{
			controleur = new Controller(this);
			controleur.initialiserSon();
		}


		/*
		|--------------------------------------------------------------------------
		| -- Fonction qui affiche le chargement du morceau audio --
		| * dureeTotale représente la "longeur" de ma chanson exprimée en millisecondes. Pour avoir un format plus compréhensif j'ai défini une fonction formaterDuree() qui prend en paramètre un temps en millisecondes. La fonction formaterDuree() retourne un objet à la fin et j'enregistre ce résultat dans mes deux variables "retourMinutesTotales" et "retourSecondesTotales".
		| Ensuite on envoie tout ça à Mootools et le tour est joué !
		|--------------------------------------------------------------------------
		|
		*/
		public function infosChargementAudio(e:Event):void{

			(e.type == 'progress' ) ? enChargement = true : enChargement = false;

			percent = Math.round(100 * (e.currentTarget.bytesLoaded/e.currentTarget.bytesTotal)); // retourne un pourcentage car on multiplie par 100.

			var dureeTotale = controleur.monSon.length;

			var retourMinutesTotales = formaterDuree(dureeTotale);
			var retourSecondesTotales = formaterDuree(dureeTotale);

			if (ExternalInterface.available) {
				ExternalInterface.call('afficherChargement', percent);
				ExternalInterface.call('afficherTempsTotal', retourMinutesTotales.tempsMinutes, retourSecondesTotales.tempsSecondes);
			}
		}


		/*
		|--------------------------------------------------------------------------
		| Fonction qui récupère le titre de la chanson cliquée par l'utilisateur
		|--------------------------------------------------------------------------
		|
		*/
		public function recupererChansonCliquee(chansonCourante:String):void{
			if(controleur.enLecture){
				controleur.stopAudio();
			}
			if(enChargement){
				controleur.monSon.close();
			}

			controleur.defaultSong = chansonCourante;
			controleur.nouveautitre = splitTitre();
			if(ExternalInterface.available){
				ExternalInterface.call('afficherTitre', controleur.nouveautitre);
			}

			controleur.chargementDuSon();
			controleur.lireAudio();
		}



		/*
		|--------------------------------------------------------------------------
		| Fonction de récupération des métadonnées
		|--------------------------------------------------------------------------
		|
		*/
		public function getInfoID3(e:Event):void{
			sonMp3 = e.currentTarget as Sound;
			id3Info = sonMp3.id3;

			var album = id3Info.album;
			var artiste = id3Info.artist;
			var titreChanson = id3Info.songName;
			var annee = id3Info.year;

			if(ExternalInterface.available){
				ExternalInterface.call('afficherMetadonnees', album, artiste, titreChanson, annee);
				ExternalInterface.call('afficherJaquette', album);
			}
		}



		/*
		|--------------------------------------------------------------------------
		| -- Fonction de récupération de la durée courante d'une chanson --
		| * Pour cette fonction, ça fonctionne de la même façon que pour le temps totale à la différence qu'on écoute la durée toutes les secondes (notre fonction est de type TimerEvent). Notre durée en cours n'est plus définie par monSon.length (qui renvoyait la durée totale d'un son) mais par le "canal.position". Pour rappel le "canal.position" renvoie la durée en cours du son en lecture (toujours en millisecondes). Comme notre fonction est de type TimerEvent "canal.position" sera actualisé chaque secondes.
		| * Il nous faut ensuite récupérer un pourcentage correspondant au moment courant de la chanson. L'opération qui nous donne ce pourcentage est la durée actuelle divisée par le temps total et le tout multiplié par 100. Je me souviens plus vraiment à quoi sert ma variable pourcentageEnCours si ce n'est d'arrondir le pourcentage.
		|--------------------------------------------------------------------------
		|
		*/
		public function afficherDureeEnCours(e:TimerEvent):void{
			var dureeEnCours = controleur.canal.position;

			var retourMinutesEnCours = formaterDuree(dureeEnCours);
			var retourSecondesEnCours = formaterDuree(dureeEnCours);

			var valeur = (dureeEnCours/controleur.monSon.length)*100;
			pourcentageEnCours = Math.round(valeur*Math.pow(10,2))/Math.pow(10,2);

			ExternalInterface.call('afficherTempsEnCours', retourMinutesEnCours.tempsMinutes, retourSecondesEnCours.tempsSecondes, pourcentageEnCours);
		}



		/*
		|--------------------------------------------------------------------------
		| -- Fonction qui formate notre durée dans un format m:s --
		| * Cette fonction travaille à partir d'une durée (en millisecondes) transmise en paramètre.
		| * Pour récupérer les minutes, on divise notre durée (en millisecondes) par 1000 ce qui nous donne des secondes. On redivise en suite par 60 pour convertir en secondes.
		| * Pour récupérer les secondes , on divise notre durée (en millisecondes) par 1000 ce qui nous donne des secondes puis on fait un modulo (%) pour récupérer le reste de la division. Ce résultat correspondra ensuite à notre valeur en secondes.
		| * Dans les deux cas, on force la variable en string (je sais plus pourquoi mais je crois qu'il fallais le faire pour que ça fonctionne ^^ ). Le "Math.floor()" va nous permettre d'arrondir notre temps à l'entier inférieur (pour éviter par exemple d'avoir un 15.58 secondes et l'arrondira à 15secondes).
		| * En dessous je fais une petite condition qui teste si la valeur de la variable est inférieur à 10. Ça permet de rajouter un 0 avant le nombre. C'est juste pour qu'au niveau visuel ça soit moins choquant.
		| * Cette fonction permet d'avoir dans deux variables notre temps formaté correctement pour les minutes et les secondes. Malheuresement un "return" ne permet de renvoyer qu'un seul résultat. C'est pour cela que j'ai créé un nouvel objet "retourObjet" qui stockera en lui deux variables. Et là on a rusé car maintenant on ne retourne qu'un élément (notre objet) mais qui contient nos deux variables !
		| Si tu ne comprends pas vraiment la notion d'objet essaye d'imaginer que c'est comme un tableau en PHP qui contiendrait plusieurs valeurs.
		|--------------------------------------------------------------------------
		|
		*/
		public function formaterDuree(duree):Object{
			var tempsMinutes = Math.floor(duree/1000/60).toString();
			var tempsSecondes = Math.floor(duree/1000%60).toString();

			if(tempsMinutes < 10){
				tempsMinutes = "0"+tempsMinutes.toString();
			}
			if(tempsSecondes < 10){
				tempsSecondes = "0"+tempsSecondes.toString();
			}

			var retourObjet:Object = new Object();
			retourObjet.tempsMinutes = tempsMinutes;
			retourObjet.tempsSecondes = tempsSecondes;

			return retourObjet;
		}




		/*
		|--------------------------------------------------------------------------
		| -- Fonction qui découpe le titre du morceau en plusieurs segments --
		| * Ce code permet de spliter le titre du morceau pour avoir:
		|		- un affichage avec espace entre les mots
		|		- une majuscule sur chacun d'entre eux.
		|--------------------------------------------------------------------------
		|
		*/
		public function splitTitre():String{

			/*
			*/
			regexp = /_/;
			controleur.jaquette = controleur.defaultSong;
			titre = controleur.defaultSong.split(regexp);
			newtitre = "";

			for(var i:int = 0; i< titre.length; i++){
				titre[i] = String(titre[i].charAt(0).toUpperCase() + titre[i].substr( 1, titre[i].length ));
				newtitre += titre[i]+" ";
			}
			newtitre = replace(newtitre, "-", " ");
			return newtitre;
		}



		/*
		|--------------------------------------------------------------------------
		| Fonction qui remplace un caractère par un autre
		|--------------------------------------------------------------------------
		|
		*/
		public function replace(input:String, replace:String, replaceWith:String):String{
			var sb:String = new String();
			var found:Boolean = false;

			var sLen:Number = input.length;
			var rLen:Number = replace.length;

			for (var i:Number = 0; i < sLen; i++){
				if(input.charAt(i) == replace.charAt(0)){
					found = true;
					for(var j:Number = 0; j < rLen; j++){
						if(!(input.charAt(i + j) == replace.charAt(j))){
							found = false;
							break;
						}
					}

					if(found){
						sb += replaceWith;
						i = i + (rLen - 1);
						continue;
					}
				}

				sb += input.charAt(i);
			}
			return sb;
		} // Fin de la fonction replace



	}

}