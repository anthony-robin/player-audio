package fr.unicaen {

	import flash.events.Event;
	import flash.display.MovieClip;
	import flash.media.Sound;
	import flash.media.ID3Info;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.external.ExternalInterface;
	import flash.events.ProgressEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;


	/*
	|-----------------------------------------------------------------------------------
	| Cette classe gère tout ce qui touche au chargement et au controle du player audio
	|-----------------------------------------------------------------------------------
	|
	*/
	public class Controller{

		var monSon:Sound;
		var canal:SoundChannel;
		var enLecture:Boolean = false;
		var positionLecture:Number = 0;
		var defaultSong:String;
		var chemin:String;
		var vue:Main;
		var jaquette:String;
		var enCours;
		var nouveautitre:String;
		var monTimer:Timer;
		var trans:SoundTransform = new SoundTransform(0.5);
		var mute:Boolean;
		var currentVolume:Number = 0.5;
		var reset:Boolean = false;


		public function Controller(vue:Main) {
			this.vue = vue;
		}

		/*
		|--------------------------------------------------------------------------
		| Fonction qui initialise le son par défaut
		|--------------------------------------------------------------------------
		|
		*/
		public function initialiserSon():void{

			// On récupère les paramètres définis dans mootools
			chemin = this.vue.loaderInfo.parameters.chemin;
			defaultSong = this.vue.loaderInfo.parameters.defaultSong;

			if(chemin == null) {
				chemin = "assets/audio/";
			}
			if(defaultSong == null) {
				defaultSong = "efectos_vocales";
			}

			nouveautitre = vue.splitTitre();
			currentVolume = trans.volume;


			if(ExternalInterface.available){
				ExternalInterface.call('afficherTitre', nouveautitre);
				ExternalInterface.call('trace', chemin+defaultSong+".mp3");
				ExternalInterface.call('afficherChargement', enCours);
				ExternalInterface.call('afficherPourcentageVolume', currentVolume*100);

				ExternalInterface.addCallback('lireAudioJS', lireAudio);
				ExternalInterface.addCallback('recuperePositionCurseurJS', recuperePositionCurseur);
				ExternalInterface.addCallback('recuperePositionCurseurVolumeJS', recuperePositionCurseurVolume);
				ExternalInterface.addCallback('stopAudioJS', stopAudio);
				ExternalInterface.addCallback('muteVolumeJS', muteVolume);
				ExternalInterface.addCallback('RecupererChansonCliqueeJS', vue.recupererChansonCliquee);
			}

			chargementDuSon();
		}



		/*
		|--------------------------------------------------------------------------
		| Fonction qui charge le son demandé
		|--------------------------------------------------------------------------
		|
		*/
		public function chargementDuSon():void{
			monSon = new Sound();
			monSon.load(new URLRequest(chemin+defaultSong+'.mp3'));
			
			monSon.addEventListener(ProgressEvent.PROGRESS, vue.infosChargementAudio);
			monSon.addEventListener(Event.COMPLETE, vue.infosChargementAudio);
			
			monSon.addEventListener(Event.ID3, vue.getInfoID3);

			monTimer = new Timer(1000);

			//lireAudio();
		}


		/*
		|--------------------------------------------------------------------------
		| Fonction qui lance la lecture du son (gère également la pause)
		|--------------------------------------------------------------------------
		|
		*/
		public function lireAudio():void{

			monTimer.addEventListener(TimerEvent.TIMER, vue.afficherDureeEnCours);

			if(enLecture){
				monTimer.stop();
				positionLecture = canal.position;
				canal.stop();
				enLecture = false;
			}
			else{
				monTimer.start();
				canal = monSon.play(positionLecture);
				enLecture = true;
			}

			recuperePositionCurseurVolume(currentVolume*100);
		}



		/*
		|--------------------------------------------------------------------------
		| Fonction qui récupère la position du curseur dans la barre de lecture
		|--------------------------------------------------------------------------
		|
		*/
		public function recuperePositionCurseur(pourcent:Number):void{
			if(enLecture){
				reset = true;
				stopAudio();
				enLecture = true;

				var valeur = (pourcent*monSon.length)/100;
				canal = monSon.play(valeur);
			}

			recuperePositionCurseurVolume(currentVolume*100);
		}



		/*
		|--------------------------------------------------------------------------
		| Fonction qui récupère la position du curseur dans la barre de volume
		|--------------------------------------------------------------------------
		|
		*/
		public function recuperePositionCurseurVolume(pourcentage:Number):void{
			trans = canal.soundTransform;
			trans.volume = pourcentage/100;

			/*if (trans.volume < 0){trans.volume = 0;}*/
			canal.soundTransform = trans;
			currentVolume = trans.volume;

			if(ExternalInterface.available){
				ExternalInterface.call('afficherPourcentageVolume', currentVolume*100);
			}
		}



		/*
		|--------------------------------------------------------------------------
		| Fonction qui stoppe un son
		|--------------------------------------------------------------------------
		|
		*/
		public function stopAudio():void{
			canal.stop();
			positionLecture = 0;

			if(!reset){
				monTimer.stop();
			}
			enLecture = false;
			reset = false;


		}


		/*
		|--------------------------------------------------------------------------
		| Fonction qui coupe le volume du son ou le remet suivant l'état
		|--------------------------------------------------------------------------
		|
		*/
		public function muteVolume():void{
			trans = canal.soundTransform;
			if(!mute){
				trans.volume = 0;
				mute = true;
			}
			else{
				if(currentVolume == 0.5){
					currentVolume = 0.5;
				}
				trans.volume = currentVolume;
				mute = false;
			}
			canal.soundTransform = trans;

			if(ExternalInterface.available){
				ExternalInterface.call('afficherPourcentageVolume', Math.round(trans.volume*100));
			}
		}



	}

}
