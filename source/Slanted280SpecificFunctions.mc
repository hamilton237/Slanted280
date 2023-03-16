using Toybox.Math;

function drawStatusBar(dc, y, spacing, percent, offColor, onColor, bgColor, W) {

	// Validate percent is between 0 and 100
	if (percent < 0) { 
		percent = 0;
	}
	if (percent > 100) {
		percent = 100;
	}

	dc.setPenWidth(1);

	// Figure out how many small parrallelograms fit in screen width
	// given at this Y height we have 0.675% of width avaliable
	var maxWidth = W * 0.675 ;
	var nbrSquares = maxWidth / spacing;
	nbrSquares = nbrSquares.toNumber();

	// Center the bar
	var barWidth = nbrSquares * spacing;
	var startingPos = Math.round(((W - barWidth ) /2));

	// What % is each square worth?
	var percentParCase = 100.toFloat() / nbrSquares.toFloat();

	// What square is "on" with this percentage
    var squareOn = percent / percentParCase;
	squareOn = squareOn.toNumber();
    if (squareOn < nbrSquares) {squareOn++;}

	// Draw the squares
	for (var i=0; i<nbrSquares; i++) {
		var pos = startingPos + (i * spacing);
		var on = false;
		if (i + 1 == squareOn){
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

function getThemeColors(theme) {
	var colors;
	switch (theme) {
		case 0:
			colors = T_ENDURO2;
			break;
		case 1:
			colors = T_SHARKS;
			break;
		case 2:
			colors = T_NATURE;
			break;
		case 3:
			colors = T_ICE;
			break;
		case 4:
			colors = T_FIRE;
			break;
		case 6:
			colors = T_WHITE;
			break;
		case 5:
			colors = T_ORANGE;
			break;
		default:
			colors = T_ENDURO2;
			break;
	}

	return colors;
}





