<!DOCTYPE html>
<html lang="fr">

	<head><!-- En-tete du document  -->

		<!-- Balise META -->
		<meta charset="UTF-8" />
  		<meta name="description" content="" />
  		<meta name="keywords" content="" />
   		<meta name="robots" content="index,follow" />
   		<meta name="viewport" content="width=device-width,initial-scale=1" />
		<title>Anthony ROBIN | Projet Action Script 3 - Player Audio</title>

   		<!-- CSS -->
   		<link rel="stylesheet" type="text/css" href="assets/css/style.css" media="all" />

   		<!--[if lt IE 9]>
        <script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script>
    	<![endif]-->
    	<!-- [if (gte IE 6)&(lte IE 8)]>
			<script type="text/javascript" src="https://raw.github.com/keithclark/selectivizr/master/selectivizr.js"></script>
		<![endif] -->


  	</head>

<body>
	<div id="navigateur">
		<p>Le site est optimisé pour un affichage sous <span class="important">Google Chrome</span>. La balise progress n'étant pas encore normalisée, elle ne fonctionne correctement que sur ce navigateur. <span id="fermer"><a href="#">Fermer le message</a></span></p>
	</div>

	<div id="wrapper">

		<h1>Player Audio - Action Script 3 + Mootools</h1>

		<div id="playerAudio">
			<div id="monSWF"></div>

			<div id="haut">
				<div id="boutons">
					<p id="jouer" class="play"><a href="#">Play / Pause</a></p>
					<p id="stop" class="stop"><a href="#">Stop</a></p>

					<h4>Volume <span class="volume"></span></h4>
					<div id="controleVolume">
						<progress id="progressionVolume" value="50" min="0" max="100">0%</progress>
						<span id="barreVolume" class="drag"></span>
					<p id="sonMute" class="mute"><a href="#">Mute</a></p>
					</div>
				</div>

				<div class="titreChanson"></div>

				<div id="progress">

				    <progress id="progression" value="" min="0" max="100">0%</progress>
				    <progress id="lecture" value="" min="0" max="100">0%</progress>
				    <span id="barreLecture" class="drag"></span>

					<div id="chargementEtDuree">
						<p id="chargement"></p>
						<p id="duree">
							<span>Durée:</span>
							<span class="minutesEnCours">00</span>:
							<span class="secondesEnCours">00</span>/
							<span class="minutesTotales">00</span>:
							<span class="secondesTotales">00</span>
						</p>
					</div>
				</div>
			</div>



			<div id="milieu">
				<ul id="metadonnees">
					<li>Artiste: <span class="artiste"></span></li>
					<li>Album: <span class="album"></span></li>
					<li>chanson: <span class="chanson"></span></li>
					<li>Année: <span class="annee"></span></li>
				</ul>

				<div id="jaquette">
					<img src="assets/images/jaquettes/null.jpg" alt="null" width="274" class="pochette" />
					<cite class="desc"></cite>
				</div>
			</div>


			<div id="infosDuBas">
				<ul id="chansons">

					<?php
						$listeChansons = glob("./assets/audio/*.mp3");
						foreach($listeChansons as $laChanson){
							$chansonExplode = explode("/", $laChanson);
							$chansonSansExtension = explode(".", $chansonExplode[3]);
							$chansonSansExtension = str_replace("_", " ", $chansonSansExtension);

							echo '<li class="titre couleurTitre"><span>Titre: </span><span class="letitre">'.$chansonSansExtension[0].'</span></li>';
						}
					?>

				</ul>

			</div>


			<div id="explications">
				<h2>Explications</h2>
				<p>J'ai décidé de ne pas laisser le player en autoplay au moment où l'on arrive sur la page car c'est quelque chose que je n'apprécie pas sur un lecteur audio. Je pense que c'est à l'internaute de décider s'il lance ou non le player.</p>
				<p>Les noms de mes fichiers MP3 sont de la forme "lorem_ipsum" (chaque partie est séparée par un _ ).</p>
				<p>Chacun des morceaux présents dans le dossier audio est automatiquement ajouté à la playlist grâce un script PHP.</p>
				<p>Lors d'un clic dans la barre de lecture ou du déplacement du curseur sur l'axe horizontal dans la barre de lecture, le morceau continuera automatiquement à partir de l'endroit désiré.</p>
			</div>

		</div> <!-- fin du player audio -->

		<footer>
			<p>M1 DNR2I dans le cadre du cours d'Action Script 3<br />
			Copyright &copy; Anthony ROBIN - 2013</p><br />
		</footer>


	</div><!-- Fin du wrapper -->


	<!-- JAVASCRIPT -->
	<script type="text/javascript" src="assets/js/mootools.js"></script>
	<script type="text/javascript" src="assets/js/mootools_more.js"></script>
	<script type="text/javascript" src="assets/js/player.js"></script>


</body>
</html>