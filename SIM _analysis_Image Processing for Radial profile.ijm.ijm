macro "Radial profile preprocessing quantitative" {

    // Get all open images (you already split channels and closed unused ones)
    list = getList("image.titles");
    if (list.length == 0)
        exit("No images are open. Please open and split your channels first.");
   
   // Scale from your calibration
    scaleDistPx  = 4406;
    scaleKnownUm = 21992.2;

    // ROI size in pixels
    roiW = 3600;
    roiH = 3600;
    
    // Preprocessing parameters (edit these if needed)
    outRadius = 2;        // pixels, neighbourhood for Remove Outliers
    outThresh = 50;       // grey values, threshold for Remove Outliers
    outWhich  = "Bright"; // "Bright" or "Dark" outliers
    bgRolling = 50;       // pixels, rolling ball radius for background subtraction
    
    // Set global scale on first image
    selectWindow(list[0]);
    run("Set Scale...", "distance=" + scaleDistPx + " known=" + scaleKnownUm + " unit=um global");


    // Apply preprocessing to every open image
    for (i = 0; i < list.length; i++) {
        selectWindow(list[i]);
        run("8-bit");

        // 1) Remove rare artefact pixels
        run("Remove Outliers...",
            "radius=" + outRadius +
            " threshold=" + outThresh +
            " which=" + outWhich);

        // 2) Subtract uneven background
        run("Subtract Background...", "rolling=" + bgRolling);
    }

    // Bring first image to front as reference
    selectWindow(list[0]);

    // Step 1: you place the ROI
    waitForUser(
        "Place circular ROI",
        "Please draw your circular ROI on each open channel image that you want to analyse.\n\n" +
        "Use the Oval selection tool and position it as precisely as possible.\n\n" +
        "When you are done with ROI placement on all images, click OK."
    );

    // Step 2: you run the radial profile macro and save data 
    // Step 3: mreasure within Roi and intensity 