window.addEvent('domready', function() {

	var isChrome = Boolean(window.chrome);
	cheminSon = 'http://localhost/player-audio/assets/audio/';
	chansonParDefaut = 'No_Love';


	/*****
	 * Déclaration de variables communes à tout le programme
	 *****/
	tailleBarre = $('lecture').getSize(); // Object {x: 300, y: 20}
	tailleCurseur = $('barreLecture').getSize(); // Object {x: 10, y: 20}
	tailleCurseurVolume = $('barreVolume').getSize(); // Object {x: 5, y: 20}
	bleuSong = "#0c0c4e";



	/*
	|--------------------------------------------------------------------------
	| Script qui permet de récupérer dynamiquement la chanson par défaut et de lui appliquer le style d'une chanson en lecture
	|--------------------------------------------------------------------------
	|
	*/
	styleChanson = $('chansons').getElements('.titre').getElement('.letitre').get('text');

	Array.each(styleChanson, function(chansonTab, index){
		style = chansonTab.replace(/ /g, '_');

		selecteur = $('chansons').getElements('.titre').getElement('.letitre')

		if(style == chansonParDefaut){
			selecteur[index].getParent().morph({
		      'marginLeft': '30px',
		      'backgroundColor' : bleuSong,
		      'listStyleImage' :'url("./assets/images/fleche.png")'
		    });
		}
	});



	if(!isChrome){
		$('navigateur').setStyle('opacity', 0);
		$('navigateur').setStyle('display', 'block');
		(function(){ $('navigateur').fade('in')}).delay(1000);

		/*****
		 * Ecouteur d'événement sur le bouton fermer dans la div#navigateur
		 *****/
		$('fermer').addEvent('click', function(event){
			event.preventDefault();
			$('navigateur').fade('out');
		});
	}





	/*
	|--------------------------------------------------------------------------
	| Objet Swiff qui gère le fichier SWF
	|--------------------------------------------------------------------------
	|
	*/
	var ﬂash = new Swiff('projet_flash.swf',{
		id: 'PlayerFlashMootools',
		width: 10,
		height: 10,
		params: {
			wMode: 'transparent',
			bgcolor: '#E2E668'
		},
		container: 'monSWF',
		vars: {
			defaultSong : chansonParDefaut,
			chemin : cheminSon
		},
		callBacks: {
			// load : console.log('ﬂash en lecture auto')
		}

	});


	/*
	|--------------------------------------------------------------------------
	| Ecouteurs d'événements qui seront transmis à Mootools
	|--------------------------------------------------------------------------
	|
	*/
		/**********
		/* Sur le bouton jouer (play/pause)
		 **********/
		$('jouer').addEvent('click', function(){
			if($('jouer').get('class') != 'pause'){
				this.toggleClass('pause');
			}
			else{
				this.set('class', 'play');
			}

			Swiff.remote($('PlayerFlashMootools'), "lireAudioJS");
		});


		/**********
		/* Sur le bouton stop. Je gère aussi le style du bouton jouer
		 **********/
		$('stop').addEvent('click', function(){
			if($('jouer').get('class') == 'play pause'){
				$('jouer').set('class', 'play');
			}
			if($('jouer').get('class') == 'pause'){
				$('jouer').set('class', 'play');
			}

			// Je repositionne la barre de lecture et le curseur à 0;
			$('barreLecture').setStyle('left', 0);
			$('lecture').set('value', 0);

			// Je réinitialise le temps courant à 0
			$('duree').getElements('.minutesEnCours').set('html', "00");
			$('duree').getElements('.secondesEnCours').set('html', "00");

			Swiff.remote($('PlayerFlashMootools'), "stopAudioJS");
		});


		/**********
		/* Sur le contrôle du son
		 **********/

		var controleVolumeInMootools = function(){

			// $('controleVolume').show();
			// $('controleVolume').getElement('progress').fade('in');

			tailleBarreVolumeDefaut   = $('progressionVolume').getSize();
			positionBarreVolumeDefaut = (tailleBarreVolumeDefaut.x * 0.5);

			$('barreVolume').setStyle('left', positionBarreVolumeDefaut);
			$('progressionVolume').set('value', 50);
			// $('boutons').getElement('h4').removeEvent('mouseover', controleVolumeInMootools);

		}

		// $('boutons').getElement('h4').addEvent('mouseover', controleVolumeInMootools);

		controleVolumeInMootools();

		/* ***** */
		$('sonMute').addEvent('click', function(event){
			event.preventDefault();
			Swiff.remote($('PlayerFlashMootools'), "muteVolumeJS");
		});


		/**********
		/* Sur la position du clic dans la barre de volume
		 **********/
		$('progressionVolume').addEvent('click', function(event){
			positionX = event.page.x; // Coordonnees en x où l'utilisateur a cliqué
			decalageGauche = this.getPosition().x;
			positionX -= decalageGauche; // On retranche decalageGauche pour avoir une valeur entre 0 et tailleBarre

			tailleBarreVolumeDefaut = $('progressionVolume').getSize();
			positionBarreVolumeDefaut = (tailleBarreVolumeDefaut.x * 0.5);

			// On injecte la valeur pourcentage dans notre balise <progress>
			pourcentage = (positionX*100)/tailleBarreVolumeDefaut.x;
			this.set('value', pourcentage);

			// On positionne le curseur en fonction de l'endroit cliqué
			positionBarreVolume = positionX - (tailleBarreVolumeDefaut.x/2);
			$('barreVolume').setStyle('left', positionBarreVolume+positionBarreVolumeDefaut);

			Swiff.remote($('PlayerFlashMootools'), 'recuperePositionCurseurVolumeJS', pourcentage);
		});






		/**********
		/* Sur la chanson cliquée dans la playlist
		 **********/
		$('chansons').getElements('.titre').addEvent('click', function(){

			// Je récupère la valeur 'text' de mon élément qui possède le titre de la chanson
			// J'applique en suite un traitement qui remet les '_' à la place des espaces (étape inverse de ce qui avait été précédement fait en PHP)
			chansonCliquee = this.getElement('.letitre').get('text');
			chansonCliquee = chansonCliquee.replace(/ /g, '_');

			// Je stylise les éléments de ma playlist et donne un background différent pour la chanson en cours de lecture
			$('chansons').getElements('.titre').removeClass('highlighted').removeClass('couleurTitre').addClass('couleurTitre');
			this.addClass('highlighted');

			$('jouer').set('class', 'pause');

			// Je repositionne la barre de lecture et le curseur à 0;
			$('barreLecture').setStyle('left', 0);
			$('lecture').set('value', 0);

			// $('chansons').getElements('.titre').setStyle('marginLeft', 0)
			// this.setStyle('marginLeft', '30px');

			$('chansons').getElements('.titre').morph({
		      'marginLeft': 0,
		      'backgroundColor' : '#313131',
		      'listStyleImage': 'none',
		      'listStyleType': 'square',
		    });
		    this.morph({
		      'marginLeft': '30px',
		      'backgroundColor' : bleuSong,
		      'listStyleImage' :'url("./assets/images/fleche.png")'
		    });


			Swiff.remote($('PlayerFlashMootools'), "RecupererChansonCliqueeJS", chansonCliquee);
		});


		$('chansons').getElements('.titre').addEvent('mouseover', function(){
			this.addClass('survol');
		});

		$('chansons').getElements('.titre').addEvent('mouseout', function(){
			this.removeClass('survol');
		});


		/**********
		/* Sur la position du clic dans la barre de lecture
		 **********/
		$('lecture').addEvent('click', function(event){
			positionX = event.page.x; // Coordonnees en x où l'utilisateur a cliqué
			decalageGauche = this.getPosition().x; // 570px à partir du bord gauche
			positionX -= decalageGauche; // On retranche decalageGauche pour avoir une valeur entre 0 et tailleBarre

			// On injecte la valeur pourcentage dans notre balise <progress>
			pourcentage = (positionX*100)/tailleBarre.x;
			this.set('value', pourcentage);

			// On positionne le curseur en fonction de l'endroit cliqué
			positionBarreLecture = positionX - (tailleCurseur.x/2);
			$('barreLecture').setStyle('left', positionBarreLecture);

			Swiff.remote($('PlayerFlashMootools'), 'recuperePositionCurseurJS', pourcentage);
		});


		/**********
		/* Sur la position du drop dans la barre de lecture
		 **********/
		var handler = new Drag.Move($('barreLecture'), {
			container : $('lecture'),
			droppables : $('lecture'),
			onDrop : function(element) {
				posX = element.getPosition($('lecture')).x;
				pourcentage = Math.ceil((posX*100)/(tailleBarre.x - tailleCurseur.x));
				Swiff.remote($('PlayerFlashMootools'), 'recuperePositionCurseurJS', pourcentage);
			}
		});

		var handler2 = new Drag.Move($('barreVolume'), {
			container : $('progressionVolume'),
			droppables : $('progressionVolume'),
			onDrop : function(element) {
				posiX = element.getPosition($('progressionVolume')).x;
				pourcentage = Math.ceil((posiX*100)/(tailleBarreVolumeDefaut.x - tailleCurseurVolume.x));
				$('progressionVolume').set('value', pourcentage);
				Swiff.remote($('PlayerFlashMootools'), 'recuperePositionCurseurVolumeJS', pourcentage);
			}
		});


});



	/*
	|--------------------------------------------------------------------------
	| Fonction qui permet d'avoir un effet de fadein sur la pochette
	| de l'album au chargement de la page.
	|--------------------------------------------------------------------------
	|
	*/
	window.addEvents({
		load: function(){
			$('jaquette').set('styles', {
	            'opacity': 0,
	            'visibility': 'visible'
	        });
	        $('jaquette').fade('in');
		}
	});


	/*
	|--------------------------------------------------------------------------
	| Fonctions transmises de l'ActionScript 3 à Mootools
	|--------------------------------------------------------------------------
	|
	*/
	function afficherTitre(titre){
		$('playerAudio').getElements('.titreChanson').set('html',  "Titre en cours: "+titre);
		$('jaquette').getElements('.desc').set('html', titre);
	}

	function afficherPourcentageVolume(volume){
		volume = Math.round(volume);
		// console.log("Pourcentage Volume: "+volume);
		$('playerAudio').getElements('.volume').set('html',  volume+"%");
	}

	function afficherChargement(enCours) {
		$('chargement').set('html', enCours+" % chargé(s)");
		$('progression').set('value', enCours);
	}

	function afficherJaquette(jaquette) {
		$('jaquette').getElements('.pochette').setProperty('alt', jaquette);
		$('jaquette').getElements('.pochette').setProperty('src', 'assets/images/jaquettes/'+jaquette+'.jpg').setStyle('opacity', 0).fade('in').delay(300);
	}

	function afficherTempsTotal(minutes, secondes) {
		$('duree').getElements('.minutesTotales').set('html', minutes);
		$('duree').getElements('.secondesTotales').set('html', secondes);
	}

	function afficherTempsEnCours(minutes, secondes, avancement) {
		$('duree').getElements('.minutesEnCours').set('html', minutes);
		$('duree').getElements('.secondesEnCours').set('html', secondes);

		$('lecture').set('value', avancement);

		posBar = Math.ceil(avancement/100 * (tailleBarre.x - (tailleCurseur.x/2)));
		$('barreLecture').setStyle('left', posBar);
	}

	function afficherMetadonnees(album, artiste, titreChanson, annee) {
		// if(album == 'null'){album = 'inconnu';}
		// if(annee == 'null'){annee = 'inconnue';}
		$('metadonnees').getElements('.album').set('html', album);
		$('metadonnees').getElements('.artiste').set('html', artiste);
		$('metadonnees').getElements('.chanson').set('html', titreChanson);
		$('metadonnees').getElements('.annee').set('text', annee);
	}

	function trace(message){
		console.log("Chemin utilisé pour récupérer les sons: "+message);
	}