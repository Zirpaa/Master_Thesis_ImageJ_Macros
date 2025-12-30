macro "Radial Profile" {

    requires("1.52p");

    // Verifica presenza ROI
    if (selectionType == -1) {
        exit("Seleziona un ROI (Oval) prima di procedere.");
    }

    // Bounding box ROI
    getSelectionBounds(x, y, w, h);

    // Centro ROI
    xc = x + w/2;
    yc = y + h/2;

    // Raggio massimo
    maxR = floor(sqrt(w*w + h*h));

    // Array del profilo radiale
    profile = newArray(maxR);
    counts  = newArray(maxR);

    // Loop su tutti i pixel
    for (px = x; px < x+w; px++) {
        for (py = y; py < y+h; py++) {

            if (selectionContains(px, py)) {

                dx = px - xc;
                dy = py - yc;
                r = floor(sqrt(dx*dx + dy*dy));

                if (r < maxR) {
                    v = getPixel(px, py);
                    profile[r] += v;
                    counts[r] += 1;
                }
            }
        }
    }

    // Media radiale
    for (i = 0; i < maxR; i++) {
        if (counts[i] > 0)
            profile[i] = profile[i] / counts[i];
    }

    // Plot
    Plot.create("Radial Profile", "Radius (px)", "Mean Intensity");
    Plot.add("line", profile);
    Plot.show();
}
