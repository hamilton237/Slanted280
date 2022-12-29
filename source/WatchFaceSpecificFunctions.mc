using Toybox.Math;

function drawStatusBar(dc, y, spacing, percent, offColor, onColor, bgColor, W) {

	// On valide que percent est un nombre entre 0 et 100
	if (percent < 0) { 
		percent = 0;
	}
	if (percent > 100) {
		percent = 100;
	}

	dc.setPenWidth(1);

	// Calcule combien de cases peuvent entrer dans la largeur de l'écran
	// À ce Y on a juste 0.675% de la largeur disponible
	var largeurMax = W * 0.675 ;
	var nbreCases = largeurMax / spacing;
	nbreCases = nbreCases.toNumber();

	// Calcul pour centrer la barre
	var largeurBarre = nbreCases * spacing;
	var positionDebut = Math.round(((W - largeurBarre ) /2));

	// Combien de % vaut chaque case?
	var percentParCase = 100.toFloat() / nbreCases.toFloat();

	// Le pourcentage représente quelle case?
    var caseOn = percent / percentParCase;
	caseOn = caseOn.toNumber();
    if (caseOn < nbreCases) {caseOn++;}

	// Dessine les cases
	for (var i=0; i<nbreCases; i++) {
		var pos = positionDebut + (i * spacing);
		var on = false;
		if (i + 1 == caseOn){
			on = true;
		}
		if (on) {
			drawSmallParallelogramForBar(dc, pos, y, onColor, bgColor, on);
		}
		else{
			drawSmallParallelogramForBar(dc, pos, y, offColor, bgColor, on);
		}
	}
}

function drawSmallParallelogramForBar(dc, x, y, lineColor, bgColor, isFilled){
	//dc.drawRoundedRectangle(140, 30, 20, 10, 2);
	 // line1
    var line1_y = y-5;
    var line1_x0 = x+10;
    var line1_x1 = x+30;
    // line2
    var line2_y = y+5;
    var line2_x0 = x;
    var line2_x1 = x+20;

    dc.setColor(lineColor, bgColor);

    if (isFilled)
    {
        for (var i=0; i<=10; i++){
            dc.drawLine(line1_x0 - i, line1_y + i, line1_x1 - i, line1_y + i);
        }      
    }
    else{
        dc.drawLine(line1_x0, line1_y , line1_x1, line1_y);
        dc.drawLine(line2_x0, line2_y , line2_x1, line2_y);
        dc.drawLine(line2_x0, line2_y, line1_x0, line1_y);
        dc.drawLine(line2_x1, line2_y, line1_x1, line1_y); 
    }
}





