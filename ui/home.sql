CREATE OR REPLACE PROCEDURE home
IS
	cookie_auth varchar2(30); 
	ligne_utilisateur utilisateur%rowtype;
	ligne_theme theme%rowtype; 
	ligne_theme2 theme%rowtype;
	ligne_livre livre%rowtype; 
	ligne_auteur auteur%rowtype; 
	ligne_editeur editeur%rowtype;
	ligne_promo promotion%rowtype;
	ligne_panier mon_panier%rowtype;
				
	reference_livre varchar2(60); 
	nb_ventes number(5);
	nouveau_prix number(8,2);
	cptr number(3):=0;
	cptrventes number(3):=0;
	cptrpromos number(3):=0;
	referencelivre varchar2(60);
	ttc number(5,2);
	prix_reel number(8,2);
	type sqlcur is ref cursor;
	cthemes sqlcur;
	cthemes2 sqlcur;
	clivres sqlcur; 
	cauteurs sqlcur;
	cpanier sqlcur;
	
 BEGIN
 HTP.print('<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">');
 HTP.htmlopen;
 HTP.headopen;
 HTP.print('<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">');
 HTP.title('Accueil'); 
 HTP.print('<link href="/public/css/bootstrap.min.css" rel="stylesheet" type="text/css" />');
 HTP.print('<link href="/public/css/formationscss.css" rel="stylesheet" type="text/css" />');
 HTP.headclose;
 HTP.bodyopen;

 HTP.print('
 
	<!-- Entete --> 
	<div class="navbar navbar-fixed-top" >
	  <div class="navbar-inner">
		  <div class="container"> 
			<a class="brand" href="/g07_epg_dad/home" style="padding-top: 8px; padding-bottom: 0px;">
			  <b style="color:#0088cc;font-weight:bold;font-family:arial;font-size:25px;margin-right:-5px;">L</b>
			  <span style="color:#555;font-size:18px;">ibInfo</span>
			</a> 
			 
			<ul class="nav"> 
				
				<li class="divider-vertical"></li>   
				<li class="active"><a href="/g07_epg_dad/home"><i class="icon-home"></i>Accueil</a></li> 
				<li class="divider-vertical"></li>   
				<li class="dropdown">
					<a href="#" class="dropdown-toggle" data-toggle="dropdown"><i class="icon-th"></i>  Thèmes
					  <b class="caret"></b>
					</a>
					<ul class="dropdown-menu">
			');		
						--Affichage de la liste des thèmes dans le menu
						cthemes:= pa_theme.getAll('lib_theme', 'ASC');
						LOOP
						fetch cthemes into ligne_theme;
						exit when cthemes%NOTFOUND;
							HTP.print('<li><a href="/g07_epg_dad/livrespartheme' || '?' || 'numtheme=' || ligne_theme.num_theme || '&' || 'theorder=titre_livre' || '&' || 'thedirection=asc">' || ligne_theme.lib_theme || '</a></li>');   
						end loop;
						close cthemes; 
					   
 HTP.print('				   
					</ul>
				</li> 
				<li class="divider-vertical"></li>  
				<li class="dropdown">
					<a href="#" class="dropdown-toggle" data-toggle="dropdown"><i class="icon-shopping-cart"></i>  Mon Panier
					  <b class="caret"></b>
					</a>
					<ul class="dropdown-menu">
					   <li><a href="/g07_epg_dad/panier"> Consulter </a></li>
		  ');
		  			
						ttc:=utils_global.getMontalTotal; 
						if ttc > 0 then
							htp.print('<li><a href="/g07_epg_dad/passercommande1">  Passer la commande </a></li>');
							HTP.print('<li><a href="/g07_epg_dad/viderPanier' || '?' || 'redirecturl=panier"><font color="red">Vider mon panier</font></a></li>'); 
						end if;
HTP.print('		
					</ul>
				</li> 
				<li class="divider-vertical"></li>   
				');
					--Affichage menu déroulant en fonction de l'authentification
					if pa_utilisateur.isAuthenticated then
						cookie_auth := pa_utilisateur.get_cookie('login');
						ligne_utilisateur:= pa_utilisateur.getByLogin(cookie_auth);
					HTP.print('
							<li class="dropdown">
								<a href="/g07_epg_dad/consultercompte" class="dropdown-toggle" data-toggle="dropdown"><i class="icon-user"></i> '||ligne_utilisateur.prenom_utilisateur ||'
									<b class="caret"></b>
								</a>
								<ul class="dropdown-menu">
								   <li><a href="/g07_epg_dad/consultercompte"> consulter compte </a></li>
								   <li><a href="/g07_epg_dad/deconnexion">  se déconnecter </a></li>
								</ul>
							</li> 
						');
					else
					HTP.print('<li class=""><a href="/g07_epg_dad/authentificationcompte"><i class="icon-user"></i>  Mon compte </a></li> ');
					end if;
		HTP.print(' 
				<li class="divider-vertical"></li>  
			
			<form  action="/g07_epg_dad/resultatsrecherche" method="GET" class="navbar-search pull-right">
				<input type="text" name="champ" class="search-query" style="width:100px" placeholder="Rechercher">
			</form>
			</ul>
		 </div>
	 </div>
	</div>

	<!-- Corps -->
	<div class="container conteneurwtborder" id="fadeOutIn"> 
		<br/>
		<a href="/g07_epg_dad/touteslesnouveautes" title="Toutes les nouveautés"><h4>Les Nouveautés </h4></a>
		<hr/>
		<div id="this-carousel-id1" class="carousel slide">  	
		  <div class="carousel-inner"  align="center">


		  
			');		  
				
						--Affichage des 10 dernières nouveautés
						 
						clivres:= pa_livre.getAllByLimit('date_parution', 'DESC',5);
						LOOP
						fetch clivres into ligne_livre;
						exit when clivres%NOTFOUND;
						cptr:=cptr+1;
						
						if (cptr = 1) then
							HTP.print('			
							 <div class="item active well">');
						else
							HTP.print('			
							 <div class="item well">');
						end if;
				HTP.print('
				<table class="table">
					<tr>
						<td>
							<div class="alert alert-info" style="width:2%"> <h4> ' || cptr || '</h4> </div>
							<hr/><br/><br/><br/> 
							<div class="boxAddCart">
								Prix public :  
								
	');
			prix_reel:= pa_livre.getSellingPriceByRef(ligne_livre.ref_livre);
			if prix_reel != ligne_livre.prix_livre then
				htp.print(' <b><s>' || ligne_livre.prix_livre || ' € </s></b>');
				htp.print('<h4><font color="darkorange">' || prix_reel || ' € </font></h4>');
			else
				htp.print('<h4>' || ligne_livre.prix_livre || ' €</h4>');
			end if;

htp.print('									
								
								<br><i class="icon-shopping-cart"></i><a href="#myModal" role="button" data-toggle="modal" id="'||ligne_livre.ref_livre||'" class="addToCardHome">Ajouter au panier</a> 
							</div>
						</td>
						<td>
							<a href="/g07_epg_dad/detailslivre?ref_livre=' || trim(ligne_livre.ref_livre) || '&' || 'lib_cmt=empty">  <img src="/public/img/livres/' || ligne_livre.couverture || '" alt="' || ligne_livre.titre_livre || '" style="float:left; margin-right:30px;" ></a>
					 
									<font color="#0088cc"><h4>' || ligne_livre.titre_livre || '</h4></font><hr/>
									<font color="#0088cc">Nombre de pages :</font>' || ligne_livre.nb_pages || '<br/>
									<font color="#0088cc">Date de parution: </font><b><font color="darkorange">' || ligne_livre.date_parution || '</font></b></b><br/>
									<font color="#0088cc">Langue :</font> ' || ligne_livre.langue || '<br/><br/>
								 
									<font color="#0088cc">Thème (s) :</font> ');
										--On liste tous les thèmes du livre
										cthemes2:= pa_theme.getByLivreRef(ligne_livre.ref_livre, 'lib_theme', 'ASC');
										LOOP
										fetch cthemes2 into ligne_theme2;
										exit when cthemes2%NOTFOUND;
											HTP.print(ligne_theme2.lib_theme || ' ,');   
										end loop;
										close cthemes2; 
 

						HTP.print('<br/>
									<font color="#0088cc">Auteur (s) :</font> ');
										--On liste tous auteurs du livre
										cauteurs:= pa_auteur.getByLivreRef(ligne_livre.ref_livre, 'nom_auteur', 'ASC');
										LOOP
										fetch cauteurs into ligne_auteur;
										exit when cauteurs%NOTFOUND;
											HTP.print(ligne_auteur.prenom_auteur || ' ' || ligne_auteur.nom_auteur || ' ,');   
										end loop;
										close cauteurs;  
										
						HTP.print('<br/>	 
									<font color="#0088cc">Editeur :</font>');

										--On récupère le nom et le prénom de l'éditeur
										ligne_editeur:= pa_editeur.getByRefLivre(ligne_livre.ref_livre); 
										HTP.print(ligne_editeur.nom_editeur || ' (' || ligne_editeur.pays_editeur || ')');    
						HTP.print('
						</td>						
					</tr>
				</table>
				 
				<div class="carousel-caption"  align="left">
				  <p>' || ligne_livre.titre_livre ||'</p>
				  <p><a href="#myModal" role="button" data-toggle="modal" id="'||ligne_livre.ref_livre||'" class="addToCardHome">Ajouter au panier</a></p>
				</div>
			  </div>'); 
 
  
 						end loop;
						close clivres; 
					   
			HTP.print('		 
 
			</div><!-- .carousel-inner -->
			<!--  next and previous controls here
				  href values must reference the id for this carousel -->
			  <a class="carousel-control left" href="#this-carousel-id1" data-slide="prev"></a>
			  <a class="carousel-control right" href="#this-carousel-id1" data-slide="next"></a>
		</div>
		<br/>
    
		<a href="/g07_epg_dad/touteslesmeilleuresventes"title="Toutes les meilleures ventes"><h4>Les Meilleures ventes </h4></a>
		<hr/> 
		<div id="this-carousel-id2" class="carousel slide">  	
			<div class="carousel-inner"  align="center">

			');		
			

			 
			 
			 
						--Affichage des 10 dernières nouveautés 
						clivres:= pa_livre.getRefBestSellers;
						LOOP
						fetch clivres into reference_livre;
						exit when clivres%NOTFOUND;
						
						ligne_livre:= pa_livre.getByRef(reference_livre);
						nb_ventes:= pa_livre.getNbVentes(reference_livre);
						cptrventes:=cptrventes+1;
						
						if (cptrventes = 1) then
							HTP.print('			
							 <div class="item active well">');
						else
							HTP.print('			
							 <div class="item well">');
						end if;
				HTP.print('
				<table class="table">
					<tr>
						<td>
							<div class="alert alert-info" style="width:2%"> <h4> ' || cptrventes|| '</h4> </div>
							<hr/><br/><br/><br/> 
							<div class="boxAddCart">
								Prix public :  
								
	');
			prix_reel:= pa_livre.getSellingPriceByRef(ligne_livre.ref_livre);
			if prix_reel != ligne_livre.prix_livre then
				htp.print(' <b><s>' || ligne_livre.prix_livre || ' € </s></b>');
				htp.print('<h4><font color="darkorange">' || prix_reel || ' € </font></h4>');
			else
				htp.print('<h4>' || ligne_livre.prix_livre || ' €</h4>');
			end if;

htp.print('	
								
								<br><i class="icon-shopping-cart"></i><a href="#myModal" role="button" data-toggle="modal" id="'||ligne_livre.ref_livre||'" class="addToCardHome">Ajouter au panier</a>
							</div>
						</td>
						<td>
							<a href="/g07_epg_dad/detailslivre?ref_livre=' || trim(ligne_livre.ref_livre) || '&' || 'lib_cmt=empty">  <img src="/public/img/livres/' || ligne_livre.couverture || '" alt="' || ligne_livre.titre_livre || '" style="float:left; margin-right:30px;" ></a>
					 
									<font color="#0088cc"><h4>' || ligne_livre.titre_livre || '</font><font color="darkorange"> (' || nb_ventes ||' ventes)</h4></font><hr/>
									<font color="#0088cc">Nombre de pages :</font>' || ligne_livre.nb_pages || '<br/>
									<font color="#0088cc">Date de parution: </font>' || ligne_livre.date_parution || '<br/>
									<font color="#0088cc">Langue :</font> ' || ligne_livre.langue || '<br/><br/>
								 
									<font color="#0088cc">Thème (s) :</font> ');
										--On liste tous les thèmes du livre
										cthemes2:= pa_theme.getByLivreRef(ligne_livre.ref_livre, 'lib_theme', 'ASC');
										LOOP
										fetch cthemes2 into ligne_theme2;
										exit when cthemes2%NOTFOUND;
											HTP.print(ligne_theme2.lib_theme || ' ,');   
										end loop;
										close cthemes2; 
 

						HTP.print('<br/>
									<font color="#0088cc">Auteur (s) :</font> ');
										--On liste tous auteurs du livre
										cauteurs:= pa_auteur.getByLivreRef(ligne_livre.ref_livre, 'nom_auteur', 'ASC');
										LOOP
										fetch cauteurs into ligne_auteur;
										exit when cauteurs%NOTFOUND;
											HTP.print(ligne_auteur.prenom_auteur || ' ' || ligne_auteur.nom_auteur || ' ,');   
										end loop;
										close cauteurs;  
										
						HTP.print('<br/>	 
									<font color="#0088cc">Editeur :</font>');

										--On récupère le nom et le prénom de l'éditeur
										ligne_editeur:= pa_editeur.getByRefLivre(ligne_livre.ref_livre); 
										HTP.print(ligne_editeur.nom_editeur || ' (' || ligne_editeur.pays_editeur || ')');    
						HTP.print('
						</td>						
					</tr>
				</table>
				 
				<div class="carousel-caption"  align="left">
				  <p>' || ligne_livre.titre_livre ||'</p>
				  <p><a href="#myModal" role="button" data-toggle="modal" id="'||ligne_livre.ref_livre||'" class="addToCardHome">Ajouter au panier</a></p>
				</div>
			  </div>'); 
 
  
 						end loop;
						close clivres; 
					   
			HTP.print('	


			
			</div><!-- .carousel-inner -->
			<!--  next and previous controls here
				  href values must reference the id for this carousel -->
			  <a class="carousel-control left" href="#this-carousel-id2" data-slide="prev"></a>
			  <a class="carousel-control right" href="#this-carousel-id2" data-slide="next"></a>
		</div>
		<br/>
    
		<a href="/g07_epg_dad/touslesbonsplans" title="Tous les bons plans"><h4>Les Bons plans </h4></a>
		<hr/> 
		<div id="this-carousel-id3" class="carousel slide">  	
			<div class="carousel-inner"  align="center">
 
 
 			');		
						--Affichage des 10 dernières nouveautés 
						clivres:= pa_livre.getByBestSoldes;
						LOOP
						fetch clivres into ligne_livre;
						exit when clivres%NOTFOUND;
						 
						ligne_promo:= pa_promotion.getByNum(ligne_livre.num_promo);
						nouveau_prix:= ligne_livre.prix_livre*(1- (ligne_promo.pourcentage/100));
						 
						cptrpromos:=cptrpromos+1;
						
						if (cptrpromos = 1) then
							HTP.print('			
							 <div class="item active well">');
						else
							HTP.print('			
							 <div class="item well">');
						end if;
				HTP.print('
				<table class="table">
					<tr>
						<td>
							<div class="alert alert-info" style="width:2%"> <h4> ' || cptrpromos|| '</h4> </div>
							<hr/><br/><br/><br/> 
							<div class="boxAddCart">
								Prix public : <s><b>' || ligne_livre.prix_livre || ' €<b></s><h4><font color="darkorange">' || nouveau_prix || ' €</font></h4>
								<br><i class="icon-shopping-cart"></i><a href="#myModal" role="button" data-toggle="modal" id="'||ligne_livre.ref_livre||'" class="addToCardHome">Ajouter au panier</a>
							</div>
						</td>
						<td>
							<a href="/g07_epg_dad/detailslivre?ref_livre=' || trim(ligne_livre.ref_livre) || '&' || 'lib_cmt=empty">  <img src="/public/img/livres/' || ligne_livre.couverture || '" alt="' || ligne_livre.titre_livre || '" style="float:left; margin-right:30px;" ></a>
					 
									<font color="#0088cc"><h4>' || ligne_livre.titre_livre || '</font><font color="darkorange"> (-' || ligne_promo.pourcentage ||'%)</h4></font><hr/>
									<font color="#0088cc">Nombre de pages :</font>' || ligne_livre.nb_pages || '<br/>
									<font color="#0088cc">Date de parution: </font>' || ligne_livre.date_parution || '<br/>
									<font color="#0088cc">Langue :</font> ' || ligne_livre.langue || '<br/><br/>
								 
									<font color="#0088cc">Thème (s) :</font> ');
										--On liste tous les thèmes du livre
										cthemes2:= pa_theme.getByLivreRef(ligne_livre.ref_livre, 'lib_theme', 'ASC');
										LOOP
										fetch cthemes2 into ligne_theme2;
										exit when cthemes2%NOTFOUND;
											HTP.print(ligne_theme2.lib_theme || ' ,');   
										end loop;
										close cthemes2; 
 

						HTP.print('<br/>
									<font color="#0088cc">Auteur (s) :</font> ');
										--On liste tous auteurs du livre
										cauteurs:= pa_auteur.getByLivreRef(ligne_livre.ref_livre, 'nom_auteur', 'ASC');
										LOOP
										fetch cauteurs into ligne_auteur;
										exit when cauteurs%NOTFOUND;
											HTP.print(ligne_auteur.prenom_auteur || ' ' || ligne_auteur.nom_auteur || ' ,');   
										end loop;
										close cauteurs;  
										
						HTP.print('<br/>	 
									<font color="#0088cc">Editeur :</font>');

										--On récupère le nom et le prénom de l'éditeur
										ligne_editeur:= pa_editeur.getByRefLivre(ligne_livre.ref_livre); 
										HTP.print(ligne_editeur.nom_editeur || ' (' || ligne_editeur.pays_editeur || ')');    
						HTP.print('
						</td>						
					</tr>
				</table>
				 
				<div class="carousel-caption"  align="left">
				  <p>' || ligne_livre.titre_livre ||'</p>
				  <p><a href="#myModal" role="button" data-toggle="modal" id="'||ligne_livre.ref_livre||'" class="addToCardHome">Ajouter au panier</a></p>
				</div>
			  </div>'); 
 
  
 						end loop;
						close clivres; 
					   
			HTP.print('	
 
 
			</div><!-- .carousel-inner -->
			<!--  next and previous controls here
				  href values must reference the id for this carousel -->
			  <a class="carousel-control left" href="#this-carousel-id3" data-slide="prev"></a>
			  <a class="carousel-control right" href="#this-carousel-id3" data-slide="next"></a>
		</div> 
	  
	<!-- Modal -->
<div id="myModal" class="modal hide fade" tabindex="-1" >
  <form method="POST" name="ajouterAuPanierForm" action="/g07_epg_dad/ajouteraupanier">   
    <input type="hidden" name="ref_livre" id="input_ref_livre"/>  
	<input type="hidden" name="type_support" value="papier" id="type_support"/>
	<input type="hidden" name="prix_unitaire" value="10" id="prix_unitaire"/>
	<input type="hidden" name="quantite" value="1" id="quantite"/>
	<input type="hidden" name="action" value="ajout" id="action"/>
    <div class="modal-header well">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
      <h3 id="myModalLabel">Confirmation</h3>
    </div>
    <div class="modal-body">
      <p>    
          Votre livre va être ajouter au panier.<br/>
		  Pour modifier la quantité, veuillez vous rendre dans votre panier.<hr/>
		  Veuillez choisir une action.
		  <br/><br/>
      </p>
    </div>
    <div class="modal-footer">
      <button class="btn" data-dismiss="modal" aria-hidden="true">Annuler</button>
	  <button type="submit" name="redirecturl" value="home" class="btn btn-info"> <i class="icon-shopping-cart icon-white"></i> Ajouter</button>
      <button type="submit" name="redirecturl" value="panier" class="btn btn-info"> <i class="icon-shopping-cart icon-white"></i> Ajouter et consulter mon panier</button>
    </div>
  </form>
</div>
<!-- Fin modal -->
	 
	<!-- Pied de page -->  
	<hr/>
	<div class="footer">
		  <div class="container" id="footer">   
			  Copyright 2013 | BD50 - Lodjeu - Libam - Yarga - Ntieche
		  </div>
	</div> 
 
 ');
 
  
 

 HTP.print('<script type="text/javascript" src="/public/js/jquery-1.9.1.min.js" ></script>');
 HTP.print('<script type="text/javascript" src="/public/js/bootstrap.min.js" ></script>');
  HTP.print('
 <script type="text/javascript">
 
	$(".addToCardHome").click(function(event){ 
		$("#input_ref_livre").val($(this).attr("id"));  
	});
 
 
 </script>');
 HTP.bodyclose;
 HTP.htmlclose;
 END home;
 / 